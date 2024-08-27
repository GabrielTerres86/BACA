DECLARE
  CURSOR cr_crapcop IS 
   SELECT cop.cdcooper
   FROM crapcop cop;     
   
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_nmparam crappat.nmpartar%TYPE;
  vr_cdpartar crappat.cdpartar%TYPE; 
BEGIN
  vr_nmparam := 'Pre-Aprovado fluxo IFRS9 - Limite';
  vr_cdpartar := 326;
  
  insert into crappat(cdpartar, nmpartar, tpdedado, cdprodut)
  values (vr_cdpartar, vr_nmparam, 1, 0);
  
  OPEN cr_crapcop;
  LOOP
       FETCH cr_crapcop INTO vr_cdcooper;
       EXIT WHEN cr_crapcop%NOTFOUND;
       insert into crappco(cdpartar, cdcooper, dsconteu)
       values (vr_cdpartar, vr_cdcooper, 0);
  END LOOP;
  CLOSE cr_crapcop;
  
  COMMIT;
END; 




