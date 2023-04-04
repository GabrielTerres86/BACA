DECLARE
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;
  vr_handle               UTL_FILE.FILE_TYPE;
  vr_handle_log           UTL_FILE.FILE_TYPE;
  vr_des_erro             VARCHAR2(10000);
  vr_aux_vllimite         NUMBER := 1000;
  vr_cont_commit          NUMBER(6) := 0;
  vr_cont_update          NUMBER(9) := 0;
  vr_cont_registros       NUMBER(9) := 10000;
  vr_coop_controle        NUMBER(2) := 0;
  vr_coop_quebra          NUMBER(2) := 0;
  vr_nmarq_log            VARCHAR2(5000);
  vr_nmarq_rollback       VARCHAR2(5000);

  vr_aux_texto VARCHAR2(5000);

  CURSOR cr_rollback IS
    select
		distinct
		cdcooper,
		nrdconta,
		idseqttl,
		idtipo_limite,
		idperiodo,
		cdsituacao,
		case
		  when sum(vllimite) = sum(vllimite_por_transacao) then
			0
		  else
			1
		end as por_transacao,
		sum(vllimite) as vllimite,
		sum(vllimite_por_transacao) as vllimite_por_transacao
    from (
      select
		  distinct
		  cdcooper,
		  nrdconta,
		  idseqttl,
		  idtipo_limite,
		  idperiodo,
		  cdsituacao,
		  vllimite,
		  0 as vllimite_por_transacao,
		  flpor_transacao
      from pix.tbpix_limite_cooperado
		  where idtipo_limite = 2
		  and cdsituacao = 1
		  and flpor_transacao = 0

      union all

      select
		  distinct
		  cdcooper,
		  nrdconta,
		  idseqttl,
		  idtipo_limite,
		  idperiodo,
		  cdsituacao,
		  0 as vllimite,
		  vllimite as vllimite_por_transacao,
		  flpor_transacao
      from pix.tbpix_limite_cooperado
		  where idtipo_limite = 2
		  and cdsituacao = 1
		  and flpor_transacao = 1
    ) LIMITES
    group by
		cdcooper,
		nrdconta,
		idseqttl,
		idtipo_limite,
		idperiodo,
		cdsituacao
    order by 
		cdcooper, 
		nrdconta, 
		idseqttl, 
		idperiodo 
	asc;
  rw_rollback cr_rollback%ROWTYPE;

