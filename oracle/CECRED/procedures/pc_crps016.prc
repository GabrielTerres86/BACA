CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS016" (pr_cdcooper in craptab.cdcooper%type
                            ,pr_flgresta  IN PLS_INTEGER            --> Flag padr�o para utiliza��o de restart
                            ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                            ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                            ,pr_cdcritic out crapcri.cdcritic%type
                            ,pr_dscritic out varchar2) as
/* ..........................................................................

   Programa: PC_CRPS016 (Antigo Fontes/crps016.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/92.                      Ultima atualizacao: 14/10/2013

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

               08/08/2013 - Convers�o Progress >> Oracle PL/SQL (Daniel - Supero).

               14/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                            das criticas e chamadas a fimprg.p (Douglas Pagel).
............................................................................. */
  -- Data do movimento
  cursor cr_crapdat(pr_cdcooper in craptab.cdcooper%type) is
    select dat.dtmvtolt
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
  -- Cursor para valida��o da cooperativa
  cursor cr_crapcop is
    SELECT nmrescop, dsdircop
      FROM crapcop
     WHERE cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%rowtype;
  -- Rowtype para validacao da data
  rw_crapdat btch0001.cr_crapdat%rowtype;
  -- Busca os tipos de conta com a descri��o
  cursor cr_craptip (pr_cdcooper in craptip.cdcooper%type) is
    select craptip.cdtipcta,
           to_char(craptip.cdtipcta, 'fm00')||'-'||craptip.dstipcta dstipcta
      from craptip
     where craptip.cdcooper = pr_cdcooper;
  -- Busca a descri��o da ag�ncia
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
           sum(ativo) ativo,
           sum(demitido) demitido,
           sum(round(vlstotal, 0)) vlstotal,
           sum(round(vltsalan, 0)) vltsalan,
           sum(round(vlprimes, 0)) vlprimes,
           sum(round(vlsegmes, 0)) vlsegmes,
           sum(round(vltermes, 0)) vltermes
      from (select crapass.cdagenci,
                   decode(crapass.cdbcochq,
                          85, decode(crapass.cdtipcta,
                                     8, 96,
                                     9, 97,
                                     10, 98,
                                     11, 99,
                                     crapass.cdtipcta),
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
              cdtipcta
     order by cdagenci,
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
  -- Defini��o da tabela para armazenar os tipos de conta
  type typ_tab_tipo is table of typ_tipo index by binary_integer;
  -- Inst�ncia da tabela. O �ndice � o tipo de conta
  vr_tab_tipo      typ_tab_tipo;
  -- �ndice para leitura da PL/Table
  vr_ind           binary_integer;
  -- C�digo do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%type;
  -- Nome dos meses que ser�o calculados
  vr_dsmes1        varchar2(15);
  vr_dsmes2        varchar2(15);
  vr_dsmes3        varchar2(15);
  -- Controle da quebra do relat�rio
  vr_cdagenci      crapage.cdagenci%type := 0;
  -- Vari�veis para armazenar o total por ag�ncia
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
  -- Vari�vel para armazenar as informa��es em XML
  vr_des_xml       clob;
  -- Vari�vel para o caminho e nome do arquivo base
  vr_nom_diretorio varchar2(200);
  vr_nom_arquivo   varchar2(200);
  -- Subrotina para escrever texto na vari�vel CLOB do XML
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
  -- Se n�o encontrar
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor pois haver� raise
    CLOSE cr_crapcop;
    -- Montar mensagem de critica
    vr_cdcritic := 651;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;
  END IF;

  -- Valida��es iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);
  -- Se a variavel de erro � <> 0
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  -- Incluir nome do m�dulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS016',
                             pr_action => vr_cdprogra);
  -- Leitura do calend�rio da cooperativa
  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat
   INTO rw_crapdat;
  -- Se n�o encontrar
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

  -- Identificar os meses que ser�o utilizados para calcular a m�dia
  vr_dsmes1 := gene0001.vr_vet_nmmesano(to_char(vr_dtmvtolt, 'mm'));
  vr_dsmes2 := gene0001.vr_vet_nmmesano(to_char(add_months(vr_dtmvtolt, -1), 'mm'));
  vr_dsmes3 := gene0001.vr_vet_nmmesano(to_char(add_months(vr_dtmvtolt, -2), 'mm'));
  -- Buscar a descri��o dos tipos de contas e armazenar em PL/Table
  for rw_craptip in cr_craptip (pr_cdcooper) loop
    -- Se for conta conv�nio, inclui o c�digo do banco na descri��o, para diferenciar
    if rw_craptip.cdtipcta in (8, 9, 10, 11) then
      vr_tab_tipo(rw_craptip.cdtipcta).vr_dstipcta := rw_craptip.dstipcta||' (756)';
      vr_tab_tipo(rw_craptip.cdtipcta+88).vr_dstipcta := rw_craptip.dstipcta||' (085)';
    else
      vr_tab_tipo(rw_craptip.cdtipcta).vr_dstipcta := rw_craptip.dstipcta;
    end if;
  end loop;
  -- Inicializar o CLOB para armazenar o arquivo XML
  vr_des_xml := null;
  dbms_lob.createtemporary(vr_des_xml, true);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  -- Inicilizar as informa��es do XML
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps016>');
  pc_escreve_xml('<dsmes1>'||vr_dsmes1||'</dsmes1>'||
                 '<dsmes2>'||vr_dsmes2||'</dsmes2>'||
                 '<dsmes3>'||vr_dsmes3||'</dsmes3>');
  -- Leitura dos totais de saldo em conta-corrente por tipo de conta
  for rw_crapsld in cr_crapsld (pr_cdcooper,
                                vr_dtmvtolt) loop
    -- Verifica se � uma nova ag�ncia para incluir informa��es de quebra
    if rw_crapsld.cdagenci <> vr_cdagenci then
      open cr_crapage (pr_cdcooper,
                       rw_crapsld.cdagenci);
        fetch cr_crapage into rw_crapage;
        -- Se n�o encontrar a ag�ncia, gera erro e finaliza execu��o
        if cr_crapage%notfound then
          close cr_crapage;
          pr_cdcritic := 15;
          raise vr_exc_saida;
        end if;
      close cr_crapage;
      -- Se n�o � a primeira ag�ncia, inclui os totais fecha a quebra anterior
      if vr_cdagenci <> 0 then
        pc_escreve_xml('<qtativos_tot>'||to_char(vr_qtativo, 'fm999G990')||'</qtativos_tot>'||
                       '<qtdemitidos_tot>'||to_char(vr_qtdemitido, 'fm999G990')||'</qtdemitidos_tot>'||
                       '<vltsalan_tot>'||to_char(vr_vltsalan, 'fm999G999G990')||'</vltsalan_tot>'||
                       '<vlstotal_tot>'||to_char(vr_vlstotal, 'fm999G999G990')||'</vlstotal_tot>'||
                       '<vlprimes_tot>'||to_char(vr_vlprimes, 'fm999G999G990')||'</vlprimes_tot>'||
                       '<vlsegmes_tot>'||to_char(vr_vlsegmes, 'fm999G999G990')||'</vlsegmes_tot>'||
                       '<vltermes_tot>'||to_char(vr_vltermes, 'fm999G999G990')||'</vltermes_tot>');
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
    -- Inclui a linha no XML
    pc_escreve_xml('<tipo dstipcta="'||vr_tab_tipo(rw_crapsld.cdtipcta).vr_dstipcta||'">'||
                     '<qtativos>'||to_char(rw_crapsld.ativo, 'fm999G990')||'</qtativos>'||
                     '<qtdemitidos>'||to_char(rw_crapsld.demitido, 'fm999G990')||'</qtdemitidos>'||
                     '<vltsalan>'||to_char(rw_crapsld.vltsalan, 'fm999G999G990')||'</vltsalan>'||
                     '<vlstotal>'||to_char(rw_crapsld.vlstotal, 'fm999G999G990')||'</vlstotal>'||
                     '<vlprimes>'||to_char(rw_crapsld.vlprimes, 'fm999G999G990')||'</vlprimes>'||
                     '<vlsegmes>'||to_char(rw_crapsld.vlsegmes, 'fm999G999G990')||'</vlsegmes>'||
                     '<vltermes>'||to_char(rw_crapsld.vltermes, 'fm999G999G990')||'</vltermes>'||
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
    vr_tab_tipo(rw_crapsld.cdtipcta).vr_qtativo := nvl(vr_tab_tipo(rw_crapsld.cdtipcta).vr_qtativo, 0) + rw_crapsld.ativo;
    vr_tab_tipo(rw_crapsld.cdtipcta).vr_qtdemitido := nvl(vr_tab_tipo(rw_crapsld.cdtipcta).vr_qtdemitido, 0) + rw_crapsld.demitido;
    vr_tab_tipo(rw_crapsld.cdtipcta).vr_vltsalan := nvl(vr_tab_tipo(rw_crapsld.cdtipcta).vr_vltsalan, 0) + rw_crapsld.vltsalan;
    vr_tab_tipo(rw_crapsld.cdtipcta).vr_vlstotal := nvl(vr_tab_tipo(rw_crapsld.cdtipcta).vr_vlstotal, 0) + rw_crapsld.vlstotal;
    vr_tab_tipo(rw_crapsld.cdtipcta).vr_vlprimes := nvl(vr_tab_tipo(rw_crapsld.cdtipcta).vr_vlprimes, 0) + rw_crapsld.vlprimes;
    vr_tab_tipo(rw_crapsld.cdtipcta).vr_vlsegmes := nvl(vr_tab_tipo(rw_crapsld.cdtipcta).vr_vlsegmes, 0) + rw_crapsld.vlsegmes;
    vr_tab_tipo(rw_crapsld.cdtipcta).vr_vltermes := nvl(vr_tab_tipo(rw_crapsld.cdtipcta).vr_vltermes, 0) + rw_crapsld.vltermes;
  end loop;
  -- Verifica se gerou informa��o no arquivo
  if vr_cdagenci <> 0 then
    -- Inclui os totais da �ltima ag�ncia e fecha a quebra
    pc_escreve_xml('<qtativos_tot>'||to_char(vr_qtativo, 'fm999G990')||'</qtativos_tot>'||
                   '<qtdemitidos_tot>'||to_char(vr_qtdemitido, 'fm999G990')||'</qtdemitidos_tot>'||
                   '<vltsalan_tot>'||to_char(vr_vltsalan, 'fm999G999G990')||'</vltsalan_tot>'||
                   '<vlstotal_tot>'||to_char(vr_vlstotal, 'fm999G999G990')||'</vlstotal_tot>'||
                   '<vlprimes_tot>'||to_char(vr_vlprimes, 'fm999G999G990')||'</vlprimes_tot>'||
                   '<vlsegmes_tot>'||to_char(vr_vlsegmes, 'fm999G999G990')||'</vlsegmes_tot>'||
                   '<vltermes_tot>'||to_char(vr_vltermes, 'fm999G999G990')||'</vltermes_tot>');
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
      -- Trata o registro somente se houver algum valor
      if nvl(vr_tab_tipo(vr_ind).vr_qtativo, 0) <> 0 or
         nvl(vr_tab_tipo(vr_ind).vr_qtdemitido, 0) <> 0 or
         nvl(vr_tab_tipo(vr_ind).vr_vltsalan, 0) <> 0 or
         nvl(vr_tab_tipo(vr_ind).vr_vlstotal, 0) <> 0 or
         nvl(vr_tab_tipo(vr_ind).vr_vlprimes, 0) <> 0 or
         nvl(vr_tab_tipo(vr_ind).vr_vlsegmes, 0) <> 0 or
         nvl(vr_tab_tipo(vr_ind).vr_vltermes, 0) <> 0 then
        -- Inclui a linha no XML
        pc_escreve_xml('<tipo dstipcta="'||vr_tab_tipo(vr_ind).vr_dstipcta||'">'||
                         '<qtativos>'||to_char(vr_tab_tipo(vr_ind).vr_qtativo, 'fm999G990')||'</qtativos>'||
                         '<qtdemitidos>'||to_char(vr_tab_tipo(vr_ind).vr_qtdemitido, 'fm999G990')||'</qtdemitidos>'||
                         '<vltsalan>'||to_char(vr_tab_tipo(vr_ind).vr_vltsalan, 'fm999G999G990')||'</vltsalan>'||
                         '<vlstotal>'||to_char(vr_tab_tipo(vr_ind).vr_vlstotal, 'fm999G999G990')||'</vlstotal>'||
                         '<vlprimes>'||to_char(vr_tab_tipo(vr_ind).vr_vlprimes, 'fm999G999G990')||'</vlprimes>'||
                         '<vlsegmes>'||to_char(vr_tab_tipo(vr_ind).vr_vlsegmes, 'fm999G999G990')||'</vlsegmes>'||
                         '<vltermes>'||to_char(vr_tab_tipo(vr_ind).vr_vltermes, 'fm999G999G990')||'</vltermes>'||
                       '</tipo>');
        -- Soma os totais
        vr_qtativo := vr_qtativo + vr_tab_tipo(vr_ind).vr_qtativo;
        vr_qtdemitido := vr_qtdemitido + vr_tab_tipo(vr_ind).vr_qtdemitido;
        vr_vltsalan := vr_vltsalan + vr_tab_tipo(vr_ind).vr_vltsalan;
        vr_vlstotal := vr_vlstotal + vr_tab_tipo(vr_ind).vr_vlstotal;
        vr_vlprimes := vr_vlprimes + vr_tab_tipo(vr_ind).vr_vlprimes;
        vr_vlsegmes := vr_vlsegmes + vr_tab_tipo(vr_ind).vr_vlsegmes;
        vr_vltermes := vr_vltermes + vr_tab_tipo(vr_ind).vr_vltermes;
      end if;
      -- Passa para o pr�ximo registro da PL/Table
      vr_ind := vr_tab_tipo.next(vr_ind);
    end loop;
    -- Inclui os totais do resumo e fecha a quebra
    pc_escreve_xml('<qtativos_tot>'||to_char(vr_qtativo, 'fm999G990')||'</qtativos_tot>'||
                   '<qtdemitidos_tot>'||to_char(vr_qtdemitido, 'fm999G990')||'</qtdemitidos_tot>'||
                   '<vltsalan_tot>'||to_char(vr_vltsalan, 'fm999G999G990')||'</vltsalan_tot>'||
                   '<vlstotal_tot>'||to_char(vr_vlstotal, 'fm999G999G990')||'</vlstotal_tot>'||
                   '<vlprimes_tot>'||to_char(vr_vlprimes, 'fm999G999G990')||'</vlprimes_tot>'||
                   '<vlsegmes_tot>'||to_char(vr_vlsegmes, 'fm999G999G990')||'</vlsegmes_tot>'||
                   '<vltermes_tot>'||to_char(vr_vltermes, 'fm999G999G990')||'</vltermes_tot>');
    pc_escreve_xml('</agencia>');
  end if;
  -- Fecha a tag principal para encerrar o XML
  pc_escreve_xml('</crps016>');
  -- Busca do diret�rio base da cooperativa
  vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                            pr_cdcooper => pr_cdcooper,
                                            pr_nmsubdir => '/rl'); --> Utilizaremos o rl
  -- Executa o relat�rio com os maiores saldos
  vr_nom_arquivo := 'crrl021';
  -- Chamada do iReport para gerar o arquivo de sa�da
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                              pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                              pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                              pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                              pr_dsxmlnode => '/crps016/agencia/tipo',  --> N� base do XML para leitura dos dados
                              pr_dsjasper  => 'crrl021.jasper',    --> Arquivo de layout do iReport
                              pr_dsparams  => null,                --> Enviar como par�metro apenas a ag�ncia
                              pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo||'.lst', --> Arquivo final
                              pr_flg_gerar => 'N',
                              pr_qtcoluna  => 132,
                              pr_sqcabrel  => 1,
                              pr_flg_impri => 'S',    --> Chamar a impress�o (Imprim.p)
                              pr_nmformul  => '',     --> Nome do formul�rio para impress�o
                              pr_nrcopias  => 1,      --> N�mero de c�pias para impress�o
                              pr_des_erro  => vr_dscritic);       --> Sa�da com erro

  -- Liberando a mem�ria alocada para os CLOBs
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);
  -- Testar se houve erro
  -- Verifica se ocorreu erro na gera��o do arquivo ou na solicita��o do relat�rio
  if vr_dscritic is not null then
    raise vr_exc_saida;
  end if;

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informa��es atualizada
  COMMIT;
EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas c�digo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descri��o
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
    -- Se foi retornado apenas c�digo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descri��o
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos c�digo e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;

  WHEN OTHERS THEN
    -- Efetuar retorno do erro n�o tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;
END;
/

