CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS155(pr_cdcooper in craptab.cdcooper%type
                                      ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic out crapcri.cdcritic%type
                                      ,pr_dscritic out varchar2) as
/* ..........................................................................

   Programa: PC_CRPS155 (Antigo Fontes/crps155.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Janeiro/95.                     Ultima atualizacao: 26/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 002.
               Emite listagem das POUPANCAS PROGRAMADAS RDCA por agencia.
               Relatorio 124

   Observacao: Para que haja o pedido de impressao do relatorio para a agencia
               devera existir a seguinte tabela CRED-GENERI-0-IMPREL124-agencia
               onde o texto da tabela informa os dias que deve ser impresso o
               relatorio.

   Alteracoes: 03/06/96 - Acerto no total (Deborah).

               09/07/96 - Alterado para listar tambem a agencia 3 (Deborah).

               17/09/96 - Alterado para listar somente as agencias cadastradas
                          na tabela de impressao (Odair).

               03/01/97 - Alterar a tabela de tratamento das poupancas programa-
                          das para tpregist = 2 para nao confiltar com programa
                          109 (Odair).

               26/01/2000 - Gerar pedidos de impressao (Deborah).

               02/10/2003 - Imprimir somente 1 via do relatorio (Ze Eduardo).

               06/10/2003 - Eliminar a tabela DESPESA (Deborah).

               17/10/2003 - Tratamento para calculo do VAR (Margarete).

               28/09/2004 - Aumentado nro digitos nrctrrpp(Mirtes).

               29/09/2004 - Gravacao de dados na tabela gninfpl do banco
                            generico, para relatorios gerenciais (Junior).

               29/06/2005 - Alimentado campo cdcooper das tabelas crapvar e
                            craptab (Diego).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               31/03/2006 - Corrigir rotina de impressao do relatorio 124
                            (Junior).

               09/04/2008 - Alterado formato do campo "craprpp.qtprepag" e da
                            variável "apl_qtprepag" de "999" para "zz9" no FORM
                            (Kbase IT Solutions - Paulo Ricardo Maciel).
                          - Situacao = 5 -> Resgate (Guilherme).

               20/08/2008 - Desprezar poupancas para o VAR com saldo
                            zerado (Magui).

               05/02/2013 - Conversão Progress >> Oracle PL/SQL (Daniel-Supero)

               11/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                            das criticas e chamadas a fimprg.p (Douglas Pagel).

               26/11/2013 - Correção na fn_imprime onde a função poderia retornar
                            sem retorno algum, gerando erro (Marcos-Supero)

               10/02/2014 - Inclusão da chamada a fimprg e também da formatação
                            de alguns campos. (Marcos-Supero)

               18/02/2014 - Alterado totalizador de PAs de 99 para 999. (Gabriel)

               26/05/2014 - Nao utilizar mais a tabela CRAPVAR (desativacao da VAR). (Andrino-RKAM)

               14/11/2014 - Foi retirada a procedure interna que gerava o XML. A geração ocorre
                            através da gene0002.pc_escreve_xml. (Alisson - AMcom)



............................................................................. */
/****** Decisoes sobre o VAR ************************************************
Poupanca programada sera mensal com taxa provisoria senao houver mensal
*****************************************************************************/
  -- Data do movimento
  cursor cr_crapdat(pr_cdcooper in craptab.cdcooper%type) is
    select dat.inproces,
           dat.dtmvtolt,
           dat.dtmvtopr
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
  -- Dados da cooperativa
  cursor cr_crapcop(pr_cdcooper in craptab.cdcooper%type) is
    select 1
      from crapcop
     where crapcop.cdcooper = pr_cdcooper;
  rw_crapcop    cr_crapcop%rowtype;
  -- Buscar o percentual de IR da aplicação
  cursor cr_craptab is
    select craptab.dstextab
      from craptab
     where craptab.cdcooper = pr_cdcooper
       and upper(craptab.nmsistem) = 'CRED'
       and craptab.cdempres = 0
       and upper(craptab.tptabela) = 'CONFIG'
       and upper(craptab.cdacesso) = 'PERCIRAPLI'
       and craptab.tpregist = 0;
  rw_craptab   cr_craptab%rowtype;
  -- Informações da poupança programada
  cursor cr_craprpp(pr_cdcooper in craptab.cdcooper%type) is
    select /*+ index(craprpp craprpp##craprpp2)*/
           craprpp.rowid,
           craprpp.cdsitrpp,
           decode(craprpp.cdsitrpp,
                  1, 'ATIVO',
                  2, 'SUSPENSO',
                  3, 'CANCELADO',
                  4, 'CANCELADO',
                  5, 'VENCIDA',
                  ' ') dssituac,
           craprpp.nrdconta,
           craprpp.dtiniper,
           craprpp.nrctrrpp,
           craprpp.dtdebito,
           craprpp.vlprerpp,
           craprpp.qtprepag,
           craprpp.dtfimper
      from craprpp
     where craprpp.cdcooper = pr_cdcooper;
  -- Informações do associado
  cursor cr_crapass(pr_cdcooper in craptab.cdcooper%TYPE) is
    select crapage.cdagenci,
           crapass.nrdconta,
           decode(crapass.nrramemp,0,null,crapass.nrramemp) nrramemp,
           crapass.nmprimtl,
           crapass.cdsitdct,
           crapass.cdtipcta,
           crapage.nmresage
      from crapass
         , crapage
     where crapage.cdcooper(+) = crapass.cdcooper
       AND crapage.cdagenci(+) = crapass.cdagenci
       AND crapass.cdcooper = pr_cdcooper;
  -- Buscar as taxas a serem aplicadas
  cursor cr_craptrd (pr_dtiniper in craprpp.dtiniper%type,
                     pr_vlsdrdpp in craprpp.vlsdrdpp%type) is
    select txofidia,
           txprodia
      from craptrd
     where craptrd.cdcooper = 1
       and craptrd.dtiniper = pr_dtiniper
       and craptrd.tptaxrda = 2
       and craptrd.incarenc = 0
       and craptrd.vlfaixas <= pr_vlsdrdpp
     ORDER BY craptrd.progress_recid;
  -- Cursor alternativo para buscar as taxas, caso o primeiro não retorne informação
  cursor cr_craptrd2 (pr_vlsdrdpp in craprpp.vlsdrdpp%type) is
    select txofidia,
           txprodia
      from craptrd
     where craptrd.cdcooper = 1
       and craptrd.tptaxrda = 2
       and craptrd.incarenc = 0
       and craptrd.vlfaixas <= pr_vlsdrdpp
     order BY craptrd.progress_recid desc;
  -- Registro para armazenar o resultado dos dois cursores acima
  rw_craptrd    cr_craptrd%rowtype;
  /* Registro para armazenar informações das aplicações */
  type typ_aplicacao is record (nrdconta craprpp.nrdconta%type,
                                nrctrrpp craprpp.nrctrrpp%type,
                                diapoupa number(2),
                                nrramemp crapass.nrramemp%type,
                                vlprerpp craprpp.vlprerpp%type,
                                qtprepag craprpp.qtprepag%type,
                                vlsldapl craprpp.vlsdrdpp%type,
                                nmprimtl crapass.nmprimtl%type,
                                dsdacstp varchar2(3),
                                dssituac varchar2(10));
  /* Tabela onde serão armazenados os registros das aplicações */
  /* O índice da tabela será o número da conta concatenado com o número da conta rpp */
  type typ_tab_aplicacao is table of typ_aplicacao index by varchar2(20);
  /* Registro para armazenar as informações da agência */
  type typ_agencia is record (cdagenci       crapass.cdagenci%type,
                              nmresage       crapage.nmresage%type,
                              tab_aplicacao  typ_tab_aplicacao, /* Instância da tabela de aplicações */
                              qtaplica       number(7),
                              vlprerpp       craprpp.vlprerpp%type,
                              vlsldapl       craprpp.vlsdrdpp%type);
  /* Tabela onde serão armazenados os registros da agência */
  /* O índice da tabela será o código da agência */
  type typ_tab_agencia is table of typ_agencia index by binary_integer;
  /* Instância da tabela */
  vr_tab_agencia   typ_tab_agencia;
  /* Tabela de dados para melhora de performance */
  type typ_reg_crapass is record (cdagenci crapass.cdagenci%TYPE,
                                  nrdconta crapass.nrdconta%TYPE,
                                  nrramemp crapass.nrramemp%TYPE,
                                  nmprimtl crapass.nmprimtl%TYPE,
                                  cdsitdct crapass.cdsitdct%TYPE,
                                  cdtipcta crapass.cdtipcta%TYPE,
                                  nmresage crapage.nmresage%TYPE);
  type typ_tab_reg_crapass is table of typ_reg_crapass
                             index by Binary_Integer; --cta(10)
  vr_tab_crapass typ_tab_reg_crapass;
  --
  -- Exception para tratamento de erros tratáveis sem abortar a execução
  vr_exc_mensagem  exception;
  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Data do movimento
  vr_inproces      crapdat.inproces%type;
  vr_dtmvtolt      crapdat.dtmvtolt%type;
  vr_dtmvtopr      crapdat.dtmvtopr%type;
  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);
  -- Variáveis utilizadas para auxiliar o processamento das informações
  vr_vlsdrdpp      NUMBER; -- craprpp.vlsdrdpp%type;
  vr_nmresage      crapage.nmresage%type;
  vr_txaplica      NUMBER; --craptrd.txofidia%type;
  vr_dtcalcul      craprpp.dtiniper%type;
  vr_vltotren      NUMBER; -- craprpp.vlsdrdpp%type;
  vr_dtdpagto      craprpp.dtiniper%type;
  vr_vlrendim      NUMBER; --craprpp.vlsdrdpp%type;
  -- Variáveis para armazenar as informações em XML
  --vr_xmltype       xmltype;
  vr_des_xml       clob;
  vr_dstexto       varchar2(32700);
  -- Variável para o caminho e nome do arquivo base
  vr_nom_diretorio varchar2(200);
  vr_nom_arquivo   varchar2(200);
  -- Índices para leitura das pl/tables ao gerar o XML
  vr_indice_agencia    number(10);
  vr_indice_aplicacao  varchar2(20);
  -- Função que define se o relatório deve ser impresso ou somente deve gerar o arquivo LST
  function fn_imprime(pr_cdagenci in number) return varchar2 is
    cursor cr_craptab2 is
      select craptab.dstextab
        from craptab
       where craptab.cdcooper = pr_cdcooper
         and upper(craptab.nmsistem) = 'CRED'
         and craptab.cdempres = 0
         and upper(craptab.tptabela) = 'GENERI'
         and upper(craptab.cdacesso) = 'IMPREL124'
         and craptab.tpregist = pr_cdagenci;
    rw_craptab2     cr_craptab2%rowtype;
  begin
    if to_char(vr_dtmvtolt, 'mmyyyy') <> to_char(vr_dtmvtopr, 'mmyyyy') then
      -- No processo mensal, imprime para todas as agências
      return('S');
    else
      -- Caso contrário, verifica se foi parametrizado para imprimir
      open cr_craptab2;
      fetch cr_craptab2 into rw_craptab2;
      if cr_craptab2%notfound then
        close cr_craptab2;
        return('N');
      else
        if trim(rw_craptab2.dstextab) like '%'||to_char(vr_dtmvtolt, 'd')||'%' then
          close cr_craptab2;
          return('S');
        else
          close cr_craptab2;
          return('N');
        end if;
      end if;
    end if;
  end;
  --