BEGIN

  vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/ritm0290030/' || '1_LOG.txt';
  
  gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_log,
                           pr_tipabert => 'W',
                           pr_utlfileh => vr_handle_log,
                           pr_des_erro => vr_des_erro);
						   
  IF vr_des_erro IS NOT NULL THEN
	vr_dscritic := 'Erro ao abrir arquivo de LOG: ' || vr_des_erro;
	RAISE vr_exc_erro;
  END IF;
    
  OPEN cr_rollback;
  LOOP
    FETCH cr_rollback INTO rw_rollback;
    EXIT WHEN cr_rollback%NOTFOUND;

      vr_cont_commit := vr_cont_commit + 1;
      vr_cont_update := vr_cont_update + 1;
    
    IF vr_coop_quebra > 0 AND vr_coop_quebra <> rw_rollback.cdcooper THEN         
       IF vr_cont_commit <= vr_cont_registros AND vr_cont_commit > 0 THEN
          vr_cont_commit := 0;
          COMMIT;
          
          vr_aux_texto := 'COMMIT;';
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                 pr_des_text => vr_aux_texto);
          vr_aux_texto := '';
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                 pr_des_text => vr_aux_texto);        
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                 pr_des_text => 'END;');
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
       END IF;
    END IF;
    
    IF vr_coop_controle <> rw_rollback.cdcooper THEN
		vr_coop_controle := rw_rollback.cdcooper;
		vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/ritm0290030/' || 'coop_' || vr_coop_controle || '_ROLLBACK.sql';
		gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback,
						   pr_tipabert => 'W',
						   pr_utlfileh => vr_handle,
						   pr_des_erro => vr_des_erro);
		IF vr_des_erro IS NOT NULL THEN
			vr_dscritic := 'Erro ao abrir arquivo de ROLLBACK: ' || vr_des_erro;
			RAISE vr_exc_erro;
		END IF;

		gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
					 pr_des_text => 'BEGIN');
		vr_aux_texto := '';
		gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
					 pr_des_text => vr_aux_texto);
    END IF;
      
	IF rw_rollback.por_transacao = 0 THEN
		vr_aux_texto := '  UPDATE pix.tbpix_limite_cooperado SET vllimite = ' ||
		rw_rollback.vllimite ||
		' WHERE cdcooper = ' || rw_rollback.cdcooper ||
		' and nrdconta = ' || rw_rollback.nrdconta ||
		' and idseqttl = ' || rw_rollback.idseqttl ||
		' and idtipo_limite = ' || rw_rollback.idtipo_limite ||
		' and idperiodo = ' || rw_rollback.idperiodo ||
		' and cdsituacao = ' || rw_rollback.cdsituacao || ';';

		gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
					   pr_des_text => vr_aux_texto);
	END IF;

	IF rw_rollback.por_transacao = 1 THEN
		vr_aux_texto := '  UPDATE pix.tbpix_limite_cooperado SET vllimite = ' ||
		rw_rollback.vllimite ||
		' WHERE cdcooper = ' || rw_rollback.cdcooper ||
		' and nrdconta = ' || rw_rollback.nrdconta ||
		' and idseqttl = ' || rw_rollback.idseqttl ||
		' and idtipo_limite = ' || rw_rollback.idtipo_limite ||
		' and idperiodo = ' || rw_rollback.idperiodo ||
		' and cdsituacao = ' || rw_rollback.cdsituacao ||
		' and flpor_transacao = 0;';

		gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
					   pr_des_text => vr_aux_texto);
					   
		vr_aux_texto := '  UPDATE pix.tbpix_limite_cooperado SET vllimite = ' ||
		rw_rollback.vllimite_por_transacao ||
		' WHERE cdcooper = ' || rw_rollback.cdcooper ||
		' and nrdconta = ' || rw_rollback.nrdconta ||
		' and idseqttl = ' || rw_rollback.idseqttl ||
		' and idtipo_limite = ' || rw_rollback.idtipo_limite ||
		' and idperiodo = ' || rw_rollback.idperiodo ||
		' and cdsituacao = ' || rw_rollback.cdsituacao ||
		' and flpor_transacao = 1;';

		gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
					   pr_des_text => vr_aux_texto);
	END IF;
		 
	IF vr_cont_commit = vr_cont_registros THEN
		vr_aux_texto := 'COMMIT;';
		gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
				 pr_des_text => vr_aux_texto);
		vr_aux_texto := '';
		gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
				 pr_des_text => vr_aux_texto);
	END IF;
    
    vr_coop_quebra := rw_rollback.cdcooper;
    
    UPDATE pix.tbpix_limite_cooperado
    SET vllimite = vr_aux_vllimite
    WHERE cdcooper = rw_rollback.cdcooper
    and nrdconta = rw_rollback.nrdconta
    and idseqttl = rw_rollback.idseqttl
    and idtipo_limite = rw_rollback.idtipo_limite
    and idperiodo = rw_rollback.idperiodo
    and cdsituacao = rw_rollback.cdsituacao;

    IF vr_cont_commit = vr_cont_registros THEN
		vr_cont_commit := 0;
		COMMIT;
    END IF;
   
  END LOOP;
  CLOSE cr_rollback;

  IF vr_cont_commit <= vr_cont_registros AND vr_cont_commit > 0 THEN
	vr_aux_texto := 'COMMIT;';
	gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
		 pr_des_text => vr_aux_texto);
	vr_aux_texto := '';
	gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
		 pr_des_text => vr_aux_texto);
  END IF;
                 
  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                 pr_des_text => 'END;');

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
  
  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                 pr_des_text => 'Registros alterados: ' || vr_cont_update);
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);

  COMMIT;

EXCEPTION

  WHEN vr_exc_erro THEN
    dbms_output.put_line('Erro arquivos: ' || vr_dscritic);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                   pr_des_text => 'Erro arquivos: ' ||
                                                  vr_dscritic ||
                                                  ' SQLERRM: ' || SQLERRM);
  
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                   pr_des_text => 'COMMIT;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;
  WHEN OTHERS THEN
    dbms_output.put_line('Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                   pr_des_text => 'Erro geral: ' ||
                                                  ' SQLERRM: ' || SQLERRM);
  
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                   pr_des_text => 'COMMIT;');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;
END;
/