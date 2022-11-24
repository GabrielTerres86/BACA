BEGIN
  DECLARE
 
  vr_exc_saida EXCEPTION;  
  pr_cdcooper  CECRED.crapcop.cdcooper%TYPE := 1;
    
  vr_cdcritic  PLS_INTEGER;
  vr_dscritic  VARCHAR2(4000);
  vr_exc_erro  EXCEPTION;
  
  vr_linha     VARCHAR2(32767);
  vr_ind_arquivo_backup utl_file.file_type;
  vr_nmdir     VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0233067';
  vr_nmarq     VARCHAR2(100)  := 'ROLLBACK_INC0233067_novas_prop_outubro.sql';
  vr_lista_propostas  VARCHAR2(1000):=NULL;
            
  CURSOR cr_cria_propostas(pr_cdcooper  IN CECRED.crawseg.cdcooper%TYPE) IS
   SELECT w.cdcooper, w.nrdconta, w.nrctrato, w.nrproposta 
     FROM cecred.crawseg w 
    WHERE w.cdcooper = pr_cdcooper
      AND (w.nrctrato, w.nrproposta) IN 
         ((2827963,'770351890630'),
          (5943090,'770657391247'),
          (4154323,'770359324731'),
          (2657094,'770658235869'),
          (2657016,'770658235834'),
          (1865011,'770655882596'))
    ORDER BY 1,2,3,4;
    
  CURSOR cr_lista_propostas_criadas IS  
    SELECT listagg('''' || t.nrproposta || '''',',')  nrproposta
      FROM cecred.tbseg_prestamista t,
           cecred.crapseg s
      WHERE t.cdcooper = s.cdcooper
        AND t.nrdconta = s.nrdconta
        AND t.nrctrseg = s.nrctrseg
        AND s.cdsitseg = 1
        AND t.nrctremp IN (2827963,4154323,5943090,2657016,2657094,1865011);    
        
  BEGIN
   
    vr_lista_propostas := NULL; 
    
    CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir
                                   ,pr_nmarquiv => vr_nmarq   
                                   ,pr_tipabert => 'W'
                                   ,pr_utlfileh => vr_ind_arquivo_backup
                                   ,pr_des_erro => vr_dscritic);
                                    
    IF vr_dscritic IS NOT NULL THEN         
      RAISE vr_exc_erro;
    END IF;

    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,'BEGIN');
  
    FOR rw_cria_propostas IN cr_cria_propostas(pr_cdcooper => pr_cdcooper) LOOP
      
      CECRED.SEGU0003.pc_efetiva_proposta_sp(pr_cdcooper => rw_cria_propostas.cdcooper,
                                             pr_nrdconta => rw_cria_propostas.nrdconta,
                                             pr_nrctrato => rw_cria_propostas.nrctrato,
                                             pr_cdagenci => 1,
                                             pr_nrdcaixa => 1,
                                             pr_cdoperad => 1,
                                             pr_nmdatela => 'ATENDA',
                                             pr_idorigem => 5,
                                             pr_versaldo => 'S',
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic);
      
       IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
       END IF;                                               
    END LOOP;
    COMMIT;
      
    OPEN cr_lista_propostas_criadas;
      FETCH cr_lista_propostas_criadas INTO vr_lista_propostas;
      IF cr_lista_propostas_criadas%NOTFOUND THEN
        vr_lista_propostas := NULL;             
      END IF;
    CLOSE cr_lista_propostas_criadas;
           
    IF vr_lista_propostas IS NOT NULL THEN
      vr_linha :=  'DELETE CECRED.crawseg WHERE nrproposta IN ( ' || vr_lista_propostas || ');'; 
                                              
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);
                           
      vr_linha :=  'DELETE CECRED.crapseg WHERE nrctrseg IN (SELECT nrctrseg FROM cecred.tbseg_prestamista WHERE nrproposta IN (' || vr_lista_propostas || '));'; 
                                              
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);
             
      vr_linha :=  'DELETE CECRED.tbseg_prestamista WHERE nrproposta IN ( ' || vr_lista_propostas || ');'; 
                                              
      CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,vr_linha);
    END IF;
      
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,' COMMIT;');
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,' END; ');
    CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo_backup,'/ ');
    CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo_backup );
    
  END;  