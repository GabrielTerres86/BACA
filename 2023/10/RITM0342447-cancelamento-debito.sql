Begin
  UPDATE CECRED.craplau l
     SET l.insitlau = 3, l.dtdebito = to_date('16/06/2023', 'dd/mm/yyyy')
   WHERE l.cdcooper = 9
     AND l.nrdconta = 191310
     AND l.nrctremp = 87029;
  commit;
end;
