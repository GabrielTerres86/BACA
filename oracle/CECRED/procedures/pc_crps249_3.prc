CREATE OR REPLACE PROCEDURE CECRED.pc_crps249_3(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                        ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                        ,pr_nmestrut  IN craphis.nmestrut%TYPE --> Nome da tabela
                                        ,pr_cdhistor  IN craphis.cdhistor%TYPE --> Código do histórico
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                        ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
 /* ..........................................................................

   Programa: pc_crps249_3 (antigo Fontes/crps249_3.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/98                     Ultima atualizacao: 28/02/2013

   Dados referentes ao programa:

   Frequencia: Diario. Exclusivo.
   Objetivo  : Atende a solicitacao 76.
               Gerar arquivo para contabilidade.
               Ordem do programa na solicitacao 1.

   Alteracoes: 13/06/2000 - Tratar lancamentos por PAC (Odair)

               22/08/2000 - Tratar cheque salario Bancoob (Deborah).

               25/04/2001 - Tratar pac ate 99 (Edson).

               21/06/2005 - Mudar para conta 1179 (CTITG) - Ze Eduardo
                            Somente Credifiesc, Cecrisacred e Credcrea.

               07/07/2005 - Alimentado campo cdcooper tabela craprej (Diego).

               10/12/2005 - Atualizar craprej.nrdctitg (Magui).

               25/01/2006 - Efetuar unico lancamento para CTA ITG (Ze).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               15/12/2008 - Substituir a tab "ContaConve" pela gnctace (Ze).

               18/05/2011 - Ajuste para contabilizar a quantidade de boletos
                            atraves do dsidendi na craplcm (Gabriel)

               28/02/2013 - Conversão Progress >> Oracle PL/Sql (Daniel - Supero)
............................................................................. */
  -- Buscar informações dos associados e lançamentos
  cursor cr_craplcm is
    select crapass.cdagenci,
           craplcm.dsidenti,
           craplcm.cdbccxlt,
           craplcm.nrdctabb,
           craplcm.vllanmto
      from crapass,
           craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt = pr_dtmvtolt
       and craplcm.cdhistor = pr_cdhistor
       and crapass.cdcooper = craplcm.cdcooper
       and crapass.nrdconta = craplcm.nrdconta
     order by craplcm.cdbccxlt,
              craplcm.nrdctabb;
  -- Variável para armazenar o nome do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Variáveis para criação de cursor dinâmico
  vr_num_cursor    number;
  vr_num_retor     number;
  vr_cursor        varchar2(32000);
  -- Variáveis para retorno do cursor dinâmico
  vr_cdbccxlt      craprej.cdbccxlt%type;
  vr_nrdctabb      craprej.nrdctabb%type;
  vr_indice        varchar2(15);
  vr_cdagenci      craprej.cdagenci%type;
  vr_vllanmto      craprej.vllanmto%type;
  vr_qtlanmto      number(10);
  -- Variáveis para armazenar a lista de contas convênio
  vr_lscontas      varchar2(4000);
  vr_lsconta4      varchar2(4000);
  -- Tratamento de erros
  vr_exc_erro      exception;
  -- Variável auxiliar para o número da conta BB
  vr_rel_nrdctabb  number(10);
  -- Variáveis para receber o retorno do procedimento btch0001.pc_conta_itg_digito_x
  vr_dsdctitg      varchar2(10);
  vr_stsnrcal      number(1); -- 1 verdadeiro, 0 falso
  /* Registro para armazenar os valores por agência */
  type typ_agencia is record (qtccuage  craprej.nrseqdig%type,
                              vlccuage  craprej.vllanmto%type);
  /* Tabela onde serão armazenados os registros da agência */
  /* O índice da tabela será o código da agência */
  type typ_tab_agencia is table of typ_agencia index by binary_integer;
  /* Registro para armazenar informações agrupadas por cdbccxlt e nrdctabb */
  type typ_crawtot is record (cdbccxlt     craprej.cdbccxlt%type,
                              nrdctabb     craprej.nrdctabb%type,
                              vldctabb     craprej.vllanmto%type,
                              qtdctabb     craprej.nrseqdig%type,
                              tab_agencia  typ_tab_agencia);
  /* Tabela onde serão armazenadas as informações agrupadas */
  /* O índice da tabela será cdbccxlt e nrdctabb */
  type typ_tab_crawtot is table of typ_crawtot index by varchar2(15);
  /* Instância da tabela */
  vr_crawtot   typ_tab_crawtot;

  /* Procedimento para inicialização da PL/Table de agência ao criar novo
     registro, garantindo que os campos terão valor zero, e não nulo. */
  procedure pc_cria_agencia_pltable (pr_indice in varchar2,
                                  pr_agencia in crapage.cdagenci%type) is
  BEGIN
    -- Se o registro ainda não existe
    if not vr_crawtot(pr_indice).tab_agencia.exists(pr_agencia) then
      vr_crawtot(pr_indice).tab_agencia(pr_agencia).vlccuage := 0;
      vr_crawtot(pr_indice).tab_agencia(pr_agencia).qtccuage := 0;
      vr_crawtot(pr_indice).tab_agencia(999).vlccuage := 0;
      vr_crawtot(pr_indice).tab_agencia(999).qtccuage := 0;
    end if;
  end;
  /* Função para verificar a última CONTACONVE cadastrada */
  function fn_ultctaconve (pr_dstextab in varchar2) return varchar2 is
    vr_dstextab    varchar2(4000) := pr_dstextab;
  begin
    if instr(pr_dstextab, ',', -1) = length(trim(pr_dstextab))   then
      vr_dstextab := substr(pr_dstextab, 1, length(trim(pr_dstextab)) - 1);
      vr_dstextab := substr(vr_dstextab, instr(vr_dstextab, ',', -1) + 1, 10);
    elsif instr(pr_dstextab, ',', -1) > 0 then
      vr_dstextab := substr(pr_dstextab, instr(pr_dstextab, ',', -1) + 1, 10);
    end if;
    return vr_dstextab;
  end;
  --
BEGIN
  vr_cdprogra := 'CRPS249';  /* igual ao origem */
  /*  Le tabela com as contas convenio do Banco do Brasil   */
  vr_lscontas := gene0005.fn_busca_conta_centralizadora(pr_cdcooper, 0);
  -- Se não tiver contas
  if vr_lscontas is null then
    pr_cdcritic := 393;
    pr_dscritic := gene0001.fn_busca_critica(393);
    return;
  end if;
  --
  vr_lsconta4 := gene0005.fn_busca_conta_centralizadora(pr_cdcooper, 4);
  if vr_lsconta4 is null then
    pr_cdcritic := 393;
    pr_dscritic := gene0001.fn_busca_critica(393);
    return;
  else
    vr_rel_nrdctabb := to_number(fn_ultctaconve(vr_lsconta4));
  end if;
  -- Define a query do cursor dinâmico
  vr_cursor := 'select x.cdbccxlt,'||
                     ' x.nrdctabb,'||
                     ' c.cdagenci,'||
                     ' sum(x.vllanmto),'||
                     ' count(x.vllanmto)'||
                ' from crapass c, '||pr_nmestrut||' x'||
               ' where x.cdcooper = '||pr_cdcooper||
                 ' and x.dtmvtolt = to_date('''||to_char(pr_dtmvtolt, 'ddmmyyyy')||''', ''ddmmyyyy'')'||
                 ' and x.cdhistor = '||pr_cdhistor||
                 ' and c.cdcooper = x.cdcooper'||
                 ' and c.nrdconta = x.nrdconta'||
               ' group by x.cdbccxlt, x.nrdctabb, c.cdagenci'||
               ' order by x.cdbccxlt, x.nrdctabb';
  -- Cria cursor dinâmico
  vr_num_cursor := dbms_sql.open_cursor;
  -- Comando Parse
  dbms_sql.parse(vr_num_cursor, vr_cursor, 1);
  -- Definindo Colunas de retorno
  dbms_sql.define_column(vr_num_cursor, 1, vr_cdbccxlt);
  dbms_sql.define_column(vr_num_cursor, 2, vr_nrdctabb);
  dbms_sql.define_column(vr_num_cursor, 3, vr_cdagenci);
  dbms_sql.define_column(vr_num_cursor, 4, vr_vllanmto);
  dbms_sql.define_column(vr_num_cursor, 5, vr_qtlanmto);
  -- Execução do select dinamico
  vr_num_retor := dbms_sql.execute(vr_num_cursor);
  -- Abre o cursor e começa a processar os registros
  loop
    -- Verifica se há alguma linha de retorno do cursor
    vr_num_retor := dbms_sql.fetch_rows(vr_num_cursor);
    if vr_num_retor = 0 THEN
      -- Se o cursor dinamico está aberto
      IF dbms_sql.is_open(vr_num_cursor) THEN
        -- Fecha o mesmo
        dbms_sql.close_cursor(vr_num_cursor);
      END if;
      exit;
    else
      -- Carrega variáveis com o retorno do cursor
      dbms_sql.column_value(vr_num_cursor, 1, vr_cdbccxlt);
      dbms_sql.column_value(vr_num_cursor, 2, vr_nrdctabb);
      dbms_sql.column_value(vr_num_cursor, 3, vr_cdagenci);
      dbms_sql.column_value(vr_num_cursor, 4, vr_vllanmto);
      dbms_sql.column_value(vr_num_cursor, 5, vr_qtlanmto);
      -- Identifica o número da conta a utilizar
      -- Necessário utilizar as vírgulas como delimitadores para garantir que encontrou o número correto, e não apenas parte dele.
      if instr(','||vr_lscontas||',', ','||vr_nrdctabb||',') = 0 and
         pr_cdcooper <> 3 then
        vr_nrdctabb := vr_rel_nrdctabb;
      end if;
      -- Monta o índice
      vr_indice := lpad(vr_cdbccxlt, 5, '0')||lpad(vr_nrdctabb, 10, '0');
      -- Atribui os campos chave
      vr_crawtot(vr_indice).cdbccxlt := vr_cdbccxlt;
      vr_crawtot(vr_indice).nrdctabb := vr_nrdctabb;
      pc_cria_agencia_pltable(vr_indice,
                           vr_cdagenci);
      -- Acumula quantidade caso o histórico não seja 266
      if pr_cdhistor <> 266 then
        vr_crawtot(vr_indice).qtdctabb := nvl(vr_crawtot(vr_indice).qtdctabb, 0) + vr_qtlanmto;
        vr_crawtot(vr_indice).tab_agencia(vr_cdagenci).qtccuage := nvl(vr_crawtot(vr_indice).tab_agencia(vr_cdagenci).qtccuage, 0) + vr_qtlanmto;
        vr_crawtot(vr_indice).tab_agencia(999).qtccuage := nvl(vr_crawtot(vr_indice).tab_agencia(999).qtccuage, 0) + vr_qtlanmto;
      end if;
      -- Acumula o valor
      vr_crawtot(vr_indice).vldctabb := nvl(vr_crawtot(vr_indice).vldctabb, 0) + vr_vllanmto;
      vr_crawtot(vr_indice).tab_agencia(vr_cdagenci).vlccuage := nvl(vr_crawtot(vr_indice).tab_agencia(vr_cdagenci).vlccuage, 0) + vr_vllanmto;
      vr_crawtot(vr_indice).tab_agencia(999).vlccuage := nvl(vr_crawtot(vr_indice).tab_agencia(999).vlccuage, 0) + vr_vllanmto;
    end if;
  end loop;

  -- Se o cursor dinamico está aberto
  IF dbms_sql.is_open(vr_num_cursor) THEN
    -- Fecha o mesmo
    dbms_sql.close_cursor(vr_num_cursor);
  END if;

  -- Caso o histórico seja 266, lê a tabela craplcm e acumula a quantidade
  if pr_cdhistor = 266 then
    for rw_craplcm in cr_craplcm loop
      -- Identifica o número da conta a utilizar
      -- Necessário utilizar as vírgulas como delimitadores para garantir que encontrou o número correto, e não apenas parte dele.
      if instr(','||vr_lscontas||',', ','||rw_craplcm.nrdctabb||',') = 0 and
         pr_cdcooper <> 3 then
        vr_nrdctabb := vr_rel_nrdctabb;
      else
        vr_nrdctabb := rw_craplcm.nrdctabb;
      end if;
      -- Monta o índice
      vr_indice := lpad(rw_craplcm.cdbccxlt, 5, '0')||lpad(vr_nrdctabb, 10, '0');
      -- Atribui os campos chave
      vr_crawtot(vr_indice).cdbccxlt := rw_craplcm.cdbccxlt;
      vr_crawtot(vr_indice).nrdctabb := vr_nrdctabb;
      -- Acumula a quantidade, utilizando a informação da tabela (quando houver)
      if trim(rw_craplcm.dsidenti) is null then
        vr_crawtot(vr_indice).qtdctabb := nvl(vr_crawtot(vr_indice).qtdctabb, 0) + 1;
        vr_crawtot(vr_indice).tab_agencia(rw_craplcm.cdagenci).qtccuage := nvl(vr_crawtot(vr_indice).tab_agencia(rw_craplcm.cdagenci).qtccuage, 0) + 1;
        vr_crawtot(vr_indice).tab_agencia(999).qtccuage := nvl(vr_crawtot(vr_indice).tab_agencia(999).qtccuage, 0) + 1;
      else
        vr_crawtot(vr_indice).qtdctabb := nvl(vr_crawtot(vr_indice).qtdctabb, 0) + to_number(trim(rw_craplcm.dsidenti));
        vr_crawtot(vr_indice).tab_agencia(rw_craplcm.cdagenci).qtccuage := nvl(vr_crawtot(vr_indice).tab_agencia(rw_craplcm.cdagenci).qtccuage, 0) + to_number(trim(rw_craplcm.dsidenti));
        vr_crawtot(vr_indice).tab_agencia(999).qtccuage := nvl(vr_crawtot(vr_indice).tab_agencia(999).qtccuage, 0) + to_number(trim(rw_craplcm.dsidenti));
      end if;
      --
    end loop;
  end if;
  -- Lê a PL/Table e grava as informações na craprej
  vr_indice := vr_crawtot.first;
  while vr_indice is not null loop
    -- Busca o número da conta integração
    gene0005.pc_conta_itg_digito_x(vr_crawtot(vr_indice).nrdctabb,
                                   vr_dsdctitg,
                                   vr_stsnrcal,
                                   pr_cdcritic,
                                   pr_dscritic);
    if pr_dscritic is not null then
      rollback;
      return;
    end if;
    -- Insere o registro totalizador
    BEGIN
      insert into craprej (cdpesqbb,
                           cdagenci,
                           cdhistor,
                           dtmvtolt,
                           vllanmto,
                           nrseqdig,
                           dtrefere,
                           nrdctabb,
                           cdbccxlt,
                           cdcooper,
                           nrdctitg)
      values (vr_cdprogra,
              999,
              pr_cdhistor,
              pr_dtmvtolt,
              vr_crawtot(vr_indice).vldctabb,
              vr_crawtot(vr_indice).qtdctabb,
              'COMPBB',
              vr_crawtot(vr_indice).nrdctabb,
              vr_crawtot(vr_indice).cdbccxlt,
              pr_cdcooper,
              vr_dsdctitg);
    exception
      when others then
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao criar registro totalizador na CRAPREJ para caixa '||vr_crawtot(vr_indice).cdbccxlt||' e conta '||vr_crawtot(vr_indice).nrdctabb||': '||sqlerrm;
        rollback;
        return;
    end;
    -- Insere as informações de cada agência
    vr_cdagenci := vr_crawtot(vr_indice).tab_agencia.first;
    while vr_cdagenci is not null loop
      BEGIN
        insert into craprej (cdpesqbb,
                             cdagenci,
                             cdhistor,
                             dtmvtolt,
                             vllanmto,
                             nrseqdig,
                             dtrefere,
                             nrdctabb,
                             cdbccxlt,
                             cdcooper)
        values (vr_cdprogra,
                decode(vr_cdagenci,
                       999, 0,
                       vr_cdagenci),
                pr_cdhistor,
                pr_dtmvtolt,
                vr_crawtot(vr_indice).tab_agencia(vr_cdagenci).vlccuage,
                vr_crawtot(vr_indice).tab_agencia(vr_cdagenci).qtccuage,
                'TARIFA',
                vr_crawtot(vr_indice).nrdctabb,
                vr_crawtot(vr_indice).cdbccxlt,
                pr_cdcooper);
      exception
        when others then
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao criar registro na CRAPREJ para agência '||vr_cdagenci||', caixa '||vr_crawtot(vr_indice).cdbccxlt||' e conta '||vr_crawtot(vr_indice).nrdctabb||': '||sqlerrm;
          rollback;
          return;
      end;
      vr_cdagenci := vr_crawtot(vr_indice).tab_agencia.next(vr_cdagenci);
    end loop;
    vr_indice := vr_crawtot.next(vr_indice);
  end loop;

exception
  when others then
    pr_dscritic := 'Erro PC_CRPS249_3: '||SQLERRM;
END PC_CRPS249_3;
/

