CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS139" (pr_cdcooper in craptab.cdcooper%TYPE
                     ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                     ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                     ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                     ,pr_cdcritic out crapcri.cdcritic%TYPE
                     ,pr_dscritic out varchar2) as
/* ..........................................................................

   Programa: PC_CRPS139 (Antigo Fontes/crps139.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair                              Ultima atualizacao: 11/11/2013
   Data    : Novembro/95

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 004.
               Emite relatorio com os maiores saldos-medios.

   Alteracoes: 01/12/95 - Acerto no numero de vias (Deborah).

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               26/08/1999 - Tratar circular 2852 (Deborah).

               10/02/2000 - Gerar pedido de impressao (Deborah).

               19/11/2004 - Gerar tambem relatorio com TODOS saldos-medios
                            (rl/crrl116_99.lst);
                            Mudado nome do arquivo temporario de "crrl139.tmp"
                            para "crrl116.tmp" (Evandro).

               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               08/11/2006 - Incluido PAC do associado nos relatorios (Elton).

               06/01/2010 - Relatorio não irá mais listar os 100 maiores, e sim
                            os cooperados cujo valor dos saldos-medios seja maior
                            que o parametrizado na TAB007 (Fernando).

               29/07/2013 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero).

               11/11/2013 - Remoção da to_char(date,'MONTH') devido a mesma escrever
                            em inglês quando executada pela Progress - usar o vetor
                            da gene0001 que possui os meses por extenso (Marcos-Supero)

			   17/07/2017 - to_char para representar valores acima de 1 BI (Andrey - Mouts)

............................................................................. */
  -- Data do movimento
  cursor cr_crapdat(pr_cdcooper in craptab.cdcooper%type) is
    select dat.dtmvtolt
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
  -- Buscar o valor separador dos maiores cotistas
  cursor cr_craptab is
    select to_number(substr(craptab.dstextab,17,15)) dstextab
      from craptab
     where craptab.cdcooper = pr_cdcooper
       and upper(craptab.nmsistem) = 'CRED'
       and craptab.cdempres = 11
       and upper(craptab.tptabela) = 'USUARI'
       and upper(craptab.cdacesso) = 'MAIORESDEP'
       and craptab.tpregist = 1;
  rw_craptab   cr_craptab%rowtype;
  -- Lista dos saldos dos últimos 3 meses
  cursor cr_crapsld(pr_cdcooper in crapsld.cdcooper%type,
                    pr_dtmvtolt in crapsld.dtrefere%type) is
    select crapsld.nrdconta,
           crapsld.vlprimes,
           crapsld.vlsegmes,
           crapsld.vltermes,
           round((crapsld.vlprimes + crapsld.vlsegmes + crapsld.vltermes) / 3, 2) vlsldmed_round,
           ((crapsld.vlprimes + crapsld.vlsegmes + crapsld.vltermes) / 3) vlsldmed,
           nvl(crapass.nmprimtl, 'NAO CADASTRADO') nmprimtl,
           crapass.nrmatric,
           crapass.cdagenci,
           crapass.inpessoa
      from crapass,
           (select crapsld.cdcooper,
                   crapsld.nrdconta,
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
             from crapsld
            where crapsld.cdcooper = pr_cdcooper) crapsld
     where crapass.cdcooper(+) = crapsld.cdcooper
       and crapass.nrdconta(+) = crapsld.nrdconta
     order by 5 desc,
              crapsld.nrdconta;
  --
  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%type;
  -- Nome dos meses que serão calculados
  vr_dsmes1        varchar2(15);
  vr_dsmes2        varchar2(15);
  vr_dsmes3        varchar2(15);
  -- Contador de registros, que será utilizados para preencher a coluna ORDEM
  cont             number(7) := 0;
  -- Tratamento de erros
  vr_exc_erro      exception;
  vr_exc_fimprg    exception;
  -- Variáveis para armazenar as informações em XML
  vr_des_xml       clob;
  vr_des_xml2      clob;
  -- Variável para o caminho e nome do arquivo base
  vr_nom_diretorio varchar2(200);
  vr_nom_arquivo   varchar2(200);
  -- Valor que define o limite para separar os maiores cotistas dos demais
  vr_vlsdmact      crapcot.vldcotas%type;
  -- Variável auxiliar para definir se irá escrever a informação nos dois arquivos
  vr_escreve_arquivo_2  boolean;
  -- Subrotina para escrever texto na variável CLOB do XML
  procedure pc_escreve_xml(pr_des_dados in varchar2,
                           pr_escreve_arquivo_2 in boolean) is
  begin
    dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
    if pr_escreve_arquivo_2 then
      dbms_lob.writeappend(vr_des_xml2, length(pr_des_dados), pr_des_dados);
    end if;
  end;
  --
