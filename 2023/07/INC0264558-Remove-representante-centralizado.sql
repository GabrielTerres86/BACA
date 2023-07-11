DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0264558_dados.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'INC0264558_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'INC0264558_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  
  vr_cdcooper           CECRED.crapass.CDCOOPER%TYPE;
  vr_nrdconta           CECRED.crapass.NRDCONTA%TYPE;
  vr_dsnatjur           VARCHAR2(255);
  vr_cdnatjur           CECRED.crapjur.NATJURID%TYPE;
  vr_dtmvtolt           CECRED.crapalt.DTALTERA%TYPE;
  vr_comments           VARCHAR2(2000);
  vr_msgalt             VARCHAR2(1000);
  vr_hrtransa           CECRED.craplgm.HRTRANSA%TYPE;
  vr_nrdrowid           ROWID;
  vr_seq_enc            NUMBER(3);
  vr_dsmodule           VARCHAR2(100);
  
  CURSOR cr_rep IS
    SELECT p.nrcpfcgc
      , r.*
    FROM CECRED.Tbcadast_Pessoa_Juridica_Rep r
    JOIN CECRED.tbcadast_pessoa p on r.idpessoa_representante = p.idpessoa
    WHERE r.idpessoa = 243573
      AND r.idpessoa_representante = 19467;
  
  rg_rep                cr_rep%ROWTYPE;
  
  CURSOR cr_rep_total IS
    SELECT p.nrcpfcgc
      , r.tpcargo_representante
      , dom.dscodigo
    FROM CECRED.Tbcadast_Pessoa_Juridica_Rep r
    JOIN CECRED.tbcadast_pessoa p ON r.idpessoa_representante = p.idpessoa
    LEFT JOIN tbcadast_dominio_campo dom ON to_char(r.tpcargo_representante) = dom.cddominio
                                            AND dom.nmdominio = 'TPCARGO_REPRESENTANTE'
    WHERE r.idpessoa = 243573;
  
  rg_rep_total          cr_rep_total%ROWTYPE;
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0264558';
  
  vr_seq_file   := 1;
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp || LPAD(vr_seq_file, 3, '0') || '.sql'
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN
    
    RAISE vr_exception;
     
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqlog
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arqlog
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN
    
    RAISE vr_exception;
     
  END IF;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Início: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  vr_count := 0;
  
  OPEN cr_rep;
  FETCH cr_rep INTO rg_rep;
  
  IF cr_rep%FOUND THEN
    BEGIN
      
      DELETE CECRED.Tbcadast_Pessoa_Juridica_Rep
      WHERE idpessoa               = rg_rep.idpessoa
        AND idpessoa_representante = rg_rep.idpessoa_representante;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'INSERT INTO CECRED.Tbcadast_Pessoa_Juridica_Rep ( '
                                                    || ' idpessoa '
                                                    || ' , nrseq_representante '
                                                    || ' , idpessoa_representante '
                                                    || ' , tpcargo_representante '
                                                    || ' , dtvigencia '
                                                    || ' , dtadmissao '
                                                    || ' , persocio '
                                                    || ' , flgdependencia_economica '
                                                    || ' , cdoperad_altera '
                                                    || ' , nrdconta '
                                                    || ' , cdcooper'
                                                    || ' ) VALUES ( '
                                                    ||          rg_rep.idpessoa 
                                                    || ' , ' || rg_rep.nrseq_representante 
                                                    || ' , ' || rg_rep.idpessoa_representante 
                                                    || ' , ' || rg_rep.tpcargo_representante 
                                                    || ' , TO_DATE( ''' || TO_CHAR(rg_rep.dtvigencia, 'DD/MM/RRRR') || ''' , ''DD/MM/RRRR'') '
                                                    || ' , TO_DATE( ''' || TO_CHAR(rg_rep.dtadmissao, 'DD/MM/RRRR') || ''' , ''DD/MM/RRRR'') '
                                                    || ' , ' || rg_rep.persocio 
                                                    || ' , ' || rg_rep.flgdependencia_economica 
                                                    || ' , ' || rg_rep.cdoperad_altera 
                                                    || ' , ' || NVL( TRIM( TO_CHAR(rg_rep.nrdconta) ), 'NULL')
                                                    || ' , ' || NVL( TRIM( TO_CHAR(rg_rep.cdcooper) ), 'NULL')
                                                    || ' ); ' );
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' * Representante com CPF: ' || rg_rep.nrcpfcgc || ' excluído com sucesso. ');
      
    EXCEPTION
      WHEN OTHERS THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ******** ERRO ao excluir representante com CPF: ' || rg_rep.nrcpfcgc || '. ERRO: ' || SQLERRM);
        
    END;
  
  ELSE
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ******** ATENÇÃO: Representante NÃO encontrado para exclusão.');
    
  END IF;
  
  CLOSE cr_rep;
  
  OPEN cr_rep_total;
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ==> Representantes restantes após script:');
  LOOP
    FETCH cr_rep_total INTO rg_rep_total;
    EXIT WHEN cr_rep_total%NOTFOUND;
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' Rep: ' || rg_rep_total.nrcpfcgc || ' - Cargo: (' || rg_rep_total.tpcargo_representante || ') ' || rg_rep_total.dscodigo);
    
  END LOOP;
  
  CLOSE cr_rep_total;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  COMMIT; ');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS'));
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exception THEN
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20003, 'Erro: ' || vr_dscritic);
    
  WHEN OTHERS THEN
    
    cecred.pc_internal_exception;
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20004, 'ERRO NÃO TRATADO: ' || SQLERRM);
    
END;
