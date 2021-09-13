declare 
begin
  
  delete crapcob cob
  where cob.cdcooper = 9
  and   cob.nrdconta = 930 
  and cob.dtmvtolt >= '01-08-2021';
  commit;
  
end;  
