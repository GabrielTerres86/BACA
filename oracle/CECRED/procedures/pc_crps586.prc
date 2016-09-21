create or replace procedure cecred.pc_crps586(pr_cdcooper  in craptab.cdcooper%type   --> Codigo da cooperativa logada
                                      ,pr_flgresta  in pls_integer             --> Flag padrão para utilização de restart
                                      ,pr_stprogra out pls_integer             --> Saída de termino da execução
                                      ,pr_infimsol out pls_integer             --> Saída de termino da solicitação,
                                      ,pr_cdcritic out crapcri.cdcritic%type   --> Código de critica de erro
                                      ,pr_dscritic out varchar2) as            --> Descritição da critica de erro

/* ..........................................................................

   Programa: PC_CRPS586 ( Antigos Fontes/crps586.p + Includes/crps586.i )
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Henrique
   Data    : Dezembro/2010                     Ultima atualizacao: 16/01/2014

   Dados referentes ao programa:

   Frequencia: Anual (Batch)
   Objetivo  : Calculo do saldo medio para retorno de sobras.
               Atende a solicitacao 007. Ordem 2. Crrl586               
               Calculo anual dos juros sobre capital.
   
   Alterações: 10/01/2011 - Incluido o total por PAC.
                          - Alterado para exibir tres grupos. De socios ativos,
                            demitidos no ano atual e demitidos. (Henrique)
                            
               12/11/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (Guilherme Gielow)    

               16/01/2014 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero).
               
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
  -- Dados para geração de extrato para Imposto de Renda
  cursor cr_crapdir (pr_cdcooper in crapdir.cdcooper%type,
                     pr_dtmvtolt in crapdir.dtmvtolt%type) is
    select dir.nrdconta,
           ass.cdagenci,
           substr(ass.nmprimtl, 1, 25) nmprimtl,
           ass.nrmatric,
           apli0001.fn_round((dir.smposano##1 + dir.smposano##2 + dir.smposano##3 + dir.smposano##4 +
                              dir.smposano##5 + dir.smposano##6 + dir.smposano##7 + dir.smposano##8 +
                              dir.smposano##9 + dir.smposano##10 + dir.smposano##11 + dir.smposano##12) / 12, 2) smposano,
           dir.dtdemiss
      from crapass ass,
           crapdir dir
     where dir.cdcooper = pr_cdcooper
       and dir.dtmvtolt = pr_dtmvtolt
       and ass.cdcooper (+) = dir.cdcooper
       and ass.nrdconta (+) = dir.nrdconta;
  -- PL/Table para armazenar, ordenar e completar os dados
  -- para geração de extrato para Imposto de Renda
  type typ_crapdir is record (cdagenci  crapass.cdagenci%type,
                              nrdconta  crapdir.nrdconta%type,
                              nmprimtl  crapass.nmprimtl%type,
                              nrmatric  crapass.nrmatric%type,
                              smposano  crapdir.smposano##1%type,
                              dtdemiss  crapdir.dtdemiss%type,
                              fldemiss  number(1));
  type typ_tab_crapdir is table of typ_crapdir index by varchar2(16);
  -- O índice da pl/table é formado pelos campos cdagenci(5) Flgdemis(1) e nrdconta(10).
  vr_ind_crapdir     varchar2(16);
  vr_crapdir         typ_tab_crapdir;
  --
  rw_crapdat         btch0001.cr_crapdat%rowtype;
  -- Código do programa
  vr_cdprogra        crapprg.cdprogra%type;
  -- Variável para armazenar o primeiro dia do ano corrente
  vr_dtmvtolt        crapdat.dtmvtolt%type;
  -- Tratamento de erros
  vr_exc_saida       exception;
  vr_exc_fimprg      exception;
  vr_cdcritic        pls_integer;
  vr_dscritic        varchar2(4000);
  -- Variáveis para armazenar as informações em XML
  vr_des_xml         clob;
  -- Variáveis auxiliares no processamento da crapdir
  vr_fldemiss        number(1);
  vr_cdagenci        number(5);
  -- Variável para armazenar os dados do XML antes de incluir no CLOB
  vr_texto_completo  varchar2(32600);
  -- Variável para o caminho e nome do arquivo base
  vr_nom_diretorio   varchar2(200);
  vr_nom_arquivo     varchar2(200);

begin
  -- Nome do programa
  vr_cdprogra := 'CRPS586';
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS586',
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
  -- Montar primeiro dia do ano corrente
  vr_dtmvtolt := trunc(rw_crapdat.dtmvtolt, 'yyyy');
  -- Leitura dos dados para geração de extrato para Imposto de Renda
  for rw_crapdir in cr_crapdir (pr_cdcooper,
                                rw_crapdat.dtmvtolt) loop
    -- Seta o flag que indica o estado da demissão
    if rw_crapdir.dtdemiss is null then
      vr_fldemiss := 1;
    elsif rw_crapdir.dtdemiss >= vr_dtmvtolt then
      vr_fldemiss := 2;
    else
      vr_fldemiss := 3;
    end if;
    -- Define o índice
    vr_ind_crapdir := lpad(rw_crapdir.cdagenci, 5, '0')||vr_fldemiss||lpad(rw_crapdir.nrdconta, 10, '0');
    -- Incluir informações na PL/Table
    vr_crapdir(vr_ind_crapdir).cdagenci := rw_crapdir.cdagenci;
    vr_crapdir(vr_ind_crapdir).fldemiss := vr_fldemiss;
    vr_crapdir(vr_ind_crapdir).nrdconta := rw_crapdir.nrdconta;
    vr_crapdir(vr_ind_crapdir).nmprimtl := rw_crapdir.nmprimtl;
    vr_crapdir(vr_ind_crapdir).nrmatric := rw_crapdir.nrmatric;
    vr_crapdir(vr_ind_crapdir).smposano := rw_crapdir.smposano;
    vr_crapdir(vr_ind_crapdir).dtdemiss := rw_crapdir.dtdemiss;
  end loop;
  -- Definição do diretório e nome do arquivo a ser gerado
  vr_nom_diretorio := gene0001.fn_diretorio('c',  -- /usr/coop
                                            pr_cdcooper,
                                            'rl');
  vr_nom_arquivo := 'crrl586.lst';
  -- Leitura da PL/Table e geração do arquivo XML para o relatório
  -- Inicializar o CLOB
  vr_des_xml := null;
  dbms_lob.createtemporary(vr_des_xml, true);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  -- Inicilizar as informações do XML
  vr_texto_completo := null;
  gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                         ,pr_texto_completo => vr_texto_completo
                         ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><crrl586>');
  -- Inicializar o código da agencia para testes de quebra
  vr_cdagenci := -1;
  -- Leitura da PL/Table para montagem do XML base ao relatório
  vr_ind_crapdir := vr_crapdir.first;
  while vr_ind_crapdir is not null loop
    -- No primeiro registro
    IF vr_cdagenci <> vr_crapdir(vr_ind_crapdir).cdagenci THEN
      -- Gerar a tag de agência
      gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                             ,pr_texto_completo => vr_texto_completo
                             ,pr_texto_novo     => '<agencia cdagenci="'||lpad(vr_crapdir(vr_ind_crapdir).cdagenci, 3, ' ')||'">');      
      -- Guardar a agência atual
      vr_cdagenci := vr_crapdir(vr_ind_crapdir).cdagenci;
    END IF;
    -- Gerar a linha de detalhe
    gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                           ,pr_texto_completo => vr_texto_completo
                           ,pr_texto_novo     => '<conta fldemiss="'||vr_crapdir(vr_ind_crapdir).fldemiss||'">'||
                                                   '<nrdconta>'||to_char(vr_crapdir(vr_ind_crapdir).nrdconta, 'fm9999G990G0')||'</nrdconta>'||
                                                   '<nmprimtl>'||vr_crapdir(vr_ind_crapdir).nmprimtl||'</nmprimtl>'||
                                                   '<nrmatric>'||to_char(vr_crapdir(vr_ind_crapdir).nrmatric, 'fm999G990')||'</nrmatric>'||
                                                   '<smposano>'||to_char(vr_crapdir(vr_ind_crapdir).smposano, 'fm999G999G999G990D00')||'</smposano>'||
                                                   '<dtdemiss>'||to_char(vr_crapdir(vr_ind_crapdir).dtdemiss, 'dd/mm/yyyy')||'</dtdemiss>'||
                                                 '</conta>');
    -- Testar se for o ultimo registro da Pltable ou da agência atual
    IF vr_ind_crapdir = vr_crapdir.last OR vr_cdagenci <> vr_crapdir(vr_crapdir.Next(vr_ind_crapdir)).cdagenci THEN
      -- Fechar a tag de agência
      gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                             ,pr_texto_completo => vr_texto_completo
                             ,pr_texto_novo     => '</agencia>');
    END IF;
    -- Busca do próximo registro
    vr_ind_crapdir := vr_crapdir.next(vr_ind_crapdir);
  end loop;
  -- Encerrar a tag raiz
  gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                         ,pr_texto_completo => vr_texto_completo
                         ,pr_texto_novo     => '</crrl586>'
                         ,pr_fecha_xml      => true);
  -- Solicita o relatório
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                              pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                              pr_dtmvtolt  => rw_crapdat.dtmvtolt, --> Data do movimento atual
                              pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                              pr_dsxmlnode => '/crrl586/agencia/conta',    --> Nó base do XML para leitura dos dados
                              pr_dsjasper  => 'crrl586.jasper',    --> Arquivo de layout do iReport
                              pr_dsparams  => null,
                              pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo, --> Arquivo final
                              pr_flg_gerar => 'N',
                              pr_qtcoluna  => 80,
                              pr_sqcabrel  => 1,
                              pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)
                              pr_nmformul  => '80col',             --> Nome do formulário para impressão
                              pr_nrcopias  => 1,                   --> Número de cópias para impressão
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

