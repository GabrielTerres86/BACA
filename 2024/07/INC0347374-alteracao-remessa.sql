DECLARE
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  
BEGIN
  
  UPDATE PAGAMENTO.TB_BAIXA_PCR_REMESSA TBPREM SET TBPREM.NRPROGRESS_CRAPTIT = NULL
   WHERE TBPREM.IDBAIXA_PCR_REMESSA IN (69388273, 69387986, 69387991, 69387996, 69388279, 69388227, 69388008, 69388034, 69388038, 69388045, 
                                        69388072, 69388096, 69388144, 69388245, 69388213, 69388215, 69388217, 69387984, 69387988, 69387994, 
                                        69388015, 69388039, 69388115, 69388129, 69388131, 69388177, 69388178, 69388185, 69388189, 69388197, 
                                        69388205, 69388276, 69388032, 69388048, 69388051, 69388071, 69388090, 69388094, 69388122, 69388139, 
                                        69388140, 69388142, 69388243, 69388196, 69388363, 69388374, 69388369, 69388293, 69388325, 69388324, 
                                        69388330, 69388204, 69388221, 69388277, 69388009, 69388016, 69388028, 69388061, 69388091, 69388092, 
                                        69388114, 69388121, 69388128, 69388242, 69388151, 69388174, 69388187, 69388216, 69388266, 69388268, 
                                        69388271, 69388361, 69388383, 69388391);

  COMMIT;
    pagamento.montarjobremessaboaimaroctg(pr_cdcooper => 0
                                         ,pr_nrdconta => 0
                                         ,pr_dtmvtolt => to_date('22072024', 'ddmmyyyy')
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_cdcooper => 3, pr_compleme => 'INC0347374');
END;  
