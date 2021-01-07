/* Reprocessar retorno da CIP no Aimaro - INC0068484
   Atualizar a situação do retorno para zero, para o mesmo ser reprocessado e atualizado no Aimaro
   Sincronizar com a CIP*/
BEGIN
  --
  UPDATE tbcobran_retorno_npc trn
     SET trn.cdsituac = 0
   WHERE trn.cdlegado = 'LEG'
     AND trn.idtitleg = '43120663'
     AND trn.idoperjd = to_number('20201019001774209451')
     AND trn.nrispbad = 5463212;
  --
  COMMIT;
  --
END;
