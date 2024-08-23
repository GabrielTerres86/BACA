begin
  
update  cecred.tbchq_deposito_cheque_mob m
   set m.insituacao = 4
where  m.insituacao = 1
  and  m.dtdeposito < trunc(sysdate);
  and (m.cdcooper, m.nrdconta, m.idseqdeposito) IN
       ((16, 943746, 243396),
        (9, 432610, 243393),
        (9, 432610, 243395),
        (9, 432610, 243394),
        (1, 10002707, 243513),
        (1, 10002707, 243514),
        (1, 10002707, 243512));
        
commit;
end;
