begin
	UPDATE crapass t
	   SET t.nmprimtl = 'JOÃO DA SILVA GONÇALVES'
	 WHERE T.CDCOOPER = 1 AND T.NRDCONTA = 11706643;
	commit;
end;