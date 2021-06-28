declare
begin 
	
delete crapprm
 where cdacesso = 'IDENT_DEPOSITANTE_R80'
   and dsvlrprm = 'S'
   and cdcooper = 1;
   
   commit;
end;
/