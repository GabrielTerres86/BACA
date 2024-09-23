DECLARE
  vr_nmdireto   VARCHAR2(4000) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                            pr_cdcooper => 0,
                                                            pr_cdacesso => 'ROOT_DIRCOOP') ||
                                  'cecred/arq/';
  vr_nmarqimp   VARCHAR2(100) := 'RITM0417529.csv';
  vr_ind_arquiv utl_file.file_type;

  vr_linha          VARCHAR2(5000);
  vr_campo          GENE0002.typ_split;
  vr_texto_padrao   VARCHAR2(200);
  vr_cont           NUMBER(6) := 0;
  vr_dscritic       VARCHAR2(32767);
  vr_data           DATE := SYSDATE;
  vr_registros_data PLS_INTEGER := 500;
  vr_cont_data      PLS_INTEGER := 1;

  vr_cdcooper           tbcalris_colaboradores.cdcooper%TYPE;
  vr_cdvaga             tbcalris_colaboradores.cdidentificador_vaga%TYPE;
  vr_nome               tbcalris_colaboradores.nmpessoa%TYPE;
  vr_cpf                tbcalris_colaboradores.nrcpfcgc%TYPE;
  vr_tpcolaborador      tbcalris_colaboradores.tpcolaborador%TYPE;
  vr_valor              tbcalris_colaboradores.vlsalario%TYPE;
  vr_valorvaga          tbcalris_colaboradores.vlsalario_vaga%TYPE;
  vr_relac              tbcalris_colaboradores.tprelacionamento%TYPE;
  vr_dsrelac            tbcalris_colaboradores.dsrelacionamento%TYPE;
  vr_cidade             tbcalris_colaboradores.dscidade%TYPE;
  vr_UF                 tbcalris_colaboradores.dsuf%TYPE;
  vr_valorpendencia     tbcalris_colaboradores.vlpendencia%TYPE;
  vr_valorendividamento tbcalris_colaboradores.vlendividamento%TYPE;
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
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv,
                                   pr_des_text => vr_linha);
    EXCEPTION
      WHEN no_data_found THEN
        EXIT;
    END;
    vr_cont      := vr_cont + 1;
    vr_cont_data := vr_cont_data + 1;
    vr_campo     := GENE0002.fn_quebra_string(pr_string  => vr_linha,
                                              pr_delimit => ';');
  
    vr_cdcooper           := GENE0002.fn_char_para_number(TRIM(vr_campo(1)));
    vr_cdvaga             := GENE0002.fn_char_para_number(vr_campo(2));
    vr_nome               := TRIM(vr_campo(3));
    vr_cpf                := GENE0002.fn_char_para_number(replace(replace(vr_campo(4), '.', ''), '-', ''));
    vr_tpcolaborador      := TRIM(vr_campo(5));
    vr_valor              := GENE0002.fn_char_para_number(vr_campo(6));
    vr_valorvaga          := GENE0002.fn_char_para_number(vr_campo(7));
    vr_relac              := GENE0002.fn_char_para_number(vr_campo(8));
    vr_dsrelac            := TRIM(vr_campo(9));
    vr_cidade             := TRIM(vr_campo(10));
    vr_UF                 := REPLACE(REPLACE(TRIM(vr_campo(11)),
                                             CHR(13),
                                             ''),
                                     CHR(10),
                                     '');
    vr_valorpendencia     := GENE0002.fn_char_para_number(vr_campo(12));
    vr_valorendividamento := GENE0002.fn_char_para_number(vr_campo(13));
  
    BEGIN
      MERGE INTO CECRED.TBCALRIS_COLABORADORES dest
      USING (SELECT vr_cdcooper AS cdcooperativa,
                    vr_cdvaga AS cdvaga,
                    vr_nome AS nome,
                    vr_cpf AS cpf,
                    vr_tpcolaborador AS tipocolaborador,
                    vr_valor AS valor,
                    vr_valorvaga AS valorvaga,
                    vr_relac AS relac,
                    vr_dsrelac AS dsrelac,
                    vr_cidade AS cidade,
                    vr_UF AS UF,
                    vr_valorpendencia AS valorpendencia,
                    vr_valorendividamento AS valorendividamento,
                    SYSDATE AS data,
                    'A' AS inst
               FROM dual)
      ON (dest.NRCPFCGC = cpf AND dest.CDIDENTIFICADOR_VAGA = cdvaga)
      WHEN MATCHED THEN
        UPDATE
           SET dest.CDCOOPER         = cdcooperativa,
               dest.NMPESSOA         = nome,
               dest.TPCOLABORADOR    = tipocolaborador,
               dest.VLSALARIO        = valor,
               dest.VLSALARIO_VAGA   = valorvaga,
               dest.TPRELACIONAMENTO = relac,
               dest.DSRELACIONAMENTO = dsrelac,
               dest.DSCIDADE         = cidade,
               dest.DSUF             = UF,
               dest.VLPENDENCIA      = valorpendencia,
               dest.VLENDIVIDAMENTO  = valorendividamento,
               dest.DHRECEBIMENTO    = data,
               dest.INSITUACAO       = inst
      WHEN NOT MATCHED THEN
        INSERT
          (CDCOOPER,
           NRCPFCGC,
           NMPESSOA,
           CDIDENTIFICADOR_VAGA,
           TPCOLABORADOR,
           VLSALARIO,
           VLSALARIO_VAGA,
           TPRELACIONAMENTO,
           DSRELACIONAMENTO,
           DSCIDADE,
           DSUF,
           VLPENDENCIA,
           VLENDIVIDAMENTO,
           DHRECEBIMENTO,
           INSITUACAO)
        VALUES
          (cdcooperativa,
           cpf,
           nome,
           cdvaga,
           tipocolaborador,
           valor,
           valorvaga,
           relac,
           dsrelac,
           cidade,
           UF,
           valorpendencia,
           valorendividamento,
           data,
           inst);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao processar MERGE na CALCULADORA COL: ' ||
                       SQLERRM;
        dbms_output.put_line(vr_dscritic || ' ' || vr_cpf);
    END;
  
    IF vr_cont >= 500 THEN
      vr_cont := 0;
      COMMIT;
    END IF;
  
    IF vr_cont_data >= vr_registros_data THEN
      vr_cont_data := 0;
      vr_data      := vr_data + 1;
    END IF;
  END LOOP;

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  dbms_output.put_line('Registros processados com sucesso. ');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    dbms_output.put_line(SQLERRM);
    dbms_output.put_line(SQLCODE);
    ROLLBACK;
END;