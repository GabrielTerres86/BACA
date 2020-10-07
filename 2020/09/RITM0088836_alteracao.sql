BEGIN
   /* Cancelamento de cheques da VIACREDI não retirados antes de 31/12/2014 */
	UPDATE crapfdc fdc
	   SET dtretchq = trunc(SYSDATE), 
		   dtliqchq = trunc(SYSDATE), 
		   incheque = 8
	 WHERE fdc.cdcooper = 1
	   AND fdc.dtretchq IS NULL
	   AND fdc.incheque = 0
	   AND progress_recid >= 6685544
	   AND progress_recid <= 37879967
	   AND fdc.cdbanchq IN (1, 85, 756)
	   AND fdc.cdagechq IN (101, 103, 3239, 3420, 4415)
	   AND fdc.dtemschq <= '31/12/2014';

   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
END;
