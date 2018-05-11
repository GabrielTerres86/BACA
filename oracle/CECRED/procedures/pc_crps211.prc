create or replace procedure cecred.pc_crps211(pr_cdcooper  in craptab.cdcooper%type,
                     pr_flgresta  in pls_integer,            --> Flag padrão para utilização de restart
                     pr_stprogra out pls_integer,            --> Saída de termino da execução
                     pr_infimsol out pls_integer,            --> Saída de termino da solicitação,
                     pr_cdcritic out crapcri.cdcritic%type,
                     pr_dscritic out varchar2) as
/* ..........................................................................

   Programa: pc_crps211 (antigo Fontes/crps211.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Setembro/97                     Ultima atualizacao: 18/12/2013

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 002.
               Gerar resumo de lancamento de cotas e emprestimos.
               Emite relatorio 168.

   Alteracoes: 02/12/97 - Alterado o numero do lote de deb em conta de cotas
                          (Deborah).

               27/01/98 - Criado historico 277 - estorno de juros (Deborah).

               29/01/98 - Acerto na alteracao anterior (Deborah).

               16/03/98 - Alterado para acrescentar o historico 282 ao 108
                          (Deborah).

               19/07/99 - Alterado para chamar a rotina de impressao (Edson).

               02/04/00 - Tratar historico 349 (Odair)

               22/03/2000 - Tratar historico 353 (Deborah).

               02/05/2000 - Listar historico 353 (Odair)

               03/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               05/07/2002 - Tratar historicos 392, 393 e 395 (Edson).

               19/08/2003 - Incluir mais uma via para a gerencia (Deborah).

               10/11/2002 - Tratar historicos 441 e 443 (Edson).

               05/01/2006 - Cancelar impressao da Coope 1 (Magui).

               30/01/2006 - Imprimir uma unica via para CREDIFIESC (Evandro).

               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               22/05/2007 - Retirarado vinculacao da execucao do
                         fontes/imprim.p ao codigo da cooperativa. (Guilherme).

               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper =
                            glb_cdcooper) no "for each" da tabela CRAPHIS.
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

               23/11/2009 - Alteracao Codigo Historico (Kbase).

               05/04/2010 - Alteracao Historico (Gati)

               09/09/2013 - Nova forma de chamar as agencias, de PAC agora
                            a escrita será PA (André Euzébio - Supero).

               18/12/2013 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero).

			   10/09/2017 - Melhoria 324 - tratar historicos 2381, 2396, 2401, 2408 (Jean - Mout´S)
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
  -- Buscar os lançamentos em empréstimos
  cursor cr_craplem (pr_cdcooper in craplem.cdcooper%type,
                     pr_dtmvtolt in craplem.dtmvtolt%type) is
    select craphis.cdhistor,
           substr(gene0002.fn_mask(craphis.cdhistor, 'zzz9')||' - '||craphis.dshistor, 1, 20) dshistor,
           craphis.indebcre,
           craplem.nrdolote,
           craplem.vllanmto
      from craphis,
           craplem
     where craplem.cdcooper = pr_cdcooper
       and craplem.dtmvtolt = pr_dtmvtolt
       and craplem.cdhistor in ( 88,  93,  95,  99,  91,
                                 92,  94, 277, 349, 353,
                                392, 393, 395, 441, 443,
							                  2381, 2396, 2401) -- Melhoria 324 - inclusao das transferencias a prejuizo
       and craphis.cdhistor = craplem.cdhistor
       and craphis.cdcooper = craplem.cdcooper;
  -- Buscar os lançamentos em depósitos à vista
  cursor cr_craplcm (pr_cdcooper in craplcm.cdcooper%type,
                     pr_dtmvtolt in craplcm.dtmvtolt%type) is
    select craphis.cdhistor,
           substr(gene0002.fn_mask(craphis.cdhistor, 'zzz9')||' - '||craphis.dshistor, 1, 20) dshistor,
           craphis.indebcre,
           craplcm.nrdolote,
           craplcm.vllanmto
      from craphis,
           craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt = pr_dtmvtolt
       and craplcm.cdhistor in (2, 15, 108, 282)
       and craphis.cdhistor = craplcm.cdhistor
       and craphis.cdcooper = craplcm.cdcooper
     order by craplcm.cdhistor;
  -- Buscar as capas de lote
  cursor cr_craplot (pr_cdcooper in craplot.cdcooper%type,
                     pr_dtmvtolt in craplot.dtmvtolt%type,
                     pr_tipo in number) is
    select craplot.cdagenci,
           craplot.cdbccxlt,
           craplot.nrdolote,
           craplot.tplotmov,
           craplot.vlcompdb,
           craplot.vlcompcr
      from craplot
     where craplot.cdcooper = pr_cdcooper
       and craplot.dtmvtolt = pr_dtmvtolt
       and (   (pr_tipo = 1 and craplot.tplotmov in (4, 5))
            or (pr_tipo = 2 and craplot.tplotmov in (2, 3)))
     order by craplot.tplotmov,
              craplot.cdagenci,
              craplot.nrdolote;
  -- Buscar os lançamentos de cotas / capital
  cursor cr_craplct (pr_cdcooper in craplct.cdcooper%type,
                     pr_dtmvtolt in craplct.dtmvtolt%type) is
    select craphis.cdhistor,
           substr(gene0002.fn_mask(craphis.cdhistor, 'zzz9')||' - '||craphis.dshistor, 1, 20) dshistor,
           craphis.indebcre,
           craplct.nrdolote,
           craplct.vllanmto
      from craphis,
           craplct
     where craplct.cdcooper = pr_cdcooper
       and craplct.dtmvtolt = pr_dtmvtolt
       and craphis.cdhistor = craplct.cdhistor
       and craphis.cdcooper = craplct.cdcooper;
  --
  rw_crapdat       btch0001.cr_crapdat%rowtype;
  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%type;
  -- Tratamento de erros
  vr_exc_saida     exception;
  vr_exc_fimprg    exception;
  vr_cdcritic      pls_integer;
  vr_dscritic      varchar2(4000);
  -- Variáveis para armazenar as informações em XML
  vr_des_xml       clob;
  -- Variável para o caminho e nome do arquivo base
  vr_nom_diretorio varchar2(200);
  vr_nom_arquivo   varchar2(200);
  vr_nrcopias      number(1);
  -- PL/Table para armazenar os valores acumulados por histórico
  type typ_craphis is record (cdhistor  craphis.cdhistor%type,
                              dshistor  craphis.dshistor%type,
                              indebcre  craphis.indebcre%type,
                              vlhistor  number(15,2),
                              qthistor  number(6));
  type typ_tab_craphis is table of typ_craphis index by binary_integer;
  vr_craphis       typ_tab_craphis;
  -- Variáveis para leitura da PL/Table
  vr_indice          number(4);
  vr_indice_aux      number(4);
  -- Variáveis para acumular os totais a serem exibidos no relatório
  aux_ctempres       number(15,2) := 0;
  aux_qtempres       number(6) := 0;
  aux_vlliquid       number(15,2) := 0;
  aux_qtliquid       number(6) := 0;
  aux_vldebcta_emp   number(15,2) := 0;
  aux_qtdebcta_emp   number(6) := 0;
  aux_vlcrdfol_emp   number(15,2) := 0;
  aux_qtcrdfol_emp   number(6) := 0;
  aux_vldebcta_cota  number(15,2) := 0;
  aux_qtdebcta_cota  number(6) := 0;
  aux_vlcrdfol_cota  number(15,2) := 0;
  aux_qtcrdfol_cota  number(6) := 0;
  aux_vlcrdcax       number(15,2) := 0;
  -- Variáveis para acumular os totais por grupo de históricos
  vr_tot_vlhistor    number(15,2) := 0;
  vr_tot_qthistor    number(6) := 0;
  --
  -- Subrotina para acumular as informações na pl/table
  procedure inclui_craphis_pl(pr_cdhistor in craphis.cdhistor%type,
                              pr_dshistor in craphis.dshistor%type,
                              pr_indebcre in craphis.indebcre%type,
                              pr_vlhistor in number) is
  begin
    if vr_craphis.exists(pr_cdhistor) then
      vr_craphis(pr_cdhistor).vlhistor := vr_craphis(pr_cdhistor).vlhistor + pr_vlhistor;
      vr_craphis(pr_cdhistor).qthistor := vr_craphis(pr_cdhistor).qthistor + 1;
    else
      vr_craphis(pr_cdhistor).cdhistor := pr_cdhistor;
      vr_craphis(pr_cdhistor).dshistor := pr_dshistor;
      vr_craphis(pr_cdhistor).indebcre := pr_indebcre;
      vr_craphis(pr_cdhistor).vlhistor := pr_vlhistor;
      vr_craphis(pr_cdhistor).qthistor := 1;
    end if;
  end;
  -- Subrotina para escrever texto na variável CLOB do XML
  procedure pc_escreve_xml(pr_des_dados in varchar2) is
  begin
    dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
  end;
  --
begin
  -- Nome do programa
  vr_cdprogra := 'CRPS211';
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS211',
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
  vr_dtmvtolt := rw_crapdat.dtmvtolt;
  --
  -- Ler as informações necessárias para o relatório, calcular totais e armazenar em pl/table
  --
  -- Leitura dos lançamentos em empréstimos
  for rw_craplem in cr_craplem (pr_cdcooper,
                                vr_dtmvtolt) loop
    if rw_craplem.cdhistor = 93 or
       (rw_craplem.cdhistor = 95 and rw_craplem.nrdolote <> 8453) then
      -- 93 PG. EMPR. FP.
      -- 95 PG. EMPR. C/C
      aux_vlcrdfol_emp := aux_vlcrdfol_emp + rw_craplem.vllanmto;
      aux_qtcrdfol_emp := aux_qtcrdfol_emp + 1;
    elsif rw_craplem.cdhistor = 99 then
      -- 99 CONTRATO EMPR.
      aux_ctempres := aux_ctempres + rw_craplem.vllanmto;
      aux_qtempres := aux_qtempres + 1;
    elsif rw_craplem.cdhistor = 88 then
      -- 88 ESTORNO PAGTO
      inclui_craphis_pl(rw_craplem.cdhistor,
                        rw_craplem.dshistor,
                        rw_craplem.indebcre,
                        rw_craplem.vllanmto);
      aux_vlcrdcax := aux_vlcrdcax - rw_craplem.vllanmto;
    elsif rw_craplem.cdhistor in (91,92,94,277,349,353,392,393,395,441,443, 2381, 2396, 2401) then
      -- 91	PG. EMPR. C/C
      -- 92	PG. EMPR. CX.
      -- 94	DESC/ABON.EMP
      -- 277	ESTORNO JUROS
      -- 349	TRF. PREJUIZO
      -- 353	TRANSF. COTAS
      -- 392	ABAT.CONCEDID
      -- 393	PAGTO AVALIST
      -- 395	SERV./TAXAS
      -- 441	JUROS S/ATRAS
      -- 443	MULTA S/ATRAS
	  -- 2381 - TRF PREJUIZO EMP PP (M324)
	  -- 2396 - TRF PREJUIZO FIN PP (M324)
	  -- 2401 - TRF PREJUIZO EMP/FIN TR (M324)
	  
      inclui_craphis_pl(rw_craplem.cdhistor,
                        rw_craplem.dshistor,
                        rw_craplem.indebcre,
                        rw_craplem.vllanmto);
      aux_vlcrdcax := aux_vlcrdcax + rw_craplem.vllanmto;
    end if;
  end loop; -- Fim cr_craplem
  -- Leitura dos lançamentos em depósitos à vista
  for rw_craplcm in cr_craplcm (pr_cdcooper,
                                vr_dtmvtolt) loop
    if rw_craplcm.cdhistor in (2, 15) then
      -- 2	CR.BLOQ.EMPR.
      -- 15	CR.EMPRESTIMO
      inclui_craphis_pl(rw_craplcm.cdhistor,
                        rw_craplcm.dshistor,
                        rw_craplcm.indebcre,
                        rw_craplcm.vllanmto);
    elsif rw_craplcm.cdhistor = 108 then
      -- 108	PREST.EMPREST
      if rw_craplcm.nrdolote = 8456 then
        aux_vlliquid := aux_vlliquid + rw_craplcm.vllanmto;
        aux_qtliquid := aux_qtliquid + 1;
      elsif rw_craplcm.nrdolote = 8457 then
        aux_vldebcta_emp := aux_vldebcta_emp + rw_craplcm.vllanmto;
        aux_qtdebcta_emp := aux_qtdebcta_emp + 1;
      elsif rw_craplcm.nrdolote = 8458 then
        aux_vlcrdfol_emp := aux_vlcrdfol_emp + rw_craplcm.vllanmto;
        aux_qtcrdfol_emp := aux_qtcrdfol_emp + 1;
      end if;
    elsif rw_craplcm.cdhistor = 282 then
      -- 282	DB.EMPRESTIMO
      aux_vlliquid := aux_vlliquid + rw_craplcm.vllanmto;
      aux_qtliquid := aux_qtliquid + 1;
    end if;
  end loop; -- Fim cr_craplcm
  -- Leitura dos lançamentos de cotas / capital
  for rw_craplct in cr_craplct (pr_cdcooper,
                                vr_dtmvtolt) loop
    if rw_craplct.cdhistor = 75 then
      -- 75	PG. PLANO C/C
      if rw_craplct.nrdolote = 8464 then
        aux_vldebcta_cota := aux_vldebcta_cota + rw_craplct.vllanmto;
        aux_qtdebcta_cota := aux_qtdebcta_cota + 1;
      else
        aux_vlcrdfol_cota := aux_vlcrdfol_cota + rw_craplct.vllanmto;
        aux_qtcrdfol_cota := aux_qtcrdfol_cota + 1;
      end if;
    elsif rw_craplct.cdhistor = 62 then
      -- 62	PG. PLANO FP.
      aux_vlcrdfol_cota := aux_vlcrdfol_cota + rw_craplct.vllanmto;
      aux_qtcrdfol_cota := aux_qtcrdfol_cota + 1;
    else
      inclui_craphis_pl(rw_craplct.cdhistor,
                        rw_craplct.dshistor,
                        rw_craplct.indebcre,
                        rw_craplct.vllanmto);
    end if;
  end loop; -- Fim cr_craplct
  --
  -- Inicia a montagem do XML, incluindo:
  --   Totais;
  --   Empréstimos (créditos e pagamentos);
  --   Lotes referentes aos empréstimos;
  --   Cotas/capital (créditos e débitos);
  --   Lotes referentes às cotas/capital.
  --
  -- Busca do diretório base da cooperativa
  vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                            pr_cdcooper => pr_cdcooper,
                                            pr_nmsubdir => '/rl'); --> Utilizaremos o rl
  -- Inicializar o CLOB
  vr_des_xml := null;
  dbms_lob.createtemporary(vr_des_xml, true);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  -- Inicilizar as informações do XML
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl168>');
    -- Inclui os campos de total
    pc_escreve_xml('<ctempres>'||to_char(aux_ctempres, 'fm999g999g999g990d00')||'</ctempres>'||
                   '<qtempres>'||to_char(aux_qtempres, 'fm999g990')||'</qtempres>'||
                   '<vlliquid>'||to_char(aux_vlliquid, 'fm999g999g999g990d00')||'</vlliquid>'||
                   '<qtliquid>'||to_char(aux_qtliquid, 'fm999g990')||'</qtliquid>'||
                   '<vldebcta_emp>'||to_char(aux_vldebcta_emp, 'fm999g999g999g990d00')||'</vldebcta_emp>'||
                   '<qtdebcta_emp>'||to_char(aux_qtdebcta_emp, 'fm999g990')||'</qtdebcta_emp>'||
                   '<vlcrdfol_emp>'||to_char(aux_vlcrdfol_emp, 'fm999g999g999g990d00')||'</vlcrdfol_emp>'||
                   '<qtcrdfol_emp>'||to_char(aux_qtcrdfol_emp, 'fm999g990')||'</qtcrdfol_emp>'||
                   '<vldebcta_cota>'||to_char(aux_vldebcta_cota, 'fm999g999g999g990d00')||'</vldebcta_cota>'||
                   '<qtdebcta_cota>'||to_char(aux_qtdebcta_cota, 'fm999g990')||'</qtdebcta_cota>'||
                   '<vlcrdfol_cota>'||to_char(aux_vlcrdfol_cota, 'fm999g999g999g990d00')||'</vlcrdfol_cota>'||
                   '<qtcrdfol_cota>'||to_char(aux_qtcrdfol_cota, 'fm999g990')||'</qtcrdfol_cota>');
    -- Empréstimos
    pc_escreve_xml('<Emprestimos>');
      -- Inclui informações referentes aos históricos 2 e 15 (Crédito conta corrente)
      vr_indice := vr_craphis.first;
      vr_indice_aux := null;
      -- Inicializa variáveis para acumular os totais
      vr_tot_vlhistor := 0;
      vr_tot_qthistor := 0;
      --
      while vr_indice is not null loop
        if vr_indice in (2, 15) then
          if vr_craphis.exists(vr_indice) then
            pc_escreve_xml('<Credito_CC>');
            pc_escreve_xml('<dshistor>'||vr_craphis(vr_indice).dshistor||'</dshistor>'||
                           '<indebcre>'||vr_craphis(vr_indice).indebcre||'</indebcre>'||
                           '<vlhistor>'||to_char(vr_craphis(vr_indice).vlhistor, 'fm999g999g999g990d00')||'</vlhistor>'||
                           '<qthistor>'||to_char(vr_craphis(vr_indice).qthistor, 'fm999g990')||'</qthistor>'
                           );
            pc_escreve_xml('</Credito_CC>');
            vr_indice_aux := vr_indice;
            -- Acumula totais
            vr_tot_vlhistor := vr_tot_vlhistor + vr_craphis(vr_indice).vlhistor;
            vr_tot_qthistor := vr_tot_qthistor + vr_craphis(vr_indice).qthistor;
          end if;
        end if;
        vr_indice := vr_craphis.next(vr_indice);
        -- Eliminar o registro já processado
        if vr_indice_aux is not null then
          vr_craphis.delete(vr_indice_aux);
          vr_indice_aux := null;
        end if;
      end loop;
      -- Inclui totais no XML
      pc_escreve_xml('<tot_vlhistor_credito_cc>'||to_char(vr_tot_vlhistor, 'fm999g999g999g990d00')||'</tot_vlhistor_credito_cc>'||
                     '<tot_qthistor_credito_cc>'||to_char(vr_tot_qthistor, 'fm999g990')||'</tot_qthistor_credito_cc>');
      -- Inclui informações referentes aos históricos de pagamentos
      vr_indice := 88;
      vr_indice_aux := null;
      -- Inicializa variáveis para acumular os totais
      vr_tot_vlhistor := 0;
      vr_tot_qthistor := 0;
      --
      while vr_indice is not null loop
        if vr_indice in (88, 91, 92, 94, 277, 349, 353, 392, 393, 395, 2381, 2396, 2401) then
          if vr_craphis.exists(vr_indice) then
            pc_escreve_xml('<Pagamentos>');
            pc_escreve_xml('<dshistor>'||vr_craphis(vr_indice).dshistor||'</dshistor>'||
                           '<indebcre>'||vr_craphis(vr_indice).indebcre||'</indebcre>'||
                           '<vlhistor>'||to_char(vr_craphis(vr_indice).vlhistor, 'fm999g999g999g990d00')||'</vlhistor>'||
                           '<qthistor>'||to_char(vr_craphis(vr_indice).qthistor, 'fm999g990')||'</qthistor>');
            pc_escreve_xml('</Pagamentos>');
            vr_indice_aux := vr_indice;
            -- Acumula totais
            vr_tot_vlhistor := vr_tot_vlhistor + vr_craphis(vr_indice).vlhistor;
            vr_tot_qthistor := vr_tot_qthistor + vr_craphis(vr_indice).qthistor;
          end if;
        end if;
        vr_indice := vr_craphis.next(vr_indice);
        -- Eliminar o registro já processado
        if vr_indice_aux is not null then
          vr_craphis.delete(vr_indice_aux);
          vr_indice_aux := null;
        end if;
      end loop;
      -- Inclui totais no XML
      -- Inclui também o vlcrdcax, que é calculado considerando os históricos 441 e 443, e é o valor usado no relatório
      pc_escreve_xml('<tot_vlhistor_pagamentos>'||to_char(vr_tot_vlhistor, 'fm999g999g999g990d00')||'</tot_vlhistor_pagamentos>'||
                     '<tot_qthistor_pagamentos>'||to_char(vr_tot_qthistor, 'fm999g990')||'</tot_qthistor_pagamentos>'||
                     '<vlcrdcax>'||to_char(aux_vlcrdcax, 'fm999g999g999g990d00')||'</vlcrdcax>');
      -- Lotes de empréstimos
      -- Leitura dos lotes
      for rw_craplot in cr_craplot (pr_cdcooper,
                                    vr_dtmvtolt,
                                    1) loop
        pc_escreve_xml('<Lotes_Emprestimos>');
        pc_escreve_xml('<cdagenci>'||to_char(rw_craplot.cdagenci, 'fm990')||'</cdagenci>'||
                       '<cdbccxlt>'||to_char(rw_craplot.cdbccxlt, 'fm990')||'</cdbccxlt>'||
                       '<nrdolote>'||to_char(rw_craplot.nrdolote, 'fm999g990')||'</nrdolote>'||
                       '<tplotmov>'||to_char(rw_craplot.tplotmov, 'fm0')||'</tplotmov>'||
                       '<vlcompdb>'||to_char(rw_craplot.vlcompdb, 'fm999g999g999g990d00')||'</vlcompdb>'||
                       '<vlcompcr>'||to_char(rw_craplot.vlcompcr, 'fm999g999g999g990d00')||'</vlcompcr>');
        pc_escreve_xml('</Lotes_Emprestimos>');
      end loop;
    -- Fecha os empréstimos
    pc_escreve_xml('</Emprestimos>');
    --
    -- Limpar demais históricos de Empréstimos
    vr_indice := vr_craphis.first;
    vr_indice_aux := null;
    while vr_indice is not null loop
      if vr_indice in (  2,  15, 108, 282,
                        88,  93,  95,  99,
                        91,  92,  94, 277, 349, 353, 392, 393, 395, 441, 443, 2381, 2396, 2401) then
        vr_indice_aux := vr_indice;
      end if;
      vr_indice := vr_craphis.next(vr_indice);
      -- Eliminar o registro já processado
      if vr_indice_aux is not null then
        vr_craphis.delete(vr_indice_aux);
        vr_indice_aux := null;
      end if;
    end loop;
    -- Cotas / Capital
    pc_escreve_xml('<Cotas>');
      -- Inclui informações referentes a créditos
      vr_indice := vr_craphis.first;
      -- Inicializa variáveis para acumular os totais
      vr_tot_vlhistor := 0;
      vr_tot_qthistor := 0;
      --
      while vr_indice is not null loop
        if vr_craphis(vr_indice).indebcre = 'C' then
          if vr_craphis.exists(vr_indice) then
            pc_escreve_xml('<Creditos>');
            pc_escreve_xml('<dshistor>'||vr_craphis(vr_indice).dshistor||'</dshistor>'||
                           '<indebcre>'||vr_craphis(vr_indice).indebcre||'</indebcre>'||
                           '<vlhistor>'||to_char(vr_craphis(vr_indice).vlhistor, 'fm999g999g999g990d00')||'</vlhistor>'||
                           '<qthistor>'||to_char(vr_craphis(vr_indice).qthistor, 'fm999g990')||'</qthistor>');
            pc_escreve_xml('</Creditos>');
            -- Acumula totais
            vr_tot_vlhistor := vr_tot_vlhistor + vr_craphis(vr_indice).vlhistor;
            vr_tot_qthistor := vr_tot_qthistor + vr_craphis(vr_indice).qthistor;
          end if;
        end if;
        vr_indice := vr_craphis.next(vr_indice);
      end loop;
      -- Inclui totais no XML
      pc_escreve_xml('<tot_vlhistor_creditos>'||to_char(vr_tot_vlhistor, 'fm999g999g999g990d00')||'</tot_vlhistor_creditos>'||
                     '<tot_qthistor_creditos>'||to_char(vr_tot_qthistor, 'fm999g990')||'</tot_qthistor_creditos>');
      -- Inclui informações referentes a débitos
      vr_indice := vr_craphis.first;
      -- Inicializa variáveis para acumular os totais
      vr_tot_vlhistor := 0;
      vr_tot_qthistor := 0;
      --
      while vr_indice is not null loop
        if vr_craphis(vr_indice).indebcre = 'D' then
          if vr_craphis.exists(vr_indice) then
            pc_escreve_xml('<Debitos>');
            pc_escreve_xml('<dshistor>'||vr_craphis(vr_indice).dshistor||'</dshistor>'||
                           '<indebcre>'||vr_craphis(vr_indice).indebcre||'</indebcre>'||
                           '<vlhistor>'||to_char(vr_craphis(vr_indice).vlhistor, 'fm999g999g999g990d00')||'</vlhistor>'||
                           '<qthistor>'||to_char(vr_craphis(vr_indice).qthistor, 'fm999g990')||'</qthistor>');
            pc_escreve_xml('</Debitos>');
            -- Acumula totais
            vr_tot_vlhistor := vr_tot_vlhistor + vr_craphis(vr_indice).vlhistor;
            vr_tot_qthistor := vr_tot_qthistor + vr_craphis(vr_indice).qthistor;
          end if;
        end if;
        vr_indice := vr_craphis.next(vr_indice);
      end loop;
      -- Inclui totais no XML
      pc_escreve_xml('<tot_vlhistor_debitos>'||to_char(vr_tot_vlhistor, 'fm999g999g999g990d00')||'</tot_vlhistor_debitos>'||
                     '<tot_qthistor_debitos>'||to_char(vr_tot_qthistor, 'fm999g990')||'</tot_qthistor_debitos>');
      -- Lotes de cotas / capital
      -- Leitura dos lotes
      for rw_craplot in cr_craplot (pr_cdcooper,
                                    vr_dtmvtolt,
                                    2) loop
        pc_escreve_xml('<Lotes_Cotas>');
        pc_escreve_xml('<cdagenci>'||to_char(rw_craplot.cdagenci, 'fm990')||'</cdagenci>'||
                       '<cdbccxlt>'||to_char(rw_craplot.cdbccxlt, 'fm990')||'</cdbccxlt>'||
                       '<nrdolote>'||to_char(rw_craplot.nrdolote, 'fm999g990')||'</nrdolote>'||
                       '<tplotmov>'||to_char(rw_craplot.tplotmov, 'fm0')||'</tplotmov>'||
                       '<vlcompdb>'||to_char(rw_craplot.vlcompdb, 'fm999g999g999g990d00')||'</vlcompdb>'||
                       '<vlcompcr>'||to_char(rw_craplot.vlcompcr, 'fm999g999g999g990d00')||'</vlcompcr>');
        pc_escreve_xml('</Lotes_Cotas>');
      end loop;
    -- Fecha as cotas / capital
    pc_escreve_xml('</Cotas>');
  -- Finaliza o XML
  pc_escreve_xml('</crrl168>');
  -- Nome base do arquivo é crrl086
  vr_nom_arquivo := 'crrl168';
  -- Número de cópias
  if pr_cdcooper = 6 then
    vr_nrcopias := 1;
  else
    vr_nrcopias := 2;
  end if;
  -- Gerar o arquivo de XML com mesmo nome e na mesma pasta do arquivo de saída
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                              pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                              pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                              pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                              pr_dsxmlnode => '/crrl168',          --> Nó base do XML para leitura dos dados
                              pr_dsjasper  => 'crrl168.jasper',    --> Arquivo de layout do iReport
                              pr_dsparams  => null,                --> Enviar como parâmetro apenas a agência
                              pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo||'.lst', --> Arquivo final com código da agência
                              pr_flg_gerar => 'N',
                              pr_qtcoluna  => 80,
                              pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)
                              pr_nmformul  => '80col',                --> Nome do formulário para impressão
                              pr_nrcopias  => vr_nrcopias,         --> Número de cópias para impressão
                              pr_des_erro  => vr_dscritic);        --> Saída com erro
  -- Liberando a memória alocada pro CLOB
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
                                 pr_nmarqlog => vr_cdprogra,
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
    pr_cdcritic := NVL(vr_cdcritic,0);
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

