---- ESTOU SUBINDO ESSE SCRIPT PARA CORRIGIR ERRO DO AMBIENTE TEST


-- SCRIPT JA LIBERADO EM PROD, MAS NAO PRESENTE NO AMBIENTE
-- SCRIPT ORIGINAL:
  -- prj0023820-update-crapaca.sql
  -- /2021/11/prj0023820-update-crapaca.sql    --- Renier Figueiredo Padilha   29 de nov. de 2021  master(!28833)

BEGIN
  UPDATE crapaca a SET a.lstparam = 'pr_nrdconta,pr_cdprodut,pr_vlcontra,pr_cddchave,pr_vltrnot,pr_vlboont,pr_cdvltrn,pr_cdvlbon'
   WHERE a.nmdeacao = 'VALIDA_VALOR_ADESAO'
     AND a.nmpackag = 'CADA0006';
  COMMIT;     
END;
