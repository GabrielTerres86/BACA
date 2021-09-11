begin 

	UPDATE craplfp g 
	   SET g.idsitlct = 'T', 
		   g.dsobslct = ''
	 WHERE g.cdcooper = 7 
	   AND g.nrdconta  IN  (294950,402354,385581,391514,402150,346713,370851)  
	   AND g.progress_recid in (5692354,5697946,5701436,5701451,5701452,5703470,5703510)
	   AND g.dsobslct = 'Transf. solicitada, aguardar transmissão';
   
	commit; 

end; 