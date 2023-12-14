begin
  
  UPDATE cecred.crawseg w SET W.NRPROPOSTA = '202315147521' where w.NRCTRSEG = 1589428 and w.NRDCONTA = 9051309 and w.NRPROPOSTA = '202315035483' and w.cdcooper = 1;

   
  UPDATE CECRED.craplau l
     SET l.insitlau = 3, l.dtdebito = to_date('28/03/2023', 'dd/mm/yyyy')
   WHERE l.cdcooper = 10
     AND l.nrdconta =  212156
     AND l.nrctremp = 46085;
     
  commit;
end;  
