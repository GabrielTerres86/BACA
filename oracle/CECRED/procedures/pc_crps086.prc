create or replace procedure cecred.pc_crps086(pr_cdcooper  in craptab.cdcooper%type,
                     pr_flgresta  in pls_integer,            --> Flag padrão para utilização de restart
                     pr_stprogra out pls_integer,            --> Saída de termino da execução
                     pr_infimsol out pls_integer,            --> Saída de termino da solicitação,
                     pr_cdcritic out crapcri.cdcritic%type,
                     pr_dscritic out varchar2) as
/* ..........................................................................

   Programa: pc_crps086 - Antigo Fontes/crps086.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 21/01/2015

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 013 (mensal - limpeza mensal)
               Emite: arquivo geral de extratos dos emprestimos para
                      microfilmagem.

   Alteracao : 03/03/95 - Alterado para modificar o layout da microfilmagem
                          (Odair).

               26/06/96 - Alterado o layout para mostrar o campo lem.vlpreemp
                          quando maior que 0 (Odair).

               03/04/97 - Alterado para mudar do /win10 para o /win12 (Deborah).

               07/04/98 - Alterado para incluir novo parametro no shell
                          transmic (Deborah).

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               23/12/1999 - Buscar dados da cooperativa no crapcop (Deborah).

               10/01/2000 - Padronizar mensagens (Deborah).

               23/03/2000 - Tratar arquivos de microfilmagem, transmitindo para
                            Hering somente arquivos com registros (Odair)

               01/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               02/07/2001 - Tratar contratos em prejuizo (Deborah/Margarete).

               30/06/2004 - Prever avalistas terceiros(Mirtes)
                            (alterada includes crps086.i)

               02/08/2004 - Alterado o caminho do win12 (Julio)

               20/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               13/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper =
                            glb_cdcooper) no "for each" da tabela CRAPHIS.
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

               30/10/2008 - Alteracao CDEMPRES (Diego).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               30/01/2014 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero).

               29/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow).

               21/01/2015 - Alterado o formato do campo nrctremp para 8
                            caracters (Kelvin - 233714)
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
  -- Buscar as informações de cabeçalho para empréstimos liquidados
  cursor cr_crapepr (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtrefere in crapdat.dtmvtolt%type) is
    select epr.cdcooper,
           epr.nrdconta,
           epr.nrctremp,
           epr.dtmvtolt,
           epr.dtultpag,
           epr.inprejuz,
           epr.vlsdprej,
           epr.vlpreemp,
           epr.qtpreemp,
           epr.vljuracu,
           to_char(epr.cdlcremp, 'fm0000')||' - '||lcr.dslcremp dslcremp,
           to_char(epr.cdfinemp, 'fm000')||' - '||fin.dsfinemp dsfinemp,
           epr.dtprejuz,
           epr.vlprejuz,
           epr.vljraprj,
           epr.nrctaav1,
           decode(epr.nrctaav1,
                  0, avt1.nmdavali1,
                  nvl(av1.nmprimtl, 'NAO CADASTRADO')) nmdaval1,
           epr.nrctaav2,
           decode(epr.nrctaav2,
                  0, decode(epr.nrctaav1,
                            0, avt2.nmdavali2,
                            avt1.nmdavali1),
                  nvl(av2.nmprimtl, 'NAO CADASTRADO')) nmdaval2,
           nvl(tit.nmprimtl, 'NAO CADASTRADO') nmprimtl,
           decode(tit.inpessoa,
                  1, ttl.cdempres,
                  jur.cdempres) cdempres
      from crapfin fin,
           craplcr lcr,
           crapttl ttl,
           crapjur jur,
           (select cdcooper,
                   nrdconta,
                   nrctremp,
                   row_number() over(partition by nrdconta, nrctremp order by cdcooper) nravali,
                   nrcpfcgc || ' -  ' || nmdavali nmdavali2
              from crapavt
             where cdcooper = pr_cdcooper
               and tpctrato = 1) avt2,
           (select cdcooper,
                   nrdconta,
                   nrctremp,
                   row_number() over(partition by nrdconta, nrctremp order by cdcooper) nravali,
                   nrcpfcgc || ' -  ' || nmdavali nmdavali1
              from crapavt
             where cdcooper = pr_cdcooper
               and tpctrato = 1) avt1,
           crapass tit,
           crapass av2,
           crapass av1,
           crapepr epr
     where epr.cdcooper = pr_cdcooper
       and epr.vlsdeved = 0
       and epr.inliquid > 0
       -- Busca os empréstimos liquidados com prejuízo ou liquidados no mês de referência
       and (   (    epr.inprejuz = 0
                and to_char(epr.dtultpag, 'mm') = to_char(pr_dtrefere, 'mm'))
            or (    epr.inprejuz = 1
                and epr.vlsdprej = 0))
       -- Buscar avalistas pela conta informada no empréstimo
       and av1.cdcooper (+) = epr.cdcooper
       and av1.nrdconta (+) = epr.nrctaav1
       and av2.cdcooper (+) = epr.cdcooper
       and av2.nrdconta (+) = epr.nrctaav2
       -- Buscar avalista1 pelo cadastro de avalistas não associados
       and avt1.cdcooper (+) = epr.cdcooper
       and avt1.nrdconta (+) = epr.nrdconta
       and avt1.nrctremp (+) = epr.nrctremp
       and avt1.nravali (+) = 1
       -- Buscar avalista2 pelo cadastro de avalistas não associados
       and avt2.cdcooper (+) = epr.cdcooper
       and avt2.nrdconta (+) = epr.nrdconta
       and avt2.nrctremp (+) = epr.nrctremp
       and avt2.nravali (+) = 2
       -- Buscar titular
       and tit.cdcooper (+) = epr.cdcooper
       and tit.nrdconta (+) = epr.nrdconta
       -- Titular PF
       and ttl.cdcooper (+) = tit.cdcooper
       and ttl.nrdconta (+) = tit.nrdconta
       and ttl.idseqttl (+) = 1
       -- Titular PJ
       and jur.cdcooper (+) = tit.cdcooper
       and jur.nrdconta (+) = tit.nrdconta
       -- Descrição da linha de crédito
       and lcr.cdcooper = epr.cdcooper
       and lcr.cdlcremp = epr.cdlcremp
       -- Descrição da finalidade
       and fin.cdcooper = epr.cdcooper
       and fin.cdfinemp = epr.cdfinemp;
  -- Busca os lançamentos de empréstimos liquidados
  cursor cr_craplem (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtrefere in crapdat.dtmvtolt%type) is
    select lem.nrdconta,
           lem.nrctremp,
           lem.dtmvtolt,
           lem.cdhistor,
           lem.nrdocmto,
           lem.vllanmto,
           lem.cdagenci,
           lem.cdbccxlt,
           lem.nrdolote,
           his.dshistor,
           his.indebcre,
           lem.txjurepr,
           lem.dtpagemp,
           lem.vlpreemp,
           epr.inprejuz,
           epr.vlsdprej/*,
           lem.progress_recid*/,
           max(lem.dtmvtolt) over (partition by lem.cdcooper, lem.nrdconta, lem.nrctremp) max_data
      from craphis his,
           craplem lem,
           crapepr epr
     where epr.cdcooper = pr_cdcooper
       and epr.vlsdeved = 0
       and epr.inliquid > 0
       -- Busca os empréstimos liquidados com prejuízo ou liquidados no mês de referência
       and (   (    epr.inprejuz = 0
                and to_char(epr.dtultpag, 'mm') = to_char(pr_dtrefere, 'mm'))
            or (    epr.inprejuz = 1
                and epr.vlsdprej = 0))
       and lem.cdcooper = epr.cdcooper
       and lem.nrdconta = epr.nrdconta
       and lem.nrctremp = epr.nrctremp
       and his.cdcooper = lem.cdcooper
       and his.cdhistor = lem.cdhistor;
  --
  rw_crapdat         btch0001.cr_crapdat%rowtype;
  rw_craptab         btch0001.cr_craptab%rowtype;
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

  -- PL/Table para armazenar os lançamentos de empréstimo
  type typ_craplem is record (nrdconta  craplem.nrdconta%type,
                              nrctremp  craplem.nrctremp%type,
                              dtmvtolt  craplem.dtmvtolt%type,
                              cdhistor  craplem.cdhistor%type,
                              nrdocmto  craplem.nrdocmto%type,
                              vllanmto  craplem.vllanmto%type,
                              cdagenci  craplem.cdagenci%type,
                              cdbccxlt  craplem.cdbccxlt%type,
                              nrdolote  craplem.nrdolote%type,
                              dshistor  craphis.dshistor%type,
                              indebcre  craphis.indebcre%type,
                              txjurepr  craplem.txjurepr%type,
                              dtpagemp  craplem.dtpagemp%type,
                              vlpreemp  craplem.vlpreemp%type);
  type typ_tab_craplem is table of typ_craplem index by varchar2(58);
  -- O índice da pl/table é formado pelos campos dtmvtolt, cdhistor, nrdocmto e nrdolote.
  vr_ind_craplem   varchar2(58);
  vr_ind_craplem_prox   varchar2(58);

  -- PL/Table para armazenar os empréstimos liquidados
  type typ_crapepr is record (cdcooper    crapepr.cdcooper%type,
                              nrdconta    crapepr.nrdconta%type,
                              nrctremp    crapepr.nrctremp%type,
                              dtmvtolt    crapepr.dtmvtolt%type,
                              dtultpag    crapepr.dtultpag%type,
                              inprejuz    crapepr.inprejuz%type,
                              vlsdprej    crapepr.vlsdprej%type,
                              vlpreemp    crapepr.vlpreemp%type,
                              qtpreemp    crapepr.qtpreemp%type,
                              vljuracu    crapepr.vljuracu%type,
                              dslcremp    varchar2(38),
                              dsfinemp    varchar2(38),
                              dtprejuz    crapepr.dtprejuz%type,
                              vlprejuz    crapepr.vlprejuz%type,
                              vljraprj    crapepr.vljraprj%type,
                              nrctaav1    crapepr.nrctaav1%type,
                              nmdaval1    varchar2(67),
                              nrctaav2    crapepr.nrctaav2%type,
                              nmdaval2    varchar2(67),
                              nmprimtl    crapass.nmprimtl%type,
                              cdempres    crapttl.cdempres%type,
                              vr_craplem  typ_tab_craplem);
  type typ_tab_crapepr is table of typ_crapepr index by varchar2(20);
  vr_crapepr       typ_tab_crapepr;
  -- O índice da pl/table é formado pelos campos nrdconta e nrctremp.
  vr_ind_crapepr   varchar2(20);
  -- Variáveis para cálculo do saldo devedor
  aux_vlsdeved     crapepr.vlprejuz%type;
  vr_vlsdeved      crapepr.vlprejuz%type;
  -- Variáveis para campos que podem ser nulos no relatório
  vr_txjurepr      craplem.txjurepr%type;
  vr_vlpreemp      craplem.vlpreemp%type;
  -- Variáveis para cada linha de cabeçalho do relatório
  vr_cab1          varchar2(132);
  vr_cab2          varchar2(132);
  vr_cab3          varchar2(132);
  vr_cab4          varchar2(132);
  vr_cab5          varchar2(132);
  vr_cab6          varchar2(132);
  vr_cab8          varchar2(132);
  vr_cab9          varchar2(132);
  -- Variáveis utilizadas para verificar se o relatório deve executar e
  -- para fazer a cópia para a CIA HERING.
  vr_regis000      craptab.dstextab%type;
  vr_regis086      craptab.dstextab%type;
  vr_typ_said      varchar2(4);
  vr_des_erro      varchar2(4000);
  -- Subrotina para escrever texto na variável CLOB do XML
  procedure pc_escreve_xml(pr_des_dados in varchar2,
                           pr_fecha_xml in boolean default false) is
  begin
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
  end;

