CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS002(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa Solicitada
                                             ,pr_flgresta IN PLS_INTEGER --> Flag 0/1 para utilizar restart na chamada
                                             ,pr_stprogra OUT PLS_INTEGER --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS --> Texto de erro/critica encontrada
  /* ..........................................................................
  
     Programa: Fontes/crps002.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Edson
     Data    : Novembro/91.                        Ultima atualizacao: 14/10/2016
  
     Dados referentes ao programa:
  
     Frequencia: Diario.
     Objetivo  : Atende a solicitacao 001 (Batch - atualizacao).
                 Liberar diariamente os depositos bloqueados para o dia seguinte.
  
     Alteracoes: 22/04/1998 - Tratamento para milenio e troca para V8 (Margarete).
                 
                 28/08/2003 - Incluir numero da conta na critica quando valor do
                              saldo bloqueado for negativo (Junior). 
                              
                 14/02/2006 - Unificacao dos bancos - SQLWorks - Eder      
                 
                 09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                              glb_cdcooper) no "find" da tabela CRAPHIS. 
                            - Kbase IT Solutions - Paulo Ricardo Maciel.
                            
                 19/10/2009 - Alteracao Codigo Historico (Kbase).
                 
                 14/10/2016 - Conversão para PL/SQL (Linhares) 
                        
  ............................................................................. */

BEGIN

  DECLARE
  
    --Variaveis de Críticas
    vr_cdcritic INTEGER;
    vr_cdprogra VARCHAR2(10);
    vr_dscritic VARCHAR2(4000);
  
    --Variaveis de Excecao
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
  
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.nrtelura,
             cop.cdbcoctl,
             cop.cdagectl,
             cop.dsdircop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
  
    --Cursor para a tabela de depósitos bloqueados
    CURSOR cr_crapdpb(pr_cdcooper IN craptab.cdcooper%TYPE, pr_dtliblan IN crapdat.dtmvtolt%TYPE) IS
      SELECT dpb.nrdconta,
             dpb.vllanmto,
             his.cdhistor,
             his.inhistor,
             ROW_NUMBER() OVER(PARTITION BY dpb.cdcooper, dpb.nrdconta ORDER BY dpb.nrdconta) nrseq,
             COUNT(1) OVER(PARTITION BY dpb.cdcooper, dpb.nrdconta ORDER BY dpb.nrdconta) qtdregis
        FROM crapdpb dpb,
             craphis his
       WHERE dpb.cdcooper = pr_cdcooper
         AND dpb.dtliblan = pr_dtliblan
         AND dpb.inlibera = 1
         AND his.cdcooper(+) = dpb.cdcooper
         AND his.cdhistor(+) = dpb.cdhistor
       ORDER BY dpb.nrdconta;
    rw_crapdpb cr_crapdpb%ROWTYPE;
  
    --Tipo de dado para receber as datas da tabela crapdat
    rw_crapdat btch0001.rw_crapdat%TYPE;
  
    -- Variáveis para sumarização dos lançamentos
    vr_vlsdbloq crapsld.vlsdbloq%TYPE;
    vr_vlsdblpr crapsld.vlsdblpr%TYPE;
    vr_vlsdblfp crapsld.vlsdblfp%TYPE;
  
  BEGIN
  
    ----------------------
    -- Validações iniciais
    ----------------------
  
    vr_cdprogra := 'CRPS002';
  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);
  
    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                              pr_flgbatch => 1,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_cdcritic => vr_cdcritic);
  
    --Se retornou critica aborta programa
    IF vr_cdcritic <> 0 THEN
      RAISE vr_exc_saida;
    END IF;
  
    -------------------
    -- Rotina Principal
    -------------------
  
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
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
  
    -- Busca a data Atual
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
  
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;
  
    -- Varre os depósitos bloqueados
    FOR rw_crapdpb IN cr_crapdpb(pr_cdcooper => pr_cdcooper,
                                 pr_dtliblan => rw_crapdat.dtmvtolt) LOOP
    
      -- Limpa Variaveis
      IF rw_crapdpb.nrseq = 1 THEN
        vr_vlsdbloq := 0;
        vr_vlsdblpr := 0;
        vr_vlsdblfp := 0;
      END IF;
    
      -- Se não há histórico efetua Raise
      IF NVL(rw_crapdpb.cdhistor,
             0) = 0 THEN
        vr_cdcritic := 80; -- Lancamento sem historico cadastrado
        RAISE vr_exc_saida;
      END IF;
    
      CASE rw_crapdpb.inhistor
        WHEN 3 THEN
          vr_vlsdbloq := vr_vlsdbloq + rw_crapdpb.vllanmto;
        WHEN 4 THEN
          vr_vlsdblpr := vr_vlsdblpr + rw_crapdpb.vllanmto;
        WHEN 5 THEN
          vr_vlsdblfp := vr_vlsdblfp + rw_crapdpb.vllanmto;
        ELSE
          vr_cdcritic := 83; -- Historico desconhecido no lancamento.
          RAISE vr_exc_saida;
      END CASE;
    
      -- se varreu todos os lançamentos da conta
      IF (rw_crapdpb.nrseq = rw_crapdpb.qtdregis) THEN
      
        -- Atualiza Saldo
        BEGIN
          UPDATE crapsld sld
             SET sld.vlsdbloq = sld.vlsdbloq - vr_vlsdbloq,
                 sld.vlsdblpr = sld.vlsdblpr - vr_vlsdblpr,
                 sld.vlsdblfp = sld.vlsdblfp - vr_vlsdblfp,
                 sld.vlsddisp = sld.vlsddisp + (vr_vlsdbloq + vr_vlsdblpr + vr_vlsdblfp)
           WHERE sld.cdcooper = pr_cdcooper
             AND sld.nrdconta = rw_crapdpb.nrdconta
          RETURNING sld.vlsdbloq, sld.vlsdblpr, sld.vlsdblfp INTO vr_vlsdbloq, vr_vlsdblpr, vr_vlsdblfp;
          IF SQL%ROWCOUNT = 0 THEN
            vr_cdcritic := 10; -- Associado sem registro de saldo.
            RAISE vr_exc_saida;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro no atualizar CRAPSLD - Conta: ' || to_char(rw_crapdpb.nrdconta) || ' ' ||
                           SQLERRM;
            RAISE vr_exc_saida;
        END;
      
        -- Valida Saldo Negativo
        IF (vr_vlsdbloq < 0 OR vr_vlsdblpr < 0 OR vr_vlsdblfp < 0) THEN
          vr_cdcritic := 136; -- Valor do saldo bloqueado negativo.
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2,
                                     pr_des_log      => to_char(SYSDATE,
                                                                'hh24:mi:ss') || ' - ' ||
                                                        vr_cdprogra || ' --> ' || vr_dscritic ||
                                                        ' Conta: ' || rw_crapdpb.nrdconta);
        
          -- Limpa Criticas
          vr_cdcritic := 0;
          vr_dscritic := NULL;
        END IF;
      
      END IF;
    
    END LOOP;
  
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);
  
    COMMIT;
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic > 0 AND
         vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := NVL(vr_cdcritic,
                         0);
      pr_dscritic := vr_dscritic;
      ROLLBACK;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na procedure pc_crps002. ' || SQLERRM;
      ROLLBACK;
    
  END;

END;
/
