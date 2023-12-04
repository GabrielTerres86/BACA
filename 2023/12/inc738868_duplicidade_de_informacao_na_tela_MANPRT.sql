DECLARE
 vr_nrdrowid  ROWID;
BEGIN
  DELETE FROM tbcobran_retorno_ieptb tri
   WHERE tri.cdcooper = 1
     AND tri.nrdconta = 15814882
     AND tri.dtmvtolt = TO_DATE('07/11/2023', 'DD/MM/RRRR')
     AND tri.nrseqarq = 2
     AND tri.vlsaldo_titulo = 10.02;
  
  CECRED.GENE0001.pc_gera_log(pr_cdcooper => 1
                             ,pr_nrdconta => 15814882
                             ,pr_idseqttl => 1
                             ,pr_cdoperad => 't0035324'
                             ,pr_dscritic => 'Registro excluido com sucesso na tabela tbcobran_retorno_ieptb'
                             ,pr_dsorigem => 'COBRANCA'
                             ,pr_dstransa => 'INC738868 duplicidade de informacao na tela MANPRT'
                             ,pr_dttransa => TRUNC(SYSDATE)
                             ,pr_flgtrans => 1
                             ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                             ,pr_nmdatela => 'SCRIPT ADHOC'
                             ,pr_nrdrowid => vr_nrdrowid);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
     CECRED.pc_internal_exception(pr_cdcooper => 1
                                 ,pr_compleme => 'Erro na exclusao de registro na tabela tbcobran_retorno_ieptb - SCRIPT ADHOC => INC738868');
END;
