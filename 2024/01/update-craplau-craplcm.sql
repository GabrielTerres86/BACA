
begin 
  
update cecred.craplcm set nrdocmto = 184226160, 
where nrdolote = 10004  and nrdconta = 97802212 and nrdocmto = 18422616;

update cecred.craplau set nrdocmto = 184226160, 
where cdseqtel = 202406  and nrdconta = 97802212 and nrdocmto = 18422616;

commit;
end;

