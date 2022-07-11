begin 

delete gncpddc c 
where  c.cdcooper = 3
   and c.dtmvtolt = to_date('08/07/2022','DD/MM/YYYY');
 
commit;
end;
