begin
  update cecred.crapseg s
     set s.cdsitseg = 2, s.dtcancel = s.dtinivig, s.cdmotcan = 4
   where s.cdcooper = 1
     and s.nrdconta = 9519947
     and s.NRCTRSEG in (1520345, 1528126, 1535799);
  commit;
end;
