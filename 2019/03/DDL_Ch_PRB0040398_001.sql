--DDL_Ch_PRB0040398_001.sql
--  26/02/2019 - Eliminar gearção de arquivo especial npc_RRRRMM.log -- nome do arquivo de log mensal
--               (Belli - Envolti - PRB0040398)
-- 
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1487, '1487 - Situacao do titulo invalida.', 4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1489, '1489 - Inclusao Rejeitada operacao de envio para a CIP',  4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1490, '1490 - Alteracao Rejeitada operacao de envio para a CIP', 4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1491, '1491 - Baixa Rejeitada operacao de envio para a CIP',     4, 0);
INSERT INTO crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA) VALUES (1492, '1492 - Operacao Rejeitada operacao de envio para a CIP',  4, 0);

COMMIT;
