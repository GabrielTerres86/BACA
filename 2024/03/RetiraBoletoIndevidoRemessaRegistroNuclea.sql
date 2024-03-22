BEGIN
  UPDATE cecred.TBCOBRAN_REMESSA_NPC npc
     SET npc.cdsituac = 2
   WHERE cdsituac = 0
     AND NOT EXISTS (SELECT 1
            FROM crapcob cob
           WHERE cob.cdcooper = 8
             AND cob.nrdconta = 82475920
             AND cob.nrdocmto IN (122, 123, 124)
             AND cob.idtitleg = npc.idtitleg);
  UPDATE tbcobran_retorno_npc trn
     SET trn.cdsituac = 2
   WHERE trn.cdsituac = 0
     AND NOT EXISTS (SELECT 1
            FROM crapcob cob
           WHERE cob.cdcooper = 8
             AND cob.nrdconta = 82475920
             AND cob.nrdocmto IN (122, 123, 124)
             AND cob.idtitleg = trn.idtitleg);
  COMMIT;
END;
