DECLARE

  /*INC00110124 - Reprocessar os titulos com problemas na CIP */
BEGIN
  --Reprocessamento
  UPDATE tbcobran_remessa_npc trn
     SET trn.cdsituac = 0
   WHERE trn.idtitleg IN (63419087
                         ,63419088
                         ,63419089
                         ,63419072
                         ,63419074
                         ,63419076
                         ,63419070
                         ,63419069
                         ,63419071
                         ,63419073
                         ,63419075);

  COMMIT;

END;
