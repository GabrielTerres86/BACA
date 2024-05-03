DECLARE

  CURSOR cr_crapcop IS
  SELECT cop.cdcooper,
         'CONTA_FUNDING_CONTRATO' nome_param,
         CASE WHEN cop.cdcooper = 1 THEN 671
              WHEN cop.cdcooper = 2 THEN 892
              WHEN cop.cdcooper = 7 THEN 914
              WHEN cop.cdcooper = 11 THEN 932
              WHEN cop.cdcooper = 16 THEN 680 
              ELSE 0 END conta_param     
    FROM cecred.crapcop cop
   WHERE cop.flgativo = 1
     AND cop.cdcooper IN(1,2,7,11,16)
   UNION
  SELECT cop.cdcooper,
         'CONTA_PRO_COTISTA_CTR' nome_param,
         CASE WHEN cop.cdcooper = 1 THEN 710
              WHEN cop.cdcooper = 2 THEN 906
              WHEN cop.cdcooper = 7 THEN 922
              WHEN cop.cdcooper = 11 THEN 949
              WHEN cop.cdcooper = 16 THEN 728 
              ELSE 0 END conta_param    
    FROM cecred.crapcop cop
   WHERE cop.flgativo = 1
     AND cop.cdcooper IN(1,2,7,11,16)
ORDER BY nome_param,cdcooper;
 
BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP
      INSERT INTO cecred.crappat
        (CDPARTAR
        ,NMPARTAR
        ,TPDEDADO
        ,CDPRODUT)
      SELECT (SELECT MAX(cdpartar) + 1 FROM cecred.crappat)
             ,rw_crapcop.nome_param
             ,2
             ,0
        FROM DUAL
       WHERE NOT EXISTS(SELECT 1 FROM cecred.crappat b WHERE b.nmpartar = rw_crapcop.nome_param);
       
      INSERT INTO cecred.crappco
         (CDPARTAR
         ,CDCOOPER
         ,DSCONTEU)
      VALUES
         ((SELECT a.cdpartar FROM cecred.crappat a WHERE a.nmpartar = rw_crapcop.nome_param)
         ,rw_crapcop.cdcooper
         ,rw_crapcop.conta_param);
  
      COMMIT;
  END LOOP;
  
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
END;
