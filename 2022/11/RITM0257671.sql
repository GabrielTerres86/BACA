DECLARE
  vr_nmdireto   VARCHAR2(4000) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                           ,pr_cdcooper => 0
                                                           ,pr_cdacesso => 'ROOT_DIRCOOP')||'cecred/arq/';
  vr_nmarqimp  VARCHAR2(100) := 'RITM0257671.csv';
  vr_ind_arquiv  utl_file.file_type;

  vr_linha       VARCHAR2(5000);
  vr_campo       GENE0002.typ_split;
  vr_cont         NUMBER(6) := 0;
  vr_dscritic     VARCHAR2(32767);
  vr_teste varchar(5000);
  
  vr_cpf tbcalris_colaboradores.nrcpfcgc%TYPE;
  vr_nome tbcalris_colaboradores.nmpessoa%TYPE;
  vr_valor tbcalris_colaboradores.vlsalario%TYPE;
  vr_valorvaga tbcalris_colaboradores.vlsalario_vaga%TYPE;
  vr_relac tbcalris_colaboradores.tprelacionamento%TYPE;
  vr_dsrelac tbcalris_colaboradores.dsrelacionamento%TYPE;
  vr_cidade tbcalris_colaboradores.dscidade%TYPE;
  vr_UF tbcalris_colaboradores.dsuf%TYPE;
  vr_data tbcalris_colaboradores.dhrecebimento%TYPE;
  vr_data_atual tbcalris_colaboradores.dhrecebimento%TYPE;
  vr_cooperativa tbcalris_colaboradores.cdcooper%TYPE;
  vr_exc_saida EXCEPTION; 
  
  CURSOR cr_colaborador (pr_cdcooper IN CECRED.TBCALRIS_COLABORADORES.CDCOOPER%type
                       ,pr_nrcpf IN CECRED.TBCALRIS_COLABORADORES.NRCPFCGC%type
                       ,pr_tpcolab IN CECRED.TBCALRIS_COLABORADORES.TPCOLABORADOR%type) IS    
    SELECT COUNT(COLAB.IDCALRIS_COLABORADOR) QUANTIDADE
     FROM CECRED.TBCALRIS_COLABORADORES COLAB
    WHERE COLAB.NRCPFCGC = pr_nrcpf;        
  vr_atualiza     cr_colaborador%ROWTYPE;
  
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
  vr_data := SYSDATE;
  vr_data_atual := vr_data;

  LOOP    
    BEGIN
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv, pr_des_text => vr_linha);      
    EXCEPTION
      WHEN no_data_found THEN
        EXIT;
    END;  
    vr_cont  := vr_cont + 1;    
    vr_campo := GENE0002.fn_quebra_string(pr_string => vr_linha, pr_delimit => ';');    
    vr_cooperativa := GENE0002.fn_char_para_number(vr_campo(1));      
    vr_nome := vr_campo(2);    
    vr_cpf := GENE0002.fn_char_para_number(vr_campo(3));
    vr_teste := vr_campo(3);
    vr_relac := GENE0002.fn_char_para_number(vr_campo(4));
    vr_dsrelac := vr_campo(5);
    vr_cidade := vr_campo(6);
    vr_UF := vr_campo(7);        
    vr_valor := GENE0002.fn_char_para_number(vr_campo(8));    
    vr_valorvaga := GENE0002.fn_char_para_number(vr_campo(9)); 
    
    BEGIN       
      OPEN cr_colaborador (pr_cdcooper => vr_cooperativa
                          ,pr_nrcpf => vr_cpf
                          ,pr_tpcolab => 'L');
      
      FETCH cr_colaborador INTO vr_atualiza;
      CLOSE cr_colaborador; 
      IF vr_atualiza.quantidade > 0 THEN
         UPDATE CECRED.TBCALRIS_COLABORADORES SET VLSALARIO = vr_valor, VLSALARIO_VAGA = vr_valorvaga, DHALTERACAO = vr_data_atual,
                TPRELACIONAMENTO = vr_relac, DSRELACIONAMENTO = vr_dsrelac, DSCIDADE = vr_cidade, DSUF = vr_UF, CDCOOPER = vr_cooperativa,
                TPCOLABORADOR = 'L', CDIDENTIFICADOR_VAGA = 0
          WHERE NRCPFCGC = vr_cpf;  
      ELSE
         INSERT INTO CECRED.TBCALRIS_COLABORADORES 
                     (CDCOOPER, NRCPFCGC, NMPESSOA, CDIDENTIFICADOR_VAGA, TPCOLABORADOR, VLSALARIO, VLSALARIO_VAGA, TPRELACIONAMENTO, DSRELACIONAMENTO, 
                      DSCIDADE, DSUF, DHRECEBIMENTO, DHALTERACAO, INSITUACAO) 
              VALUES (vr_cooperativa, vr_cpf, vr_nome, '0', 'L', vr_valor, vr_valorvaga, vr_relac, vr_dsrelac, vr_cidade, vr_UF, vr_data, vr_data_atual, 'A');       
     END IF; 
     
     IF vr_cont = 450 THEN
        vr_cont := 0;
        vr_data := vr_data + 1;
        vr_data_atual := vr_data;       
        COMMIT;
     END IF;   
   EXCEPTION               
   WHEN OTHERS THEN
      vr_dscritic := 'Erro ao INCLUIR CALCULADORA COL: '||SQLERRM || ' ' || vr_nome || ' ' || vr_teste ;
      dbms_output.put_line(vr_dscritic || ' ' || vr_cpf);
   END;
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