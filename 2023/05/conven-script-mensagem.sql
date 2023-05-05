begin
UPDATE crapcri cri
   SET  SET cri.dscritic =  '001 - Sistema sem data de movimento. 1'
  WHERE cri.cdcritic = 1;
  commit;
  end;