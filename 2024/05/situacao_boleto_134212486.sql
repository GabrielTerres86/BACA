BEGIN
update TBCOBRAN_REMESSA_NPC
set cdsituac = 0
where idtitleg = '134212486';
   COMMIT;
END;