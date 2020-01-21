--Exclusão de registro da tabela craplau - INC0033219

delete from craplau l
where l.progress_recid in (29377869,29377870,29377871,
						   29377872,29377873,29377874,
                           29377875,29377876,29377877,
						   29377878,29377879,29377880); 
	   
	COMMIT;	   
