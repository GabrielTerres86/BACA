BEGIN
   /* Cancelamento de cheques da VIACREDI não retirados antes de 31/12/2014 */
   UPDATE crapfdc fdc
      SET dtretchq = trunc(SYSDATE), dtliqchq = trunc(SYSDATE), incheque = 8
    WHERE fdc.cdcooper = 1
      AND fdc.dtretchq IS NULL
      AND fdc.incheque = 0
      AND fdc.dtemschq <= '31/12/2014';

   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
END;
