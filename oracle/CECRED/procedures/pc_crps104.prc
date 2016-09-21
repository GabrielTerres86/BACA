create or replace procedure cecred.pc_crps104(pr_cdcooper  in craptab.cdcooper%type,
                                       pr_flgresta  in pls_integer,            --> Flag padrão para utilização de restart
                                       pr_stprogra out pls_integer,            --> Saída de termino da execução
                                       pr_infimsol out pls_integer,            --> Saída de termino da solicitação,
                                       pr_cdcritic out crapcri.cdcritic%type,
                                       pr_dscritic out varchar2) as
/* ..........................................................................

   Programa: pc_crps104 - antigo Fontes/crps104.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/94.                    Ultima atualizacao: 05/09/2013

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 1.
               Calcula as aplicacoes RDCA aniversariantes.
               Ordem do programa da solicitacao: 8.
               Nao gera relatorio.

   Alteracao : 22/11/96 - Alterado para selecionar somente aplicacoes com
                          tpaplica = 3 (Odair).

             15/12/2004 - Ajustes para tratar das novas aliquotas de
                           IRRF (Margarete).

             06/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                          "fontes/iniprg.p" por causa da "glb_cdcooper"
                          (Evandro).

             15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

             26/11/2010 - Retirar da sol 1 ordem 90 e colocar na sol 82
                          ordem 79.E na CECRED sol 82 e ordem 82  (Magui).

             05/09/2013 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero).
............................................................................. */
  -- Data do movimento
  cursor cr_crapdat(pr_cdcooper in craptab.cdcooper%type) is
    select dat.dtmvtolt,
           dat.dtmvtopr,
           dat.inproces
      from crapdat dat
     where dat.cdcooper = pr_cdcooper;
  -- Aplicações RDCA não calculadas no mês
  cursor cr_craprda (pr_cdcooper in craprda.cdcooper%type,
                     pr_nrdconta in craprda.nrdconta%type,
                     pr_dtmvtolt in craprda.dtfimper%type) is
    select craprda.nrdconta,
           craprda.nraplica,
           craprda.rowid
      from craprda
     where craprda.cdcooper = pr_cdcooper
       and craprda.nrdconta >= pr_nrdconta
       and craprda.dtfimper <= pr_dtmvtolt
       and craprda.insaqtot = 0
       and craprda.incalmes = 0
       and craprda.tpaplica = 3
     order by nrdconta,
              nraplica;
  --
  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%type;
  vr_dtmvtopr      crapdat.dtmvtopr%type;
  vr_inproces      crapdat.inproces%type;
  -- Tratamento de erros
  vr_exc_saida     EXCEPTION;
  vr_exc_fimprg    EXCEPTION;
  vr_cdcritic      PLS_INTEGER;
  vr_dscritic      VARCHAR2(4000);
  -- Variáveis para controle de reprocesso
  vr_dsrestar      crapres.dsrestar%type;
  vr_nrctares      crapres.nrdconta%type;
  vr_inrestar      number(1);
  -- Variáveis de retorno do cálculo da aplicação
  vr_insaqtot      craprda.insaqtot%type;
  vr_vlsdrdca      craprda.vlsdrdca%type;
  vr_sldpresg      craprda.vlsdrdca%type;
  vr_dup_vlsdrdca  craprda.vlsdrdca%type;
  --
begin
  -- Nome do programa
  vr_cdprogra := 'CRPS104';
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
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS104',
                             pr_action => vr_cdprogra);
  -- Buscar a data do movimento
  open cr_crapdat(pr_cdcooper);
    fetch cr_crapdat into vr_dtmvtolt,
                          vr_dtmvtopr,
                          vr_inproces;
  close cr_crapdat;
  -- Buscar informações de reprocesso
  btch0001.pc_valida_restart (pr_cdcooper,
                              vr_cdprogra,
                              pr_flgresta,
                              vr_nrctares,
                              vr_dsrestar,
                              vr_inrestar,
                              vr_cdcritic,
                              vr_dscritic);
  if vr_dscritic is not null then
    raise vr_exc_saida;
  end if;
  -- Busca faixas de IR
  apli0001.pc_busca_faixa_ir_rdca(pr_cdcooper);
  -- Busca aplicações RDCA não calculadas no mês
  for rw_craprda in cr_craprda (pr_cdcooper,
                                vr_nrctares,
                                vr_dtmvtolt) loop
    -- Verifica se tem conta para restart e descarta as aplicações já processadas
    if vr_inrestar > 0 and
       rw_craprda.nrdconta = vr_nrctares and
       rw_craprda.nraplica <= to_number(vr_dsrestar) then
      continue;
    end if;
    -- Executa o cálculo da aplicação
    apli0001.pc_calc_aplicacao(pr_cdcooper,
                               vr_dtmvtolt,
                               vr_dtmvtopr,
                               rw_craprda.rowid,
                               vr_cdprogra,
                               vr_inproces,
                               vr_insaqtot,
                               vr_vlsdrdca,
                               vr_sldpresg,
                               vr_dup_vlsdrdca,
                               vr_cdcritic,
                               vr_dscritic);
    -- Verifica se conseguiu calcular
    if vr_dscritic is not null then
      raise vr_exc_saida;
    end if;
    -- Verifica se foi saque total e possui saldo, e ajusta o indicador
    if vr_insaqtot = 1 and
       vr_vlsdrdca > 0 then
      begin
        update craprda
           set craprda.insaqtot = 0
         where craprda.rowid = rw_craprda.rowid;
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar a aplicação RDCA: '||sqlerrm;
          raise vr_exc_saida;
      end;
    end if;
    -- Atualiza controle de reprocesso
    begin
      update crapres
         set crapres.nrdconta = rw_craprda.nrdconta,
             crapres.dsrestar = to_char(rw_craprda.nraplica)
       where crapres.cdcooper = pr_cdcooper
         and crapres.cdprogra = vr_cdprogra;
      if sql%rowcount = 0 then
        vr_cdcritic := 151;
        vr_dscritic := gene0001.fn_busca_critica(151);
        --
        raise vr_exc_saida;
      end if;
    exception
      when others then
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar controle de reprocesso: '||sqlerrm;
        raise vr_exc_saida;
    end;
    -- Verificar a quantidade de registros processados e comitar a cada 5000
    IF mod(cr_craprda%ROWCOUNT,5000) = 0 THEN
      commit;
    END IF;
  end loop;
  -- Eliminar controle de reprocesso
  btch0001.pc_elimina_restart(pr_cdcooper,
                              vr_cdprogra,
                              pr_flgresta,
                              vr_dscritic);
  if vr_dscritic is not null then
    vr_cdcritic := 0;
    raise vr_exc_saida;
  end if;
  --
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

