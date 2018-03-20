CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS016" (pr_cdcooper in craptab.cdcooper%type
                            ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                            ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                            ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                            ,pr_cdcritic out crapcri.cdcritic%type
                            ,pr_dscritic out varchar2) as
/* ..........................................................................

   Programa: PC_CRPS016 (Antigo Fontes/crps016.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/92.                      Ultima atualizacao: 28/02/2018

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 011.
               Emite relatorio com totais de saldo em conta-corrente por tipo
               de conta (21).

   Alteracoes: 30/08/94 - Alterado para nao dividir por 1000 e desprezar os
                          associados com data de eliminacao (Edson).

               22/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               16/04/2010 - Incluir Tipos de Conta diferentes para 085 e 756
                            (Guilherme/Supero)

               08/08/2013 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero).

               14/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                            das criticas e chamadas a fimprg.p (Douglas Pagel).
               
               28/02/2018 - Incluida quebra por tipo de pessoa. Aumentada mascara
                            dos campos de totais. PRJ366 (Lombardi).
............................................................................. */
  -- Data do movimento
  cursor cr_crapdat(pr_cdcooper in craptab.cdcooper%type) is
    select dat.dtmvtolt
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
  -- Cursor para validação da cooperativa
  cursor cr_crapcop is
    SELECT nmrescop, dsdircop
      FROM crapcop
     WHERE cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%rowtype;
  -- Rowtype para validacao da data
  rw_crapdat btch0001.cr_crapdat%rowtype;
  -- Busca os tipos de conta com a descrição
  cursor cr_tipo_conta (pr_cdcooper in craptip.cdcooper%type) is
    SELECT cta.inpessoa 
          ,ctc.cdtipo_conta
          --,cta.dstipo_conta
          ,to_char(ctc.cdtipo_conta, 'fm00')||'-'||cta.dstipo_conta dstipo_conta
      FROM tbcc_tipo_conta      cta
          ,tbcc_tipo_conta_coop ctc
     WHERE cta.cdtipo_conta = ctc.cdtipo_conta
       AND cta.inpessoa     = ctc.inpessoa
       AND ctc.cdcooper     = pr_cdcooper;
  -- Busca a descrição da agência
  cursor cr_crapage (pr_cdcooper in crapage.cdcooper%type,
                     pr_cdagenci in crapage.cdagenci%type) is
    select to_char(crapage.cdagenci, 'fm000')||' - '||crapage.nmresage agencia
      from crapage
     where crapage.cdcooper = pr_cdcooper
       and crapage.cdagenci = pr_cdagenci;
  rw_crapage      cr_crapage%rowtype;
  -- Lista dos totais de saldo em conta-corrente por tipo de conta
  cursor cr_crapsld(pr_cdcooper in crapsld.cdcooper%type,
                    pr_dtmvtolt in crapsld.dtrefere%type) is
    select cdagenci,
           cdtipcta,
           inpessoa,
           sum(ativo) ativo,
           sum(demitido) demitido,
           sum(round(vlstotal, 0)) vlstotal,
           sum(round(vltsalan, 0)) vltsalan,
           sum(round(vlprimes, 0)) vlprimes,
           sum(round(vlsegmes, 0)) vlsegmes,
           sum(round(vltermes, 0)) vltermes
      from (select crapass.cdagenci,
                   crapass.inpessoa,
                   decode(crapass.cdbcochq,
                          85, crapass.cdtipcta,
                          crapass.cdtipcta) cdtipcta,
                   decode(crapass.dtdemiss,
                          null, 1,
                          0) ativo,
                   decode(crapass.dtdemiss,
                          null, 0,
                          1) demitido,
                   (crapsld.vlsddisp +
                    crapsld.vlsdbloq +
                    crapsld.vlsdblpr +
                    crapsld.vlsdblfp +
                    crapsld.vlsdchsl) vlstotal,
                   crapsld.vltsalan,
                   decode(to_char(pr_dtmvtolt, 'mm'),
                          '01', crapsld.vlsmstre##1,
                          '02', crapsld.vlsmstre##2,
                          '03', crapsld.vlsmstre##3,
                          '04', crapsld.vlsmstre##4,
                          '05', crapsld.vlsmstre##5,
                          '06', crapsld.vlsmstre##6,
                          '07', crapsld.vlsmstre##1,
                          '08', crapsld.vlsmstre##2,
                          '09', crapsld.vlsmstre##3,
                          '10', crapsld.vlsmstre##4,
                          '11', crapsld.vlsmstre##5,
                          '12', crapsld.vlsmstre##6,
                          0) vlprimes,
                   decode(to_char(pr_dtmvtolt, 'mm'),
                          '01', crapsld.vlsmstre##6,
                          '02', crapsld.vlsmstre##1,
                          '03', crapsld.vlsmstre##2,
                          '04', crapsld.vlsmstre##3,
                          '05', crapsld.vlsmstre##4,
                          '06', crapsld.vlsmstre##5,
                          '07', crapsld.vlsmstre##6,
                          '08', crapsld.vlsmstre##1,
                          '09', crapsld.vlsmstre##2,
                          '10', crapsld.vlsmstre##3,
                          '11', crapsld.vlsmstre##4,
                          '12', crapsld.vlsmstre##5,
                          0) vlsegmes,
                   decode(to_char(pr_dtmvtolt, 'mm'),
                          '01', crapsld.vlsmstre##5,
                          '02', crapsld.vlsmstre##6,
                          '03', crapsld.vlsmstre##1,
                          '04', crapsld.vlsmstre##2,
                          '05', crapsld.vlsmstre##3,
                          '06', crapsld.vlsmstre##4,
                          '07', crapsld.vlsmstre##5,
                          '08', crapsld.vlsmstre##6,
                          '09', crapsld.vlsmstre##1,
                          '10', crapsld.vlsmstre##2,
                          '11', crapsld.vlsmstre##3,
                          '12', crapsld.vlsmstre##4,
                          0) vltermes
              from crapsld,
                   crapass
             where crapass.cdcooper = pr_cdcooper
               and crapass.dtelimin is null
               and crapsld.cdcooper = crapass.cdcooper
               and crapsld.nrdconta = crapass.nrdconta)
     group by cdagenci,
              inpessoa,
              cdtipcta
     order by cdagenci,
              inpessoa,
              cdtipcta;
  --
  -- PL/Table contendo os tipos de conta e a soma dos valores
  type typ_tipo is record (vr_dstipcta    varchar2(50),
                           vr_qtativo     number(6),
                           vr_qtdemitido  number(6),
                           vr_vltsalan    crapsld.vltsalan%type,
                           vr_vlstotal    crapsld.vltsalan%type,
                           vr_vlprimes    crapsld.vltsalan%type,
                           vr_vlsegmes    crapsld.vltsalan%type,
                           vr_vltermes    crapsld.vltsalan%type);
  -- Definição da tabela para armazenar os tipos de conta
  type typ_tab_tipo_2 is table of typ_tipo index by binary_integer;
  
  type typ_tab_tipo is table of typ_tab_tipo_2 index by binary_integer;
  
  -- Instância da tabela. O índice é o tipo de conta
  vr_tab_tipo      typ_tab_tipo;
  -- Índice para leitura da PL/Table
  vr_ind           binary_integer;
  vr_ind_2         binary_integer;
  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%type;
  -- Nome dos meses que serão calculados
  vr_dsmes1        varchar2(15);
  vr_dsmes2        varchar2(15);
  vr_dsmes3        varchar2(15);
  -- Controle da quebra do relatório
  vr_cdagenci      crapage.cdagenci%type := 0;
  vr_inpessoa      crapass.inpessoa%type := 0;
  -- Descricao tipo de pessoa
  vr_dsinpessoa    VARCHAR2(29);
  -- Variáveis para armazenar o total por agência
  vr_qtativo       number(6);
  vr_qtdemitido    number(6);
  vr_vltsalan      crapsld.vltsalan%type;
  vr_vlstotal      crapsld.vltsalan%type;
  vr_vlprimes      crapsld.vltsalan%type;
  vr_vlsegmes      crapsld.vltsalan%type;
  vr_vltermes      crapsld.vltsalan%type;
  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);
  -- Variável para armazenar as informações em XML
  vr_des_xml       clob;
  -- Variável para o caminho e nome do arquivo base
  vr_nom_diretorio varchar2(200);
  vr_nom_arquivo   varchar2(200);
  -- Subrotina para escrever texto na variável CLOB do XML
  procedure pc_escreve_xml(pr_des_dados in varchar2) is
  begin
    dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
  end;
  --
