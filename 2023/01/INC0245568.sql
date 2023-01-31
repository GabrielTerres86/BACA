BEGIN
  update cecred.crapsnh snh
  set snh.cdsitsnh = 1,
      snh.dtlibera = trunc(sysdate),
      snh.dtaltsit = trunc(sysdate),
      snh.qtacerro = 0
  where snh.cdcooper = 2
    and snh.nrdconta in (1164929, 581879)
    and snh.tpdsenha = 1
    and snh.cdsitsnh = 2;

  update cecred.crapopi opi
  set opi.dtlibera = sysdate,
      opi.dtultalt = sysdate,
      opi.flgsitop = 1,
      opi.qtacerro = 0
  where opi.cdcooper = 2
    and opi.nrdconta in (1164929, 581879)
    and opi.flgsitop = 0
    and opi.tpoperai = 0
    and (trunc(sysdate) - trunc(opi.DTULTALT)) <= 5;
    
  commit;  
END;