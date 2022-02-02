DECLARE 
   vr_nmarqimp1            VARCHAR2(100)  := 'backup.txt';
   vr_ind_arquiv1          utl_file.file_type;   
   vr_rootmicros           VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
   vr_nmdireto             VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/PRB0046859';        
   vr_dscritic             VARCHAR2(4000);
   vr_excsaida             EXCEPTION;
   
   CURSOR cr_crawcrd IS
    SELECT c.*,c.rowid FROM crawcrd c
     WHERE c.cdadmcrd IS NULL
       AND SUBSTR(c.nrcrcard,0,6) = '604203';
   rw_crawcrd cr_crawcrd%ROWTYPE;
   
   CURSOR cr_crapcrd IS
     SELECT b.rowid, b.*
       FROM crapcrd b,
            crawcrd c
      WHERE b.cdadmcrd is null
        and c.cdcooper = b.cdcooper
        and c.nrdconta = b.nrdconta
        and c.nrctrcrd = b.nrctrcrd
        AND SUBSTR(c.nrcrcard,0,6) = '604203';
   rw_crapcrd cr_crapcrd%ROWTYPE;

   CURSOR cr_crapadc IS 
     SELECT a.*, a.rowid FROM crapadc a
      WHERE a.cdadmcrd = 11
        AND a.nrctamae <> 604203;
   rw_crapadc cr_crapadc%ROWTYPE;
   
  CURSOR cr_conta_cartao IS    
    SELECT b.rowid, b.*
    FROM tbcrd_conta_cartao b,
         crawcrd c
    WHERE b.cdadmcrd is null
      and c.cdcooper = b.cdcooper
      and c.nrcctitg = b.nrconta_cartao
      AND c.nrdconta = b.nrdconta
      AND c.cdadmcrd IS null
      AND SUBSTR(c.nrcrcard,0,6) = '604203';
  rw_conta_cartao  cr_conta_cartao%ROWTYPE;
   
   
       
   PROCEDURE pc_backup (pr_msg VARCHAR2) IS
   BEGIN
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
   END; 
  
   PROCEDURE fecha_arquivos IS
   BEGIN
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
   END;
        
BEGIN
   
   -- Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp1       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv1     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro  
  
  -- Em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  FOR rw_conta_cartao IN cr_conta_cartao LOOP
    pc_backup('update tbcrd_conta_cartao set cdadmcrd = ' || NVL(trim(to_char(rw_conta_cartao.cdadmcrd)),'null') ||  ' where cdcooper = ' || rw_conta_cartao.cdcooper ||
                                                                                                      '   and nrdconta = ' || rw_conta_cartao.nrdconta ||
                                                                                                      '   and nrconta_cartao = ' || rw_conta_cartao.nrconta_cartao || ' ;' );

    BEGIN
      UPDATE tbcrd_conta_cartao SET cdadmcrd = 11
        WHERE ROWID = rw_conta_cartao.rowid;
    EXCEPTION
      WHEN OTHERS THEN 
        vr_dscritic := 'Erro ao efetuar update na tbcrd_conta_cartao. cdcooper: ' || rw_conta_cartao.cdcooper || ' nrdconta: ' || rw_conta_cartao.nrdconta || ' nrconta_cartao: ' || rw_conta_cartao.nrconta_cartao ; 
        RAISE vr_excsaida;  
    END;

  END LOOP;
  
  FOR rw_crawcrd IN cr_crawcrd LOOP
    pc_backup('update crawcrd set cdadmcrd = ' || NVL(trim(to_char(rw_crawcrd.cdadmcrd)),'null') ||  ' where cdcooper = ' || rw_crawcrd.cdcooper ||
                                                                                      '   and nrdconta = ' || rw_crawcrd.nrdconta ||
                                                                                      '   and nrctrcrd = ' || rw_crawcrd.nrctrcrd || ' ;' );

    BEGIN
      UPDATE crawcrd SET cdadmcrd = 11
        WHERE ROWID = rw_crawcrd.rowid;
    EXCEPTION
      WHEN OTHERS THEN 
        vr_dscritic := 'Erro ao efetuar update na crawepr. cdcooper: ' || rw_crawcrd.cdcooper || ' nrdconta: ' || rw_crawcrd.nrdconta || ' nrctrcrd: ' || rw_crawcrd.nrctrcrd ; 
        RAISE vr_excsaida;  
    END;

  END LOOP;
    
  FOR rw_crapcrd IN cr_crapcrd LOOP
    pc_backup('update crapcrd set cdadmcrd = ' || NVL(trim(to_char(rw_crapcrd.cdadmcrd)),'null') ||  ' where cdcooper = ' || rw_crapcrd.cdcooper ||
                                                                                      '   and nrdconta = ' || rw_crapcrd.nrdconta ||
                                                                                      '   and nrctrcrd = ' || rw_crapcrd.nrctrcrd || ' ;' );

    BEGIN
      UPDATE crapcrd SET cdadmcrd = 11
        WHERE ROWID = rw_crapcrd.rowid;
    EXCEPTION
      WHEN OTHERS THEN 
        vr_dscritic := 'Erro ao efetuar update na crapcrd. cdcooper: ' || rw_crapcrd.cdcooper || ' nrdconta: ' || rw_crapcrd.nrdconta || ' nrctrcrd: ' || rw_crapcrd.nrctrcrd ; 
        RAISE vr_excsaida;  
    END;

  END LOOP;
    
  FOR rw_crapadc IN cr_crapadc LOOP
    pc_backup('update crapadc set nrctamae = ' || NVL(trim(to_char(rw_crapadc.nrctamae)),'null') ||  ' where cdcooper = ' || rw_crapadc.cdcooper ||
                                                                                      '   and cdadmcrd = ' || rw_crapadc.cdadmcrd || ' ;' );
                                                                        
    BEGIN
      UPDATE crapadc SET nrctamae = 604203
       WHERE ROWID = rw_crapadc.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao efetuar update na crapadc.'; 
        RAISE vr_excsaida;  
    END;
  END LOOP;
  
  COMMIT;   
       
  fecha_arquivos;
  
EXCEPTION 
     WHEN vr_excsaida then  
         pc_backup('ERRO ' || vr_dscritic);  
         fecha_arquivos;  
         ROLLBACK;    
     WHEN OTHERS then
         vr_dscritic :=  sqlerrm;
         pc_backup('ERRO ' || vr_dscritic); 
         fecha_arquivos; 
         ROLLBACK;   
END;
