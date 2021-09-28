declare
  -- Local variables here
  vr_cdcooper    crapcop.cdcooper%TYPE;
  pr_dscritic    VARCHAR2(5000) := ' ';
  vr_nmarqimp1   VARCHAR2(100) := 'backup3.txt';
  vr_ind_arquiv1 utl_file.file_type;
  vr_nmarqimp2   VARCHAR2(100) := 'loga3.txt';
  vr_ind_arquiv2 utl_file.file_type;
  vr_nmarqimp3   VARCHAR2(100) := 'erro3.txt';
  vr_ind_arquiv3 utl_file.file_type;
  vr_rootmicros  VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',
                                                             3,
                                                             'ROOT_MICROS');
  vr_nmdireto    VARCHAR2(4000) := vr_rootmicros || 'cpd/bacas/prj0023533';
  vr_excsaida EXCEPTION;

  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE flgativo = 1
       AND cdcooper NOT IN (1,16,3);
  rw_crapcop cr_crapcop%ROWTYPE;

  CURSOR cr_operacoes(pr_cdcooper crapcop.cdcooper%TYPE) IS
    select distinct cdcooper,
                    nrdconta,
                    cdoperacao,
                    dtoperacao,
                    nrsequen,
                    total_estorno
      from (select ope.*,
                   (select count(1)
                      from craplcm lcm_est
                     where lcm_est.dtmvtolt = ope.dtoperacao
                       and lcm_est.nrdconta = ope.nrdconta
                       and lcm_est.cdhistor in (570, 857)
                       and lcm_est.nrdctabb = 0
                       and lcm_est.cdcooper = ope.cdcooper
                       and (case
                             when ope.cdoperacao = 18 then
                              90
                             when ope.cdoperacao = 19 then
                              91
                             else
                              99999999
                           END) = lcm_est.cdagenci) total_estorno
              FROM tbcc_operacoes_diarias ope, craplcm lcm
             WHERE lcm.dtmvtolt = ope.dtoperacao
               AND lcm.nrdconta = ope.nrdconta
               AND lcm.cdhistor in (570, 857)
               AND lcm.cdcooper = ope.cdcooper
               and ope.cdoperacao in (18, 19)
               AND ope.dtoperacao > '31/12/2020'
               AND ope.dtoperacao < '01/01/2022'
               AND ope.cdcooper = pr_cdcooper
               AND (CASE
                     when ope.cdoperacao = 18 then
                      90
                     when ope.cdoperacao = 19 then
                      91
                     else
                      99999999
                   END) = lcm.cdagenci)
     WHERE total_estorno > 0
     ORDER BY dtoperacao;

  procedure backup3(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
  END;

  procedure loga3(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2, pr_msg);
  END;

  procedure erro3(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv3, pr_msg);
  END;

  PROCEDURE fecha_arquivos IS
  BEGIN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); --> Handle do arquivo aberto;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3);
  END;

BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP  
    
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto --> Diretorio do arquivo
                          ,
                           pr_nmarquiv => rw_crapcop.cdcooper || vr_nmarqimp1 --> Nome do arquivo
                          ,
                           pr_tipabert => 'W' --> modo de abertura (r,w,a)
                          ,
                           pr_utlfileh => vr_ind_arquiv1 --> handle do arquivo aberto
                          ,
                           pr_des_erro => pr_dscritic); --> erro
  -- em caso de crítica
  IF pr_dscritic IS NOT NULL THEN
    RAISE vr_excsaida;
  END IF;

  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto --> Diretorio do arquivo
                          ,
                           pr_nmarquiv => rw_crapcop.cdcooper || vr_nmarqimp2 --> Nome do arquivo
                          ,
                           pr_tipabert => 'W' --> modo de abertura (r,w,a)
                          ,
                           pr_utlfileh => vr_ind_arquiv2 --> handle do arquivo aberto
                          ,
                           pr_des_erro => pr_dscritic); --> erro
  -- em caso de crítica
  IF pr_dscritic IS NOT NULL THEN
    RAISE vr_excsaida;
  END IF;

  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto --> Diretorio do arquivo
                          ,
                           pr_nmarquiv => rw_crapcop.cdcooper || vr_nmarqimp3 --> Nome do arquivo
                          ,
                           pr_tipabert => 'W' --> modo de abertura (r,w,a)
                          ,
                           pr_utlfileh => vr_ind_arquiv3 --> handle do arquivo aberto
                          ,
                           pr_des_erro => pr_dscritic); --> erro
  -- em caso de crítica
  IF pr_dscritic IS NOT NULL THEN
    RAISE vr_excsaida;
  END IF;
  loga3('INICIO ' || to_char(sysdate, 'DD/MM/YYYY HH:MI:SS'));
  
    FOR rw_operacoes IN cr_operacoes(pr_cdcooper => rw_crapcop.cdcooper) LOOP
            
      IF rw_operacoes.nrsequen >= rw_operacoes.total_estorno THEN
        
        backup3('update from tbcc_operacoes_diarias set nrsequen = ' || rw_operacoes.nrsequen ||
            ' where cdcooper = ' || rw_operacoes.cdcooper ||
            ' and cdoperacao = ' || rw_operacoes.cdoperacao ||
            ' and dtoperacao = ' || rw_operacoes.dtoperacao ||
            ' and nrdconta =  ' || rw_operacoes.nrdconta || ';');
            
        update tbcc_operacoes_diarias ope
           set ope.nrsequen = (ope.nrsequen - rw_operacoes.total_estorno)
         where ope.nrdconta = rw_operacoes.nrdconta
           and ope.cdcooper = rw_operacoes.cdcooper
           and ope.cdoperacao = rw_operacoes.cdoperacao
           and ope.dtoperacao = rw_operacoes.dtoperacao
           and ope.nrsequen = rw_operacoes.nrsequen;
           
           loga3(rw_crapcop.cdcooper || ';' || rw_operacoes.nrdconta || ';' || 
            rw_operacoes.cdoperacao || ';' || rw_operacoes.dtoperacao || ';' ||
            rw_operacoes.total_estorno);
                             
      END IF;      
    
    END LOOP;
    
    fecha_arquivos;
  
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN vr_excsaida then
    pr_dscritic := 'ERRO ' || pr_dscritic;
    loga3('ERRO ' || to_char(sysdate, 'DD/MM/YYYY HH:MI:SS'));
    erro3(pr_dscritic ||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
    fecha_arquivos;
    ROLLBACK;
  WHEN OTHERS then
    pr_dscritic := 'ERRO ' || pr_dscritic || sqlerrm;
    loga3('ERRO ' || to_char(sysdate, 'DD/MM/YYYY HH:MI:SS'));
    erro3(pr_dscritic ||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
    fecha_arquivos;
    ROLLBACK;
  
END;
/