begin
  -- Nome do programa
  vr_cdprogra := 'CRPS139';
  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => pr_cdcritic);
  -- Se retornou algum erro
  if pr_cdcritic <> 0 then
    -- Buscar descrição do erro
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    -- Envio centralizado de log de erro
    raise vr_exc_erro;
  end if;
  pr_cdcritic := 0;
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS139',
                             pr_action => vr_cdprogra);
  -- Buscar a data do movimento
  open cr_crapdat(pr_cdcooper);
    fetch cr_crapdat into vr_dtmvtolt;
  close cr_crapdat;
  -- Identificar os meses que serão utilizados para calcular a média
  vr_dsmes1 := GENE0001.vr_vet_nmmesano(to_char(vr_dtmvtolt, 'MM'))||'/'||to_char(vr_dtmvtolt, 'yyyy');
  vr_dsmes2 := GENE0001.vr_vet_nmmesano(to_char(add_months(vr_dtmvtolt, -1),'MM'))||'/'||to_char(add_months(vr_dtmvtolt, -1), 'yyyy');
  vr_dsmes3 := GENE0001.vr_vet_nmmesano(to_char(add_months(vr_dtmvtolt, -2),'MM'))||'/'||to_char(add_months(vr_dtmvtolt, -2), 'yyyy');
  -- Buscar o valor separador dos maiores cotistas
  open cr_craptab;
    fetch cr_craptab into rw_craptab;
    if cr_craptab%notfound then
      vr_vlsdmact := 10000;
    else
      vr_vlsdmact := rw_craptab.dstextab;
      if vr_vlsdmact = 0 then
        vr_vlsdmact := 0.01;
      end if;
    end if;
  close cr_craptab;
  -- Inicializar os CLOBs para armazenar os arquivos XML
  -- Serão gerados 2 arquivos. Um com todos os cotistas (crrl361) e outro com os maiores cotistas (crrl028).
  -- O parâmetro boolean da pc_escreve_xml define se irá escrever nos dois arquivos (true) ou somente no primeiro (false).
  vr_des_xml := null;
  dbms_lob.createtemporary(vr_des_xml, true);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  --
  vr_des_xml2 := null;
  dbms_lob.createtemporary(vr_des_xml2, true);
  dbms_lob.open(vr_des_xml2, dbms_lob.lob_readwrite);
  -- Inicilizar as informações do XML
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps139>', true);
  pc_escreve_xml('<dsmes1>'||vr_dsmes1||'</dsmes1>'||
                 '<dsmes2>'||vr_dsmes2||'</dsmes2>'||
                 '<dsmes3>'||vr_dsmes3||'</dsmes3>',
                 true);
  -- Leitura dos cotistas para inclusão no arquivo XML
  for rw_crapsld in cr_crapsld (pr_cdcooper,
                                vr_dtmvtolt) loop
    -- Descartar os registros que sejam "cheque administrativo"
    if rw_crapsld.inpessoa = 3 then
      continue;
    end if;
    -- Descartar os registros com saldo negativo, e colocar a informação no log
    if rw_crapsld.vlsldmed < 0 or
       rw_crapsld.vlprimes < 0 or
       rw_crapsld.vlsegmes < 0 or
       rw_crapsld.vltermes < 0 then
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1,
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || 'SALDO MEDIO NEGATIVO:  CONTA: '||to_char(rw_crapsld.nrdconta, 'fm9999G999G9'),
                                 pr_nmarqlog     => vr_cdprogra);
      continue;
    end if;
    -- Descartar os registros com saldo médio zerado
    if rw_crapsld.vlsldmed = 0 then
      continue;
    end if;
    -- Verifica se o associado existe. Caso não exista, aborta a execução.
    if rw_crapsld.nmprimtl = 'NAO CADASTRADO' then
      pr_cdcritic := 9;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      raise vr_exc_erro;
    end if;
    -- Se o valor do cotista for maior que o limite, escreve nos dois arquivos.
    vr_escreve_arquivo_2 := (rw_crapsld.vlsldmed >= vr_vlsdmact);
    -- Incrementa o contador de registros
    cont := cont + 1;
    -- Inclui a linha no XML
    pc_escreve_xml('<cotista>'||
                     '<agencia>'||rw_crapsld.cdagenci||'</agencia>'||
                     '<ordem>'||to_char(cont, 'fm9G999G999')||'</ordem>'||
                     '<nrdconta>'||to_char(rw_crapsld.nrdconta, 'fm9999G999G9')||'</nrdconta>'||
                     '<nrmatric>'||to_char(rw_crapsld.nrmatric, 'fm999G990')||'</nrmatric>'||
                     '<nmprimtl>'||substr(rw_crapsld.nmprimtl, 1, 33)||'</nmprimtl>'||
                     '<vlsldmed>'||rw_crapsld.vlsldmed_round||'</vlsldmed>'||
                     '<vlsldmed_char>'||to_char(rw_crapsld.vlsldmed_round, 'fm9g999g999g990d00')||'</vlsldmed_char>'||
                     '<vlprimes>'||rw_crapsld.vlprimes||'</vlprimes>'||
                     '<vlprimes_char>'||to_char(rw_crapsld.vlprimes, 'fm9g999g999g990d00')||'</vlprimes_char>'||
                     '<vlsegmes>'||rw_crapsld.vlsegmes||'</vlsegmes>'||
                     '<vlsegmes_char>'||to_char(rw_crapsld.vlsegmes, 'fm9g999g999g990d00')||'</vlsegmes_char>'||
                     '<vltermes>'||rw_crapsld.vltermes||'</vltermes>'||
                     '<vltermes_char>'||to_char(rw_crapsld.vltermes, 'fm9g999g999g990d00')||'</vltermes_char>'||
                   '</cotista>',
                   vr_escreve_arquivo_2);
  end loop;
  -- Fecha a tag principal para encerrar o XML
  pc_escreve_xml('</crps139>', true);
  -- Busca do diretório base da cooperativa
  vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                            pr_cdcooper => pr_cdcooper,
                                            pr_nmsubdir => '/rl'); --> Utilizaremos o rl
  -- Executa o relatório com os maiores saldos
  vr_nom_arquivo := 'crrl116';
  -- Chamada do iReport para gerar o arquivo de saída
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                              pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                              pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                              pr_dsxml     => vr_des_xml2,         --> Arquivo XML de dados (CLOB)
                              pr_dsxmlnode => '/crps139/cotista',  --> Nó base do XML para leitura dos dados
                              pr_dsjasper  => 'crrl116.jasper',    --> Arquivo de layout do iReport
                              pr_dsparams  => null,                --> Enviar como parâmetro apenas a agência
                              pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo||'.lst', --> Arquivo final
                              pr_flg_gerar => 'N',
                              pr_qtcoluna  => 132,
                              pr_sqcabrel  => 1,
                              pr_flg_impri => 'S',    --> Chamar a impressão (Imprim.p)
                              pr_nmformul  => '',     --> Nome do formulário para impressão
                              pr_nrcopias  => 2,      --> Número de cópias para impressão
                              pr_des_erro  => pr_dscritic);       --> Saída com erro
  -- Verifica se ocorreu erro na geração do arquivo ou na solicitação do relatório
  if pr_dscritic is not null then
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 2, -- Erro tratado
                               pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| pr_dscritic,
                               pr_nmarqlog => vr_cdprogra);
  end if;
  -- Executa o relatório com a relação de todas as contas com saldo médio positivo
  vr_nom_arquivo := 'crrl116_'||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL');
  -- Chamada do iReport para gerar o arquivo de saída
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                              pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                              pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                              pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                              pr_dsxmlnode => '/crps139/cotista',  --> Nó base do XML para leitura dos dados
                              pr_dsjasper  => 'crrl116.jasper',    --> Arquivo de layout do iReport
                              pr_dsparams  => null,                --> Enviar como parâmetro apenas a agência
                              pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo||'.lst', --> Arquivo final
                              pr_flg_gerar => 'N',
                              pr_qtcoluna  => 132,
                              pr_sqcabrel  => 2,
                              pr_des_erro  => pr_dscritic);       --> Saída com erro

  -- Verifica se ocorreu erro na geração do arquivo ou na solicitação do relatório
  if pr_dscritic is not null then
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 2, -- Erro tratado
                               pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| pr_dscritic,
                               pr_nmarqlog => vr_cdprogra);
  end if;
  -- Liberando a memória alocada para os CLOBs
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);
  dbms_lob.close(vr_des_xml2);
  dbms_lob.freetemporary(vr_des_xml2);
  -- Testar se houve erro
  if pr_dscritic is not null then
    -- Gerar exceção
    pr_cdcritic := 0;
    raise vr_exc_erro;
  end if;
  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  --
  commit;
EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF nvl(pr_cdcritic,0) > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF nvl(pr_cdcritic,0) > 0 OR pr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || pr_dscritic );
    END IF;
    -- Limpa as variaveis, pois o retorno pelo fimprg tem que ser limpo
    pr_dscritic := NULL;
    pr_cdcritic := 0;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;
  WHEN vr_exc_erro THEN
    -- Se foi retornado apenas código
    IF nvl(pr_cdcritic,0) > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;
    -- Efetuar rollback
    ROLLBACK;
  when others then
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Desfazer as alterações
    rollback;
end;
/

