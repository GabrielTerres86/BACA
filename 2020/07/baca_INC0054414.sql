-- Created on 06/07/2020 by F0030248
-- Autor: Rafael Cechet
-- Data: 06/07/2020 
declare 
  -- Local variables here
  i integer;
begin
  -- Test statements here
  FOR rw IN (SELECT a.progress_recid recid, a.nrdctabb, to_number(substr(a.cdpesqbb, 45, 9)) nrdctabb_real  
		           FROM craplcm a
							WHERE a.cdcooper >= 1
								AND a.dtmvtolt = to_date('03/07/2020','DD/MM/RRRR')
								AND a.cdhistor = 1015
								AND a.cdpesqbb LIKE 'INTERNET - TRANSFERENCIA ON-LINE - CONTA    %'
								AND EXISTS (SELECT 1 FROM craplcm b
														 WHERE b.cdcooper = a.cdcooper
															 AND b.nrdconta = to_number(substr(a.cdpesqbb, 45, 9))
															 AND b.nrdctabb = a.nrdconta
															 AND b.dtmvtolt = a.dtmvtolt
															 AND b.vllanmto = a.vllanmto
															 AND b.cdagenci = a.cdagenci
															 AND b.cdhistor = 1014)) LOOP
															 
		--dbms_output.put_line('update craplcm set nrdctabb = ' || rw.nrdctabb || ' where progress_recid = ' || to_char(rw.recid) || ';');
		--dbms_output.put_line('update craplcm set nrdctabb = ' || rw.nrdctabb_real || ' where progress_recid = ' || to_char(rw.recid) || ';');		
		update craplcm set nrdctabb = rw.nrdctabb_real where progress_recid = rw.recid;
															 
  END LOOP;															 
	
	COMMIT;
EXCEPTION 
	WHEN OTHERS THEN
		ROLLBACK;
		dbms_output.put_line('Enviar o erro abaixo para rafael.cechet@ailos.coop.br');
		dbms_output.put_line('Erro: ' || SQLERRM);
end;