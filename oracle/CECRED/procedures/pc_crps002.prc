CREATE OR REPLACE PROCEDURE pc_crps002(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                       pr_dtmvtolt IN craplcm.dtmvtolt%type,
                                       pr_flgresta IN NUMBER, --> Indicador de restart
                                       pr_nrctares IN crapass.nrdconta%type,
                                       pr_stprogra OUT PLS_INTEGER,
                                       pr_infimsol OUT PLS_INTEGER, --> Saída de termino da solicitação
                                       pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                       pr_dscritic OUT VARCHAR2) IS
  /* ............................................................................
   Programa: PC_CRPS002 (Antigo Fontes/crps002.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Renato Raul Cordeiro - AMcom
   Data    : Dezembro/2018.                       Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diario
   Objetivo  : Atende a solicitacao 001 (batch - atualizacao).
               Liberar diariamente os depositos bloqueados para o dia seguinte.

   Alteracoes: 

   */

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop, cop.nmextcop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS002';

  vr_exc_saida exception;

  vr_nrdconta crapass.nrdconta%type;
  vr_cdhistor crapdpb.cdhistor%type;
  vr_nrdocmto crapdpb.nrdocmto%type;
  vr_cdagenci crapdpb.cdagenci%type;
  vr_cdbccxlt crapdpb.cdbccxlt%type;
  vr_nrdctabb crapass.nrdconta%type;
  
  vr_inhistor craphis.inhistor%type;

  vr_tptransa craptrf.tptransa%type;
  vr_insittrs craptrf.insittrs%type;

  vr_flgfirst number(1);

  vr_rowid_crapsld rowid;

  vr_vlsdbloq crapsld.vlsdbloq%type;

  vr_vlsdblpr crapsld.vlsdblpr%type;

  vr_vlsdblfp crapsld.vlsdblfp%type;

  wexiste number(1);

  vr_crapsld_rowid rowid;

  vr_nrctares crapass.nrdconta%type;
  vr_dsrestar varchar2(2000);
  vr_inrestar number;

  vr_tab_retorno lanc0001.typ_reg_retorno;
  vr_incrineg  INTEGER;

  PROCEDURE pr_verifica_conta_prejuizo (pr_cdcooper IN  craplcm.cdcooper%TYPE 
                                      , pr_nrdconta IN  craplcm.nrdconta%TYPE
                                      , pr_dtmvtolt IN  craplcm.dtmvtolt%TYPE
                                      , pr_cdhistor IN  craplcm.cdhistor%TYPE
                                      , pr_nrdocmto IN  craplcm.nrdocmto%type
                                      , pr_cdagenci IN  craplcm.cdagenci%type
                                      , pr_cdbccxlt IN  craplcm.cdbccxlt%type
                                      , pr_vllanmto IN  craplcm.vllanmto%TYPE
                                      , pr_nrdctabb IN  craplcm.nrdctabb%TYPE) is
    vr_nrseqdig       craplot.nrseqdig%TYPE;   -- Aramazena o valor do campo "nrseqdig" da CRAPLOT para referência na CRAPLCM
                                      
  begin
    if prej0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta) then

        vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
                                  ,pr_nmdcampo => 'NRSEQDIG'
                                  ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                  to_char(pr_dtmvtolt, 'DD/MM/RRRR')||';'||
                                  '1;100;650009');

        -- Efetua débito do valor que será transferido para a Conta Transitória (créditos bloqueados por prejuízo em conta)
        lanc0001.pc_gerar_lancamento_conta(
           pr_dtmvtolt => pr_dtmvtolt,
           pr_cdagenci => pr_cdagenci,
           pr_cdbccxlt => pr_cdbccxlt,
           pr_nrdolote => 650009,
           pr_nrdconta => pr_nrdconta,
           pr_nrdocmto => pr_nrdocmto,
           pr_cdhistor => 2719,
           pr_nrseqdig => vr_nrseqdig,
           pr_vllanmto => pr_vllanmto,
           pr_nrdctabb => pr_nrdctabb,
           pr_cdpesqbb => 'ESTORNO DE CREDITO RECEBIDO EM C/C EM PREJUIZO',
           pr_dtrefere => pr_dtmvtolt,
           pr_hrtransa => gene0002.fn_busca_time,
           pr_cdoperad => 1,
           pr_cdcooper => pr_cdcooper,
           pr_cdorigem => 5,
           pr_tab_retorno => vr_tab_retorno,
           pr_incrineg => vr_incrineg,
           pr_cdcritic => pr_cdcritic,
           pr_dscritic => pr_dscritic
        );

        if (nvl(pr_cdcritic,0) <> 0 or trim(pr_dscritic) is not null) then
           RAISE vr_exc_saida;
        end if;

        -- Insere lançamento do crédito transferido para a Conta Transitória
        INSERT INTO TBCC_PREJUIZO_LANCAMENTO (
               dtmvtolt
             , cdagenci
             , nrdconta
             , nrdocmto
             , cdhistor
             , vllanmto
             , dthrtran
             , cdoperad
             , cdcooper
             , cdorigem
        )
        VALUES (
               pr_dtmvtolt
             , pr_cdagenci
             , pr_nrdconta
             , pr_nrdocmto
             , 2738 
             , pr_vllanmto
             , SYSDATE
             , 1
             , pr_cdcooper
             , 5
        );

    end if;
  end pr_verifica_conta_prejuizo;