begin
  -- Define o ponto de início da transação, para poder desfazer o processo, caso necessário
  savepoint trans_poup;
  -- Nome do programa
  vr_cdprogra := 'CRPS155';
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS155',
                             pr_action => vr_cdprogra);

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
  -- Buscar o percentual de IR da aplicação
  open cr_craptab;
    fetch cr_craptab into rw_craptab;
  close cr_craptab;
  -- Buscar a data do movimento
  open cr_crapdat(pr_cdcooper);
    fetch cr_crapdat into vr_inproces,
                          vr_dtmvtolt,
                          vr_dtmvtopr;
  close cr_crapdat;

  -- Buscar os dados da cooperativa
  open cr_crapcop(pr_cdcooper);
    fetch cr_crapcop into rw_crapcop;
    if cr_crapcop%notfound then
      close cr_crapcop;
      vr_cdcritic := 651;
      raise vr_exc_saida;
    end if;
  close cr_crapcop;

  -- Buscar todos os associados e incluir no registro de memória
  FOR rg_crapass IN cr_crapass(pr_cdcooper) LOOP
    vr_tab_crapass(rg_crapass.nrdconta).cdagenci := rg_crapass.cdagenci;
    vr_tab_crapass(rg_crapass.nrdconta).nrdconta := rg_crapass.nrdconta;
    vr_tab_crapass(rg_crapass.nrdconta).nrramemp := rg_crapass.nrramemp;
    vr_tab_crapass(rg_crapass.nrdconta).nmprimtl := rg_crapass.nmprimtl;
    vr_tab_crapass(rg_crapass.nrdconta).cdsitdct := rg_crapass.cdsitdct;
    vr_tab_crapass(rg_crapass.nrdconta).cdtipcta := rg_crapass.cdtipcta;
    vr_tab_crapass(rg_crapass.nrdconta).nmresage := NVL(TRIM(rg_crapass.nmresage),'***************');
  END LOOP;

  -- Leitura das poupanças programadas
  for rw_craprpp in cr_craprpp(pr_cdcooper) loop
    -- Executa cálculo de poupança (antigo poupanca.i)
    apli0001.pc_calc_poupanca (pr_cdcooper => pr_cdcooper,
                               pr_dstextab => rw_craptab.dstextab,
                               pr_cdprogra => vr_cdprogra,
                               pr_inproces => vr_inproces,
                               pr_dtmvtolt => vr_dtmvtolt,
                               pr_dtmvtopr => vr_dtmvtopr,
                               pr_rpp_rowid => rw_craprpp.rowid,
                               pr_vlsdrdpp => vr_vlsdrdpp,
                               pr_cdcritic => vr_cdcritic,
                               pr_des_erro => vr_dscritic);
    if vr_dscritic is not null or vr_cdcritic is not null then
      raise vr_exc_saida;
    end if;
    -- Verifica o saldo e a situação da poupança programada
    if (vr_vlsdrdpp = 0 and (rw_craprpp.cdsitrpp = 3 or rw_craprpp.cdsitrpp = 4 or rw_craprpp.cdsitrpp = 5)) or
       vr_vlsdrdpp < 0 then
      -- Descarta o registro e passa para a próxima iteração do loop
      continue;
    end if;
    -- Buscar informações do associado
    IF NOT vr_tab_crapass.EXISTS(rw_craprpp.nrdconta) THEN
      vr_cdcritic := 251; -- 251 - Associado nao encontrado no crapass. ERRO DE SISTEMA.
      raise vr_exc_saida;
    END IF;

    -- Cabeçalho agência
    vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).cdagenci := vr_tab_crapass(rw_craprpp.nrdconta).cdagenci;
    vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).nmresage := vr_tab_crapass(rw_craprpp.nrdconta).nmresage;
    -- Aplicações
    vr_indice_aplicacao := lpad(rw_craprpp.nrdconta, 10, '0')||lpad(rw_craprpp.nrctrrpp, 10, '0');
    vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).tab_aplicacao(vr_indice_aplicacao).nrdconta := rw_craprpp.nrdconta;
    vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).tab_aplicacao(vr_indice_aplicacao).nrctrrpp := rw_craprpp.nrctrrpp;
    vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).tab_aplicacao(vr_indice_aplicacao).diapoupa := to_number(to_char(rw_craprpp.dtdebito, 'dd'));
    vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).tab_aplicacao(vr_indice_aplicacao).nrramemp := vr_tab_crapass(rw_craprpp.nrdconta).nrramemp;
    vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).tab_aplicacao(vr_indice_aplicacao).vlprerpp := rw_craprpp.vlprerpp;
    vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).tab_aplicacao(vr_indice_aplicacao).qtprepag := rw_craprpp.qtprepag;
    vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).tab_aplicacao(vr_indice_aplicacao).vlsldapl := vr_vlsdrdpp;
    vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).tab_aplicacao(vr_indice_aplicacao).nmprimtl := vr_tab_crapass(rw_craprpp.nrdconta).nmprimtl;
    vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).tab_aplicacao(vr_indice_aplicacao).dsdacstp := to_char(vr_tab_crapass(rw_craprpp.nrdconta).cdsitdct)||lpad(to_char(vr_tab_crapass(rw_craprpp.nrdconta).cdtipcta), 2, '0');
    vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).tab_aplicacao(vr_indice_aplicacao).dssituac := rw_craprpp.dssituac;
    -- Acumula os totalizadores
    if vr_vlsdrdpp > 0 then
      vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).qtaplica := nvl(vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).qtaplica, 0) + 1;
    end if;
    if rw_craprpp.cdsitrpp = 1 then
      vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).vlprerpp := nvl(vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).vlprerpp, 0) + rw_craprpp.vlprerpp;
    end if;
    vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).vlsldapl := nvl(vr_tab_agencia(vr_tab_crapass(rw_craprpp.nrdconta).cdagenci).vlsldapl, 0) + vr_vlsdrdpp;
    -- Criando base para calculo do VAR
    if vr_vlsdrdpp <= 0 then
      -- Não calcula e passa para o próximo registro
      continue;
    end if;
    -- Buscar as taxas a serem aplicadas
    open cr_craptrd (rw_craprpp.dtiniper,
                     vr_vlsdrdpp);
      fetch cr_craptrd into rw_craptrd;
      if cr_craptrd%notfound then
        open cr_craptrd2 (vr_vlsdrdpp);
          fetch cr_craptrd2 into rw_craptrd;
          if cr_craptrd2%notfound then
            close cr_craptrd;
            close cr_craptrd2;
            vr_cdcritic := 347;
            vr_dscritic := gene0001.fn_busca_critica(347)||
                           ' Data: '||to_char(rw_craprpp.dtiniper, 'dd/mm/yyyy')||
                           ' Conta: '||rw_craprpp.nrdconta||
                           ' Poup: '||rw_craprpp.nrctrrpp;
            raise vr_exc_saida;
          end if;
        close cr_craptrd2;
      end if;
    close cr_craptrd;
    -- Define qual taxa utilizar
    if rw_craptrd.txofidia > 0 then
      vr_txaplica := rw_craptrd.txofidia / 100;
    else
      if rw_craptrd.txprodia > 0 then
        vr_txaplica := rw_craptrd.txprodia / 100;
      else
        vr_cdcritic := 427;
        vr_dscritic := gene0001.fn_busca_critica(427)||
                       ' Data: '||to_char(rw_craprpp.dtiniper, 'dd/mm/yyyy')||
                       ' Conta: '||rw_craprpp.nrdconta||
                       ' Poup: '||rw_craprpp.nrctrrpp;
        raise vr_exc_saida;
      end if;
    end if;
    --
    vr_dtcalcul := rw_craprpp.dtiniper;
    vr_vltotren := vr_vlsdrdpp;
    --
    while vr_dtcalcul < rw_craprpp.dtfimper loop
      -- Busca o próximo dia útil
      vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper,
                                                 vr_dtcalcul);

      -- Verifica novamente a data - Renato Darosci - 19/03/2014
      EXIT WHEN vr_dtcalcul >= rw_craprpp.dtfimper;

      -- Acumula os valores
      vr_vlrendim := trunc(APLI0001.fn_round(vr_vltotren * vr_txaplica,10), 8);
      vr_vltotren := vr_vltotren + vr_vlrendim;
      -- Incrementa a data
      vr_dtcalcul := vr_dtcalcul + 1;
    end loop;
    --
    if rw_craprpp.dtfimper < vr_dtmvtopr then
      vr_dtdpagto := vr_dtmvtopr;
    else
      vr_dtdpagto := rw_craprpp.dtfimper;
    end if;
    --
  end loop;

  -- *******************
  -- Leitura da PL/Table e geração do XML para o relatório
  -- *******************
  -- Busca do diretório base da cooperativa
  vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                            pr_cdcooper => pr_cdcooper,
                                            pr_nmsubdir => '/rl'); --> Utilizaremos o rl
  --
  vr_indice_agencia := vr_tab_agencia.first;
  -- Se houver informação, deve criar o arquivo
  if vr_indice_agencia is not null then
    while vr_indice_agencia is not null loop
      -- Deve gerar um arquivo para cada agência
      -- Inicializar o CLOB
      vr_des_xml := null;
      vr_dstexto := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?>');
      -- Início da leitura das informações
      -- Incluir o cabeçalho
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                    '<agencia cdagenci="'||vr_indice_agencia||'">'||
                       '<nmresage>'||vr_tab_agencia(vr_indice_agencia).nmresage||'</nmresage>'||
                       '<qtaplica>'||to_char(vr_tab_agencia(vr_indice_agencia).qtaplica, '9G999G990')||'</qtaplica>'||
                       '<vlprerpp>'||to_char(vr_tab_agencia(vr_indice_agencia).vlprerpp, '999G999G999G990D00')||'</vlprerpp>'||
                       '<vlsldapl>'||to_char(vr_tab_agencia(vr_indice_agencia).vlsldapl, '999G999G999G990D00')||'</vlsldapl>');
      -- Inclui os dados das contas (tab_aplicacao)
      vr_indice_aplicacao := vr_tab_agencia(vr_indice_agencia).tab_aplicacao.first;
      while vr_indice_aplicacao is not null loop
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
                      '<conta nrdconta="'||to_char(vr_tab_agencia(vr_indice_agencia).tab_aplicacao(vr_indice_aplicacao).nrdconta, 'fm9G999G999G9')||'">'||
                         '<dsdacstp>'||vr_tab_agencia(vr_indice_agencia).tab_aplicacao(vr_indice_aplicacao).dsdacstp||'</dsdacstp>'||
                         '<nmprimtl>'||SUBSTR(vr_tab_agencia(vr_indice_agencia).tab_aplicacao(vr_indice_aplicacao).nmprimtl,0,40)||'</nmprimtl>'||
                         '<nrramemp>'||to_char(vr_tab_agencia(vr_indice_agencia).tab_aplicacao(vr_indice_aplicacao).nrramemp, '9999')||'</nrramemp>'||
                         '<nrctrrpp>'||to_char(vr_tab_agencia(vr_indice_agencia).tab_aplicacao(vr_indice_aplicacao).nrctrrpp, 'fm9999G999')||'</nrctrrpp>'||
                         '<diapoupa>'||to_char(vr_tab_agencia(vr_indice_agencia).tab_aplicacao(vr_indice_aplicacao).diapoupa, '00')||'</diapoupa>'||
                         '<vlprerpp>'||to_char(vr_tab_agencia(vr_indice_agencia).tab_aplicacao(vr_indice_aplicacao).vlprerpp, '9G999G990D00')||'</vlprerpp>'||
                         '<qtprepag>'||to_char(vr_tab_agencia(vr_indice_agencia).tab_aplicacao(vr_indice_aplicacao).qtprepag, '990')||'</qtprepag>'||
                         '<dssituac>'||vr_tab_agencia(vr_indice_agencia).tab_aplicacao(vr_indice_aplicacao).dssituac||'</dssituac>'||
                         '<vlsldapl>'||to_char(vr_tab_agencia(vr_indice_agencia).tab_aplicacao(vr_indice_aplicacao).vlsldapl, '9G999G990D00')||'</vlsldapl>'||
                      '</conta>');
        vr_indice_aplicacao := vr_tab_agencia(vr_indice_agencia).tab_aplicacao.next(vr_indice_aplicacao);
      end loop;
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</agencia>',true);
      -- Nome base do arquivo é crrl124_
      vr_nom_arquivo := 'crrl124_'||to_char(vr_indice_agencia, 'fm009');
      -- Gerar o arquivo de XML com mesmo nome e na mesma pasta do arquivo de saída
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                  pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                  pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                                  pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                                  pr_dsxmlnode => '/agencia/conta',    --> Nó base do XML para leitura dos dados
                                  pr_dsjasper  => 'crrl124.jasper',    --> Arquivo de layout do iReport
                                  pr_dsparams  => null,                --> Enviar como parâmetro apenas a agência
                                  pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo||'.lst', --> Arquivo final com código da agência
                                  pr_flg_gerar => 'N',
                                  pr_qtcoluna  => 132,
                                  pr_flg_impri => fn_imprime(vr_indice_agencia),    --> Chamar a impressão (Imprim.p)
                                  pr_nmformul  => '132dm',             --> Nome do formulário para impressão
                                  pr_nrcopias  => 1,                   --> Número de cópias para impressão
                                  pr_des_erro  => vr_dscritic);        --> Saída com erro
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      -- Limpar variavel texto do clob
      vr_dstexto:= NULL;
      -- Testar se houve erro
      if vr_dscritic is not null then
        -- Gerar exceção
        vr_cdcritic := 0;
        raise vr_exc_saida;
      end if;
      -- Gravacao de dados no banco GENERICO - Relatorios Gerenciais
      begin
        update gninfpl
           set vltotppr = vr_tab_agencia(vr_indice_agencia).vlsldapl
         where gninfpl.cdcooper = pr_cdcooper
           and gninfpl.cdagenci = vr_indice_agencia
           and gninfpl.dtmvtolt = vr_dtmvtolt;
        if sql%rowcount = 0 then
          begin
            insert into gninfpl (cdcooper,
                                 cdagenci,
                                 dtmvtolt,
                                 vltotppr)
            values (pr_cdcooper,
                    vr_indice_agencia,
                    vr_dtmvtolt,
                    vr_tab_agencia(vr_indice_agencia).vlsldapl);
          exception
            when others then
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir GNINFPL: '||sqlerrm;
              raise vr_exc_saida;
          end;
        end if;
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar GNINFPL: '||sqlerrm;
          raise vr_exc_saida;
      end;
      -- Passar para a próxima agência
      vr_indice_agencia := vr_tab_agencia.next(vr_indice_agencia);
    end loop;
  end if;
  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informações atualizadas
  COMMIT;

exception
  when vr_exc_saida then
    -- Desfazer as alterações
    rollback to trans_poup;
    -- Incluir erro no log
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;

  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;
end PC_CRPS155;
/

