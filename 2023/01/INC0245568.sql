BEGIN
  update cecred.crapsnh snh
  set snh.cdsitsnh = 1, -- liberada
      snh.dtlibera = trunc(sysdate),
      snh.dtaltsit = trunc(sysdate),
      snh.qtacerro = 0 -- qtde de erros no login
  where snh.cdcooper = 2 -- cooperativa >>>>>>>>> AJUSTAR AQUI A COOPERATIVA DESEJADA <<<<<<<<<<<<<
    and snh.nrdconta in (1164929, 581879) -- número da conta  >>>>>>> AJUSTAR AQUI O NÚMERO DE CONTA DESEJADO <<<<<<<
    and snh.tpdsenha = 1 -- senha de canais (CO e app)
    and snh.cdsitsnh = 2; -- senha bloqueada

  update cecred.crapopi opi
  set opi.dtlibera = sysdate,
      opi.dtultalt = sysdate,
      opi.flgsitop = 1, -- liberado
      opi.qtacerro = 0
  where opi.cdcooper = 2 -- cooperativa    >>>>>>>>> AJUSTAR AQUI A COOPERATIVA DESEJADA <<<<<<<<<<<<<
    and opi.nrdconta in (1164929, 581879) -- número da conta  >>>>>>> AJUSTAR AQUI O NÚMERO DE CONTA DESEJADO <<<<<<<
    and opi.flgsitop = 0 -- operador bloqueado
    and opi.tpoperai = 0 -- operdaor normal
    and (trunc(sysdate) - trunc(opi.DTULTALT)) <= 5;  -- considerar bloqueio nos últimos 5 dias
    
  commit;  
END;