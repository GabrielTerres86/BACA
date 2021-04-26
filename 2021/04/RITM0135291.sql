
declare 

  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/RITM0135291';
  vr_nmarqimp        VARCHAR2(100)  := 'rollback_RITM0135291.sql';
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
  SELECT ASS.CDCOOPER, ASS.NRDCONTA, ASS.DTADMISS, ASS.DTABTCCT, ASS.DTMVTOLT
   FROM CRAPASS ASS
  WHERE ASS.DTDEMISS IS not NULL
    AND ASS.DTADMISS > ASS.DTABTCCT 
    AND ASS.CDCOOPER IN ( 7,6,12,5,16,8,1,2,14,13,10,11,9)
    AND NOT EXISTS ( SELECT 1
                       FROM CRAPTCO TCO
                      WHERE TCO.CDCOOPER = ASS.CDCOOPER
                        AND TCO.NRDCONTA = ASS.NRDCONTA ) 
   ORDER BY 1, 2;  
  
  rw_contas cr_contas%ROWTYPE;
  
BEGIN
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de critica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  FOR rw_contas IN cr_contas LOOP
    

       vr_bkp_dep_vista_1 := '';
       
       UPDATE CRAPASS
          SET DTADMISS = rw_contas.dtabtcct
        WHERE CDCOOPER = rw_contas.CDCOOPER
          AND NRDCONTA = rw_contas.NRDCONTA;
             
        vr_bkp_dep_vista_1 := 'UPDATE CRAPASS SET DTADMISS = TO_DATE( ''' || RW_CONTAS.DTADMISS || ''',''DD/MM/YYYY'') WHERE CDCOOPER = ' || RW_CONTAS.CDCOOPER || ' AND NRDCONTA = ' || RW_CONTAS.NRDCONTA ||';';                         

     
     IF vr_bkp_dep_vista_1 IS NOT NULL THEN 
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_bkp_dep_vista_1); 
     END IF;
     
    
          
   
  END LOOP;
  
  commit; 
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');                            
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;      
  
  EXCEPTION 
     WHEN vr_excsaida then
          ROLLBACK;
          raise_application_error( -20001,vr_dscritic);         
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  
                           
end;
