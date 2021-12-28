declare
  vr_cdcooper  crapcop.cdcooper%TYPE; --> Codigo Cooperativa
  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

  -- Codigo do programa
  vr_cdprogra        CONSTANT crapprg.cdprogra%TYPE := 'CRPS720';
  
  -- Tratamento de erros
  vr_exc_saida       EXCEPTION;
  vr_cdcritic        PLS_INTEGER;
  vr_dscritic        VARCHAR2(4000);

  vr_idprglog        NUMBER := 0;
  vr_qtdias_carencia NUMBER := 0;
  
  --geracao arquivo
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/inc0117237';
  vr_nmarqimp        VARCHAR2(100)  := 'inc0117237_rollback.txt';   
  vr_ind_arquiv      utl_file.file_type;

  ------------------------------- CURSORES ---------------------------------

  -- Busca os dados dos contratos e parcelas
  CURSOR cr_epr_pep IS
    SELECT crapepr.cdagenci,
           crapepr.nrdconta,
           crapepr.nrctremp,
           crapepr.dtmvtolt,
           crapepr.qtpreemp,
           crapepr.vlsprojt,
           crawepr.dtdpagto,
           crapepr.vlemprst,
           crapepr.cdlcremp,
           crawepr.txmensal,
           crawepr.idcarenc,
           crawepr.cddindex,
           ROW_NUMBER() OVER(PARTITION BY crapepr.nrdconta ORDER BY crapepr.cdcooper, crapepr.nrdconta) AS numconta,
           COUNT(1) OVER(PARTITION BY crapepr.nrdconta) qtdconta,
           crawepr.cdcooper,
           pep2.dtvencto dtaniversario,
           crapepr.vlpreemp,
           pep1.vlparepr, 
           pep1.vlsdvpar,
           pep1.nrparepr
      FROM crapepr
      JOIN crawepr
        ON crawepr.cdcooper = crapepr.cdcooper
       AND crawepr.nrdconta = crapepr.nrdconta
       AND crawepr.nrctremp = crapepr.nrctremp
      JOIN crappep pep1
        ON pep1.cdcooper = crapepr.cdcooper
       AND pep1.nrdconta = crapepr.nrdconta
       AND pep1.nrctremp = crapepr.nrctremp
       AND pep1.inliquid = 0
       AND pep1.dtvencto BETWEEN to_date('01/01/2022', 'dd/mm/yyyy') AND to_date('17/01/2022', 'dd/mm/yyyy')
      JOIN crappep pep2
        ON pep2.cdcooper = crapepr.cdcooper
       AND pep2.nrdconta = crapepr.nrdconta
       AND pep2.nrctremp = crapepr.nrctremp
       AND (pep2.vlmtapar > 0 OR pep2.vlpagmta > 0)
       AND pep2.dtvencto BETWEEN to_date('01/12/2021', 'dd/mm/yyyy') AND to_date('17/12/2021', 'dd/mm/yyyy')
     WHERE crapepr.tpemprst = 2 -- Pos-Fixado
       AND crapepr.inliquid = 0
       AND crawepr.dtdpagto < to_date('01/12/2021', 'dd/mm/yyyy')
       AND pep1.vlparepr > pep2.vlparepr;

  -- Busca os dados dos contratos e parcelas
  CURSOR cr_crappep(vr_cdcooper IN crappep.cdcooper%TYPE,
                    pr_nrdconta IN crappep.nrdconta%TYPE,
                    pr_nrctremp IN crappep.nrctremp%TYPE,
                    pr_dtaniver IN crappep.Dtvencto%TYPE) IS
    SELECT crappep.nrparepr, crappep.dtvencto, crappep.vltaxatu
      FROM crappep
     WHERE crappep.cdcooper = vr_cdcooper
       and crappep.nrdconta = pr_nrdconta
       and crappep.nrctremp = pr_nrctremp
       and crappep.inliquid = 0
       and crappep.dtvencto > pr_dtaniver
       and exists
     (select 1
              from crappep pep
             where pep.cdcooper = crappep.cdcooper
               and pep.nrdconta = crappep.nrdconta
               and pep.nrctremp = crappep.nrctremp
               AND pep.dtvencto >= to_date('01/01/2022', 'dd/mm/yyyy')
               AND pep.dtvencto <= to_date('17/01/2022', 'dd/mm/yyyy')) 
       and rownum = 1
     order by crappep.nrparepr asc;
  rw_crappep cr_crappep%ROWTYPE;

  -- Busca os dados da carencia
  CURSOR cr_carencia IS
    SELECT param.idcarencia, param.qtddias
      FROM tbepr_posfix_param_carencia param
     WHERE param.idparametro = 1;


  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  -- Registro para armazenar informacoes do contrato
  TYPE typ_parc_atu IS RECORD(
    cdcooper crappep.cdcooper%TYPE,
    nrdconta crappep.nrdconta%TYPE,
    nrctremp crappep.nrctremp%TYPE,
    nrparepr crappep.nrparepr%TYPE,
    vlparepr crappep.vlparepr%TYPE,
    vltaxatu crappep.vltaxatu%TYPE);

  -- Tabela onde serao armazenados os registros do contrato
  TYPE typ_tab_parc_atu IS TABLE OF typ_parc_atu INDEX BY PLS_INTEGER;

  vr_tab_parc_epr typ_tab_parc_atu;
  vr_tab_parc_pep typ_tab_parc_atu;
  vr_tab_parcelas EMPR0011.typ_tab_parcelas;
  vr_tab_carencia CADA0001.typ_tab_number;
  vr_tab_craplcr  CADA0001.typ_tab_number;
  vr_tab_craptxi  CADA0001.typ_tab_number;

  ------------------------------- VARIAVEIS -------------------------------
  vr_idx_parc_epr    PLS_INTEGER;
  vr_idx_parc_pep    PLS_INTEGER;
  vr_idx_parcelas    INTEGER;
  vr_qtdconta        INTEGER;

  --------------------------- SUBROTINAS INTERNAS --------------------------
  -- Grava os dados das parcelas, emprestimo e controle do batch
  PROCEDURE pc_grava_dados(pr_tab_parc_pep IN typ_tab_parc_atu,
                           pr_tab_parc_epr IN typ_tab_parc_atu) IS
    vr_nrdconta crapass.nrdconta%TYPE;
  BEGIN
    -- Atualizar Parcelas
    BEGIN
      FORALL idx IN 1 .. pr_tab_parc_pep.COUNT SAVE EXCEPTIONS
        UPDATE crappep
           SET vlparepr = pr_tab_parc_pep(idx).vlparepr,
               vlsdvpar = pr_tab_parc_pep(idx)
                          .vlparepr - (nvl(crappep.vlpagpar, 0) +
                                       nvl(crappep.vldespar, 0)),
               vltaxatu = pr_tab_parc_pep(idx).vltaxatu
         WHERE cdcooper = pr_tab_parc_pep(idx).cdcooper
           AND nrdconta = pr_tab_parc_pep(idx).nrdconta
           AND nrctremp = pr_tab_parc_pep(idx).nrctremp
           AND nrparepr = pr_tab_parc_pep(idx).nrparepr
           AND inliquid = 0;
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
      
        FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
          cecred.pc_log_programa(PR_DSTIPLOG   => 'E',
                                 PR_CDPROGRAMA => vr_cdprogra,
                                 pr_cdcooper   => vr_cdcooper,
                                 pr_dsmensagem => 'crappep -' ||
                                                  ' cdcooper: ' || pr_tab_parc_pep(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).cdcooper ||
                                                  ' nrdconta: ' || pr_tab_parc_pep(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrdconta ||
                                                  ' nrctremp: ' || pr_tab_parc_pep(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrctremp ||
                                                  ' nrparepr: ' || pr_tab_parc_pep(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrparepr ||
                                                  ' vlparepr: ' || pr_tab_parc_pep(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vlparepr ||
                                                  ' vltaxatu: ' || pr_tab_parc_pep(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vltaxatu ||
                                                  ' Oracle error: ' ||
                                                  SQLERRM(-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE),
                                 PR_IDPRGLOG   => vr_idprglog);
        END LOOP;
      
        vr_dscritic := 'Erro ao atualizar crappep: ' ||
                       SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_exc_saida;
    END;
  
    -- Atualizar Emprestimos
    BEGIN
      FORALL idx IN 1 .. pr_tab_parc_epr.COUNT SAVE EXCEPTIONS
        UPDATE crapepr
           SET vlpreemp = pr_tab_parc_epr(idx).vlparepr
         WHERE cdcooper = pr_tab_parc_epr(idx).cdcooper
           AND nrdconta = pr_tab_parc_epr(idx).nrdconta
           AND nrctremp = pr_tab_parc_epr(idx).nrctremp;
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
      
        FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
          cecred.pc_log_programa(PR_DSTIPLOG   => 'E',
                                 PR_CDPROGRAMA => vr_cdprogra,
                                 pr_cdcooper   => vr_cdcooper,
                                 pr_dsmensagem => 'crapepr -' ||
                                                  ' cdcooper: ' || pr_tab_parc_epr(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).cdcooper ||
                                                  ' nrdconta: ' || pr_tab_parc_epr(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrdconta ||
                                                  ' nrctremp: ' || pr_tab_parc_epr(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrctremp ||
                                                  ' vlpreemp: ' || pr_tab_parc_epr(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).vlparepr ||
                                                  ' Oracle error: ' ||
                                                  SQLERRM(-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE),
                                 PR_IDPRGLOG   => vr_idprglog);
        END LOOP;
      
        vr_dscritic := 'Erro ao atualizar crapepr: ' ||
                       SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_exc_saida;
    END;
  
    -- Condicao para verificar se foi processado numero da conta
    vr_nrdconta := 0;
    IF pr_tab_parc_epr.COUNT > 0 THEN
      vr_nrdconta := pr_tab_parc_epr(pr_tab_parc_epr.LAST).nrdconta;
    END IF;
  
   -- COMMIT;
  END pc_grava_dados;
  
  FUNCTION f_busca_valores (pr_cdcooper crappep.cdcooper%type,
                            pr_nrdconta crappep.nrdconta%type,
                            pr_nrctremp crappep.nrctremp%type,
                            pr_nrparepr crappep.nrparepr%type) return varchar2 is
      vr_texto varchar2(100);                      
    BEGIN
      --null;
      select  'set   vlparepr = ' || replace(vlparepr, ',','.') || ',vlsdvpar = ' || replace(vlsdvpar, ',','.')
        into vr_texto
        from crappep
       where cdcooper = pr_cdcooper
       and   nrdconta = pr_nrdconta
       and   nrctremp = pr_nrctremp
       and   nrparepr = pr_nrparepr;
       
       RETURN vr_texto;
  EXCEPTION
       WHEN OTHERS THEN
         null;
    
  end f_busca_valores;

BEGIN

  --------------- VALIDACOES INICIAIS -----------------

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                             pr_action => 'PC_' || vr_cdprogra || '_1');

  --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

  -- Inicializa
  vr_qtdconta := 0;

  -- Limpa PL Table
  vr_tab_parc_epr.DELETE;
  vr_tab_parc_pep.DELETE;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_exc_saida;
  END IF;    
  
  -- Carregar tabela de carencia
  FOR rw_carencia IN cr_carencia LOOP
    vr_tab_carencia(rw_carencia.idcarencia) := rw_carencia.qtddias;
  END LOOP;

  -- Listagem dos contratos e parcelas
  FOR rw_epr_pep IN cr_epr_pep LOOP
    ------------------------------------------------------------------------------------------
    -- Condicao para verificar se devemos efetuar o recalculo de parcela
    ------------------------------------------------------------------------------------------
    -- 1) Parcela contendo somente o juros na carencia, o calculo devera ocorrer sempre no mes anterior
    -- 2) Parcela Principal devera ocorrer todos os meses, mesmo quando as proximas parcelas estiverem liquidadas
    -- 3) Apos o vencimento da ultima parcela nao devera mais efetuar o calculo de parcela
    -- 4) O recalculo somente ocorre no dia do aniversario da parcela
    OPEN cr_crappep(vr_cdcooper => rw_epr_pep.cdcooper,
                    pr_nrdconta => rw_epr_pep.nrdconta,
                    pr_nrctremp => rw_epr_pep.nrctremp,
                    pr_dtaniver => rw_epr_pep.dtaniversario);
    FETCH cr_crappep
      INTO rw_crappep;

    -- Se não encontrar informações
    IF cr_crappep%NOTFOUND THEN
      -- Fechar o cursor pois teremos raise
      CLOSE cr_crappep;
      CONTINUE;
    END IF;
    -- Apenas fechar o cursor para continuar o processo
    CLOSE cr_crappep;
  
    -- Limpa PL Table
    vr_tab_parcelas.DELETE;
  
    vr_qtdias_carencia := 0; -- Inicializa
  
    -- Se for Pos-Fixado e existir carencia
    IF vr_tab_carencia.EXISTS(rw_epr_pep.idcarenc) THEN
      vr_qtdias_carencia := vr_tab_carencia(rw_epr_pep.idcarenc);
    END IF;
  
    -- Chama o calculo da proxima parcela
    EMPR0011.pc_calcula_prox_parcela_pos(pr_cdcooper        => rw_epr_pep.cdcooper,
                                         pr_flgbatch        => TRUE,
                                         pr_dtcalcul        => rw_epr_pep.dtaniversario, --pr_dtmvtolt,
                                         pr_nrdconta        => rw_epr_pep.nrdconta,
                                         pr_nrctremp        => rw_epr_pep.nrctremp,
                                         pr_dtefetiv        => rw_epr_pep.dtmvtolt,
                                         pr_dtdpagto        => rw_epr_pep.dtdpagto,
                                         pr_txmensal        => rw_epr_pep.txmensal,
                                         pr_vlrdtaxa        => rw_crappep.vltaxatu, --vr_tab_craptxi(vr_tab_craplcr(rw_epr_pep.cdlcremp))
                                         pr_qtpreemp        => rw_epr_pep.qtpreemp,
                                         pr_vlsprojt        => rw_epr_pep.vlsprojt,
                                         pr_vlemprst        => rw_epr_pep.vlemprst,
                                         pr_nrparepr        => rw_crappep.nrparepr,
                                         pr_dtvencto        => rw_crappep.dtvencto,
                                         pr_qtdias_carencia => vr_qtdias_carencia,
                                         pr_tab_parcelas    => vr_tab_parcelas,
                                         pr_cdcritic        => vr_cdcritic,
                                         pr_dscritic        => vr_dscritic);
    -- Se houve erro
    IF NVL(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    -- Carrega PLTABLE das Parcelas
    vr_idx_parcelas := vr_tab_parcelas.FIRST;
    WHILE vr_idx_parcelas IS NOT NULL LOOP
      vr_idx_parc_pep := vr_tab_parc_pep.COUNT + 1;
      vr_tab_parc_pep(vr_idx_parc_pep).cdcooper := rw_epr_pep.cdcooper;
      vr_tab_parc_pep(vr_idx_parc_pep).nrdconta := rw_epr_pep.nrdconta;
      vr_tab_parc_pep(vr_idx_parc_pep).nrctremp := rw_epr_pep.nrctremp;
      vr_tab_parc_pep(vr_idx_parc_pep).nrparepr := vr_tab_parcelas(vr_idx_parcelas).nrparepr;
      vr_tab_parc_pep(vr_idx_parc_pep).vlparepr := vr_tab_parcelas(vr_idx_parcelas).vlparepr;
      vr_tab_parc_pep(vr_idx_parc_pep).vltaxatu := vr_tab_parcelas(vr_idx_parcelas).vlrdtaxa;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update crappep ' 
                                                || f_busca_valores(rw_epr_pep.cdcooper , rw_epr_pep.nrdconta, rw_epr_pep.nrctremp, vr_tab_parcelas(vr_idx_parcelas).nrparepr)  
                                                ||' where cdcooper = ' || rw_epr_pep.cdcooper 
                                                ||' and   nrdconta = ' || rw_epr_pep.nrdconta 
                                                ||' and   nrctremp = ' || rw_epr_pep.nrctremp 
                                                ||' and   nrparepr = ' || vr_tab_parcelas(vr_idx_parcelas).nrparepr || '; ' ); 
      
      vr_idx_parcelas := vr_tab_parcelas.NEXT(vr_idx_parcelas);
    END LOOP;
  
    -- Carrega PLTABLE de Emprestimo
    vr_idx_parc_epr := vr_tab_parc_epr.COUNT + 1;
    vr_tab_parc_epr(vr_idx_parc_epr).cdcooper := rw_epr_pep.cdcooper;
    vr_tab_parc_epr(vr_idx_parc_epr).nrdconta := rw_epr_pep.nrdconta;
    vr_tab_parc_epr(vr_idx_parc_epr).nrctremp := rw_epr_pep.nrctremp;
    vr_tab_parc_epr(vr_idx_parc_epr).vlparepr := vr_tab_parcelas(vr_tab_parcelas.FIRST).vlparepr;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update crapepr ' 
                                                || 'set   vlpreemp = ' || replace(rw_epr_pep.vlpreemp , ',','.')
                                                ||' where cdcooper = ' || rw_epr_pep.cdcooper 
                                                ||' and   nrdconta = ' || rw_epr_pep.nrdconta 
                                                ||' and   nrctremp = ' || rw_epr_pep.nrctremp || ';');
  

    vr_qtdconta := vr_qtdconta + 1;
    -- Salvar a cada 1.000 contas
    IF MOD(vr_qtdconta, 1000) = 0 THEN
      -- Grava os dados conforme PL Table
      pc_grava_dados(pr_tab_parc_pep => vr_tab_parc_pep,
                     pr_tab_parc_epr => vr_tab_parc_epr);
      -- Limpa PL Table
      vr_tab_parc_epr.DELETE;
      vr_tab_parc_pep.DELETE;
    END IF;
  
  END LOOP; -- cr_epr_pep
  -- Grava os dados restantes conforme PL Table
  pc_grava_dados(pr_tab_parc_pep => vr_tab_parc_pep,
                 pr_tab_parc_epr => vr_tab_parc_epr);
                 
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'commit;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); 

  COMMIT;

EXCEPTION

  WHEN vr_exc_saida THEN
    vr_cdcritic := NVL(vr_cdcritic, 0);
    IF vr_cdcritic > 0 THEN
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Efetuar rollback
    ROLLBACK;

  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    vr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
  
END;

