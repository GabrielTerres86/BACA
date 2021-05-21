
declare 

  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0082960';
  vr_nmarqimp        VARCHAR2(100)  := 'rollback_INC0082960.sql';
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
    select 'UPDATE CRAPDOC SET FLGDIGIT = ' || FLGDIGIT || ' , DTBXAPEN = TO_DATE(''' || DTBXAPEN || ''',''DD/MM/YYYY'') , CDOPEBXA = ' || CDOPEBXA || ', TPBXAPEN = ' || TPBXAPEN || ' WHERE PROGRESS_RECID = ' || PROGRESS_RECID || ';' as comando
       , PROGRESS_RECID
    from crapdoc
    where tpdocmto = 8
    AND FLGDIGIT = 1
    and dtmvtolt >= '01/12/2020';  
  
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
           
        UPDATE CRAPDOC
          SET FLGDIGIT = 0
            , DTBXAPEN = ''
            , CDOPEBXA = ' '
            , tpbxapen = 0
          WHERE progress_recid = rw_contas.PROGRESS_RECID;
          
           commit;  
             
        vr_bkp_dep_vista_1 := rw_contas.comando;
     
       IF vr_bkp_dep_vista_1 IS NOT NULL THEN 
            gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_bkp_dep_vista_1); 
       END IF;
     
   
  END LOOP;
 
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');                            
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;      
  
  EXCEPTION 
     WHEN vr_excsaida then
          ROLLBACK;
          raise_application_error( -20001,vr_dscritic);         
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  
                           
end;
