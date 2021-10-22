DECLARE
  vr_nrproposta      VARCHAR2(30);
  vr_dscritic        VARCHAR2(1000);
  vr_exc_saida       EXCEPTION;  
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros|| 'cpd/bacas/INC0109157';
  vr_nmdireto :=  '/usr/coop/viacredi/arq/';
vr_nmdireto := gene0001.fn_diretorio( pr_tpdireto => 'C',  pr_cdcooper => 1 )||'/arq';
  -- Arquivo de rollback
  vr_nmarqimp        VARCHAR2(100)  := 'INC0109157_ROLLBACK.txt';     
  vr_ind_arquiv      utl_file.file_type; 
  
CURSOR cr_apolic IS
  SELECT a.cdcooper,
         a.nrdconta,
         a.nrctrseg,
         a.nrctremp,
         a.nrproposta,
         a.cdapolic
    FROM tbseg_prestamista a
   WHERE a.nrproposta in ('770354136953',
                          '770353356470',
                          '770353555383',
                          '770354197189',
                          '770354185784',
                          '770354002698',
                          '770353085689',
                          '770353340530',
                          '770354080109',
                          '770354248956',
                          '770354357585',
                          '770353194780',
                          '770354216590',
                          '770353672410',
                          '770353339826')
     AND a.tpregist = 1;
  
  CURSOR cr_prestamista(p_cdapolic tbseg_prestamista.cdapolic%TYPE) IS 
  SELECT cdapolic, 
         cdcooper, 
         nrdconta, 
         nrctrseg, 
         nrctremp,
         nrproposta
    FROM tbseg_prestamista
   WHERE cdapolic = p_cdapolic;
BEGIN 
  --Criar arquivo de Roll Back
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_exc_saida;
  END IF;
  
  FOR rw_apolic IN cr_apolic LOOP
    FOR rw_prestamista IN cr_prestamista(rw_apolic.cdapolic) LOOP
       
      vr_nrproposta := SEGU0003.FN_NRPROPOSTA(); 
                 
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'UPDATE tbseg_prestamista SET nrproposta = '||rw_prestamista.nrproposta
                                                   ||' WHERE cdapolic = '||rw_prestamista.cdapolic||';');
           
      BEGIN            
        UPDATE tbseg_prestamista g 
           SET g.nrproposta = vr_nrproposta
         WHERE g.cdapolic = rw_prestamista.cdapolic;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao gravar numero de proposta 1: '||vr_nrproposta||' - '||SQLERRM;
          RAISE vr_exc_saida;              
      END;
          
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'UPDATE crawseg SET nrproposta = ' ||rw_prestamista.nrproposta 
                                                 ||' WHERE cdcooper = ' ||rw_prestamista.cdcooper
                                                 ||'   AND nrdconta = ' ||rw_prestamista.nrdconta
                                                 ||'   AND nrctrseg = ' ||rw_prestamista.nrctrseg
                                                 ||'   AND nrctrato = ' ||rw_prestamista.nrctremp||';');
           
      BEGIN            
        UPDATE crawseg g 
           SET g.nrproposta = vr_nrproposta
         WHERE g.cdcooper = rw_prestamista.cdcooper
           AND g.nrdconta = rw_prestamista.nrdconta
           AND g.nrctrseg = rw_prestamista.nrctrseg
           AND g.nrctrato = rw_prestamista.nrctremp
           AND g.tpseguro = 4;      
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao gravar numero de proposta 2: '||vr_nrproposta||' - '||SQLERRM;
          RAISE vr_exc_saida;                
      END;
          
      -- Gravar data da utilização da proposta para que nao utilize mais o mesmo numero
      BEGIN
        UPDATE TBSEG_NRPROPOSTA 
           SET DTSEGURO = SYSDATE 
         WHERE NRPROPOSTA = vr_nrproposta; 
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao atualizar numero de TBSEG_NRPROPOSTA: '||vr_nrproposta||' - '||SQLERRM;
          RAISE vr_exc_saida;              
      END;
      COMMIT;
    END LOOP;
  END LOOP;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'COMMIT;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  vr_dscritic := 'Registro atualizado com sucesso!';
  dbms_output.put_line(vr_dscritic);
EXCEPTION
  WHEN vr_exc_saida THEN 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    vr_dscritic := 'ERRO ' || vr_dscritic;
    dbms_output.put_line(vr_dscritic);
    ROLLBACK;
END; 
/
