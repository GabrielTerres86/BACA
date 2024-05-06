DECLARE

  CURSOR cr_permiss(pr_cdcooper  cecred.crapace.cdcooper%TYPE
                   ,pr_cddopcao  cecred.crapace.cddopcao%TYPE
                   ,pr_cdcoperad cecred.crapace.cdoperad%TYPE) IS
    SELECT 1
      FROM cecred.crapace
     WHERE cdcooper = pr_cdcooper
       AND upper(nmdatela) = 'RESERV'
       AND upper(nmrotina) = ' '
       AND upper(cddopcao) = pr_cddopcao
       AND upper(cdoperad) = upper(pr_cdcoperad);
  rw_permiss cr_permiss%ROWTYPE;

BEGIN

  FOR ope IN (SELECT * FROM cecred.crapope a WHERE a.cdsitope = 1) LOOP
  
    OPEN cr_permiss(pr_cdcooper  => ope.cdcooper,
                    pr_cddopcao  => 'C',
                    pr_cdcoperad => ope.cdoperad);
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'C', ope.cdoperad, ' ', ope.cdcooper, 1, 0, 2);
    END IF;
  
    CLOSE cr_permiss;
  
    IF ope.nvoperad IN (2, 3) THEN
      OPEN cr_permiss(pr_cdcooper  => ope.cdcooper,
                      pr_cddopcao  => 'R',
                      pr_cdcoperad => ope.cdoperad);
      FETCH cr_permiss
        INTO rw_permiss;
    
      IF cr_permiss%NOTFOUND THEN
        INSERT INTO cecred.crapace
          (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
           idevento, idambace)
        VALUES
          ('RESERV', 'R', ope.cdoperad, ' ', ope.cdcooper, 1, 0, 2);
      END IF;
      CLOSE cr_permiss;
    END IF;
  
  END LOOP;

  FOR rw_coop IN (SELECT cdcooper FROM cecred.crapcop c WHERE c.flgativo = 1) LOOP
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'C',
                    pr_cdcoperad => 'f0030584');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'C', 'f0030584', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
  
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'R',
                    pr_cdcoperad => 'f0030584');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'R', 'f0030584', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'C',
                    pr_cdcoperad => 'f0034469');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'C', 'f0034469', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
  
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'R',
                    pr_cdcoperad => 'f0034469');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'R', 'f0034469', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'C',
                    pr_cdcoperad => 'f0034338');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'C', 'f0034338', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
  
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'R',
                    pr_cdcoperad => 'f0034338');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'R', 'f0034338', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'C',
                    pr_cdcoperad => 'f0034665');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'C', 'f0034665', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
  
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'R',
                    pr_cdcoperad => 'f0034665');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'R', 'f0034665', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'C',
                    pr_cdcoperad => 'f0033853');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'C', 'f0033853', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
  
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'R',
                    pr_cdcoperad => 'f0033853');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'R', 'f0033853', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'C',
                    pr_cdcoperad => 'f0033863');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'C', 'f0033863', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
  
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'R',
                    pr_cdcoperad => 'f0033863');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'R', 'f0033863', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'C',
                    pr_cdcoperad => 'f0033595');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'C', 'f0033595', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
  
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'R',
                    pr_cdcoperad => 'f0033595');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'R', 'f0033595', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'C',
                    pr_cdcoperad => 'f0033301');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'C', 'f0033301', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
  
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'R',
                    pr_cdcoperad => 'f0033301');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'R', 'f0033301', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'C',
                    pr_cdcoperad => 'f0034432');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'C', 'f0034432', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
  
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'R',
                    pr_cdcoperad => 'f0034432');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'R', 'f0034432', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'C',
                    pr_cdcoperad => 'f0033655');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'C', 'f0033655', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
  
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'R',
                    pr_cdcoperad => 'f0033655');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'R', 'f0033655', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'C',
                    pr_cdcoperad => 'f0034775');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'C', 'f0034775', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
  
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'R',
                    pr_cdcoperad => 'f0034775');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'R', 'f0034775', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'C',
                    pr_cdcoperad => 'f0034755');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'C', 'f0034755', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
  
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'R',
                    pr_cdcoperad => 'f0034755');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'R', 'f0034755', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'C',
                    pr_cdcoperad => 'f0033495');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'C', 'f0033495', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
  
    CLOSE cr_permiss;
  
    OPEN cr_permiss(pr_cdcooper  => rw_coop.cdcooper,
                    pr_cddopcao  => 'R',
                    pr_cdcoperad => 'f0033495');
    FETCH cr_permiss
      INTO rw_permiss;
  
    IF cr_permiss%NOTFOUND THEN
    
      INSERT INTO cecred.crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo,
         idevento, idambace)
      VALUES
        ('RESERV', 'R', 'f0033495', ' ', rw_coop.cdcooper, 1, 0, 2);
    
    END IF;
    CLOSE cr_permiss;
  
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