BEGIN
  vr_nrdconta := 0;
  vr_cdhistor := 0;
  vr_nrdocmto := 0;
  vr_cdagenci := 0;
  vr_cdbccxlt := 0;
  vr_nrdctabb := 0;

  vr_flgfirst := 1;

  vr_vlsdbloq := 0;
  vr_vlsdblpr := 0;
  vr_vlsdblfp := 0;

  vr_nrctares := pr_nrctares;

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                             pr_action => null);
  -- Verifica se a cooperativa esta cadastrada
  OPEN cr_crapcop;
  FETCH cr_crapcop
    INTO rw_crapcop;
  -- Se não encontrar
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor pois haverá raise
    CLOSE cr_crapcop;
    -- Montar mensagem de critica
    pr_cdcritic := 651;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;
  END IF;

  -- Leitura do calendário da cooperativa
  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  -- Se não encontrar
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE btch0001.cr_crapdat;
    -- Montar mensagem de critica
    pr_cdcritic := 1;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE btch0001.cr_crapdat;
  END IF;

  -- Validações iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                            pr_flgbatch => 1,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_cdcritic => pr_cdcritic);
  -- Se a variavel de erro é <> 0
  IF pr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  -- Tratamento e retorno de valores de restart
  btch0001.pc_valida_restart(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                            ,
                             pr_cdprogra => vr_cdprogra --> Código do programa
                            ,
                             pr_flgresta => pr_flgresta --> Indicador de restart
                            ,
                             pr_nrctares => vr_nrctares --> Número da conta de restart
                            ,
                             pr_dsrestar => vr_dsrestar --> String genérica com informações para restart
                            ,
                             pr_inrestar => vr_inrestar --> Indicador de Restart
                            ,
                             pr_cdcritic => pr_cdcritic --> Código da critica
                            ,
                             pr_des_erro => pr_dscritic); --> Saída de erro
  -- Se encontrou erro, gerar exceção
  IF pr_dscritic IS NOT NULL OR pr_cdcritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
  -- Se houver indicador de restart, mas não veio conta
  IF vr_inrestar > 0 AND vr_nrctares = 0 THEN
    -- Remover o indicador
    vr_inrestar := 0;
  END IF;

  for rw_crapdpb in (select h.inhistor,
                            a.cdcooper,
                            a.nrdconta,
                            a.cdhistor,
                            a.nrdocmto,
                            a.cdagenci,
                            a.cdbccxlt,
                            a.vllanmto
                       from craptrf b, craphis h, crapdpb a
                      WHERE a.cdcooper = pr_cdcooper
                        AND a.dtliblan = pr_dtmvtolt
                        AND a.nrdconta > nvl(pr_nrctares, 0)
                        and a.cdcooper = h.cdcooper
                        and a.cdhistor = h.cdhistor
--                        and a.nrdconta=33367
                        and a.cdcooper = b.cdcooper(+)
                        and a.nrdconta = b.nrdconta(+)
                        AND a.inlibera = 1
                        and ((not (b.tptransa = 1 and b.insittrs = 2)) or
                            (b.tptransa is null and b.insittrs is null))
                      order by a.cdcooper,
                               a.nrdconta,
                               a.dtliblan,
                               a.cdhistor) loop

    vr_inhistor := rw_crapdpb.inhistor;
  
    if vr_flgfirst = 1 then
      vr_nrdconta := rw_crapdpb.nrdconta;
      vr_cdhistor := rw_crapdpb.cdhistor;
      vr_nrdocmto := rw_crapdpb.nrdocmto;
      vr_cdagenci := rw_crapdpb.cdagenci;
      vr_cdbccxlt := rw_crapdpb.cdbccxlt;
      vr_nrdctabb := rw_crapdpb.nrdconta;
      vr_flgfirst := 0;
    end if;
  
    if rw_crapdpb.nrdconta = vr_nrdconta then
    
      if vr_inhistor = 3 then
        vr_vlsdbloq := vr_vlsdbloq + rw_crapdpb.vllanmto;
      elsif vr_inhistor = 4 then
        vr_vlsdblpr := vr_vlsdblpr + rw_crapdpb.vllanmto;
      elsif vr_inhistor = 5 then
        vr_vlsdblfp := vr_vlsdblfp + rw_crapdpb.vllanmto;
      else
        pr_cdcritic := 83;
        btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper,
                                   pr_ind_tipo_log  => 2 -- Erro de negócio
                                  ,
                                   pr_nmarqlog      => 'proc_batch.log',
                                   pr_tpexecucao    => 1 -- Job
                                  ,
                                   pr_cdcriticidade => 1 -- Medio
                                  ,
                                   pr_cdmensagem    => pr_cdcritic,
                                   pr_des_log       => to_char(sysdate,
                                                               'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' - ' || vr_cdprogra ||
                                                       ' --> ' ||
                                                       pr_dscritic ||
                                                       ' Conta:' ||
                                                       vr_nrdconta);
        raise vr_exc_saida;
      end if;
    end if;
    -- ponto 2
    if rw_crapdpb.nrdconta <> vr_nrdconta then
    
      begin
        select 1
          into wexiste
          from crapsld s
         where s.cdcooper = pr_cdcooper
           and s.nrdconta = vr_nrdconta;
      exception
        when no_data_found then
          pr_cdcritic := 10;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
          btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper,
                                     pr_ind_tipo_log  => 2 -- Erro de negócio
                                    ,
                                     pr_nmarqlog      => 'proc_batch.log',
                                     pr_tpexecucao    => 1 -- Job
                                    ,
                                     pr_cdcriticidade => 1 -- Medio
                                    ,
                                     pr_cdmensagem    => pr_cdcritic,
                                     pr_des_log       => to_char(sysdate,
                                                                 'DD/MM/RRRR hh24:mi:ss') ||
                                                         ' - ' ||
                                                         vr_cdprogra ||
                                                         ' --> ' ||
                                                         pr_dscritic ||
                                                         ' Conta:' ||
                                                         vr_nrdconta);
          raise vr_exc_saida;
      end;

      pr_verifica_conta_prejuizo (pr_cdcooper => pr_cdcooper
                                , pr_nrdconta => vr_nrdconta
                                , pr_dtmvtolt => pr_dtmvtolt
                                , pr_cdhistor => vr_cdhistor
                                , pr_nrdocmto => vr_nrdocmto
                                , pr_cdagenci => vr_cdagenci
                                , pr_cdbccxlt => vr_cdbccxlt
                                , pr_vllanmto => vr_vlsdbloq
                                , pr_nrdctabb => vr_nrdctabb);

      update crapsld s
         set s.vlsdbloq = s.vlsdbloq - vr_vlsdbloq,
             s.vlsdblpr = s.vlsdblpr - vr_vlsdblpr,
             s.vlsdblfp = s.vlsdblfp - vr_vlsdblfp,
             s.vlsddisp = s.vlsddisp +
                          (vr_vlsdbloq + vr_vlsdblpr + vr_vlsdblfp),
             s.vlindext = 1
       where s.cdcooper = pr_cdcooper
         and s.nrdconta = vr_nrdconta
      returning rowid into vr_crapsld_rowid;
    
      if vr_inhistor = 3 then
        vr_vlsdbloq := rw_crapdpb.vllanmto;
        vr_vlsdblpr := 0;
        vr_vlsdblfp := 0;
      elsif vr_inhistor = 4 then
        vr_vlsdbloq := 0;
        vr_vlsdblpr := rw_crapdpb.vllanmto;
        vr_vlsdblfp := 0;
      elsif vr_inhistor = 5 then
        vr_vlsdbloq := 0;
        vr_vlsdblpr := 0;
        vr_vlsdblfp := rw_crapdpb.vllanmto;
      else
        pr_cdcritic := 83;
        btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper,
                                   pr_ind_tipo_log  => 2 -- Erro de negócio
                                  ,
                                   pr_nmarqlog      => 'proc_batch.log',
                                   pr_tpexecucao    => 1 -- Job
                                  ,
                                   pr_cdcriticidade => 1 -- Medio
                                  ,
                                   pr_cdmensagem    => pr_cdcritic,
                                   pr_des_log       => to_char(sysdate,
                                                               'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' - ' || vr_cdprogra ||
                                                       ' --> ' ||
                                                       pr_dscritic ||
                                                       ' Conta:' ||
                                                       vr_nrdconta);
        raise vr_exc_saida;
      end if;
    
      begin
        wexiste := 1;
        select 1
          into wexiste
          from crapsld s
         where rowid = vr_crapsld_rowid
           and ((s.vlsdbloq < 0) or (s.vlsdblpr < 0) or (s.vlsdblfp < 0));
      exception
        when no_data_found then
          wexiste := 0;
      end;
    
      if wexiste = 0 then
        pr_cdcritic := 136;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper,
                                   pr_ind_tipo_log  => 2 -- Erro de negócio
                                  ,
                                   pr_nmarqlog      => 'proc_batch.log',
                                   pr_tpexecucao    => 1 -- Job
                                  ,
                                   pr_cdcriticidade => 1 -- Medio
                                  ,
                                   pr_cdmensagem    => pr_cdcritic,
                                   pr_des_log       => to_char(sysdate,
                                                               'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' - ' || vr_cdprogra ||
                                                       ' --> ' ||
                                                       pr_dscritic ||
                                                       ' Conta:' ||
                                                       vr_nrdconta);
      end if;
    
      -- ponto 3
      update crapres a
         set a.nrdconta = vr_nrdconta
       where a.cdcooper = pr_cdcooper
         and a.cdprogra = vr_cdprogra;
      if SQL%ROWCOUNT = 0 then
        pr_cdcritic := 151;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper,
                                   pr_ind_tipo_log  => 2 -- Erro de negócio
                                  ,
                                   pr_nmarqlog      => 'proc_batch.log',
                                   pr_tpexecucao    => 1 -- Job
                                  ,
                                   pr_cdcriticidade => 1 -- Medio
                                  ,
                                   pr_cdmensagem    => pr_cdcritic,
                                   pr_des_log       => to_char(sysdate,
                                                               'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' - ' || vr_cdprogra ||
                                                       ' --> ' ||
                                                       pr_dscritic ||
                                                       ' Conta:' ||
                                                       vr_nrdconta);
