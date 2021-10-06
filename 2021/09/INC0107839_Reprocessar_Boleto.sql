/* INC0107839 Reprocessa boleto na CIP. */
BEGIN
  --
  UPDATE tbcobran_retorno_npc trn
     SET trn.cdsituac = 0
   WHERE trn.nrispbad = 5463212
     AND trn.idoperjd = 20210928001816181517
     AND trn.idtitleg = '61454944'
     AND trn.cdlegado = 'LEG';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaoInterna(pr_compleme => 'INC0106590');
END;
