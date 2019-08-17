-- Created by f0030248 - Rafael Cechet
-- baca para atualizar crapaca - carta de anuencia
BEGIN
  UPDATE crapaca SET lstparam = 'pr_cdcooper,pr_nrdconta,pr_nrcnvcob,pr_nrdocmto,pr_cdbandoc,pr_dtcatanu,pr_nmrepres,pr_dtmvtolt' 
  WHERE nmdeacao = 'RELAT_CARTA_ANUENCIA';
  
  COMMIT;
END;