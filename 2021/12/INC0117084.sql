begin

UPDATE CRAPCEM
   SET INPRINCIPAL = 1
 where cdcooper = 1
   and nrdconta = 8197393
   AND DSDEMAIL = 'stahnke.bnu@gmail.com';
   
   commit;
   
end;