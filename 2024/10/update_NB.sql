begin
  UPDATE cecred.CRAPCBI q
    SET q.nrdconta = 1234
  WHERE q.nrbenefi = 5331749018;
  commit;
end;