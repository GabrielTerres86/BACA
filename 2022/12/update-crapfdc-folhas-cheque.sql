begin
  
update cecred.crapfdc c
  set c.incheque = 8,
      c.dtliqchq = trunc(sysdate),
      c.nrpedido = null 
where  c.cdcooper = 1
  and  c.nrdconta = 27936
  and  c.nrcheque in (171, 172, 173, 174, 175, 176, 177, 178, 179, 180);

commit;
end;
