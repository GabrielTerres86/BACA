
--Rollback dos ajustes
update crapscn a set a.qtdigito = 0 , a.tppreenc = 0 where a.progress_recid = '2720';
update crapscn a set a.qtdigito = 0 , a.tppreenc = 0 where a.progress_recid = '161';

COMMIT;