begin
  -- Nome do programa
  vr_cdprogra := 'CRPS016';

  -- Verifica se a cooperativa esta cadastrada
  OPEN cr_crapcop;
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

  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS016',
                             pr_action => vr_cdprogra);
  -- Leitura do calendário da cooperativa
  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat
   INTO rw_crapdat;
  -- Se não encontrar
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE btch0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic := 1;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE btch0001.cr_crapdat;
  END IF;
    
  -- Buscar a data do movimento
  vr_dtmvtolt := rw_crapdat.dtmvtolt;

  -- Identificar os meses que serão utilizados para calcular a média
  vr_dsmes1 := gene0001.vr_vet_nmmesano(to_char(vr_dtmvtolt, 'mm'));
  vr_dsmes2 := gene0001.vr_vet_nmmesano(to_char(add_months(vr_dtmvtolt, -1), 'mm'));
  vr_dsmes3 := gene0001.vr_vet_nmmesano(to_char(add_months(vr_dtmvtolt, -2), 'mm'));
  -- Buscar a descrição dos tipos de contas e armazenar em PL/Table
  for rw_tipo_conta in cr_tipo_conta (pr_cdcooper) loop
    vr_tab_tipo(rw_tipo_conta.inpessoa)(rw_tipo_conta.cdtipo_conta).vr_dstipcta := rw_tipo_conta.dstipo_conta;
  end loop;
  -- Inicializar o CLOB para armazenar o arquivo XML
  vr_des_xml := null;
  dbms_lob.createtemporary(vr_des_xml, true);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  -- Inicilizar as informações do XML
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps016>');
  pc_escreve_xml('<dsmes1>'||vr_dsmes1||'</dsmes1>'||
                 '<dsmes2>'||vr_dsmes2||'</dsmes2>'||
                 '<dsmes3>'||vr_dsmes3||'</dsmes3>');
  -- Leitura dos totais de saldo em conta-corrente por tipo de conta
  for rw_crapsld in cr_crapsld (pr_cdcooper,
                                vr_dtmvtolt) loop
    -- Verifica se é uma nova agência para incluir informações de quebra
    if rw_crapsld.cdagenci <> vr_cdagenci then
      open cr_crapage (pr_cdcooper,
                       rw_crapsld.cdagenci);
        fetch cr_crapage into rw_crapage;
        -- Se não encontrar a agência, gera erro e finaliza execução
        if cr_crapage%notfound then
          close cr_crapage;
          pr_cdcritic := 15;
          raise vr_exc_saida;
        end if;
      close cr_crapage;
      -- Se não é a primeira agência, inclui os totais fecha a quebra anterior
      if vr_cdagenci <> 0 then
        pc_escreve_xml('<qtativos_tot>'||to_char(vr_qtativo, 'fm999G990')||'</qtativos_tot>'||
                       '<qtdemitidos_tot>'||to_char(vr_qtdemitido, 'fm999G990')||'</qtdemitidos_tot>'||
                       '<vltsalan_tot>'||to_char(vr_vltsalan, 'fm999G999G999G990')||'</vltsalan_tot>'||
                       '<vlstotal_tot>'||to_char(vr_vlstotal, 'fm999G999G999G990')||'</vlstotal_tot>'||
                       '<vlprimes_tot>'||to_char(vr_vlprimes, 'fm999G999G999G990')||'</vlprimes_tot>'||
                       '<vlsegmes_tot>'||to_char(vr_vlsegmes, 'fm999G999G999G990')||'</vlsegmes_tot>'||
                       '<vltermes_tot>'||to_char(vr_vltermes, 'fm999G999G999G990')||'</vltermes_tot>');
        pc_escreve_xml('</agencia>');
      end if;
      -- Inclui a quebra no arquivo
      pc_escreve_xml('<agencia cdagenci="'||rw_crapage.agencia||'">');
      -- Atualiza o controle de quebra
      vr_cdagenci := rw_crapsld.cdagenci;
      -- Inicializa os totais
      vr_qtativo := 0;
      vr_qtdemitido := 0;
      vr_vltsalan := 0;
      vr_vlstotal := 0;
      vr_vlprimes := 0;
      vr_vlsegmes := 0;
      vr_vltermes := 0;
    end if;
    
    IF rw_crapsld.inpessoa = 1 THEN
      vr_dsinpessoa := 'Tipo de Pessoa PF';
    ELSIF rw_crapsld.inpessoa = 2 THEN
      vr_dsinpessoa := 'Tipo de Pessoa PJ';
    ELSE
      vr_dsinpessoa := 'Tipo de Pessoa PJ Cooperativa';
    END IF;
    
    -- Inclui a linha no XML
    pc_escreve_xml('<tipo dstipcta="'||vr_tab_tipo(rw_crapsld.inpessoa)(rw_crapsld.cdtipcta).vr_dstipcta||'">'||
                     '<qtativos>'||to_char(rw_crapsld.ativo, 'fm999G990')||'</qtativos>'||
                     '<qtdemitidos>'||to_char(rw_crapsld.demitido, 'fm999G990')||'</qtdemitidos>'||
                     '<vltsalan>'||to_char(rw_crapsld.vltsalan, 'fm999G999G999G990')||'</vltsalan>'||
                     '<vlstotal>'||to_char(rw_crapsld.vlstotal, 'fm999G999G999G990')||'</vlstotal>'||
                     '<vlprimes>'||to_char(rw_crapsld.vlprimes, 'fm999G999G999G990')||'</vlprimes>'||
                     '<vlsegmes>'||to_char(rw_crapsld.vlsegmes, 'fm999G999G999G990')||'</vlsegmes>'||
                     '<vltermes>'||to_char(rw_crapsld.vltermes, 'fm999G999G999G990')||'</vltermes>'||
                     '<inpessoa>'||vr_dsinpessoa||'</inpessoa>'||
                   '</tipo>');
    -- Soma os totais
    vr_qtativo := vr_qtativo + rw_crapsld.ativo;
    vr_qtdemitido := vr_qtdemitido + rw_crapsld.demitido;
    vr_vltsalan := vr_vltsalan + rw_crapsld.vltsalan;
    vr_vlstotal := vr_vlstotal + rw_crapsld.vlstotal;
    vr_vlprimes := vr_vlprimes + rw_crapsld.vlprimes;
    vr_vlsegmes := vr_vlsegmes + rw_crapsld.vlsegmes;
    vr_vltermes := vr_vltermes + rw_crapsld.vltermes;
    -- Acumula totais por tipo de conta na PL/Table para montar o resumo
    vr_tab_tipo(rw_crapsld.inpessoa)(rw_crapsld.cdtipcta).vr_qtativo := nvl(vr_tab_tipo(rw_crapsld.inpessoa)(rw_crapsld.cdtipcta).vr_qtativo, 0) + rw_crapsld.ativo;
    vr_tab_tipo(rw_crapsld.inpessoa)(rw_crapsld.cdtipcta).vr_qtdemitido := nvl(vr_tab_tipo(rw_crapsld.inpessoa)(rw_crapsld.cdtipcta).vr_qtdemitido, 0) + rw_crapsld.demitido;
    vr_tab_tipo(rw_crapsld.inpessoa)(rw_crapsld.cdtipcta).vr_vltsalan := nvl(vr_tab_tipo(rw_crapsld.inpessoa)(rw_crapsld.cdtipcta).vr_vltsalan, 0) + rw_crapsld.vltsalan;
    vr_tab_tipo(rw_crapsld.inpessoa)(rw_crapsld.cdtipcta).vr_vlstotal := nvl(vr_tab_tipo(rw_crapsld.inpessoa)(rw_crapsld.cdtipcta).vr_vlstotal, 0) + rw_crapsld.vlstotal;
    vr_tab_tipo(rw_crapsld.inpessoa)(rw_crapsld.cdtipcta).vr_vlprimes := nvl(vr_tab_tipo(rw_crapsld.inpessoa)(rw_crapsld.cdtipcta).vr_vlprimes, 0) + rw_crapsld.vlprimes;
    vr_tab_tipo(rw_crapsld.inpessoa)(rw_crapsld.cdtipcta).vr_vlsegmes := nvl(vr_tab_tipo(rw_crapsld.inpessoa)(rw_crapsld.cdtipcta).vr_vlsegmes, 0) + rw_crapsld.vlsegmes;
    vr_tab_tipo(rw_crapsld.inpessoa)(rw_crapsld.cdtipcta).vr_vltermes := nvl(vr_tab_tipo(rw_crapsld.inpessoa)(rw_crapsld.cdtipcta).vr_vltermes, 0) + rw_crapsld.vltermes;
  end loop;
  -- Verifica se gerou informação no arquivo
  if vr_cdagenci <> 0 then
    -- Inclui os totais da última agência e fecha a quebra
    pc_escreve_xml('<qtativos_tot>'||to_char(vr_qtativo, 'fm999G990')||'</qtativos_tot>'||
                   '<qtdemitidos_tot>'||to_char(vr_qtdemitido, 'fm999G990')||'</qtdemitidos_tot>'||
                   '<vltsalan_tot>'||to_char(vr_vltsalan, 'fm999G999G999G990')||'</vltsalan_tot>'||
                   '<vlstotal_tot>'||to_char(vr_vlstotal, 'fm999G999G999G990')||'</vlstotal_tot>'||
                   '<vlprimes_tot>'||to_char(vr_vlprimes, 'fm999G999G999G990')||'</vlprimes_tot>'||
                   '<vlsegmes_tot>'||to_char(vr_vlsegmes, 'fm999G999G999G990')||'</vlsegmes_tot>'||
                   '<vltermes_tot>'||to_char(vr_vltermes, 'fm999G999G999G990')||'</vltermes_tot>');
    pc_escreve_xml('</agencia>');
    -- R E S U M O
    -- Inclui a quebra para o resumo
    pc_escreve_xml('<agencia cdagenci="R E S U M O">');
    -- Inicializa os totais
    vr_qtativo := 0;
    vr_qtdemitido := 0;
    vr_vltsalan := 0;
    vr_vlstotal := 0;
    vr_vlprimes := 0;
    vr_vlsegmes := 0;
    vr_vltermes := 0;
    -- Leitura da PL/Table com os totais por tipo de conta
    vr_ind := vr_tab_tipo.first;
    while vr_ind is not null loop
      vr_ind_2 := vr_tab_tipo(vr_ind).first;
      while vr_ind_2 is not null loop
      -- Trata o registro somente se houver algum valor
        if nvl(vr_tab_tipo(vr_ind)(vr_ind_2).vr_qtativo, 0) <> 0 or
           nvl(vr_tab_tipo(vr_ind)(vr_ind_2).vr_qtdemitido, 0) <> 0 or
           nvl(vr_tab_tipo(vr_ind)(vr_ind_2).vr_vltsalan, 0) <> 0 or
           nvl(vr_tab_tipo(vr_ind)(vr_ind_2).vr_vlstotal, 0) <> 0 or
           nvl(vr_tab_tipo(vr_ind)(vr_ind_2).vr_vlprimes, 0) <> 0 or
           nvl(vr_tab_tipo(vr_ind)(vr_ind_2).vr_vlsegmes, 0) <> 0 or
           nvl(vr_tab_tipo(vr_ind)(vr_ind_2).vr_vltermes, 0) <> 0 THEN
           
          IF vr_ind = 1 THEN
            vr_dsinpessoa := 'Tipo de Pessoa PF';
          ELSIF vr_ind = 2 THEN
            vr_dsinpessoa := 'Tipo de Pessoa PJ';
          ELSE
            vr_dsinpessoa := 'Tipo de Pessoa PJ Cooperativa';
          END IF;
           
        -- Inclui a linha no XML
          pc_escreve_xml('<tipo dstipcta="'||vr_tab_tipo(vr_ind)(vr_ind_2).vr_dstipcta||'">'||
                           '<qtativos>'||to_char(vr_tab_tipo(vr_ind)(vr_ind_2).vr_qtativo, 'fm999G990')||'</qtativos>'||
                           '<qtdemitidos>'||to_char(vr_tab_tipo(vr_ind)(vr_ind_2).vr_qtdemitido, 'fm999G990')||'</qtdemitidos>'||
                           '<vltsalan>'||to_char(vr_tab_tipo(vr_ind)(vr_ind_2).vr_vltsalan, 'fm999G999G999G990')||'</vltsalan>'||
                           '<vlstotal>'||to_char(vr_tab_tipo(vr_ind)(vr_ind_2).vr_vlstotal, 'fm999G999G999G990')||'</vlstotal>'||
                           '<vlprimes>'||to_char(vr_tab_tipo(vr_ind)(vr_ind_2).vr_vlprimes, 'fm999G999G999G990')||'</vlprimes>'||
                           '<vlsegmes>'||to_char(vr_tab_tipo(vr_ind)(vr_ind_2).vr_vlsegmes, 'fm999G999G999G990')||'</vlsegmes>'||
                           '<vltermes>'||to_char(vr_tab_tipo(vr_ind)(vr_ind_2).vr_vltermes, 'fm999G999G999G990')||'</vltermes>'||
                           '<inpessoa>'||vr_dsinpessoa||'</inpessoa>'||
                       '</tipo>');
        -- Soma os totais
          vr_qtativo := vr_qtativo + vr_tab_tipo(vr_ind)(vr_ind_2).vr_qtativo;
          vr_qtdemitido := vr_qtdemitido + vr_tab_tipo(vr_ind)(vr_ind_2).vr_qtdemitido;
          vr_vltsalan := vr_vltsalan + vr_tab_tipo(vr_ind)(vr_ind_2).vr_vltsalan;
          vr_vlstotal := vr_vlstotal + vr_tab_tipo(vr_ind)(vr_ind_2).vr_vlstotal;
          vr_vlprimes := vr_vlprimes + vr_tab_tipo(vr_ind)(vr_ind_2).vr_vlprimes;
          vr_vlsegmes := vr_vlsegmes + vr_tab_tipo(vr_ind)(vr_ind_2).vr_vlsegmes;
          vr_vltermes := vr_vltermes + vr_tab_tipo(vr_ind)(vr_ind_2).vr_vltermes;
      end if;
        -- Passa para o próximo registro da PL/Table
        vr_ind_2 := vr_tab_tipo(vr_ind).next(vr_ind_2);
      end loop;
      -- Passa para o próximo registro da PL/Table
      vr_ind := vr_tab_tipo.next(vr_ind);
    end loop;
    -- Inclui os totais do resumo e fecha a quebra
    pc_escreve_xml('<qtativos_tot>'||to_char(vr_qtativo, 'fm999G990')||'</qtativos_tot>'||
                   '<qtdemitidos_tot>'||to_char(vr_qtdemitido, 'fm999G990')||'</qtdemitidos_tot>'||
                   '<vltsalan_tot>'||to_char(vr_vltsalan, 'fm999G999G999G990')||'</vltsalan_tot>'||
                   '<vlstotal_tot>'||to_char(vr_vlstotal, 'fm999G999G999G990')||'</vlstotal_tot>'||
                   '<vlprimes_tot>'||to_char(vr_vlprimes, 'fm999G999G999G990')||'</vlprimes_tot>'||
                   '<vlsegmes_tot>'||to_char(vr_vlsegmes, 'fm999G999G999G990')||'</vlsegmes_tot>'||
                   '<vltermes_tot>'||to_char(vr_vltermes, 'fm999G999G999G990')||'</vltermes_tot>');
    pc_escreve_xml('</agencia>');
  end if;
  -- Fecha a tag principal para encerrar o XML
  pc_escreve_xml('</crps016>');
  -- Busca do diretório base da cooperativa
  vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                            pr_cdcooper => pr_cdcooper,
                                            pr_nmsubdir => '/rl'); --> Utilizaremos o rl
  -- Executa o relatório com os maiores saldos
  vr_nom_arquivo := 'crrl021';
  -- Chamada do iReport para gerar o arquivo de saída
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                              pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                              pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                              pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                              pr_dsxmlnode => '/crps016/agencia/tipo',  --> Nó base do XML para leitura dos dados
                              pr_dsjasper  => 'crrl021.jasper',    --> Arquivo de layout do iReport
                              pr_dsparams  => null,                --> Enviar como parâmetro apenas a agência
                              pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo||'.lst', --> Arquivo final
                              pr_flg_gerar => 'N',
                              pr_qtcoluna  => 132,
                              pr_sqcabrel  => 1,
                              pr_flg_impri => 'S',    --> Chamar a impressão (Imprim.p)
                              pr_nmformul  => '',     --> Nome do formulário para impressão
                              pr_nrcopias  => 1,      --> Número de cópias para impressão
                              pr_nrvergrl => 1,
                              pr_des_erro  => vr_dscritic);       --> Saída com erro

  -- Liberando a memória alocada para os CLOBs
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);
  -- Testar se houve erro
  -- Verifica se ocorreu erro na geração do arquivo ou na solicitação do relatório
  if vr_dscritic is not null then
    raise vr_exc_saida;
  end if;

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informações atualizada
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
END;
/

