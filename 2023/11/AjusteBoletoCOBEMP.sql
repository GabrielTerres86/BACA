BEGIN
  UPDATE cecred.crapret ret
     SET ret.flcredit = 3
   WHERE ret.cdcooper = 14
     AND ret.nrcnvcob <> 990113
     AND ret.dtcredit = to_date('20/10/2023', 'dd/mm/rrrr')
     AND ret.flcredit = 0
     AND ret.cdocorre IN (6, 17, 76, 77);
  COMMIT;
END;
