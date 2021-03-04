BEGIN

  DECLARE
    -- Buscar registro da RDR
    CURSOR cr_craprdr IS
      SELECT t.nrseqrdr
        FROM craprdr t
       WHERE t.NMPROGRA = 'CRD_GRUPO_AFINIDADE_BIN';
    -- Variaveis
    vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  BEGIN
    -- Buscar RDR
    OPEN cr_craprdr;
    FETCH cr_craprdr
      INTO vr_nrseqrdr;
    -- Se nao encontrar
    IF cr_craprdr%NOTFOUND THEN
      INSERT INTO craprdr
        (nmprogra, dtsolici)
      VALUES
        ('CRD_GRUPO_AFINIDADE_BIN', SYSDATE)
      RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
    END IF;
    -- Fechar o cursor
    CLOSE cr_craprdr;
  
    INSERT INTO crapaca
      (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
      ('BUSCAR_GRUPO_AFINIDADE_BIN',
       'CRD_GRUPO_AFINIDADE_BIN',
       'pc_consultar_afinidade_bin',
       'pr_cdcooper, pr_cdadmcrd',
       vr_nrseqrdr);
  
    INSERT INTO crapaca
      (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    VALUES
      ('MANTER_GRUPO_AFINIDADE_BIN',
       'CRD_GRUPO_AFINIDADE_BIN',
       'pc_manter_afinidade_bin',
       'pr_cdcooper, pr_cdadmcrd, pr_dtvigencia, pr_bin_antigo, pr_bin_novo, pr_gf_antigo, pr_gf_novo',
       vr_nrseqrdr);
  
  
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro ao executar: CRD_GRUPO_AFINIDADE_BIN --- detalhes do erro: ' ||
                           SQLCODE || ': ' || SQLERRM);
      ROLLBACK;
  END;

  DECLARE
    TYPE typ_rec_adc IS RECORD(
      cdgrafin     tbcrd_grupo_afinidade_bin.cdgrafin%TYPE,
      cdgrafin_ant tbcrd_grupo_afinidade_bin.cdgrafin%TYPE,
      nrctamae     tbcrd_grupo_afinidade_bin.nrctamae%TYPE,
      nrctamae_ant tbcrd_grupo_afinidade_bin.nrctamae_ant%TYPE);
  
    TYPE typ_tab_adc IS TABLE OF typ_rec_adc INDEX BY PLS_INTEGER;
    vr_typ_adc typ_tab_adc;
  
    CURSOR cr_crapcop IS
      SELECT c.cdcooper, a.cdadmcrd
        FROM crapcop c, crapadc a
       WHERE c.flgativo = 1
         AND c.cdcooper <> 3
         AND c.cdcooper = a.cdcooper
         AND a.cdadmcrd BETWEEN 12 AND 18;
  
    PROCEDURE pc_definir_vetor_bins_afins IS
    BEGIN
      -- AILOS ESSENCIAL
      /*vr_typ_adc(11).cdgrafin     := 7563239;
      vr_typ_adc(11).cdgrafin_ant := 7563239;
      vr_typ_adc(11).nrctamae     := 250060;
      vr_typ_adc(11).nrctamae_ant := 604203;*/
    
      -- AILOS CLASSICO
      vr_typ_adc(12).cdgrafin := 8513239;
      vr_typ_adc(12).cdgrafin_ant := 9513239;
      vr_typ_adc(12).nrctamae := 250060;
      vr_typ_adc(12).nrctamae_ant := 512707;
    
      -- AILOS GOLD
      vr_typ_adc(13).cdgrafin := 8523239;
      vr_typ_adc(13).cdgrafin_ant := 9523239;
      vr_typ_adc(13).nrctamae := 250062;
      vr_typ_adc(13).nrctamae_ant := 515894;
    
      -- AILOS PLATINUM
      vr_typ_adc(14).cdgrafin := 8553239;
      vr_typ_adc(14).cdgrafin_ant := 9553239;
      vr_typ_adc(14).nrctamae := 529396;
      vr_typ_adc(14).nrctamae_ant := 515601;
    
      -- AILOS EMPRESAS
      vr_typ_adc(15).cdgrafin := 8533239;
      vr_typ_adc(15).cdgrafin_ant := 9533239;
      vr_typ_adc(15).nrctamae := 533100;
      vr_typ_adc(15).nrctamae_ant := 547408;
    
      -- AILOS DEBITO
      vr_typ_adc(16).cdgrafin := 8503239;
      vr_typ_adc(16).cdgrafin_ant := 9503239;
      vr_typ_adc(16).nrctamae := 550204;
      vr_typ_adc(16).nrctamae_ant := 639350;
    
      -- AILOS EMPRESAS DEB
      vr_typ_adc(17).cdgrafin := 8543239;
      vr_typ_adc(17).cdgrafin_ant := 9543239;
      vr_typ_adc(17).nrctamae := 558819;
      vr_typ_adc(17).nrctamae_ant := 639350;
    
      -- AILOS NOW PERSONALIZADO
      vr_typ_adc(18).cdgrafin := 8813239;
      vr_typ_adc(18).cdgrafin_ant := 9813239;
      vr_typ_adc(18).nrctamae := 250061;
      vr_typ_adc(18).nrctamae_ant := 516162;
    END;
  
    PROCEDURE pc_insere_tabela_bins_afin(pr_cdcooper     IN tbcrd_grupo_afinidade_bin.cdcooper%TYPE,
                                         pr_cdadmcrd     IN tbcrd_grupo_afinidade_bin.cdadmcrd%TYPE,
                                         pr_cdgrafin     IN tbcrd_grupo_afinidade_bin.cdgrafin%TYPE,
                                         pr_cdgrafin_ant IN tbcrd_grupo_afinidade_bin.cdgrafin_ant%TYPE,
                                         pr_nrctamae     IN tbcrd_grupo_afinidade_bin.nrctamae%TYPE,
                                         pr_nrctamae_ant IN tbcrd_grupo_afinidade_bin.nrctamae_ant%TYPE) IS
    BEGIN
      INSERT INTO tbcrd_grupo_afinidade_bin
        (cdcooper,
         cdadmcrd,
         cdgrafin,
         cdgrafin_ant,
         nrctamae,
         nrctamae_ant,
         dtvigencia,
         cdoperad,
         dtinclusao)
      VALUES
        (pr_cdcooper,
         pr_cdadmcrd,
         pr_cdgrafin,
         pr_cdgrafin_ant,
         pr_nrctamae,
         pr_nrctamae_ant,
         to_date('01/05/2021', 'DD/MM/RRRR'),
         'BACA',
         SYSDATE);
    END;
  
  BEGIN
    pc_definir_vetor_bins_afins;
  
    FOR dados IN cr_crapcop LOOP
      BEGIN
        pc_insere_tabela_bins_afin(dados.cdcooper,
                                   dados.cdadmcrd,
                                   vr_typ_adc    (dados.cdadmcrd).cdgrafin,
                                   vr_typ_adc    (dados.cdadmcrd).cdgrafin_ant,
                                   vr_typ_adc    (dados.cdadmcrd).nrctamae,
                                   vr_typ_adc    (dados.cdadmcrd).nrctamae_ant);
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20111,
                                  'Erro ao inserir valor. ' || SQLERRM);
      END;
    END LOOP;
  
  END;
  
  BEGIN
    -- Cria códigos tabela de histórico (craphcb)
    --
    INSERT INTO craphcb
      (cdtrnbcb, dstrnbcb, cdhistor, flgdebcc)
    VALUES
      (203, 'COMPRA MAESTRO NACIONAL DMC (ONLINE)', 3482, 1);
    --
    INSERT INTO craphcb
      (cdtrnbcb, dstrnbcb, cdhistor, flgdebcc)
    VALUES
      (204, 'COMPRA MAESTRO INTERNACIONAL DMC (ONLINE)', 3481, 1);
    --
    INSERT INTO craphcb
      (cdtrnbcb, dstrnbcb, cdhistor, flgdebcc)
    VALUES
      (263, 'ESTORNO COMPRA MAESTRO NACIONAL DMC (ONLINE)', 3486, 1);
    --
    INSERT INTO craphcb
      (cdtrnbcb, dstrnbcb, cdhistor, flgdebcc)
    VALUES
      (264, 'ESTORNO COMPRA MAESTRO INTERNACIONAL DMC (ONLINE)', 3485, 1);
    --
    INSERT INTO craphcb
      (cdtrnbcb, dstrnbcb, cdhistor, flgdebcc)
    VALUES
      (206, 'SAQUE CIRRUS INTERNACIONAL DMC (ONLINE)', 3489, 1);
    --
    INSERT INTO craphcb
      (cdtrnbcb, dstrnbcb, cdhistor, flgdebcc)
    VALUES
      (205, 'SAQUE CIRRUS NACIONAL DMC (ONLINE)', 3490, 1);
    --
    INSERT INTO craphcb
      (cdtrnbcb, dstrnbcb, cdhistor, flgdebcc)
    VALUES
      (266, 'ESTORNO SAQUE CIRRUS INTERNACIONAL DMC (ONLINE)', 3493, 1);
    --
    INSERT INTO craphcb
      (cdtrnbcb, dstrnbcb, cdhistor, flgdebcc)
    VALUES
      (265, 'ESTORNO SAQUE CIRRUS NACIONAL DMC (ONLINE)', 3494, 1);
      
    -- Criar códigos para tabela de cartões (tbcrd_his_vinculo_bancoob)
    -- 
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (204, 3481, 0);
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (203, 3482, 0);
    -- 
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (204, 3483, 1);
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (203, 3484, 1);
    -- 
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (264, 3485, 0);
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (263, 3486, 0);
    -- 
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (264, 3487, 1);
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (263, 3488, 1);
    -- 
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (206, 3489, 0);
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (205, 3490, 0);
    -- 
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (206, 3491, 1);
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (205, 3492, 1);
    -- 
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (266, 3493, 0);
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (265, 3494, 0);
    -- 
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (266, 3495, 1);
    INSERT INTO tbcrd_his_vinculo_bancoob
      (cdtrnbcb, cdhistor, tphistorico)
    VALUES
      (265, 3496, 1);

  END;
  
  COMMIT;

END;
