DECLARE
  vr_exc_erro       EXCEPTION;
  vr_dsdireto       VARCHAR2(2000);
  vr_nmarquiv       VARCHAR2(100);
  vr_dscritic       VARCHAR2(4000);
  vr_ind_arquiv     utl_file.file_type;
  vr_ind_arqlog     utl_file.file_type;
  vr_dslinha        VARCHAR2(4000);
  vr_dados_rollback CLOB;
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
  vr_dttransa       cecred.craplgm.dttransa%type;
  vr_hrtransa       cecred.craplgm.hrtransa%type;
  vr_nrdrowid       ROWID;
  vr_typ_saida      VARCHAR2(3);
  
  vr_vet_dados      cecred.gene0002.typ_split;

  vr_des_xml         CLOB;
  vr_texto_completo  VARCHAR2(32600);
  vr_nrdconta        cecred.crapass.nrdconta%TYPE;

  vr_inrisco_atraso_original cecred.crapris.innivris%TYPE;
  vr_inrisco_atraso_novo     cecred.crapris.innivris%TYPE;
  vr_inrisco_atraso          cecred.crapris.innivris%TYPE;
  
  vr_contrato        cecred.crapris.nrctremp%TYPE;
  vr_cooper          cecred.crapepr.cdcooper%TYPE;
  
  CURSOR cr_crapepr(pr_cdcooper IN cecred.crapepr.cdcooper%TYPE
                   ,pr_nrctremp IN cecred.crapepr.nrctremp%TYPE) IS
    SELECT e.nrdconta
      FROM cecred.crapepr e
     WHERE e.cdcooper = pr_cdcooper
       AND e.nrctremp = pr_nrctremp;
  rw_crapepr cr_crapepr%ROWTYPE;
  
  CURSOR cr_crapris(pr_cdcooper IN cecred.crapris.cdcooper%TYPE
                   ,pr_nrdconta IN cecred.crapris.nrdconta%TYPE
                   ,pr_nrctremp IN cecred.crapris.nrctremp%TYPE) IS
    SELECT r.qtdiaatr
          ,o.qtparcelas_controle_riscomelhora
          ,o.inrisco_melhora
          ,o.dtrisco_melhora  
          ,o.cdcritica_melhora
          ,o.tpctrato
      FROM cecred.crapris r, cecred.crapdat d, cecred.tbrisco_operacoes o
     WHERE d.cdcooper = r.cdcooper
       AND r.dtrefere = d.dtmvcentral
       AND o.cdcooper = r.cdcooper
       AND o.nrdconta = r.nrdconta
       AND o.nrctremp = r.nrctremp
       AND r.cdcooper = pr_cdcooper
       AND r.nrdconta = pr_nrdconta
       AND r.nrctremp = pr_nrctremp;
  rw_crapris cr_crapris%ROWTYPE;

  rw_crapdat cecred.btch0001.cr_crapdat%ROWTYPE;
