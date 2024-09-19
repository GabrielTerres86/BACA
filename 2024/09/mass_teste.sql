BEGIN
  
    update cecred.crapebn set insitctr = 'P'
     where cdcooper = 1
       and nrdconta in (99999137,
                        99997894,
                        99996502);
									   
commit;

end;
/