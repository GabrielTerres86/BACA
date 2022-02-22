begin
  

delete gncpddc 
where cdcooper = 1 
  and dtmvtolt = to_date('21/01/2022','DD/MM/YYYY');

commit;
end;
