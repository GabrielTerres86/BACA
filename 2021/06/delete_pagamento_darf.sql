BEGIN

  DELETE FROM craplft lft
   WHERE lft.cdcooper = 9
     AND lft.dtmvtolt = to_date('23/05/2022','dd/mm/rrrr')
     AND lft.cdagenci = 15
     AND lft.cdbccxlt = 11
     AND lft.nrdolote = 15015
     AND NVL(TRIM(lft.nrrefere), 0) = NVL(TRIM(''), 0)
     AND cdtribut = 2172;

  COMMIT;

END;
