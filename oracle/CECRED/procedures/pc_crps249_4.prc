CREATE OR REPLACE PROCEDURE CECRED.pc_crps249_4(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa solicitada
                                        ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                        ,pr_nmestrut  IN craphis.nmestrut%TYPE --> Nome da tabela
                                        ,pr_cdhistor  IN craphis.cdhistor%TYPE --> Código do histórico
                                        ,pr_tpctbcxa  IN craphis.tpctbcxa%TYPE --> Tipo de conta
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                        ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
/* ..........................................................................

   Programa: pc_crps249_4 (antigo Fontes/crps249_4.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Fevereiro/2004                  Ultima atualizacao: 03/02/2015

   Dados referentes ao programa:

   Frequencia: Diario. Exclusivo.
   Objetivo  : Atende a solicitacao 76.
               Gerar arquivo para contabilidade.
               Ordem do programa na solicitacao 1.(DOC/TED - Arq.Craptvl)

   Alteracoes: 30/06/2005 - Alimentado cdcooper da tabela craprej (Diego).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               23/03/2007 - Tratamento p/ hist. 542 e 549 - Bancoob (Ze).

               12/06/2007 - Acerto na composicao dos lancamentos (Ze).

               30/08/2007 - Acerto no hist. 549 e 558 (TED BANCOOB) (Ze).

               26/08/2009 - Substituicao do campo banco/agencia da COMPE,
                            para o banco/agencia COMPE de DOC (cdagedoc e
                            cdbandoc) - (Sidnei - Precise).

               15/10/2009 - Inclusao de tratamento para banco CECRED junto com
                            BB e Bancoob. (Guilherme - Precise)

               21/05/2010 - Ajustes na contabilizacao da nossa IF (Magui).

               25/02/2013 - Conversão Progress >> Oracle PL/Sql (Daniel - Supero)
               
               26/06/2014 - Desprezar o histórico 523 quando cooperativa CECRED.
                            (Fabricio)
							
			   03/02/2014 - (Chamado 245712) Agencia com 3 dígitos não integrando no contábil
							 (Andrino - RKAM).
               
               30/04/2019 - Ajustada a rotina para desprezar os dados de lançamentos
                            de transferencias de portabilidade, nas leituras da 
                            CRAPTVL. (Renato Darosci - Supero - Projeto 485)
............................................................................ */
  -- Informações da cooperativa
  cursor cr_crapcop is
    select flgopstr,
           cdbcoctl
      from crapcop
     where crapcop.cdcooper = pr_cdcooper;
  rw_crapcop    cr_crapcop%rowtype;
  -- Informações da agência
  cursor cr_crapage (pr_cdagenci in crapage.cdagenci%type) is
    select cdbandoc
      from crapage
     where crapage.cdcooper = pr_cdcooper
       and crapage.cdagenci = pr_cdagenci;
  rw_crapage    cr_crapage%rowtype;
  -- Variável para armazenar o nome do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Variáveis para criação de cursor dinâmico
  vr_num_cursor    number;
  vr_num_retor     number;
  vr_cursor        varchar2(32000);
  -- Variáveis para retorno do cursor dinâmico
  vr_cdagenci      craptvl.cdagenci%type;
  vr_vldocrcb      craptvl.vldocrcb%type;
  vr_tpdoctrf      craptvl.tpdoctrf%type;
  -- Flag Ope.STR da tabela crapcop
  vr_flgopstr      boolean;
  -- Variáveis para definir o tipo de documento
  vr_tpdoctrf1     craptvl.tpdoctrf%type;
  vr_tpdoctrf2     craptvl.tpdoctrf%type;
  /* Registro para acumular os valores por agência */
  type typ_agencia is record (vlcxaage  craprej.vllanmto%type,
                              qtcxaage  craprej.nrseqdig%type);
  /* Tabela onde serão armazenados os registros da agência */
  /* O índice da tabela será o código da agência. O índice 99 se refere ao total das agências */
  type typ_tab_agencia is table of typ_agencia index by binary_integer;
  /* Instância da tabela */
  vr_tab_agencia   typ_tab_agencia;
  -- Índice para leitura das informações da tabela
  vr_indice_agencia  number(3);
  /* Procedimento para inicialização da PL/Table de agência ao criar novo
     registro, garantindo que os campos terão valor zero, e não nulo. */
  procedure pc_cria_agencia_pltable (pr_agencia in crapage.cdagenci%type) is
  begin
    if not vr_tab_agencia.exists(pr_agencia) then
      vr_tab_agencia(pr_agencia).vlcxaage := 0;
      vr_tab_agencia(pr_agencia).qtcxaage := 0;
    end if;
  end;
begin
  vr_cdprogra := 'CRPS249';  /* igual ao origem */
  -- Verifica se o flag flgopstr é verdadeiro ou falso
  open cr_crapcop;
    fetch cr_crapcop into rw_crapcop;
    if cr_crapcop%found then
      vr_flgopstr := (rw_crapcop.flgopstr = 1);
    else
      vr_flgopstr := false;
    end if;
  close cr_crapcop;
  --
  if pr_cdhistor in (523, 549, 558) then  /* TED */
    vr_tpdoctrf1 := 3;
    vr_tpdoctrf2 := 3;
  elsif pr_cdhistor in (828, 542, 557) then  /* DOC */
    vr_tpdoctrf1 := 1;  /* DOC C */
    vr_tpdoctrf2 := 2;  /* DOC D */
  end if;
  -- Define a query do cursor dinâmico
  vr_cursor := 'select cdagenci,'||
                     ' vldocrcb,'||
                     ' tpdoctrf'||
                ' from '||pr_nmestrut||
               ' where cdcooper = '||pr_cdcooper||
                 ' and dtmvtolt = to_date('''||to_char(pr_dtmvtolt, 'ddmmyyyy')||''', ''ddmmyyyy'')'||
                 ' and tpdoctrf in ('||vr_tpdoctrf1||','||vr_tpdoctrf2||')';
  
  -- Se a estrutura for CRAPTVL
  IF UPPER(pr_nmestrut) = 'CRAPTVL' THEN
    -- Não devem ser considerados os lançamentos da TVL referente a portabilidade de salário,
    -- pois os mesmos estão dispostos em outros históricos
    vr_cursor := vr_cursor||' and NVL(nrridlfp,0) = 0 ';
  END IF;
  
  -- Cria cursor dinâmico
  vr_num_cursor := dbms_sql.open_cursor;
  -- Comando Parse
  dbms_sql.parse(vr_num_cursor, vr_cursor, 1);
  -- Definindo Colunas de retorno
  dbms_sql.define_column(vr_num_cursor, 1, vr_cdagenci);
  dbms_sql.define_column(vr_num_cursor, 2, vr_vldocrcb);
  dbms_sql.define_column(vr_num_cursor, 3, vr_tpdoctrf);
  -- Execução do select dinamico
  vr_num_retor := dbms_sql.execute(vr_num_cursor);
  -- Abre o cursor e começa a processar os registros
  pc_cria_agencia_pltable(999);
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
      dbms_sql.column_value(vr_num_cursor, 1, vr_cdagenci);
      dbms_sql.column_value(vr_num_cursor, 2, vr_vldocrcb);
      dbms_sql.column_value(vr_num_cursor, 3, vr_tpdoctrf);
      -- Busca informações da agência
      open cr_crapage(vr_cdagenci);
        fetch cr_crapage into rw_crapage;
        -- Caso não encontre, retorna erro
        if cr_crapage%notfound then
          pr_cdcritic := 15;
          pr_dscritic := gene0001.fn_busca_critica(15);
          close cr_crapage;
          rollback;
          return;
        end if;
      close cr_crapage;
      -- Processamento das informações do cursor dinâmico, descartando os registros inconsistentes
      if vr_tpdoctrf = 3 then  /* TEDS */
        if vr_flgopstr THEN
          -- Se o histórico for de 559-TED ON-LINE BANCOOB ou 558-TED ON-LINE
           if pr_cdhistor in (558, 549) then /*IF 85 */
            continue;
          end if;
          
          -- Se a cooperativa for CECRED e o histórico for 523
          IF pr_cdcooper = 3 AND pr_cdhistor = 523 THEN
            continue;
          END IF;
        ELSE
          -- Se for 523 - NOSSA REMESSA TED COMPE CECRED
          if pr_cdhistor = 523 then
            continue;
          end if;
        end if;
      end if;
      -- Se histórico for 557-DOC ON-LINE ou 558-TED ON-LINE
      if pr_cdhistor in (557, 558) then
        -- Se o banco não for o BANCO DO BRASIL
        if rw_crapage.cdbandoc <> 1 THEN
          continue; -- próximo
        end if;
      end if;
      -- Se histórico for 542-DOC BANCOOB ON-LINE ou 549-TED ON-LINE BANCOOB
      if pr_cdhistor in (542, 549) then
        -- Se o banco não for BANCOOB DOC
        if rw_crapage.cdbandoc <> 756 then
          continue;  -- próximo
        end if;
      end if;
      -- Se histórico for NOSSA REMESSA DOC COMPE CECRED
      if pr_cdhistor = 828 then     /*  CECRED DOC  */
        if rw_crapage.cdbandoc <> rw_crapcop.cdbcoctl then
          continue;
        end if;
      end if;
      pc_cria_agencia_pltable(vr_cdagenci);
      -- Acumula os valores dos registros consistentes, por agência
      vr_tab_agencia(vr_cdagenci).vlcxaage := nvl(vr_tab_agencia(vr_cdagenci).vlcxaage, 0) + vr_vldocrcb;
      vr_tab_agencia(vr_cdagenci).qtcxaage := nvl(vr_tab_agencia(vr_cdagenci).qtcxaage, 0) + 1;
      -- Acumula o total dos valores dos registros consistentes
      vr_tab_agencia(999).vlcxaage := nvl(vr_tab_agencia(999).vlcxaage, 0) + vr_vldocrcb;
      vr_tab_agencia(999).qtcxaage := nvl(vr_tab_agencia(999).qtcxaage, 0) + 1;
    end if;
  end loop;
  -- Se o cursor dinamico está aberto
  IF dbms_sql.is_open(vr_num_cursor) THEN
    -- Fecha o mesmo
    dbms_sql.close_cursor(vr_num_cursor);
  END if;
  --
  if vr_tab_agencia(999).vlcxaage > 0 then
    if pr_tpctbcxa in (2, 3)  then
      /* Detalhamento por agência */
      vr_indice_agencia := vr_tab_agencia.first;
      while vr_indice_agencia < 998 loop
        -- Inclui as informações na tabela de rejeitados
        begin
         insert into craprej (cdpesqbb,
                               cdagenci,
                               cdhistor,
                               dtmvtolt,
                               vllanmto,
                               nrseqdig,
                               dtrefere,
                               cdcooper)
          values (vr_cdprogra,
                  vr_indice_agencia,
                  pr_cdhistor,
                  pr_dtmvtolt,
                  vr_tab_agencia(vr_indice_agencia).vlcxaage,
                  vr_tab_agencia(vr_indice_agencia).qtcxaage,
                  pr_nmestrut,
                  pr_cdcooper);
        exception
          when others then
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao criar CRAPREJ para agência '||vr_indice_agencia||': '||sqlerrm;
            rollback;
            return;
        end;
        vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
      end loop;
    else
      /* Total geral (utilizar agência = 0 ao gravar as informações) */
      BEGIN
        insert into craprej (cdpesqbb,
                             cdagenci,
                             cdhistor,
                             dtmvtolt,
                             vllanmto,
                             nrseqdig,
                             dtrefere,
                             cdcooper)
        values (vr_cdprogra,
                0,
                pr_cdhistor,
                pr_dtmvtolt,
                vr_tab_agencia(999).vlcxaage,
                vr_tab_agencia(999).qtcxaage,
                pr_nmestrut,
                pr_cdcooper);
      exception
        when others then
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao criar CRAPREJ para agência '||vr_indice_agencia||': '||sqlerrm;
          rollback;
          return;
      end;
    end if;
  end if;
 
exception
  when others then
    pr_dscritic := 'Erro PC_CRPS249_4: '||SQLERRM;
end pc_crps249_4;
/
