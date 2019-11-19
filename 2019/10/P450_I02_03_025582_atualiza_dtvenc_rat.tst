PL/SQL Developer Test script 3.0
55
declare 
  CURSOR cr_cop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1;

  CURSOR cr_venc (pr_cdcooper  IN crapcop.cdcooper%TYPE) IS
    SELECT a.cdcooper
          ,nrdconta
          ,nrctremp
          ,a.tpctrato
          ,a.nrcpfcnpj_base
          ,a.dtrisco_rating_autom +
           decode(nvl(a.innivel_rating, 2),
                  1,nvl(tpg.qtdias_atualizacao_autom_baixo, 0),
                  2,nvl(tpg.qtdias_atualizacao_autom_medio, 0),
                  3,nvl(tpg.qtdias_atualizacao_autom_alto, 0),
                  4,nvl(tpg.qtdias_atualiz_autom_altissimo, 0)) dtvenc_ris_calc
          ,decode(nvl(a.innivel_rating, 2),
                  1,nvl(tpg.qtdias_atualizacao_autom_baixo, 0),
                  2,nvl(tpg.qtdias_atualizacao_autom_medio, 0),
                  3,nvl(tpg.qtdias_atualizacao_autom_alto, 0),
                  4,nvl(tpg.qtdias_atualiz_autom_altissimo, 0)) qtdias_venct
      FROM tbrisco_operacoes a, tbrat_param_geral tpg
     WHERE a.insituacao_rating    IN (3, 4) --3-vencido 4-efetivo
       AND a.flencerrado          = 0 --ativo
       AND a.dtvencto_rating      IS NULL
       AND a.dtrisco_rating_autom IS NOT NULL
       AND a.cdcooper             = tpg.cdcooper
       AND nvl(a.inpessoa, 1)     = tpg.inpessoa -- 16/09/2019 - Na falta considera como PF o parametro
       AND a.tpctrato             = tpg.tpproduto
       AND a.cdcooper             = pr_cdcooper
     ORDER BY cdcooper
             ,nrdconta
             ,nrctremp
             ,a.tpctrato;
     
BEGIN

  FOR rw_cop IN cr_cop LOOP
    FOR rw_venc IN cr_venc (pr_cdcooper => rw_cop.cdcooper) LOOP

      UPDATE tbrisco_operacoes t
         SET t.dtvencto_rating    = rw_venc.dtvenc_ris_calc
            ,t.qtdiasvencto_rating = rw_venc.qtdias_venct
       WHERE t.cdcooper       = rw_venc.cdcooper
         AND t.nrdconta       = rw_venc.nrdconta
         AND t.nrctremp       = rw_venc.nrctremp
         AND t.tpctrato       = rw_venc.tpctrato
         AND t.nrcpfcnpj_base = rw_venc.nrcpfcnpj_base;

    END LOOP;
    COMMIT;
  END LOOP;
END;
0
0
