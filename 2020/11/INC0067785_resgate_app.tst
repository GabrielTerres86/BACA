PL/SQL Developer Test script 3.0
217
-- Created on 17/11/2020 by F0032999
/* Verifica planos com debitos de aplicaccoes com valores incorretos
   e realizar o resgate */
declare 

  vr_cdcritic   crapcri.cdcritic%TYPE;
  vr_dscritic   varchar2(5000) := ' ';
  vr_tpcritic crapcri.cdcritic%TYPE;
  
  vr_excsaida EXCEPTION;
  vr_total_sim  pls_integer := 0;
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0067785_app';
  vr_nmarqimp        VARCHAR2(100)  := 'log.txt';
  vr_nmarqimp2       VARCHAR2(100)  := 'sucesso.txt';
  vr_nmarqimp3       VARCHAR2(100)  := 'falha.txt';
  vr_nmarqimp4       VARCHAR2(100)  := 'backup.txt';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquiv2     utl_file.file_type;
  vr_ind_arquiv3     utl_file.file_type;
  vr_ind_arquiv4     utl_file.file_type;
  
  CURSOR cr_craprac IS
   select rac.dtmvtolt,
          rac.nrdconta,
          rac.cdcooper,
          rac.nraplica,
          rac.nrctrrpp,
          rac.vlaplica,
          rpp.vlprerpp,
          rac.vlsldatl,
          rac.idblqrgt,
          rpp.vlrgtacu
     from craprac rac, craprpp rpp  
    where rac.cdcooper = rpp.cdcooper
      and rac.nrdconta = rpp.nrdconta
      and rpp.nrctrrpp = rac.nrctrrpp
      and rpp.vlprerpp < rac.vlaplica
      and rac.dtmvtolt  between '16/11/2020' and  '17/11/2020'
      and rac.idsaqtot = 0
      and rpp.cdprodut > 1;
      rw_craprac cr_craprac%ROWTYPE;
      
       CURSOR cr_crapdat (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT dat.dtmvtolt,
             dat.dtmvtopr,
             dat.dtmvtoan,
             dat.inproces,
             dat.qtdiaute,
             dat.cdprgant,
             dat.dtmvtocd,
             trunc(dat.dtmvtolt,'mm')               dtinimes, -- Pri. Dia Mes Corr.
             trunc(Add_Months(dat.dtmvtolt,1),'mm') dtpridms, -- Pri. Dia mes Seguinte
             last_day(add_months(dat.dtmvtolt,-1))  dtultdma, -- Ult. Dia Mes Ant.
             last_day(dat.dtmvtolt)                 dtultdia, -- Utl. Dia Mes Corr.
             ROWID
        FROM crapdat dat
       WHERE dat.cdcooper = pr_cdcooper;
       rw_crapdat cr_crapdat%ROWTYPE;

  vr_vlsppant_correto craprpp.vlsppant%TYPE;

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

BEGIN
  
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
    
  FOR rw_craprac IN cr_craprac LOOP
    OPEN cr_crapdat (pr_cdcooper => rw_craprac.cdcooper);
     FETCH cr_crapdat INTO rw_crapdat;
    CLOSE cr_crapdat;
    loga('Ajustando plano: Cooper: '|| rw_craprac.cdcooper || ' Conta: ' ||rw_craprac.nrdconta || ' Plano: ' ||rw_craprac.nraplica);
        

    -- Realiza o resgate.
    
        APLI0005.pc_efetua_resgate(pr_cdcooper => rw_craprac.cdcooper
                                  ,pr_nrdconta => rw_craprac.nrdconta
                                  ,pr_nraplica => rw_craprac.nraplica
                                  ,pr_vlresgat => 0
                                  ,pr_idtiprgt => 2
                                  ,pr_dtresgat => rw_crapdat.dtmvtolt
                                  ,pr_nrseqrgt => 0
                                  ,pr_idrgtcti => 0
                                  ,pr_idorigem => 0
                                  ,pr_tpcritic => vr_tpcritic
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
    
          IF vr_dscritic IS NOT NULL OR
           NVL(vr_cdcritic,0) <> 0 THEN
          vr_dscritic := ' Erro Resgate ' || vr_dscritic || ' - Cooperativa: ' || rw_craprac.cdcooper || ' - ' || rw_craprac.nrdconta || ' - ' || rw_craprac.nraplica || ' SQLERRM: ' || SQLERRM;
          falha(vr_dscritic);
          RAISE vr_excsaida;
        END IF;
        backup('update craprpp set vlrgtacu = '|| replace(rw_craprac.vlrgtacu,'.',',') ||
            'where craprpp.nrdconta = '''|| rw_craprac.nrdconta ||''||
            'and craprpp.cdcooper = '''|| rw_craprac.cdcooper ||''||
            'and craprpp.nrctrrpp = '''|| rw_craprac.nrctrrpp||''';');   
    BEGIN
      UPDATE craprpp
         SET craprpp.vlrgtacu = craprpp.vlrgtacu + rw_craprac.vlsldatl
       WHERE craprpp.nrdconta = rw_craprac.nrdconta
         and craprpp.cdcooper = rw_craprac.cdcooper
         and craprpp.nrctrrpp = rw_craprac.nrctrrpp;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro atualizando craprpp! ! Cooper: '|| rw_craprac.cdcooper || ' Conta: ' ||rw_craprac.nrdconta || ' Plano: ' ||rw_craprac.nrctrrpp || ' SQLERRM: ' || SQLERRM;
        loga(vr_dscritic);
        falha(vr_dscritic);
        RAISE vr_excsaida;
    END;
    
    sucesso('Plano ajustado com sucesso: Cooper: '|| rw_craprac.cdcooper || ' Conta: ' ||rw_craprac.nrdconta || ' Plano: ' ||rw_craprac.nrctrrpp || ' Aplicacao: ' || rw_craprac.nraplica );

    vr_total_sim := vr_total_sim + 1;

    -- commit a cada 200 registros
    IF mod(vr_total_sim,200) = 0 THEN
      commit;
    END IF;

  END LOOP;
  
  COMMIT;

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
1
vr_dscritic
1
SUCESSO
5
0
