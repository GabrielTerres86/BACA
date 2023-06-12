DECLARE
  vr_nmdireto   VARCHAR2(4000) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                           ,pr_cdcooper => 0
                                                           ,pr_cdacesso => 'ROOT_DIRCOOP')||'cecred/arq/';
  vr_nmarqimp  VARCHAR2(100) := 'INC0274631.csv';
  vr_ind_arquiv  utl_file.file_type;
  vr_linha       VARCHAR2(5000);
  vr_campo       GENE0002.typ_split;
  vr_texto_padrao VARCHAR2(200);
  vr_cont         NUMBER(6) := 0;
  vr_dscritic     VARCHAR2(32767);
  
  vr_cpf tbcalris_tanque.nrcpfcgc%TYPE;
  vr_tpcooperado tbcalris_tanque.TPCOOPERADO%TYPE;
  vr_cdstatus tbcalris_tanque.cdstatus%TYPE;
  vr_dhinicio tbcalris_tanque.DHINICIO%TYPE;
  vr_tpcalculadora tbcalris_tanque.TPCALCULADORA%TYPE; 
  vr_exc_saida EXCEPTION;
BEGIN
  dbms_output.put_line(vr_nmdireto);
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto,
                           pr_nmarquiv => vr_nmarqimp,
                           pr_tipabert => 'R',
                           pr_utlfileh => vr_ind_arquiv,
                           pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    dbms_output.put_line(vr_dscritic);
    RAISE vr_exc_saida;
  END IF;
  LOOP
    BEGIN
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv, pr_des_text => vr_linha);
    EXCEPTION
      WHEN no_data_found THEN
        EXIT;
    END;  
    vr_cont  := vr_cont + 1;    
    vr_campo := GENE0002.fn_quebra_string(pr_string => vr_linha, pr_delimit => ';');
  
    vr_cpf := GENE0002.fn_char_para_number(vr_campo(1));  
    vr_tpcooperado := 'N';
    vr_cdstatus := 1;
    vr_dhinicio := SYSDATE;
    vr_tpcalculadora := GENE0002.fn_char_para_number(vr_campo(2));    
        
   BEGIN 
     insert into CECRED.TBCALRIS_TANQUE (NRCPFCGC, TPCOOPERADO, CDSTATUS, DHINICIO, TPCALCULADORA) 
     values (vr_cpf, vr_tpcooperado, vr_cdstatus, vr_dhinicio, vr_tpcalculadora);
   EXCEPTION               
   WHEN OTHERS THEN
      vr_dscritic := 'Erro ao INCLUIR Tanque: '||SQLERRM;
      dbms_output.put_line(vr_dscritic || ' ' || vr_cpf);
   END;
  
   IF vr_cont = 500 THEN
      vr_cont := 0;
      COMMIT;
    END IF;    
  END LOOP;
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  dbms_output.put_line('Registros inclu�dos com sucesso. ');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    dbms_output.put_line(SQLERRM);
    dbms_output.put_line(SQLCODE);
    ROLLBACK; 
END;