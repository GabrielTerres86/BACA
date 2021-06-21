begin
	UPDATE crapcyb x
	  SET x.dtmancad = to_date('16/06/2021','DD/MM/RRRR')
	WHERE x.cdcooper = 5
	AND x.dtdbaixa IS NULL
	AND x.dtmancad < to_date('15/06/2021','DD/MM/RRRR');

	COMMIT;

end;
