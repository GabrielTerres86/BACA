PL/SQL Developer Test script 3.0
433
/* Ajusta aplicacoes nao resgatadas 
 
 Obs.: Considera fixo CDI 6.40

*/
declare 

  pr_cdcooper crapcop.cdcooper%TYPE := 9;
  pr_dtiniano date := to_date('01/01/2019','dd/mm/rrrr');
  pr_dstitulo varchar2(500) := 'rendimento-cooper-'||lpad(pr_cdcooper,2,'0');

  vr_cdidiari NUMBER(10,8) := (POWER((1 + 6.4 / 100),(1 / 252)) - 1) * 100;
  vr_dscritic varchar2(5000) := ' ';
  vr_cdhistor craphis.cdhistor%TYPE;
  vr_nrdocmto craplap.nrdocmto%TYPE;
  vr_nrdocmto_inicial craplap.nrdocmto%TYPE := 655000;
  vr_nrseqdig craplap.nrseqdig%TYPE := 0;
  vr_laprowid rowid;
  vr_vlrendim NUMBER(18,4);  
  vr_vltotal  NUMBER(18,4) := 0;
  vr_qtd      PLS_INTEGER := 0;
  
  TYPE typ_tab_saldo_2018 IS
   TABLE OF NUMBER(22,8)
    INDEX BY VARCHAR2(20);
  vr_tab_saldo_2018 typ_tab_saldo_2018;
  vr_index VARCHAR(20);
  
  vr_tem_critica boolean := false;
  vr_dia      date;
  vr_excsaida EXCEPTION;  
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0030663';
  vr_nmarqimp        VARCHAR2(100)  := pr_dstitulo||'-log.txt';
  vr_nmarqimp2       VARCHAR2(100)  := pr_dstitulo||'-sucesso.txt';
  vr_nmarqimp3       VARCHAR2(100)  := pr_dstitulo||'-falha.txt';
  vr_nmarqimp4       VARCHAR2(100)  := pr_dstitulo||'-backup.txt';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquiv2     utl_file.file_type;
  vr_ind_arquiv3     utl_file.file_type;
  vr_ind_arquiv4     utl_file.file_type;
  
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

  cursor cr_craprda IS
  select /*+ index (rda craprda##craprda8)*/
         rda.*
        ,rda.rowid
        ,0 saldo_cal_2018
  from craprda rda
 where rda.cdcooper = pr_cdcooper
   and rda.tpaplica in (7,8) -- RDC POS E PRE
   and rda.insaqtot = 0
   and rda.dtmvtolt < pr_dtiniano; -- cadastrados antes do dia 31/12
  rw_craprda cr_craprda%ROWTYPE;

 CURSOR cr_craplap_2018 IS
  select lap.nrdconta
        ,lap.nraplica
        ,(decode(his.indebcre,'D',-1,1) * lap.vllanmto) valor
    from craplap lap, craphis his, craprda rda
   where lap.cdcooper = pr_cdcooper
     and lap.dtmvtolt < pr_dtiniano

     and lap.cdcooper = rda.cdcooper
     and lap.nrdconta = rda.nrdconta
     and lap.nraplica = rda.nraplica
     and rda.insaqtot = 0
     
     AND his.cdcooper = lap.cdcooper
     AND his.cdhistor = lap.cdhistor;
  rw_craplap_2018 cr_craplap_2018%ROWTYPE;

 CURSOR cr_craplap (pr_cdcooper  IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta  IN craprda.nrdconta%TYPE
                   ,pr_nraplica  IN craprda.nraplica%TYPE
                   ,pr_dtmvtolt  IN craprda.dtmvtolt%TYPE) IS
  SELECT cl.*
    FROM craplap cl
   WHERE cl.cdcooper = pr_cdcooper
     AND cl.nrdconta = pr_nrdconta
     AND cl.nraplica = pr_nraplica
     AND cl.dtmvtolt = pr_dtmvtolt;
  rw_craplap cr_craplap%rowtype; 
  
 CURSOR cr_craplot (pr_cdcooper  IN crapcop.cdcooper%TYPE
                   ,pr_dtmvtolt  IN craplot.dtmvtolt%TYPE) IS
  SELECT lot.*, lot.rowid
    FROM craplot lot
   WHERE lot.cdcooper = pr_cdcooper
     AND lot.dtmvtolt = pr_dtmvtolt
     AND lot.cdagenci = 1
     AND lot.cdbccxlt = 100
     AND lot.nrdolote = 8480;
  rw_craplot cr_craplot%rowtype;   

  function formata(pr_valor NUMERIC) RETURN VARCHAR2 is
  BEGIN
    return replace(pr_valor,',','.');
  END;

  procedure loga(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
  END;
    
  procedure sucesso(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
  END;
  
  procedure falha(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv3, to_char(sysdate,'ddmmyyyy_hh24miss')||' - '|| pr_msg);
    loga(pr_msg);
  END;
  
  procedure backup(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv4, pr_msg);
  END;

begin

  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp2       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv2     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp3       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv3     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp4       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv4     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
    
  loga('Inicio Processo');  
  
  FOR rw_craplap_2018 IN cr_craplap_2018 LOOP
    vr_index := lpad(rw_craplap_2018.nrdconta,10,'0')||lpad(rw_craplap_2018.nraplica,10,'0');
    if vr_tab_saldo_2018.exists(vr_index) then
      vr_tab_saldo_2018(vr_index) := vr_tab_saldo_2018(vr_index) + rw_craplap_2018.valor;
    else
      vr_tab_saldo_2018(vr_index) := rw_craplap_2018.valor;
    end if;
  END LOOP;  
  
  loga('Carregou os saldos 2018');  
  
  -- Verifica a data da cooper viacredi
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    CLOSE BTCH0001.cr_crapdat;
    loga('Data nao encontrada!');
    RAISE vr_excsaida;
  ELSE
    CLOSE BTCH0001.cr_crapdat;
  END IF;

  IF rw_crapdat.inproces > 1 THEN
    vr_dscritic := 'Batch em execução! Cooper: '|| pr_cdcooper;
    falha(vr_dscritic);
    RAISE vr_excsaida;
  END IF;
  
  SELECT max(nvl(nrseqdig,0)) vr_nrseqdig into vr_nrseqdig
    FROM craplap
   WHERE cdcooper = pr_cdcooper
     and dtmvtolt = rw_crapdat.dtmvtolt
     and cdagenci = 1
     and cdbccxlt = 100
     and nrdolote = 8480;
  
  FOR rw_craprda IN cr_craprda LOOP
    
    vr_qtd := vr_qtd + 1;
    loga('Ajustando: Cooper: '|| rw_craprda.cdcooper || ' Conta: ' ||rw_craprda.nrdconta || ' Aplica: '|| rw_craprda.nraplica|| ' Proc: '||vr_qtd);
    
    -- Backup craprda
    backup('update craprda set vlsltxmx = '|| formata(rw_craprda.vlsltxmx) ||' ,vlsltxmm = '|| formata(rw_craprda.vlsltxmm) ||' where craprda.rowid = '''|| rw_craprda.rowid ||''';');
    
    OPEN cr_craplap(rw_craprda.cdcooper, rw_craprda.nrdconta, rw_craprda.nraplica, rw_craprda.dtmvtolt);
    FETCH cr_craplap INTO rw_craplap;
    IF cr_craplap%NOTFOUND THEN
      vr_dscritic := 'Taxa nao encontrada! Cooper: '|| rw_craprda.cdcooper || ' Conta: ' ||rw_craprda.nrdconta || ' Aplica: '|| rw_craprda.nraplica;
      falha(vr_dscritic);
      RAISE vr_excsaida;
    END IF;
    
    vr_index := lpad(rw_craprda.nrdconta,10,'0')||lpad(rw_craprda.nraplica,10,'0');
    IF NOT vr_tab_saldo_2018.exists(vr_index) THEN
      vr_dscritic := 'Saldo nao encontrado! Cooper: '|| rw_craprda.cdcooper || ' Conta: ' ||rw_craprda.nrdconta || ' Aplica: '|| rw_craprda.nraplica;
      falha(vr_dscritic);
      RAISE vr_excsaida;
    END IF;
    rw_craprda.saldo_cal_2018 := vr_tab_saldo_2018(vr_index);
    
    IF rw_craprda.tpaplica = 8 THEN
      /* RDC POS */
      vr_cdhistor := 529;
      
      vr_vlrendim := rw_craprda.saldo_cal_2018 * vr_cdidiari * rw_craplap.txaplica / 100 / 100;
      vr_dia      := pr_dtiniano;
      LOOP      
        vr_dia := gene0005.fn_valida_dia_util(pr_cdcooper, vr_dia, 'P', true, true);      
        exit when vr_dia >= rw_craprda.dtatslmx;
        
        vr_vlrendim := vr_vlrendim + (vr_vlrendim * vr_cdidiari * rw_craplap.txaplica / 100 / 100);
        vr_dia := vr_dia + 1;
      end loop;
      
    ELSIF rw_craprda.tpaplica = 7 THEN
      /* RDC PRE */
      vr_cdhistor := 474;
      
      vr_vlrendim := rw_craprda.saldo_cal_2018 * rw_craplap.txaplica / 100;
      vr_dia      := pr_dtiniano;
      LOOP      
        vr_dia := gene0005.fn_valida_dia_util(pr_cdcooper, vr_dia, 'P', true, true);      
        exit when vr_dia >= rw_craprda.dtatslmx;
        
        vr_vlrendim := vr_vlrendim + (vr_vlrendim * rw_craplap.txaplica / 100);
        vr_dia := vr_dia + 1;
      end loop;
      
    ELSE
      vr_dscritic := 'Tipo aplicacao invalida! Cooper: '|| rw_craprda.cdcooper || ' Conta: ' ||rw_craprda.nrdconta || ' Aplica: '|| rw_craprda.nraplica || ' Tpaplica: '|| rw_craprda.tpaplica;
      falha(vr_dscritic);
      CLOSE cr_craplap;
      CONTINUE;
    END IF;
    
    /* Se o valor do rendimento for zero, nao vamos fazer nada */
    IF round(vr_vlrendim,2) <= 0 THEN
      vr_dscritic := 'Rendimento calculado zerado. Cooper: '|| rw_craprda.cdcooper || ' Conta: ' ||rw_craprda.nrdconta || ' Aplica: '|| rw_craprda.nraplica || ' Tpaplica: '|| rw_craprda.tpaplica || ' Rend.: '|| formata(vr_vlrendim) ;
      loga(vr_dscritic);
      CLOSE cr_craplap;
      CONTINUE;
    END IF;
        
    vr_nrseqdig := nvl(vr_nrseqdig,0) + 1;
    vr_nrdocmto := vr_nrdocmto_inicial + vr_nrseqdig;
    vr_vltotal  := vr_vltotal + vr_vlrendim;
    BEGIN
      insert into craplap (cdagenci, cdbccxlt, dtmvtolt, nrdolote, nrdconta, cdhistor, nraplica, nrdocmto, nrseqdig, vllanmto, txaplica, dtrefere, txaplmes, cdcooper, vlrendmm)
         values
        (1   --cdagenci
        ,100 --cdbccxlt
        ,rw_crapdat.dtmvtolt
        ,8480 --nrdolote 
        ,rw_craprda.nrdconta
        ,vr_cdhistor
        ,rw_craprda.nraplica
        ,vr_nrdocmto
        ,vr_nrseqdig
        ,round(vr_vlrendim,2)  --vllanmto
        ,rw_craplap.txaplica
        ,rw_craplap.dtrefere
        ,case when rw_craprda.tpaplica = 8 then rw_craplap.txaplmes else rw_craplap.txaplica end
        ,rw_craprda.cdcooper
        ,round(vr_vlrendim,2)  -- vlrendmm
        ) returning rowid into vr_laprowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro inserindo craplap! '|| SQLERRM ||' - Cooper: '|| rw_craprda.cdcooper || ' Conta: ' ||rw_craprda.nrdconta || ' Aplica: '|| rw_craprda.nraplica;
        falha(vr_dscritic);
        RAISE vr_excsaida;
    END;

    backup('delete from craplap where rowid = '''|| vr_laprowid ||''';');
    
    BEGIN
      UPDATE craprda
         SET vlsltxmx = vlsltxmx + vr_vlrendim
            ,vlsltxmm = vlsltxmm + vr_vlrendim
       WHERE ROWID = rw_craprda.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro alterando craprda! '|| SQLERRM ||' - Cooper: '|| rw_craprda.cdcooper || ' Conta: ' ||rw_craprda.nrdconta || ' Aplica: '|| rw_craprda.nraplica;
        falha(vr_dscritic);
        RAISE vr_excsaida;
    END;
    
    sucesso('Creditado para Cooper: '|| rw_craprda.cdcooper || ' Conta: ' ||rw_craprda.nrdconta || ' Aplica: '|| rw_craprda.nraplica || ' Valor : '|| vr_vlrendim || ' Valor anterior: ' || rw_craprda.vlsltxmx || ' Valor atualizado: ' || (rw_craprda.vlsltxmx + vr_vlrendim) );
    CLOSE cr_craplap;
    
    -- Commitar a cada 1000 registros
    -- para nao lockar as aplicacoes
    IF pr_cdcooper = 1 and MOD(vr_qtd,1000) = 0 THEN
      backup('/* COMITOU AQUI '|| vr_qtd || ' registros  */');
      COMMIT;
    END IF;

  END LOOP;
  
  IF vr_tem_critica THEN
    RAISE vr_excsaida;
  END IF;
  
  /* Atualiza capa de lote */
  OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
  FETCH cr_craplot INTO rw_craplot;
  IF cr_craplot%NOTFOUND THEN
    CLOSE cr_craplot;
    
    BEGIN
      INSERT INTO craplot(cdcooper
                         ,dtmvtolt
                         ,cdagenci
                         ,cdbccxlt
                         ,nrdolote
                         ,tplotmov
                         ,vlinfodb
                         ,vlcompdb
                         ,qtinfoln
                         ,qtcompln
                         ,vlinfocr
                         ,vlcompcr)
                   VALUES(pr_cdcooper
                         ,rw_crapdat.dtmvtolt
                         ,1
                         ,100
                         ,8480
                         ,9
                         ,0
                         ,0
                         ,0
                         ,0
                         ,0
                         ,0)
                 RETURNING cdagenci
                          ,cdbccxlt
                          ,nrdolote
                          ,tplotmov
                          ,nrseqdig
                          ,rowid
                      INTO rw_craplot.cdagenci
                          ,rw_craplot.cdbccxlt
                          ,rw_craplot.nrdolote
                          ,rw_craplot.tplotmov
                          ,rw_craplot.nrseqdig
                          ,rw_craplot.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        -- Gerar erro e fazer rollback
        vr_dscritic := 'Erro inserindo craplot! '|| SQLERRM ||' - Cooper: '|| pr_cdcooper || ' Data: ' ||rw_craprda.dtmvtolt;
        falha(vr_dscritic);
        RAISE vr_excsaida;
    END;
  ELSE
    CLOSE cr_craplot;
  END IF;  
  
  BEGIN          
     UPDATE craplot ct
        SET ct.vlinfocr = NVL(ct.vlinfocr,0) + vr_vltotal
           ,ct.vlcompcr = NVL(ct.vlcompcr,0) + vr_vltotal
           ,ct.qtinfoln = NVL(ct.qtinfoln,0) + (vr_nrseqdig -  NVL(ct.nrseqdig,0))
           ,ct.qtcompln = NVL(ct.qtcompln,0) + (vr_nrseqdig -  NVL(ct.nrseqdig,0))
           ,ct.nrseqdig = NVL(ct.nrseqdig,0) + vr_nrseqdig
        WHERE ct.ROWID = rw_craplot.rowid;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro alterando craplot! '|| SQLERRM ||' - Cooper: '|| pr_cdcooper || ' Data: ' ||rw_craprda.dtmvtolt;
      falha(vr_dscritic);
      RAISE vr_excsaida;
  END;
  
  loga('Fim do Processo com sucesso');
  
  commit;

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;  

  :vr_dscritic := 'SUCESSO';
  
EXCEPTION
  WHEN vr_excsaida then 
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;    
    
  WHEN OTHERS then
    loga(vr_dscritic);
    loga(SQLERRM);
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;  
end;
0
0
