CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS223 (pr_cdcooper in craptab.cdcooper%type
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic out crapcri.cdcritic%type
                                              ,pr_dscritic out varchar2) is
/* ............................................................................

   Programa: pc_crps223 (antigo Fontes/crps223.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/98.                        Ultima atualizacao: 31/07/2014

   Dados referentes ao programa:

   Frequencia: Mensal (Batch).
   Objetivo  : Atende a solicitacao 003.
               Atualizar o rendimento das aplicacoes e da poupanca no CRAPCOT

   Alteracoes: 16/03/2000 - Atualizar crapcot.vlrentot (Deborah).

               02/12/2003 - Atualizar campos crapcot para IR (Margarete).

               28/01/2004 - Atualizar campos do abono (Margarete).

               26/05/2004 - Zerar variavel aux_vlirabpp (Margarete).

               16/12/2004 - Incluidos hist. 875/877/876(Ajuste IR)(Mirtes)

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               09/02/2007 - Alterada para a solicitacao 73. Deve rodar depois
                            que rodaram todos os programas de aplicacao.
                            Nao esquecer que o crps104, aniversario do rdca30
                            roda com glb_dtmvtolt entao esse programa deve
                            rodar depois disso (Magui).

               02/03/2007 - Rodar fimprg(meses iguais)(Mirtes).

               19/06/2007 - Incluidos historicos 475, 476, 532 e 533 referente
                            aos campos crapcot.vlirfrdc e crapcot.vlrenrdc
                            (Elton).

               07/02/2008 - Corrigir can-do. Despreza os historicos da segunda
                            linha se a ultima virgula estivesse na primeira
                            linha (Magui).

               05/02/2009 - Incluir historicos 463, 474, 529 e 531 referentes a
                            provisao e reversao de aplicacoes RDC. Novos campos
                            vlprvrdc, vlrevrdc e vlpvardc (David).

               01/09/2009 - Alterado para sol 41 e ordem 4. Rodava depois
                            do crps011 faltando assim informacoes de
                            dezembro (Magui).

               18/02/2011 - Comentado as linhas que se referem a atualizacao
                            dos seguintes campos: crapcot.vlprvrdc e
                            crapcot.vlrevrdc. (Fabricio - tarefa 38320)

               12/07/2012 - Ajustar alteracao acima pois os historicos dos
                            campos acima estao sendo somandos no campo
                            crapcop.vlirrdca (David).

               02/04/2013 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero)

               11/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                            das criticas e chamadas a fimprg.p (Douglas Pagel).
														
               31/07/2014 - Ajuste de atualização mensal de sobras e DIRF. 
							              (Reinert)

 ............................................................................ */
  --
  -- Data do movimento
  cursor cr_crapdat(pr_cdcooper in craptab.cdcooper%type) is
    select dat.dtmvtolt,
           dat.dtmvtopr
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
  -- Dados da cooperativa
  cursor cr_crapcop(pr_cdcooper in craptab.cdcooper%type) is
    select 1
      from crapcop
     where crapcop.cdcooper = pr_cdcooper;
  rw_crapcop    cr_crapcop%rowtype;
  -- Cotas e recursos
  -- Somente contas com lançamento de aplicação ou poupança no mês.
  cursor cr_crapcot(pr_cdcooper in crapcot.cdcooper%type,
                    pr_dtinimes in craplap.dtmvtolt%type,
                    pr_dtfimmes in craplap.dtmvtolt%type) is
    select crapcot.nrdconta,
           crapcot.rowid row_id
      from crapcot
     where crapcot.cdcooper = pr_cdcooper
       and (   exists (select 1
                         from craplap
                        where craplap.cdcooper = crapcot.cdcooper
                          and craplap.nrdconta = crapcot.nrdconta
                          and craplap.dtmvtolt >= pr_dtinimes
                          and craplap.dtmvtolt < pr_dtfimmes
                          and craplap.cdhistor in (116, 179, 463, 474, 475, 476,
                                                   529, 531, 532, 533, 861, 862,
                                                   866, 868, 871, 875, 876, 877))
            or exists (select 1
                         from craplpp
                        where craplpp.cdcooper = crapcot.cdcooper
                          and craplpp.nrdconta = crapcot.nrdconta
                          and craplpp.dtmvtolt >= pr_dtinimes
                          and craplpp.dtmvtolt < pr_dtfimmes
                          and craplpp.cdhistor in (863, 869, 870)));
  -- Lançamentos de aplicações RDCA
  cursor cr_craplap(pr_cdcooper in craplap.cdcooper%type,
                    pr_dtinimes in craplap.dtmvtolt%type,
                    pr_dtfimmes in craplap.dtmvtolt%type) is
    select craplap.nrdconta,
           craplap.cdhistor,
           sum(craplap.vllanmto) vllanmto
      from craplap
     where craplap.cdcooper = pr_cdcooper
       and craplap.dtmvtolt >= pr_dtinimes
       and craplap.dtmvtolt < pr_dtfimmes
       and craplap.cdhistor in (116, 179, 463, 474, 475, 476,
                                529, 531, 532, 533, 861, 862,
                                866, 868, 871, 875, 876, 877)
     group by craplap.nrdconta,
              craplap.cdhistor;
  -- Lançamentos de aplicações de poupança
  cursor cr_craplpp(pr_cdcooper in craplpp.cdcooper%type,
                    pr_dtinimes in craplpp.dtmvtolt%type,
                    pr_dtfimmes in craplpp.dtmvtolt%type) is
    select craplpp.nrdconta,
           craplpp.cdhistor,
           sum(craplpp.vllanmto) vllanmto
      from craplpp
     where craplpp.cdcooper = pr_cdcooper
       and craplpp.dtmvtolt >= pr_dtinimes
       and craplpp.dtmvtolt < pr_dtfimmes
       and craplpp.cdhistor in (863, 869, 870)
     group by craplpp.nrdconta,
              craplpp.cdhistor;
							
  -- Lançamentos de aplicação da captação
	CURSOR cr_craplac (pr_cdcooper IN craplac.cdcooper%TYPE
										,pr_dtinimes IN craplac.dtmvtolt%TYPE
										,pr_dtfimmes IN craplac.dtmvtolt%TYPE
										,pr_cdhistor IN craplac.cdhistor%TYPE) IS
	  SELECT lac.nrdconta,
		       lac.cdhistor,
		       SUM(lac.vllanmto) vllanmto
		  FROM craplac lac
		 WHERE lac.cdcooper = pr_cdcooper
			 AND lac.dtmvtolt >= pr_dtinimes
			 AND lac.dtmvtolt <= pr_dtfimmes
			 AND lac.cdhistor = pr_cdhistor
		 GROUP BY lac.nrdconta
		         ,lac.cdhistor;
	rw_craplac cr_craplac%ROWTYPE;
  --
  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Tratamento de erros

  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);
    -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%type;
  vr_dtmvtopr      crapdat.dtmvtopr%type;
  vr_dtinimes      date;
  vr_dtfimmes      date;
  vr_mes           varchar2(2);
  -- PL/Table para otimizar leitura das tabelas craplap e craplpp
  type typ_histor is record (vr_vllanmto  craplap.vllanmto%type);
  type typ_tab_histor is table of typ_histor index by binary_integer;
  type typ_conta is record (vr_histor  typ_tab_histor);

  -- Definição da tabela para armazenar os registros das agências
  type typ_tab_conta is table of typ_conta index by binary_integer;
  -- Instância da tabela. O índice será o número da conta.
  vr_tab_conta      typ_tab_conta;
  -- Variavel para leitura dos valores de lançamento de cada histórico
  vr_indice_histor  craplap.nrdconta%type;

  -- Variáveis para acumular os valores por conta
  vr_vlrenrda      craplap.vllanmto%type;
  vr_vlabnapl_ir   craplap.vllanmto%type;
  vr_vlirabap      craplap.vllanmto%type;
  vr_vlirajus      craplap.vllanmto%type;
  vr_vlrevrdc      craplap.vllanmto%type;
  vr_vlprvrdc      craplap.vllanmto%type;
  vr_vlrenrdc      craplap.vllanmto%type;
  vr_vlirfrdc      craplap.vllanmto%type;
  vr_vlirrdca      craplap.vllanmto%type;
  vr_vlrirrpp      craplpp.vllanmto%type;
  vr_vlabonpp      craplpp.vllanmto%type;
  vr_vlirabpp      craplpp.vllanmto%type;
	-- Variáveis para armazenar históricos da crapcpc
	TYPE typ_cdhistor      IS RECORD (cdhsrdap crapcpc.cdhsrdap%TYPE
	                                 ,cdhsirap crapcpc.cdhsirap%TYPE);
	TYPE typ_cdhistor_tab  IS TABLE OF typ_cdhistor INDEX BY PLS_INTEGER;
	vr_tab_hist      typ_cdhistor_tab;
	vr_contador      INTEGER := 0;

  -- Variáveis utilizadas para o update com sql dinâmico
  vr_cursor        integer;
  vr_qtlinhas      integer;
  --
