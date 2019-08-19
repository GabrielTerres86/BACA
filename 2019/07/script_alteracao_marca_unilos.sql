begin
-- Mudanças de Marcas
-- CREDIFIESC para UNILOS
-- Alteração marcas
  begin
	/* Logo */   
	update crapprm p
	   set p.dsvlrprm = replace(p.dsvlrprm,'CREDIFIESC','UNILOS')
	 where p.cdcooper = 6
	   and p.cdacesso = 'IMG_LOGO_COOP';
	   
	/* Emails */
	update crapprm p
	   set p.dsvlrprm = replace(p.dsvlrprm,'credifiesc','unilos')
	 where p.cdcooper = 6
	   and p.dsvlrprm like '%@credifiesc%';
	   
	update craptab p
	  set p.dstextab = replace(p.dstextab,'credifiesc','unilos')
	WHERE p.cdacesso = 'EMAILCADRESTRITIVO'
	  and p.dstextab like '%@credifiesc%';
	 
	commit;
   exception
     when others then
       rollback;
   end;    
end;