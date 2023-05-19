DECLARE

  vr_ind_arq        utl_file.file_type;
  vr_linha          VARCHAR2(32767);
  vr_dscritic       VARCHAR2(2000);
  vr_nmdir          VARCHAR2(4000) := CECRED.gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS')||'cpd/bacas/INC0266503';
  vr_nmarq          VARCHAR2(100)  := 'ROLLBACK_INC0266503.sql';
  vr_exc_saida      EXCEPTION;

  CURSOR cr_principal IS
    select p.cdcooper, p.nrdconta, p.nrctrseg, p.nrctremp, p.nrproposta, p.tpregist,s.cdsitseg,s.dtcancel,s.cdmotcan, p.tprecusa, s.dtinivig
	  from cecred.crawseg w,
		   cecred.crapseg s,
		   cecred.tbseg_prestamista p
	 where w.cdcooper = s.cdcooper
	   and w.nrdconta = s.nrdconta
	   and w.nrctrseg = s.nrctrseg
	   and s.cdcooper = p.cdcooper
	   and s.nrdconta = p.nrdconta
	   and s.nrctrseg = p.nrctrseg
	   and s.tpseguro = 4
	   and (p.cdcooper,p.nrdconta,p.nrctremp) in ((2,15813070,423443),
												 (2,873926,433246),
												 (2,16089367,434762),
												 (2,16156064,436918),
												 (2,637823,442887),
												 (10,110264,44124),
												 (10,169625,44731),
												 (10,15234347,44841),
												 (10,15640981,45083),
												 (10,15069524,45116),
												 (10,15160998,45122),
												 (10,15030032,45170),
												 (10,110752,45146),
												 (10,15017214,45228),
												 (10,231665,45207),
												 (10,227340,45135),
												 (10,16237030,45267),
												 (10,16248708,45263),
												 (11,729205,309697),
												 (11,14948591,316695),
												 (13,16148312,264341),
												 (13,59382,264260),
												 (13,655724,264353),
												 (13,654426,265365),
												 (13,16102690,266089),
												 (13,218065,268132),
												 (13,576042,268554),
												 (13,493376,269616),
												 (14,289981,81526),
												 (14,264539,80922),
												 (14,361860,82820),
												 (14,286052,83521),
												 (14,332755,87319),
												 (14,15123510,92699),
												 (14,332836,92139),
												 (14,157120,92295),
												 (14,16052811,93223))
	 order by p.cdcooper, p.nrdconta, p.nrctremp;

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
          vr_dscritic := 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' ||
                         vr_des_saida;
          RAISE vr_exc_erro;
        END IF;

        CECRED.gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' || pr_nmdireto || ' 1> /dev/null',
                                           pr_typ_saida   => vr_typ_saida,
                                           pr_des_saida   => vr_des_saida);

        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic := 'PERMISSAO NO DIRETORIO -> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' ||
                         vr_des_saida;
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
		  
		vr_linha := 'UPDATE CECRED.crapseg  ' ||
					'   SET cdsitseg = ' || rw_principal.cdsitseg || ', ' ||
					'		dtcancel = NULL, ' ||
					'		cdmotcan = 0 ' ||
					' WHERE cdcooper = ' || rw_principal.cdcooper ||
					'   AND nrdconta = ' || rw_principal.nrdconta ||
					'   AND nrctrseg = ' || rw_principal.nrctrseg ||
					'   AND tpseguro = 4;';

		CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);
		
		vr_linha := 'UPDATE CECRED.tbseg_prestamista ' ||
					'   SET tpregist = ' || rw_principal.tpregist || ', ' ||
					'		tprecusa = NULL ' ||
					' WHERE cdcooper = ' || rw_principal.cdcooper ||
					'   AND nrdconta = ' || rw_principal.nrdconta ||
					'   AND nrctrseg = ' || rw_principal.nrctrseg ||
					'   AND nrctremp = ' || rw_principal.nrctremp || ';';

		CECRED.GENE0001.pc_escr_linha_arquivo(vr_ind_arq,vr_linha);		
					  
		UPDATE CECRED.crapseg 
		   SET cdsitseg = 2,
			   dtcancel = rw_principal.dtinivig,
			   cdmotcan = 4
		 WHERE cdcooper = rw_principal.cdcooper
		   AND nrdconta = rw_principal.nrdconta
		   AND nrctrseg = rw_principal.nrctrseg
		   AND tpseguro = 4;
		
		UPDATE CECRED.tbseg_prestamista
		   SET tpregist = 0,
			   tprecusa = 'INC0266503 - Contratos do produto Consignado e Financiados'
		 WHERE cdcooper = rw_principal.cdcooper
		   AND nrdconta = rw_principal.nrdconta
		   AND nrctrseg = rw_principal.nrctrseg
		   AND nrctremp = rw_principal.nrctremp;		
		 
	END LOOP;
   
  COMMIT; 
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

END;