begin
  vr_cdprogra := 'CRPS223';

  -- Informa acesso
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

  -- Validações iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);
  -- Se a variavel de erro é <> 0
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  -- Buscar a data do movimento
  open cr_crapdat(pr_cdcooper);
    fetch cr_crapdat into vr_dtmvtolt,
                          vr_dtmvtopr;
  close cr_crapdat;

  -- Verifica se a cooperativa esta cadastrada
  OPEN cr_crapcop(pr_cdcooper);
  FETCH cr_crapcop
   INTO rw_crapcop;
  -- Se não encontrar
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor pois haverá raise
    CLOSE cr_crapcop;
    -- Montar mensagem de critica
    vr_cdcritic := 651;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;
  END IF;

  -- Inicializa variáveis
  vr_mes := to_char(vr_dtmvtolt, 'fmmm');
  vr_dtinimes := trunc(vr_dtmvtolt, 'mm');
  vr_dtfimmes := gene0005.fn_calc_data(vr_dtinimes,
                                       1,
                                       'M',
                                       pr_dscritic);
  -- Para cada produto de captação																				
  FOR rw_crapcpc IN (SELECT cpc.cdhsrdap,cpc.cdhsirap FROM crapcpc cpc
                      GROUP BY cpc.cdhsrdap,cpc.cdhsirap) LOOP
   
		-- Armazena os históricos na wt
    IF NVL(rw_crapcpc.cdhsrdap,0) <> 0  THEN
  		vr_tab_hist(rw_crapcpc.cdhsrdap).cdhsrdap := rw_crapcpc.cdhsrdap;
    END IF;

    IF NVL(rw_crapcpc.cdhsirap,0) <> 0  THEN
      vr_tab_hist(rw_crapcpc.cdhsirap).cdhsirap := rw_crapcpc.cdhsirap;
    END IF;

	END LOOP;																

  -- Carrega PL/Table com informações das tabelas craplap e craplpp
  for rw_craplap in cr_craplap (pr_cdcooper,
                                vr_dtinimes,
                                vr_dtfimmes) loop
    vr_tab_conta(rw_craplap.nrdconta).vr_histor(rw_craplap.cdhistor).vr_vllanmto := rw_craplap.vllanmto;
  end loop;
  for rw_craplpp in cr_craplpp (pr_cdcooper,
                                vr_dtinimes,
                                vr_dtfimmes) loop
    vr_tab_conta(rw_craplpp.nrdconta).vr_histor(rw_craplpp.cdhistor).vr_vllanmto := rw_craplpp.vllanmto;
  end loop;
	
	-- Para cada histórico de produto de captação
  vr_contador := vr_tab_hist.FIRST;

	LOOP		
	  
    EXIT WHEN vr_contador IS NULL;

	  -- Para cada lançamento de aplicação de captação com histórico de credito rendimento
		FOR rw_craplac IN cr_craplac (pr_cdcooper,
																	vr_dtinimes,
																	vr_dtfimmes,
																	vr_tab_hist(vr_contador).cdhsrdap) LOOP
			vr_tab_conta(rw_craplac.nrdconta).vr_histor(rw_craplac.cdhistor).vr_vllanmto := rw_craplac.vllanmto;
		END LOOP;
	  -- Para cada lançamento de aplicação de captação com histórico de Debito IRRF
		FOR rw_craplac IN cr_craplac (pr_cdcooper,
																	vr_dtinimes,
																	vr_dtfimmes,
																	vr_tab_hist(vr_contador).cdhsirap) LOOP
			vr_tab_conta(rw_craplac.nrdconta).vr_histor(rw_craplac.cdhistor).vr_vllanmto := rw_craplac.vllanmto;
		END LOOP;
		
    vr_contador := vr_tab_hist.NEXT(vr_contador);
	END LOOP;			
	
  -- Busca informações de cotas e recursos
  for rw_crapcot in cr_crapcot (pr_cdcooper,
                                vr_dtinimes,
                                vr_dtfimmes) loop
    vr_vlrenrda := 0;
    vr_vlirrdca := 0;
    vr_vlrirrpp := 0;
    vr_vlabnapl_ir := 0;
    vr_vlirabap := 0;
    vr_vlabonpp := 0;
    vr_vlirabpp := 0;
    vr_vlirajus := 0;
    vr_vlirfrdc := 0;
    vr_vlrenrdc := 0;
    vr_vlprvrdc := 0;
    vr_vlrevrdc := 0;
    --
    vr_indice_histor := vr_tab_conta(rw_crapcot.nrdconta).vr_histor.first;
    while vr_indice_histor is not null loop
    -- Lançamentos de aplicações RDCA para a conta (craplap)
      if vr_indice_histor in (116, 179) then
        vr_vlrenrda := vr_vlrenrda + vr_tab_conta(rw_crapcot.nrdconta).vr_histor(vr_indice_histor).vr_vllanmto;
      elsif vr_indice_histor = 866 then
        vr_vlabnapl_ir := vr_vlabnapl_ir + vr_tab_conta(rw_crapcot.nrdconta).vr_histor(vr_indice_histor).vr_vllanmto;
      elsif vr_indice_histor in (868, 871) then
        vr_vlirabap := vr_vlirabap + vr_tab_conta(rw_crapcot.nrdconta).vr_histor(vr_indice_histor).vr_vllanmto;
      elsif vr_indice_histor in (875, 876, 877) then
        vr_vlirajus := vr_vlirajus + vr_tab_conta(rw_crapcot.nrdconta).vr_histor(vr_indice_histor).vr_vllanmto;
      elsif vr_indice_histor in (463, 531) then
        vr_vlrevrdc := vr_vlrevrdc + vr_tab_conta(rw_crapcot.nrdconta).vr_histor(vr_indice_histor).vr_vllanmto;
      elsif vr_indice_histor in (474, 529) then
        vr_vlprvrdc := vr_vlprvrdc + vr_tab_conta(rw_crapcot.nrdconta).vr_histor(vr_indice_histor).vr_vllanmto;
      elsif vr_indice_histor in (475, 532) then
        vr_vlrenrdc := vr_vlrenrdc + vr_tab_conta(rw_crapcot.nrdconta).vr_histor(vr_indice_histor).vr_vllanmto;
      elsif vr_indice_histor in (476, 533) then
        vr_vlirfrdc := vr_vlirfrdc + vr_tab_conta(rw_crapcot.nrdconta).vr_histor(vr_indice_histor).vr_vllanmto;
      elsif vr_indice_histor in (861, 862) then
        vr_vlirrdca := vr_vlirrdca + vr_tab_conta(rw_crapcot.nrdconta).vr_histor(vr_indice_histor).vr_vllanmto;
      end if;
      -- Lançamentos de aplicações de poupança para a conta (craplpp)
      if vr_indice_histor = 863 then
        vr_vlrirrpp := vr_vlrirrpp + vr_tab_conta(rw_crapcot.nrdconta).vr_histor(vr_indice_histor).vr_vllanmto;
      elsif vr_indice_histor = 869 then
        vr_vlabonpp := vr_vlabonpp + vr_tab_conta(rw_crapcot.nrdconta).vr_histor(vr_indice_histor).vr_vllanmto;
      elsif vr_indice_histor = 870 then
        vr_vlirabpp := vr_vlirabpp + vr_tab_conta(rw_crapcot.nrdconta).vr_histor(vr_indice_histor).vr_vllanmto;
      end if;
						
			-- Para cada histórico de produtos de captação
      vr_contador := vr_tab_hist.FIRST;
			LOOP
				EXIT WHEN vr_contador IS NULL;

			  IF vr_indice_histor = vr_tab_hist(vr_contador).cdhsrdap THEN /* Rendimento */
          vr_vlrenrdc := vr_vlrenrdc + vr_tab_conta(rw_crapcot.nrdconta).vr_histor(vr_indice_histor).vr_vllanmto;
				END IF;
				
				IF vr_indice_histor = vr_tab_hist(vr_contador).cdhsirap THEN /* IRRF Rendimento */
          vr_vlirfrdc := vr_vlirfrdc + vr_tab_conta(rw_crapcot.nrdconta).vr_histor(vr_indice_histor).vr_vllanmto;
			  END IF;

				vr_contador := vr_tab_hist.NEXT(vr_contador);

			END LOOP;
						
		  --
      vr_indice_histor := vr_tab_conta(rw_crapcot.nrdconta).vr_histor.next(vr_indice_histor);
    end loop; -- craplpp
    -- Atualiza dados de cotas e recursos com lançamentos no mês
    begin
      vr_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(vr_cursor,
                     'update crapcot '||
                        'set crapcot.vlrenrda##'||vr_mes||' = :vr_vlrenrda, '||
                            'crapcot.vlirrdca##'||vr_mes||' = crapcot.vlirrdca##'||vr_mes||' + :vr_vlirrdca, '||
                            'crapcot.vlirajus##'||vr_mes||' = crapcot.vlirajus##'||vr_mes||' + :vr_vlirajus, '||
                            'crapcot.vlrirrpp##'||vr_mes||' = crapcot.vlrirrpp##'||vr_mes||' + :vr_vlrirrpp, '||
                            'crapcot.vlrentot##'||vr_mes||' = crapcot.vlrentot##'||vr_mes||' + :vr_vlrenrda + :vr_vlabonpp + :vr_vlabnapl_ir + :vr_vlrenrdc, '||
                            'crapcot.vlirabap##'||vr_mes||' = crapcot.vlirabap##'||vr_mes||' + :vr_vlirabap + :vr_vlirabpp, '||
                            'crapcot.vlirfrdc##'||vr_mes||' = crapcot.vlirfrdc##'||vr_mes||' + :vr_vlirfrdc, '||
                            'crapcot.vlrenrdc##'||vr_mes||' = crapcot.vlrenrdc##'||vr_mes||' + :vr_vlrenrdc, '||
                            'crapcot.vlabnapl_ir##'||vr_mes||' = crapcot.vlabnapl_ir##'||vr_mes||' + :vr_vlabonpp + :vr_vlabnapl_ir, '||
                            'crapcot.vlabonrd = crapcot.vlabonrd + :vr_vlabnapl_ir, '||
                            'crapcot.vlabonpp = crapcot.vlabonpp + :vr_vlabonpp '||
                      'where rowid = :vr_rowid',
                     dbms_sql.native);
      -- Define as variáveis usadas no cursor
      dbms_sql.bind_variable(vr_cursor, ':vr_vlrenrda', vr_vlrenrda);
      dbms_sql.bind_variable(vr_cursor, ':vr_vlirrdca', vr_vlirrdca);
      dbms_sql.bind_variable(vr_cursor, ':vr_vlrirrpp', vr_vlrirrpp);
      dbms_sql.bind_variable(vr_cursor, ':vr_vlabnapl_ir', vr_vlabnapl_ir);
      dbms_sql.bind_variable(vr_cursor, ':vr_vlirabap', vr_vlirabap);
      dbms_sql.bind_variable(vr_cursor, ':vr_vlabonpp', vr_vlabonpp);
      dbms_sql.bind_variable(vr_cursor, ':vr_vlirabpp', vr_vlirabpp);
      dbms_sql.bind_variable(vr_cursor, ':vr_vlirajus', vr_vlirajus);
      dbms_sql.bind_variable(vr_cursor, ':vr_vlirfrdc', vr_vlirfrdc);
      dbms_sql.bind_variable(vr_cursor, ':vr_vlrenrdc', vr_vlrenrdc);
      dbms_sql.bind_variable(vr_cursor, ':vr_rowid', rw_crapcot.row_id);
      --
      vr_qtlinhas := dbms_sql.execute(vr_cursor);
      dbms_sql.close_cursor(vr_cursor);
    exception
      when others then
        dbms_sql.close_cursor(vr_cursor);
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar rendimento da conta '||rw_crapcot.nrdconta||': '||sqlerrm;
        raise vr_exc_saida;
    end;
  end loop; -- crapcot
  -- Atualiza dados de cotas e recursos sem lançamentos no mês
  -- Este update é necessário porque o campo vlrenrda deve ser zerado nas contas
  -- que não tiveram lançamento no mês
  begin
    vr_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(vr_cursor,
                   'update crapcot '||
                      'set crapcot.vlrenrda##'||vr_mes||' = :vr_vlrenrda '||
                    'where crapcot.cdcooper = :vr_cdcooper '||
                      'and not exists (select 1 '||
                                        'from craplap '||
                                       'where craplap.cdcooper = crapcot.cdcooper '||
                                         'and craplap.nrdconta = crapcot.nrdconta '||
                                         'and craplap.dtmvtolt >= :vr_dtinimes '||
                                         'and craplap.dtmvtolt < :vr_dtfimmes '||
                                         'and craplap.cdhistor in (116, 179, 463, 474, 475, 476, '||
                                                                  '529, 531, 532, 533, 861, 862, '||
                                                                  '866, 868, 871, 875, 876, 877)) '||
                      'and not exists (select 1 '||
                                        'from craplpp '||
                                       'where craplpp.cdcooper = crapcot.cdcooper '||
                                         'and craplpp.nrdconta = crapcot.nrdconta '||
                                         'and craplpp.dtmvtolt >= :vr_dtinimes '||
                                         'and craplpp.dtmvtolt < :vr_dtfimmes '||
                                         'and craplpp.cdhistor in (863, 869, 870))',
                   dbms_sql.native);
    -- Define as variáveis usadas no cursor
    dbms_sql.bind_variable(vr_cursor, ':vr_vlrenrda', 0);
    dbms_sql.bind_variable(vr_cursor, ':vr_cdcooper', pr_cdcooper);
    dbms_sql.bind_variable(vr_cursor, ':vr_dtinimes', vr_dtinimes);
    dbms_sql.bind_variable(vr_cursor, ':vr_dtfimmes', vr_dtfimmes);
    --
    vr_qtlinhas := dbms_sql.execute(vr_cursor);
    dbms_sql.close_cursor(vr_cursor);
  exception
    when others then
      dbms_sql.close_cursor(vr_cursor);
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao atualizar rendimento das contas sem lançamento: '||sqlerrm;
      raise vr_exc_saida;
  end;

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Gravar as informações
  COMMIT;

EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
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
    -- Efetuar commit
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
    -- Efetuar rollback
    ROLLBACK;

 WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;

end pc_crps223;
/