--        raise vr_exc_saida;
      end if;
    
      if vr_inhistor = 3 then
        vr_vlsdbloq := rw_crapdpb.vllanmto;
      elsif vr_inhistor = 4 then
        vr_vlsdblpr := rw_crapdpb.vllanmto;
      elsif vr_inhistor = 5 then
        vr_vlsdblfp := rw_crapdpb.vllanmto;
      else
        pr_cdcritic := 83;
        btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper,
                                   pr_ind_tipo_log  => 2 -- Erro de negócio
                                  ,
                                   pr_nmarqlog      => 'proc_batch.log',
                                   pr_tpexecucao    => 1 -- Job
                                  ,
                                   pr_cdcriticidade => 1 -- Medio
                                  ,
                                   pr_cdmensagem    => pr_cdcritic,
                                   pr_des_log       => to_char(sysdate,
                                                               'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' - ' || vr_cdprogra ||
                                                       ' --> ' ||
                                                       pr_dscritic ||
                                                       ' Conta:' ||
                                                       vr_nrdconta);
        raise vr_exc_saida;
      end if;
    
    end if;
  
    -- atribui ultimo numero da conta processado
    vr_nrdconta := rw_crapdpb.nrdconta;
    vr_cdhistor := rw_crapdpb.cdhistor;
    vr_nrdocmto := rw_crapdpb.nrdocmto;
    vr_cdagenci := rw_crapdpb.cdagenci;
    vr_cdbccxlt := rw_crapdpb.cdbccxlt;
    vr_nrdctabb := rw_crapdpb.nrdconta;
  
  end loop;

  -- ponto 5
  if vr_nrdconta <> 0 then

    pr_verifica_conta_prejuizo (pr_cdcooper => pr_cdcooper
                              , pr_nrdconta => vr_nrdconta
                              , pr_dtmvtolt => pr_dtmvtolt
                              , pr_cdhistor => vr_cdhistor
                              , pr_nrdocmto => vr_nrdocmto
                              , pr_cdagenci => vr_cdagenci
                              , pr_cdbccxlt => vr_cdbccxlt
                              , pr_vllanmto => vr_vlsdbloq
                              , pr_nrdctabb => vr_nrdctabb);

    update crapsld s
       set s.vlsdbloq = s.vlsdbloq - vr_vlsdbloq,
           s.vlsdblpr = s.vlsdblpr - vr_vlsdblpr,
           s.vlsdblfp = s.vlsdblfp - vr_vlsdblfp,
           s.vlsddisp = vlsddisp + (vr_vlsdbloq + vr_vlsdblpr + vr_vlsdblfp),
           s.vlindext = 1
     where s.cdcooper = pr_cdcooper
       and s.nrdconta = vr_nrdconta
    returning rowid into vr_crapsld_rowid;
  
    begin
      wexiste := 1;
      select 1
        into wexiste
        from crapsld s
       where rowid = vr_crapsld_rowid
         and ((s.vlsdbloq < 0) or (s.vlsdblpr < 0) or (s.vlsdblfp < 0));
    exception
      when no_data_found then
        wexiste := 0;
    end;
  
    if wexiste = 0 then
      pr_cdcritic := 136;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper,
                                 pr_ind_tipo_log  => 2 -- Erro de negócio
                                ,
                                 pr_nmarqlog      => 'proc_batch.log',
                                 pr_tpexecucao    => 1 -- Job
                                ,
                                 pr_cdcriticidade => 1 -- Medio
                                ,
                                 pr_cdmensagem    => pr_cdcritic,
                                 pr_des_log       => to_char(sysdate,
                                                             'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' - ' || vr_cdprogra ||
                                                     ' --> ' || pr_dscritic ||
                                                     ' Conta:' ||
                                                     vr_nrdconta);
    end if;
  
    -- ponto 6
    update crapres a
       set a.nrdconta = vr_nrdconta
     where a.cdcooper = pr_cdcooper
       and a.cdprogra = vr_cdprogra;
    if SQL%ROWCOUNT = 0 then
      pr_cdcritic := 151;
      btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper,
                                 pr_ind_tipo_log  => 2 -- Erro de negócio
                                ,
                                 pr_nmarqlog      => 'proc_batch.log',
                                 pr_tpexecucao    => 1 -- Job
                                ,
                                 pr_cdcriticidade => 1 -- Medio
                                ,
                                 pr_cdmensagem    => pr_cdcritic,
                                 pr_des_log       => to_char(sysdate,
                                                             'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' - ' || vr_cdprogra ||
                                                     ' --> ' || pr_dscritic ||
                                                     ' Conta:' ||
                                                     vr_nrdconta);
--      raise vr_exc_saida;
    end if;
  end if;

  /* Eliminação dos registros de restart */
  BTCH0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_flgresta => pr_flgresta,
                              pr_des_erro => pr_dscritic);
  --Se ocorreu erro
  IF pr_dscritic IS NOT NULL THEN
    --Levantar Exceção
    RAISE vr_exc_saida;
  END IF;

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_stprogra => pr_stprogra);

exception
  when vr_exc_saida then
    if pr_cdcritic is not null and pr_dscritic is null then
      rollback;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    end if;
    rollback;
END pc_crps002;
/
