BEGIN
  UPDATE tbcobran_remessa_npc trn
     SET trn.cdsituac = 0
   WHERE (trn.idtitleg, trn.idopeleg) IN ((58506811, 104983720), (58520994, 104999765));
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaoInterna(pr_compleme => 'INC0100740');
END;
