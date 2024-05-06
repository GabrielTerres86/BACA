DECLARE
  vr_nrctrseg   cecred.crawseg.nrctrseg%TYPE;
  vr_nrproposta cecred.crawseg.nrproposta%TYPE;
  vr_exc_saida  EXCEPTION;
  vr_nrseqdig   NUMERIC(15);
  vr_nrsequen   NUMBER(10);
  vr_dtrefere   DATE;
  vr_nmdir      VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0307473';
  vr_nmarq      VARCHAR2(100)  := 'ROLLBACK_INC0307473.sql';
  vr_ind_arq    utl_file.file_type;
  vr_linha      VARCHAR2(32767);
  vr_dscritic   VARCHAR2(2000);
  vr_nrseguro   cecred.tbseg_prestamista.nrctrseg%TYPE;

  CURSOR cr_principal IS
    SELECT cdcooper, nrdconta, nrctrseg
      FROM cecred.crapseg s
     WHERE s.tpseguro = 4
	   AND s.cdsitseg = 1
	   AND s.vlslddev >= 200000
	   AND s.idimpdps = 0
	 ORDER BY cdcooper, nrdconta, nrctrseg;

  rw_principal cr_principal%ROWTYPE;  
  
  PROCEDURE pc_valida_direto(pr_nmdireto IN  VARCHAR2,
                             pr_dscritic OUT CECRED.crapcri.dscritic%TYPE) IS
    vr_dscritic  CECRED.crapcri.dscritic%TYPE;
    vr_typ_saida VARCHAR2(3);
    vr_des_saida VARCHAR2(1000);
    vr_exc_erro  EXCEPTION;
    
  BEGIN
    IF NOT CECRED.gene0001.fn_exis_diretorio(pr_nmdireto) THEN

      CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' || pr_nmdireto || ' 1> /dev/null',
                                         pr_typ_saida   => vr_typ_saida,
                                         pr_des_saida   => vr_des_saida);

      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic := 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;
        RAISE vr_exc_erro;
      END IF;

      CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' || pr_nmdireto || ' 1> /dev/null',
                                         pr_typ_saida   => vr_typ_saida,
                                         pr_des_saida   => vr_des_saida);

      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic := 'PERMISSAO NO DIRETORIO -> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || vr_des_saida;
        RAISE vr_exc_erro;
      END IF;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
  END;  

BEGIN
  pc_valida_direto(pr_nmdireto => vr_nmdir,
                   pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;    
    
  CECRED.GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdir,
                                  pr_nmarquiv => vr_nmarq,
                                  pr_tipabert => 'W',
                                  pr_utlfileh => vr_ind_arq,
                                  pr_des_erro => vr_dscritic);

  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := vr_dscritic ||'  Não pode abrir arquivo '|| vr_nmdir || vr_nmarq;
    RAISE vr_exc_saida;
  END IF;
      
 CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'BEGIN');
  
 FOR rw_principal IN cr_principal LOOP
     
      
   vr_linha := 'UPDATE CECRED.crapseg ' ||
               ' SET idimpdps = 0' || 
               ' WHERE cdcooper = ' || rw_principal.cdcooper ||
               ' AND nrdconta = ' || rw_principal.nrdconta ||
               ' AND nrctrseg = ' || rw_principal.nrctrseg ||
               ' AND tpseguro = 4;';
   
   CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
      
   UPDATE cecred.crapseg s 
      SET s.idimpdps = 1
    WHERE cdcooper = rw_principal.cdcooper 
      AND nrdconta = rw_principal.nrdconta 
      AND nrctrseg = rw_principal.nrctrseg
      AND tpseguro = 4;   
         
   COMMIT;
       
 END LOOP;
 
 CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
 CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
 CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
 CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq ); 
 
 EXCEPTION
   WHEN vr_exc_saida THEN
		CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
		CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
		CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
		CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
		
		vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
		dbms_output.put_line(vr_dscritic);
		ROLLBACK;
   WHEN OTHERS THEN
		CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' COMMIT;');
		CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,' END; ');
		CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,'/ ');
		CECRED.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq );
   
		vr_dscritic := vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
		dbms_output.put_line(vr_dscritic);
		ROLLBACK; 
end;
