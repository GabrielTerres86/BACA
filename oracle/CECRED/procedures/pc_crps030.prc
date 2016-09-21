CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS030 (pr_cdcooper in craptab.cdcooper%type,
                                                 pr_flgresta IN PLS_INTEGER,             --> Flag 0/1 para utilizar restart na chamada
                                                 pr_stprogra OUT PLS_INTEGER,            --> Saída de termino da execução
                                                 pr_infimsol OUT PLS_INTEGER,            --> Saída de termino da solicitação
                                                 pr_cdcritic out crapcri.cdcritic%type,
                                                 pr_dscritic out varchar2) as
/* ..........................................................................

   Programa: PC_CRPS030 (Antigo Fontes/crps030.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/92.                       Ultima atualizacao: 28/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 020.
               Emite relatorio com os maiores cotistas.

   Alteracoes: 01/12/94 - Acerto no numero de vias (Deborah).

               22/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               26/08/1999 - Tratar circular 2852 (Deborah).

               10/02/2000 - Gerar pedido de impressao (Deborah).

               14/06/2004 - Gerar listagem de todos os cotistas para a
                            Auditoria (Ze Eduardo).

               10/01/2005 - Ajuste no rel. 361 (p/ Auditoria) (Ze Eduardo).

               14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               07/11/2006 - Incluida coluna PAC do associado no relatorio
                            (Elton).

               06/01/2009 - Alterado format do campo "ORD" (Gabriel).

               06/01/2010 - Relatorio não irá mais listar os 100 maiores, e sim
                            os cooperados cujo valor das cotas seja maior que
                            o parametrizado na TAB007 (Fernando).

               25/07/2013 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero).

               08/10/2013 - Adicionados os parâmdetros: pr_flgresta/pr_stprogra/pr_infimsol
                          - Alterado o tratamento das exceções incluíndo a chamada do procedimento
                            pc_valida_fimprg
                          - Renomeado a exceçâo vr_exc_erro para vr_exc_saida e criada
                            a exceção vr_exc_fimprg (Edison - AMcom)
               
               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero)     
                            
               28/05/2014 - Ajustes na leitura dos valores de maior cotista (Marcos-Supero)                                  
                            
............................................................................. */
  -- Data do movimento
  cursor cr_crapdat(pr_cdcooper in craptab.cdcooper%type) is
    select dat.dtmvtolt
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
  -- Solicitações de emissão do relatório
  cursor cr_crapsol (pr_cdcooper in crapsol.cdcooper%type,
                     pr_dtmvtolt in crapsol.dtrefere%type) is
    select crapsol.nrseqsol,
           crapsol.nrdevias,
           rowid row_id
      from crapsol
     where crapsol.cdcooper = pr_cdcooper
       and crapsol.dtrefere = pr_dtmvtolt
       and crapsol.nrsolici = 20
       and crapsol.insitsol = 1;
  rw_crapsol     cr_crapsol%rowtype;
  -- Buscar o valor separador dos maiores cotistas
  cursor cr_craptab is
    select to_number(substr(craptab.dstextab,65,15)) dstextab
      from craptab
     where craptab.cdcooper = pr_cdcooper
       and upper(craptab.nmsistem) = 'CRED'
       and craptab.cdempres = 11
       and upper(craptab.tptabela) = 'USUARI'
       and upper(craptab.cdacesso) = 'MAIORESDEP'
       and craptab.tpregist = 1;
  rw_craptab   cr_craptab%rowtype;
  -- Lista dos cotistas
  cursor cr_crapcot(pr_cdcooper in craptab.cdcooper%type) is
    select crapcot.nrdconta,
           crapcot.vldcotas,
           nvl(crapass.nmprimtl, 'NAO CADASTRADO') nmprimtl,
           crapass.nrcpfcgc,
           crapass.nrmatric,
           crapass.cdagenci,
           crapass.inpessoa
      from crapass,
           crapcot
     where crapcot.cdcooper = pr_cdcooper
       and crapcot.vldcotas > 0
       and crapass.cdcooper(+) = crapcot.cdcooper
       and crapass.nrdconta(+) = crapcot.nrdconta
     order by crapcot.vldcotas desc,
              crapcot.nrdconta;
  --
  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%type;
  -- Tratamento de erros
  vr_exc_saida      exception;
  vr_exc_fimprg     exception;
  vr_cdcritic       crapcri.cdcritic%TYPE;
  vr_dscritic       varchar2(4000);

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
  -- Variável auxiliar para armazenar o CPF/CNPJ formatado para a saída no relatório
  vr_nrcpfcgc      varchar2(20);
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
  vr_cdprogra := 'CRPS030';
  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                            pr_flgbatch => 1,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_cdcritic => vr_cdcritic);
  -- Se retornou algum erro
  if vr_cdcritic <> 0 then
    -- Buscar descrição do erro
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    --Envio do log de erro
    RAISE vr_exc_saida;
  end if;
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS030',
                             pr_action => vr_cdprogra);
  -- Buscar a data do movimento
  open cr_crapdat(pr_cdcooper);
    fetch cr_crapdat into vr_dtmvtolt;
  close cr_crapdat;
  -- Verifica se houve alguma solicitação para o relatório
  open cr_crapsol (pr_cdcooper,
                   vr_dtmvtolt);
    fetch cr_crapsol into rw_crapsol;
    if cr_crapsol%notfound then
      vr_cdcritic := 157;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||' - SOL020';
      raise vr_exc_saida;
    end if;
  close cr_crapsol;
  -- Buscar o valor separador dos maiores cotistas
  open cr_craptab;
    fetch cr_craptab into rw_craptab;
    if cr_craptab%notfound then
      vr_vlsdmact := 10000;
    else
      vr_vlsdmact := rw_craptab.dstextab;
      -- Se o valor estiver vazio ou zerado
      if NVL(vr_vlsdmact,0) = 0 then
        -- Usar valor mínimo
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
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crps030>', true);
  -- Leitura dos cotistas para inclusão no arquivo XML
  for rw_crapcot in cr_crapcot (pr_cdcooper) loop
    -- Verifica se o associado existe. Caso não exista, aborta a execução.
    if rw_crapcot.nmprimtl = 'NAO CADASTRADO' then
      vr_cdcritic := 9;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      raise vr_exc_saida;
    end if;
    -- Se o valor do cotista for maior que o limite, escreve nos dois arquivos.
    vr_escreve_arquivo_2 := (rw_crapcot.vldcotas >= vr_vlsdmact);
    -- Formata o campo do CPF/CNPJ de acordo com o tipo de pessoa
    vr_nrcpfcgc := gene0002.fn_mask_cpf_cnpj(rw_crapcot.nrcpfcgc,
                                             rw_crapcot.inpessoa);
    --
    pc_escreve_xml('<cotista>'||
                     '<agencia>'||rw_crapcot.cdagenci||'</agencia>'||
                     '<ordem>'||cr_crapcot%rowcount||'</ordem>'||
                     '<nrdconta>'||to_char(rw_crapcot.nrdconta, 'fm9999G999G9')||'</nrdconta>'||
                     '<nrmatric>'||to_char(rw_crapcot.nrmatric, 'fm999G990')||'</nrmatric>'||
                     '<nmprimtl>'||substr(rw_crapcot.nmprimtl, 1, 35)||'</nmprimtl>'||
                     '<vldcotas>'||rw_crapcot.vldcotas||'</vldcotas>'||
                     '<vldcotas_char>'||to_char(rw_crapcot.vldcotas, 'fm99999G999G990D00')||'</vldcotas_char>'||
                     '<nrcpfcgc>'||vr_nrcpfcgc||'</nrcpfcgc>'||
                   '</cotista>',
                   vr_escreve_arquivo_2);
  end loop;
  -- Fecha a tag principal para encerrar o XML
  pc_escreve_xml('</crps030>', true);
  -- Busca do diretório base da cooperativa
  vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                            pr_cdcooper => pr_cdcooper,
                                            pr_nmsubdir => '/rl'); --> Utilizaremos o rl
  -- Executa os relatórios de acordo com as solicitações
  for rw_crapsol in cr_crapsol (pr_cdcooper,
                                vr_dtmvtolt) loop
    -- Nome base do arquivo é crrl028_
    vr_nom_arquivo := 'crrl028_'||to_char(rw_crapsol.nrseqsol, 'fm09');
    -- Chamada do iReport para gerar o arquivo de saída
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                                pr_dsxml     => vr_des_xml2,          --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => '/crps030/cotista',    --> Nó base do XML para leitura dos dados
                                pr_dsjasper  => 'crrl028.jasper',    --> Arquivo de layout do iReport
                                pr_dsparams  => null,                --> Enviar como parâmetro apenas a agência
                                pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo||'.lst', --> Arquivo final
                                pr_flg_gerar => 'N',
                                pr_qtcoluna  => 132,
                                pr_sqcabrel  => 1,
                                pr_flg_impri => 'S',    --> Chamar a impressão (Imprim.p)
                                pr_nmformul  => '',     --> Nome do formulário para impressão
                                pr_nrcopias  => 2,      --> Número de cópias para impressão
                                pr_des_erro  => vr_dscritic);       --> Saída com erro

    -- Marca a solicitação como executada
    begin
      update crapsol
         set crapsol.insitsol = 2
       where crapsol.rowid = rw_crapsol.row_id;
    exception
      when others then
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao marcar a solicitação '||rw_crapsol.row_id||' como executada: '||sqlerrm;
        raise vr_exc_saida;
    end;
  end loop;
  -- Executa o relatório de auditoria
  vr_nom_arquivo := 'crrl361';
  -- Chamada do iReport para gerar o arquivo de saída
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                              pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                              pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                              pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                              pr_dsxmlnode => '/crps030/cotista',    --> Nó base do XML para leitura dos dados
                              pr_dsjasper  => 'crrl361.jasper',    --> Arquivo de layout do iReport
                              pr_dsparams  => null,                --> Enviar como parâmetro apenas a agência
                              pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo||'.lst', --> Arquivo final
                              pr_flg_gerar => 'N',
                              pr_qtcoluna  => 132,
                              pr_sqcabrel  => 2,
                              pr_des_erro  => vr_dscritic);       --> Saída com erro

  -- Liberando a memória alocada para os CLOBs
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);
  dbms_lob.close(vr_des_xml2);
  dbms_lob.freetemporary(vr_des_xml2);
  -- Testar se houve erro
  if vr_dscritic is not null then
    -- Gerar exceção
    vr_cdcritic := 0;
    raise vr_exc_saida;
  end if;

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  --
  commit;

exception
  when vr_exc_fimprg then
    -- se foi retornado apenas código
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;
    -- se foi gerada critica para envio ao log
    if vr_cdcritic > 0 or vr_dscritic is not null then
      -- envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic
                                ,pr_nmarqlog     => vr_cdprogra);
    end if;
    -- chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- efetuar commit pois gravaremos o que foi processo até então
    commit;
  when vr_exc_saida then
    -- se foi retornado apenas código
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;
    -- devolvemos código e critica encontradas
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- efetuar rollback
    rollback;
  when others then
    -- efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- efetuar rollback
    rollback;
end;
/

