
declare 
  CURSOR cr_craprda30 IS 
   SELECT    craprda.cdcooper,
             craprda.nrdconta,
             DECODE(crapass.inpessoa,3,2,crapass.inpessoa) inpessoa, /* Tratamento para considerar pessoas do tipo 3 como PJ */
             crapass.cdagenci,
             craprda.nraplica,
             craprda.dtcalcul,
             craprda.insaqtot,
             craprda.dtmvtolt,
             craprda.vlabdiof,
             craprda.qtrgtmfx,
             craprda.qtaplmfx,
             craprda.flgctain,
             craprda.vlaplica,
             craprda.vlabcpmf,
             craprda.vlslfmes,
             craprda.cdageass,
             craprda.tpaplica,
             craprda.rowid row_id,
             crapage.nmresage,
             crapass.nmprimtl
        FROM crapass,
             crapage,
             craprda,
             crapcop
       WHERE  craprda.tpaplica = 3 -- RDCA30
         AND crapage.cdcooper = craprda.cdcooper
         AND crapage.cdagenci = craprda.cdageass
         AND crapass.cdcooper = craprda.cdcooper
         AND crapass.nrdconta = craprda.nrdconta
         AND craprda.cdcooper = crapcop.cdcooper
         AND crapcop.flgativo = 1
         AND craprda.vlslfmes <> 0
         AND (craprda.dtsdfmes <> '31/05/2019' OR craprda.dtsdfmes IS NULL)
    ORDER BY craprda.cdcooper;
    rw_craprda30 cr_craprda30%ROWTYPE;                                                       


  CURSOR cr_craprda60 IS        
   SELECT    craprda.cdcooper,
             craprda.nrdconta,
             DECODE(crapass.inpessoa,3,2,crapass.inpessoa) inpessoa, /* Tratamento para considerar pessoas do tipo 3 como PJ */
             crapass.cdagenci,
             craprda.nraplica,
             craprda.dtcalcul,
             craprda.insaqtot,
             craprda.dtmvtolt,
             craprda.vlabdiof,
             craprda.qtrgtmfx,
             craprda.qtaplmfx,
             craprda.flgctain,
             craprda.vlaplica,
             craprda.vlabcpmf,
             craprda.vlslfmes,
             craprda.cdageass,
             craprda.tpaplica,
             craprda.rowid row_id,
             crapage.nmresage,
             crapass.nmprimtl
        FROM crapass,
             crapage,
             craprda,
             crapcop
       WHERE  craprda.tpaplica = 5 -- RDCA60
         AND crapage.cdcooper = craprda.cdcooper
         AND crapage.cdagenci = craprda.cdageass
         AND crapass.cdcooper = craprda.cdcooper
         AND crapass.nrdconta = craprda.nrdconta
         AND craprda.cdcooper = crapcop.cdcooper
         AND crapcop.flgativo = 1
         AND craprda.vlslfmes <> 0
         AND (craprda.dtsdfmes <> '31/05/2019' OR craprda.dtsdfmes IS NULL)
    ORDER BY craprda.cdcooper;
    rw_craprda60 cr_craprda60%ROWTYPE;
    
  vr_nom_diretorio varchar2(200);
  vr_nmarqdat varchar2(200);
  vr_arquivo_txt utl_file.file_type;
  vr_dscritic VARCHAR2(4000);
  vr_dslinha VARCHAR2(4000);
BEGIN
  
  -- gerar arquivo contabil
  vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                            pr_cdcooper => 3,
                                            pr_nmsubdir => 'log');
                                            
  vr_nmarqdat := 'script_retorno_RITM0019956.log';                                         
                                            

  -- Abre o arquivo para escrita
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio,    --> Diretório do arquivo
                           pr_nmarquiv => vr_nmarqdat,         --> Nome do arquivo
                           pr_tipabert => 'W',                 --> Modo de abertura (R,W,A)
                           pr_utlfileh => vr_arquivo_txt,      --> Handle do arquivo aberto
                           pr_des_erro => vr_dscritic);
  
    -- RDCA30
    FOR rw_craprda30 IN cr_craprda30 LOOP
      
      vr_dslinha := 'update craprda set vlslfmes = ' || to_char(rw_craprda30.vlslfmes,'9999999999990.00') || ', insaqtot = ' || rw_craprda30.insaqtot || 
                    ' WHERE rowid = ' || '''' || rw_craprda30.row_id || '''' || ';';   
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_dslinha);       
    
     UPDATE craprda SET vlslfmes = 0, insaqtot = 1
       WHERE craprda.rowid = rw_craprda30.row_id;         
    END LOOP; -- FIM RDCA30
    
     -- RDCA60
    FOR rw_craprda60 IN cr_craprda60 LOOP
      
      vr_dslinha := 'update craprda set vlslfmes = ' || to_char(rw_craprda60.vlslfmes,'999999999990.00') || ', insaqtot = ' || rw_craprda60.insaqtot || 
                    ' WHERE rowid = ' || '''' || rw_craprda60.row_id || '''' || ';';   
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_dslinha);
      
      UPDATE craprda SET vlslfmes = 0, insaqtot = 1
       WHERE craprda.rowid = rw_craprda60.row_id;         
    END LOOP; -- FIM RDCA60
    
    vr_dslinha := ' commit;';
    gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_dslinha); 
  
  
    gene0001.pc_fecha_arquivo(vr_arquivo_txt);
    
    COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
  
end;