begin
  -- Nome do programa
  vr_cdprogra := 'CRPS086';
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS086',
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
  -- Diretorio no MAINFRAME da CIA HERING
  open btch0001.cr_craptab (pr_cdcooper,
                            'CRED',
                            'CONFIG',
                            pr_cdcooper,
                            'MICROFILMA',
                            0,
                            null);
    fetch btch0001.cr_craptab into rw_craptab;
    -- Verificar se existe informação, e gerar erro caso não exista
    if btch0001.cr_craptab%notfound then
      -- Fechar o cursor
      close btch0001.cr_craptab;
      -- Gerar exceção
      vr_cdcritic := 652;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' - CRED-CONFIG-NN-MICROFILMA-000';
      raise vr_exc_saida;
    end if;
  close btch0001.cr_craptab;
  vr_regis000 := rw_craptab.dstextab;
  -- Parametros de execucao do programa
  open btch0001.cr_craptab (pr_cdcooper,
                            'CRED',
                            'CONFIG',
                            pr_cdcooper,
                            'MICROFILMA',
                            86,
                            null);
    fetch btch0001.cr_craptab into rw_craptab;
    -- Verificar se existe informação, e gerar erro caso não exista
    if btch0001.cr_craptab%notfound then
      -- Fechar o cursor
      close btch0001.cr_craptab;
      -- Gerar exceção
      vr_cdcritic := 652;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' - CRED-CONFIG-NN-MICROFILMA-000';
      raise vr_exc_saida;
    end if;
  close btch0001.cr_craptab;
  vr_regis086 := rw_craptab.dstextab;
  -- Verifica se o programa deve rodar para esta Cooperativa
  if to_number(substr(vr_regis086,1,1)) <> 1   then
    raise vr_exc_fimprg;
  end if;
  -- Carrega pl/table com os empréstimos liquidados, ordenando por nrdconta e nrctremp
  for rw_crapepr in cr_crapepr (pr_cdcooper,
                                rw_crapdat.dtultdma) loop
    vr_ind_crapepr := lpad(rw_crapepr.nrdconta, 10, '0')||lpad(rw_crapepr.nrctremp, 10, '0');
    vr_crapepr(vr_ind_crapepr).cdcooper := rw_crapepr.cdcooper;
    vr_crapepr(vr_ind_crapepr).nrdconta := rw_crapepr.nrdconta;
    vr_crapepr(vr_ind_crapepr).nrctremp := rw_crapepr.nrctremp;
    vr_crapepr(vr_ind_crapepr).dtmvtolt := rw_crapepr.dtmvtolt;
    vr_crapepr(vr_ind_crapepr).dtultpag := rw_crapepr.dtultpag;
    vr_crapepr(vr_ind_crapepr).inprejuz := rw_crapepr.inprejuz;
    vr_crapepr(vr_ind_crapepr).vlsdprej := rw_crapepr.vlsdprej;
    vr_crapepr(vr_ind_crapepr).vlpreemp := rw_crapepr.vlpreemp;
    vr_crapepr(vr_ind_crapepr).qtpreemp := rw_crapepr.qtpreemp;
    vr_crapepr(vr_ind_crapepr).vljuracu := rw_crapepr.vljuracu;
    vr_crapepr(vr_ind_crapepr).dslcremp := rw_crapepr.dslcremp;
    vr_crapepr(vr_ind_crapepr).dsfinemp := rw_crapepr.dsfinemp;
    vr_crapepr(vr_ind_crapepr).dtprejuz := rw_crapepr.dtprejuz;
    vr_crapepr(vr_ind_crapepr).vlprejuz := rw_crapepr.vlprejuz;
    vr_crapepr(vr_ind_crapepr).vljraprj := rw_crapepr.vljraprj;
    vr_crapepr(vr_ind_crapepr).nrctaav1 := rw_crapepr.nrctaav1;
    vr_crapepr(vr_ind_crapepr).nmdaval1 := nvl(rw_crapepr.nmdaval1, ' ');
    vr_crapepr(vr_ind_crapepr).nrctaav2 := rw_crapepr.nrctaav2;
    vr_crapepr(vr_ind_crapepr).nmdaval2 := nvl(rw_crapepr.nmdaval2, ' ');
    vr_crapepr(vr_ind_crapepr).nmprimtl := rw_crapepr.nmprimtl;
    vr_crapepr(vr_ind_crapepr).cdempres := rw_crapepr.cdempres;
  end loop;
  -- Carrega pl/table com os lançamentos dos empréstimos liquidados,
  -- ordenando por nrdconta, nrctremp, dtmvtolt, cdhistor e nrdocmto
  for rw_craplem in cr_craplem (pr_cdcooper,
                                rw_crapdat.dtultdma) loop
    vr_ind_crapepr := lpad(rw_craplem.nrdconta, 10, '0')||lpad(rw_craplem.nrctremp, 10, '0');
    -- Verifica se o empréstimo está na pl/table. Se não estiver, não precisa incluir o lançamento.
    if not vr_crapepr.exists(vr_ind_crapepr) then
      continue;
    end if;
    -- Verifica se a data do último lançamento é no mês de referência
    if rw_craplem.inprejuz = 1 and
       rw_craplem.vlsdprej = 0 and
       to_char(rw_craplem.max_data, 'mmyyyy') <> to_char(rw_crapdat.dtultdma, 'mmyyyy') then
      -- Se a data é diferente, elimina o empréstimo da pl/table para que não precise processar os próximos lançamentos.
      vr_crapepr.delete(vr_ind_crapepr);
      continue;
    end if;
    -- Inclui o lançamento na pl/table
    vr_ind_craplem := to_char(rw_craplem.dtmvtolt, 'yyyymmdd')||lpad(rw_craplem.cdhistor, 5, '0')||lpad(rw_craplem.nrdocmto, 25, '0')||lpad(rw_craplem.nrdolote, 10, '0');
    vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).nrdconta := rw_craplem.nrdconta;
    vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).nrctremp := rw_craplem.nrctremp;
    vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).dtmvtolt := rw_craplem.dtmvtolt;
    vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).cdhistor := rw_craplem.cdhistor;
    vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).nrdocmto := rw_craplem.nrdocmto;
    vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).vllanmto := rw_craplem.vllanmto;
    vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).cdagenci := rw_craplem.cdagenci;
    vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).cdbccxlt := rw_craplem.cdbccxlt;
    vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).nrdolote := rw_craplem.nrdolote;
    vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).dshistor := rw_craplem.dshistor;
    vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).indebcre := rw_craplem.indebcre;
    vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).txjurepr := rw_craplem.txjurepr;
    vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).dtpagemp := rw_craplem.dtpagemp;
    vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).vlpreemp := rw_craplem.vlpreemp;
  end loop;

  -- Definição do diretório e nome do arquivo a ser gerado
  vr_nom_diretorio := gene0001.fn_diretorio('w',  -- /usr/coop/win12
                                            pr_cdcooper,
                                            'microfilmagem');
  vr_nom_arquivo := 'cradmep.'||to_char(rw_crapdat.dtultdma, 'yyyymm');
  -- Leitura das PL/Tables e geração do arquivo XML
  -- Inicializar o CLOB
  vr_des_xml := null;
  dbms_lob.createtemporary(vr_des_xml, true);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  -- Inicilizar as informações do XML
  vr_texto_completo := null;
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl086>');
  -- Cabeçalho
  vr_cab1 := '  EMP     CONTA/DV  TITULAR                   EXTRATO DE EMPRESTIMOS                                                         ORDEM  ';
  vr_cab3 := '0CONTRATO  LINHA DE CREDITO/FINALIDADE           AVALISTAS                                              PRESTACAO/JUROS     PR.     ';
  vr_cab4 := '0   DATA    HISTORICO             DOCUMENTO     LANCAMENTO         SALDO DEVEDOR  TAXA JUROS  DAT.PGTO  VLR PRESTACAO AG. BCX   LOTE';
  vr_cab6 := '0-----------------------------------------------------------------------------------------------------------------------------------';
  -- Leitura da PL/Table
  vr_ind_crapepr := vr_crapepr.first;
  while vr_ind_crapepr is not null loop
    -- Definir informações de cabeçalho
    vr_cab2 := ' '||
               lpad(to_char(vr_crapepr(vr_ind_crapepr).cdempres, 'fm99990'), 5, ' ')||'   '||
               lpad(to_char(vr_crapepr(vr_ind_crapepr).nrdconta, 'fm9999G990G0'), 10, ' ')||'  '||
               rpad(substr(vr_crapepr(vr_ind_crapepr).nmprimtl, 1, 36), 36, ' ')||'   '||
               lpad(upper(trim(to_char(add_months(rw_crapdat.dtmvtolt, -1), 'month')))||'/'||to_char(add_months(rw_crapdat.dtmvtolt, -1), 'yyyy'), 14, ' ')||
               rpad(' ', 49, ' ');
    vr_cab5 := '  '||
               lpad(to_char(vr_crapepr(vr_ind_crapepr).nrctremp, 'fm99G999G990'), 9, ' ')||' '||
               rpad(substr(vr_crapepr(vr_ind_crapepr).dslcremp, 1, 35), 35, ' ')||' '||
               lpad(to_char(vr_crapepr(vr_ind_crapepr).nrctaav1, 'fm9999G990G0'), 10, ' ')||' - '||
               rpad(substr(vr_crapepr(vr_ind_crapepr).nmdaval1, 1, 40), 40, ' ')||'  '||
               lpad(to_char(vr_crapepr(vr_ind_crapepr).vlpreemp, 'fm99999G999G990D00'), 16, ' ')||'     '||
               lpad(to_char(vr_crapepr(vr_ind_crapepr).qtpreemp,'fm990'), 3, ' ');
    vr_cab8 := '            '||
               rpad(substr(vr_crapepr(vr_ind_crapepr).dsfinemp, 1, 35), 35, ' ')||' '||
               lpad(to_char(vr_crapepr(vr_ind_crapepr).nrctaav2, 'fm9999G990G0'), 10, ' ')||' - '||
               rpad(substr(vr_crapepr(vr_ind_crapepr).nmdaval2, 1, 40), 40, ' ')||'  '||
               lpad(to_char(vr_crapepr(vr_ind_crapepr).vljuracu, 'fm99999G999G990D00'), 16, ' ')||'     ';
    if vr_crapepr(vr_ind_crapepr).inprejuz = 1 then
      vr_cab9 := '0DATA TRANSF PREJUIZO: '||
                 to_char(vr_crapepr(vr_ind_crapepr).dtprejuz, 'dd/mm/yyyy')||
                 '               VALOR TRANSF PREJUIZO: '||
                 lpad(to_char(vr_crapepr(vr_ind_crapepr).vlprejuz, 'fm99999g999g990d00'), 16, ' ')||
                 '                JUROS PREJUIZO: '||
                 lpad(to_char(vr_crapepr(vr_ind_crapepr).vljraprj, 'fm99g999g990d00'), 13, ' ');
    else
      vr_cab9 := null;
    end if;
    -- Incluir informações de cabeçalho no XML
    pc_escreve_xml('<emprestimo indice="'||vr_ind_crapepr||'">'||
                     '<cab1>'||vr_cab1||'</cab1>'||
                     '<cab2>'||vr_cab2||'</cab2>'||
                     '<cab3>'||vr_cab3||'</cab3>'||
                     '<cab4>'||vr_cab4||'</cab4>'||
                     '<cab5>'||vr_cab5||'</cab5>'||
                     '<cab6>'||vr_cab6||'</cab6>'||
                     '<cab8>'||vr_cab8||'</cab8>'||
                     '<cab9>'||vr_cab9||'</cab9>');
    -- Índice para a tabela de lançamentos
    vr_ind_craplem := vr_crapepr(vr_ind_crapepr).vr_craplem.first;
    -- Variável para cálculo do saldo devedor a cada lançamento
    if vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).cdhistor <> 99 then
      aux_vlsdeved := vr_crapepr(vr_ind_crapepr).vlprejuz;
    else
      aux_vlsdeved := 0;
    end if;
    -- Leitura dos lançamentos
    while vr_ind_craplem is not null loop
      -- Cálculo do saldo devedor
      if (vr_crapepr(vr_ind_crapepr).dtmvtolt > to_date('31071993', 'ddmmyyyy') and
          vr_crapepr(vr_ind_crapepr).dtultpag < to_date('01071994', 'ddmmyyyy')) or
         vr_crapepr(vr_ind_crapepr).dtmvtolt > to_date('30061994', 'ddmmyyyy') then
        -- Soma ou diminui o valor do lançamento
        if vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).indebcre = 'D' then
          aux_vlsdeved := aux_vlsdeved + vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).vllanmto;
        elsif vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).indebcre = 'C' and
              vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).cdhistor <> 349 then
          aux_vlsdeved := aux_vlsdeved - vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).vllanmto;
        end if;
        -- Verifica se é o último lançamento da data. Se não for, não exibe o saldo.
        vr_ind_craplem_prox := vr_crapepr(vr_ind_crapepr).vr_craplem.next(vr_ind_craplem);
        if vr_ind_craplem_prox is not null then
          if to_char(vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).dtmvtolt, 'mmyyyy') <> to_char(nvl(vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem_prox).dtmvtolt, to_date('01011900','ddmmyyyy')), 'mmyyyy') then
            vr_vlsdeved := aux_vlsdeved;
          else
            vr_vlsdeved := null;
          end if;
        else
          vr_vlsdeved := aux_vlsdeved;
        end if;
      else
        vr_vlsdeved := null;
      end if;
      -- Tratamento para campos que podem ficar vazios
      if vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).txjurepr > 0 then
        vr_txjurepr := vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).txjurepr;
      else
        vr_txjurepr := null;
      end if;
      if vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).vlpreemp > 0 then
        vr_vlpreemp := vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).vlpreemp;
      else
        vr_vlpreemp := null;
      end if;
      -- Incluir dados do lançamento e fechá-lo
      pc_escreve_xml('<lancamento>'||
                       '<dtmvtolt>'||to_char(vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).dtmvtolt, 'dd/mm/yyyy')||'</dtmvtolt>'||
                       '<dshistor>'||substr(to_char(vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).cdhistor, 'fm0000')||' '||vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).dshistor, 1, 19)||'</dshistor>'||
                       '<nrdocmto>'||to_char(to_number(substr(to_char(vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).nrdocmto, 'fm00000000000000'), 6, 9)), 'fm999G999G990')||'</nrdocmto>'||
                       '<vllanmto>'||to_char(vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).vllanmto, 'fm999G999G990D00')||'</vllanmto>'||
                       '<indebcre>'||vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).indebcre||'</indebcre>'||
                       '<vlsdeved>'||to_char(vr_vlsdeved, 'fm9999G999G999G990D00')||'</vlsdeved>'||
                       '<txjurepr>'||to_char(vr_txjurepr, 'fm990D0000000')||'</txjurepr>'||
                       '<dtpagemp>'||to_char(vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).dtpagemp, 'dd/mm/yyyy')||'</dtpagemp>'||
                       '<vlpreemp>'||to_char(vr_vlpreemp, 'fm99G999G990D00')||'</vlpreemp>'||
                       '<cdagenci>'||to_char(vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).cdagenci, 'fm990')||'</cdagenci>'||
                       '<cdbccxlt>'||to_char(vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).cdbccxlt, 'fm990')||'</cdbccxlt>'||
                       '<nrdolote>'||to_char(vr_crapepr(vr_ind_crapepr).vr_craplem(vr_ind_craplem).nrdolote, 'fm999990')||'</nrdolote>'||
                     '</lancamento>');
      vr_ind_craplem := vr_crapepr(vr_ind_crapepr).vr_craplem.next(vr_ind_craplem);
    end loop;
    -- Fechar o empréstimo
    pc_escreve_xml('</emprestimo>');
    vr_ind_crapepr := vr_crapepr.next(vr_ind_crapepr);
  end loop;
  pc_escreve_xml('</crrl086>',
                 true);
  -- Solicita o relatório
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                              pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                              pr_dtmvtolt  => rw_crapdat.dtmvtolt,         --> Data do movimento atual
                              pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                              pr_dsxmlnode => '/crrl086/emprestimo/lancamento',      --> Nó base do XML para leitura dos dados
                              pr_dsjasper  => 'cradmep.jasper',    --> Arquivo de layout do iReport
                              pr_cdrelato  => 1,  -- Passar desta forma para não ter problema na gene0002
                              pr_dsparams  => null,
                              pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo, --> Arquivo final
                              pr_flg_gerar => 'N',
                              pr_qtcoluna  => 132,
                              pr_des_erro  => vr_dscritic);        --> Saída com erro
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);
  -- Testar se houve erro
  if vr_dscritic is not null then
    -- Gerar exceção
    vr_cdcritic := 0;
    raise vr_exc_saida;
  end if;
  -- Transm. para CIA HERING
  if to_number(substr(vr_regis086, 3, 1)) = 1 then
    gene0001.pc_OScommand_Shell(pr_des_comando => 'transmic . '||vr_nom_arquivo||' AX/'||upper(vr_regis000)||'/MICMEP '||to_char(sysdate, 'sssss'),
                                pr_typ_saida   => vr_typ_said,
                                pr_des_saida   => vr_des_erro);
    -- Testa erro
    if vr_typ_said = 'ERR' then
      gene0001.pc_print('Erro ao transmitir arquivo para CIA HERING: '||vr_des_erro);
    end if;
    -- Gerar exceção
    vr_cdcritic := 658;
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' '||vr_nom_arquivo||' PARA HERING';
    -- Inclui mensagem no arquivo de log
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 1,
                               pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || vr_cdprogra || ' --> '
                                               || vr_dscritic );
  end if;
  -- Finaliza a execução com sucesso
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_stprogra => pr_stprogra);
  --
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
    commit;
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

