begin
	UPDATE crapsld a 
	  SET a.dtrefere = TO_DATE('14/03/2024','DD/MM/YYYY')
	  where a.cdcooper = 13
	  and a.dtrefere >= TO_DATE('04/03/2024','DD/MM/YYYY');
	commit;
end;