BEGIN

  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'Rollback das informacoes'||chr(13), FALSE);

  vr_dsdireto := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto := vr_dsdireto||'cpd/bacas/INC0270861'; 
  vr_nmarqbkp := 'INC0270861_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';

  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := CECRED.GENE0002.fn_busca_time;
  
 for i in 1 .. 2 loop
 
	 IF(i = 1) THEN
		vr_contrato :=  108450 ;
		vr_cooper := 5;
	 ELSE
		vr_contrato :=  102762  ;
		vr_cooper := 14;
	 END IF;
 

	 OPEN  btch0001.cr_crapdat(pr_cdcooper => vr_cooper);
	  FETCH btch0001.cr_crapdat INTO rw_crapdat;
	  CLOSE btch0001.cr_crapdat;
			
	  OPEN cr_crapepr(pr_cdcooper => vr_cooper
					 ,pr_nrctremp => vr_contrato);
	  FETCH cr_crapepr INTO rw_crapepr;
	  IF cr_crapepr%NOTFOUND THEN
		CLOSE cr_crapepr;
		raise_application_error(-20100, 'Erro: COnta nao encontrada');
	  ELSE
		vr_nrdconta := rw_crapepr.nrdconta;
		CLOSE cr_crapepr;
	  END IF;
			  
	  OPEN cr_crapris(pr_cdcooper => vr_cooper
					 ,pr_nrdconta => vr_nrdconta
					 ,pr_nrctremp => vr_contrato);
	  FETCH cr_crapris INTO rw_crapris;
	  CLOSE cr_crapris;
			  
	  cecred.RISC0004.pc_grava_risco_melhora(pr_cdcooper            => vr_cooper
											,pr_nrdconta            => vr_nrdconta
											,pr_nrctremp            => vr_contrato
											,pr_tpctrato            => rw_crapris.tpctrato
											,pr_qtcontrole_melhora  => rw_crapris.qtparcelas_controle_riscomelhora
											,pr_inrisco_melhora     => 4
											,pr_dtrisco_melhora     => rw_crapdat.dtmvtolt
											,pr_dscritic            => vr_dscritic);
	  IF vr_dscritic IS NOT NULL THEN
		RAISE vr_exc_erro;
	  END IF;
			
	  vr_nrdrowid := NULL;
			
	  CECRED.GENE0001.pc_gera_log(pr_cdcooper => vr_cooper
								 ,pr_cdoperad => 1
								 ,pr_dscritic => vr_dscritic
								 ,pr_dsorigem => 'AIMARO'
								 ,pr_dstransa => 'Atualizacao de risco melhora Consignado'
								 ,pr_dttransa => vr_dttransa
								 ,pr_flgtrans => 1
								 ,pr_hrtransa => vr_hrtransa
								 ,pr_idseqttl => 0
								 ,pr_nmdatela => NULL
								 ,pr_nrdconta => vr_nrdconta
								 ,pr_nrdrowid => vr_nrdrowid);
			
	  CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
									  ,pr_nmdcampo => 'Contrato'
									  ,pr_dsdadant => vr_contrato
									  ,pr_dsdadatu => 0);
											
	  CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
									  ,pr_nmdcampo => 'Risco Melhora'
									  ,pr_dsdadant => rw_crapris.inrisco_melhora
									  ,pr_dsdadatu => vr_inrisco_atraso);

	  gene0002.pc_escreve_xml(vr_dados_rollback
							 ,vr_texto_rollback
							 ,'UPDATE cecred.tbrisco_operacoes o' || chr(13) || 
							  '   SET o.inrisco_melhora                  = ' || nvl(to_char(rw_crapris.inrisco_melhora), 'null') || chr(13) || 
							  '      ,o.dtrisco_melhora                  = to_date(''' || nvl(to_char(rw_crapris.dtrisco_melhora), '') || ''', ''DD/MM/RRRR'')' || chr(13) || 
							  '      ,o.qtparcelas_controle_riscomelhora = ' || nvl(to_char(rw_crapris.qtparcelas_controle_riscomelhora), 'null') || chr(13) || 
							  '      ,o.cdcritica_melhora                = ' || nvl(to_char(rw_crapris.cdcritica_melhora), 'null') || chr(13) || 
							  ' WHERE o.cdcooper = '|| vr_cooper || chr(13) || 
							  '   AND o.nrdconta = ' || vr_nrdconta     || chr(13) || 
							  '   AND o.nrctremp = '|| vr_contrato || 
							  ';' ||chr(13)||chr(13), FALSE); 
			
	  gene0002.pc_escreve_xml(vr_dados_rollback
							 ,vr_texto_rollback
							 ,'UPDATE cecred.crawepr w' || chr(13) || 
							  '   SET w.inrisco_melhora  = ' || nvl(to_char(cecred.RISC0004.fn_traduz_risco(innivris => rw_crapris.inrisco_melhora)), 'null') || chr(13) || 
							  ' WHERE w.cdcooper = '||vr_cooper|| chr(13) || 
							  '   AND w.nrdconta = ' || vr_nrdconta     || chr(13) || 
							  '   AND w.nrctremp = '|| vr_contrato || 
							  ';' ||chr(13)||chr(13), FALSE); 
						  
						  
	end loop;					  
						  
        
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE); 
             
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                             
                                     ,pr_cdprogra  => 'ATENDA'                      
                                     ,pr_dtmvtolt  => trunc(SYSDATE)                
                                     ,pr_dsxml     => vr_dados_rollback             
                                     ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqbkp 
                                     ,pr_flg_impri => 'N'                           
                                     ,pr_flg_gerar => 'S'                           
                                     ,pr_flgremarq => 'N'                           
                                     ,pr_nrcopias  => 1                             
                                     ,pr_des_erro  => vr_dscritic);                 
        
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;   

  COMMIT;
  
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback); 
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro: ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, SQLERRM);
END;
