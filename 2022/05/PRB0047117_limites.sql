declare 
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/PRB0047117';
  vr_nmarqimp        VARCHAR2(100)  := 'rollback_PRB0047117_limites.sql';
  vr_ind_arquiv      utl_file.file_type;
  vr_excsaida        EXCEPTION;
  vr_dscritic        varchar2(5000) := ' ';
  vr_dtmvtolt    crapdat.dtmvtolt%TYPE;
  vr_incrineg    INTEGER;  
  vr_tab_retorno LANC0001.typ_reg_retorno;  
  vr_nrseqdig    craplcm.nrseqdig%TYPE;  
  vr_snrseqdig   VARCHAR2(400);  
  
  vr_cdcritic    crapcri.cdcritic%TYPE;
  vr_nmdcampo    VARCHAR2(400);
  vr_des_erro    VARCHAR2(400);
  
  vr_bkp_dep_vista_1 VARCHAR2(1000);
     
    
  vr_nrdolote   INTEGER;
  vr_busca      VARCHAR2(400);
  vr_sbusca     VARCHAR2(400);
  vr_nrdocmto   INTEGER;
  vr_snrdocmto  VARCHAR2(400);
  CURSOR cr_contas IS
	    select ass.cdcooper
			 , ass.nrdconta
			 , ass.dtadmiss
			 , ass.dtabtcct
			 , ass.dtmvtolt
			 , lim.dtpropos
		  from cecred.crapass ass
			   , cecred.craplim lim
		 where ass.cdcooper = lim.cdcooper
		   and ass.nrdconta = lim.nrdconta
		   and lim.insitlim = 2
		   and lim.dtpropos < ass.dtadmiss; 
  
  rw_contas cr_contas%ROWTYPE;
  
BEGIN
  

  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        
                          ,pr_nmarquiv => vr_nmarqimp        
                          ,pr_tipabert => 'W'               
                          ,pr_utlfileh => vr_ind_arquiv      
                          ,pr_des_erro => vr_dscritic);     
   
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  FOR rw_contas IN cr_contas LOOP
    
       vr_bkp_dep_vista_1 := '';
       
       UPDATE cecred.CRAPASS
          SET DTADMISS = rw_contas.dtmvtolt
        WHERE CDCOOPER = rw_contas.cdcooper
          AND NRDCONTA = rw_contas.nrdconta;
          
          commit;
             
        vr_bkp_dep_vista_1 := 'UPDATE cecred.CRAPASS SET DTADMISS = TO_DATE( ''' || RW_CONTAS.dtadmiss || ''',''DD/MM/YYYY'') WHERE CDCOOPER = ' || RW_CONTAS.cdcooper || ' AND NRDCONTA = ' || RW_CONTAS.nrdconta ||';';                         
     commit;
     IF vr_bkp_dep_vista_1 IS NOT NULL THEN 
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_bkp_dep_vista_1); 
     END IF;
     
    
          
   
  END LOOP;
  
 
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');                            
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);   
  
  EXCEPTION 
     WHEN vr_excsaida then
          ROLLBACK;
          raise_application_error( -20001,vr_dscritic);         
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); 
  
                           
end;
