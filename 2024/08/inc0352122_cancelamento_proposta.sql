begin
  update cecred.tbseg_prestamista p set p.TPREGIST = 0 where p.CDCOOPER = 1 and p.NRDCONTA = 3092283 and p.NRCTRSEG = 1864323 and p.NRPROPOSTA = '202406330123' and p.NRCTREMP = 8320127;
  update cecred.crapseg p set  p.CDSITSEG = 2, p.DTCANCEL = sysdate, p.CDMOTCAN = 6 where p.CDCOOPER = 1 and p.NRDCONTA = 3092283 and p.NRCTRSEG = 1864323;
  commit;
end;  
