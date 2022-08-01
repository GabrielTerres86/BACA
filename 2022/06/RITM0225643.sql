DECLARE
  vr_nmdireto   VARCHAR2(4000) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                           ,pr_cdcooper => 0
                                                           ,pr_cdacesso => 'ROOT_DIRCOOP')||'cecred/arq/';
  vr_nmarqimp  VARCHAR2(100) := 'RITM0225643.csv';
  vr_ind_arquiv  utl_file.file_type;

  vr_linha       VARCHAR2(5000);
  vr_campo       GENE0002.typ_split;
  vr_texto_padrao VARCHAR2(200);
  vr_cont         NUMBER(6) := 0;
  vr_dscritic     VARCHAR2(32767);
  
  vr_cpf tbcalris_colaboradores.nrcpfcgc%TYPE;
  vr_nome tbcalris_colaboradores.nmpessoa%TYPE;
  vr_valor tbcalris_colaboradores.vlsalario%TYPE;
  vr_valorvaga tbcalris_colaboradores.vlsalario_vaga%TYPE;
  vr_relac tbcalris_colaboradores.tprelacionamento%TYPE;
  vr_dsrelac tbcalris_colaboradores.dsrelacionamento%TYPE;
  vr_cidade tbcalris_colaboradores.dscidade%TYPE;
  vr_UF tbcalris_colaboradores.dsuf%TYPE;
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
    vr_nome := vr_campo(2);
    vr_relac := GENE0002.fn_char_para_number(vr_campo(3));
    vr_dsrelac := vr_campo(4);
    vr_cidade := vr_campo(5);
    vr_UF := vr_campo(6); 
    vr_valor := GENE0002.fn_char_para_number(vr_campo(7));
    vr_valorvaga := GENE0002.fn_char_para_number(vr_campo(8));    
        
   BEGIN 
     INSERT INTO CECRED.TBCALRIS_COLABORADORES 
            (CDCOOPER, NRCPFCGC, NMPESSOA, CDIDENTIFICADOR_VAGA, TPCOLABORADOR, VLSALARIO, VLSALARIO_VAGA, TPRELACIONAMENTO, DSRELACIONAMENTO, 
             DSCIDADE, DSUF, DHRECEBIMENTO, INSITUACAO) 
     VALUES (3, vr_cpf, vr_nome, '0', 'N', vr_valor, vr_valorvaga, vr_relac, vr_dsrelac, vr_cidade, vr_UF, SYSDATE, 'A');
   EXCEPTION               
   WHEN OTHERS THEN
      vr_dscritic := 'Erro ao INCLUIR CALCULADORA COL: '||SQLERRM;
      dbms_output.put_line(vr_dscritic || ' ' || vr_cpf);
   END;
  
   IF vr_cont = 500 THEN
      vr_cont := 0;
      COMMIT;
    END IF;    
  END LOOP;
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  dbms_output.put_line('Registros incluídos com sucesso. ');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    dbms_output.put_line(SQLERRM);
    dbms_output.put_line(SQLCODE);
    ROLLBACK; 
END;