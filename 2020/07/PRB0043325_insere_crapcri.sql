--PRB0043323 - Ana Volles - 17/07/2020
--select * from crapcri b order by 1 DESC;

BEGIN
  INSERT INTO crapcri (cdcritic, dscritic, tpcritic, flgchama)
  VALUES (5026, '5026 - Data Vencimento menor que a Data Atual.', 1, 0);

  COMMIT;
EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
END;
