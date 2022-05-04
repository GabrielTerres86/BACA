declare 
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/PRB0047117';
  vr_nmarqimp        VARCHAR2(100)  := 'rollback_PRB0047117_incorp.sql';
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
		 SELECT TCO.CDCOPANT  AS COOP_ORIG 
			   , TCO.NRCTAANT  AS CTA_ORIG
			   , TCO.CDCOOPER  AS COOP_DESTINO
			   , TCO.NRDCONTA  AS CTA_DESTINO
			   , ORIG.DTADMISS AS ADMISSAO_ORIG
			   , DEST.DTADMISS AS ADMISSAO_DEST
			   , OPER.DTINICTR AS DATA_OPERACAO    
			   , CASE WHEN DEST.DTADMISS > OPER.DTINICTR THEN 'NOK' ELSE 'OK' END AS STATUS 
			   , ORIG.DTABTCCT AS ABERTURA_CTA_ORIG
			   , DEST.DTABTCCT AS ABERTURA_CTA_DEST
			 , ORIG.DTMVTOLT AS DTMVTOLT_CTA_ORIG
			 , DEST.DTMVTOLT AS DTMVTOLT_CTA_DEST
			FROM cecred.CRAPASS ORIG
			   , cecred.CRAPASS DEST
			   , cecred.CRAPTCO TCO
			   , ( select r.cdcooper, r.nrdconta, r.nrctremp, r.dtinictr, a.dtadmiss
					from cecred.crapass a
                       , cecred.crapris r
					where r.dtrefere = '31/03/2022'
					and r.cdcooper = a.cdcooper
					and r.nrdconta = a.nrdconta
					and r.dtinictr < a.dtadmiss ) OPER    
		   WHERE TCO.CDCOOPER = DEST.CDCOOPER
			 AND TCO.NRDCONTA = DEST.NRDCONTA
			 AND TCO.CDCOPANT = ORIG.CDCOOPER
			 AND TCO.NRCTAANT = ORIG.NRDCONTA
			 and ORIG.DTADMISS < DEST.DTADMISS
			 AND ( ( DEST.CDCOOPER = OPER.CDCOOPER AND DEST.NRDCONTA = OPER.NRDCONTA ) or
				   ( ORIG.CDCOOPER = OPER.CDCOOPER AND ORIG.NRDCONTA = OPER.NRDCONTA ) )
		   ORDER BY 1; 
  
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
   gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'antes do for');
  FOR rw_contas IN cr_contas LOOP
     gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'entrou no for');
       vr_bkp_dep_vista_1 := '';
       begin
         UPDATE cecred.CRAPASS
            SET DTADMISS = rw_contas.ADMISSAO_ORIG
          WHERE CDCOOPER = rw_contas.COOP_DESTINO
            AND NRDCONTA = rw_contas.CTA_DESTINO;
            
             gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'atualizou');
             
            commit;
        exception
          when others then
             gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'Erro: ' || sqlerrm);
          
        end;
             
        vr_bkp_dep_vista_1 := 'UPDATE cecred.CRAPASS SET DTADMISS = TO_DATE( ''' || RW_CONTAS.ADMISSAO_DEST || ''',''DD/MM/YYYY'') WHERE CDCOOPER = ' || RW_CONTAS.COOP_DESTINO || ' AND NRDCONTA = ' || RW_CONTAS.CTA_DESTINO ||';';                         
     
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
