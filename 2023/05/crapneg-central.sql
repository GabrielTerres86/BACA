begin

	delete
	from crapsqu
	where UPPER(nmtabela) = upper('CRAPNEG')
	and UPPER(nmdcampo) = upper('NRSEQDIG')
	and UPPER(dsdchave) like upper('3;%');

	insert into crapsqu (nmtabela, nmdcampo, dsdchave, nrseqatu)
	select 'CRAPNEG', 'NRSEQDIG', '3;'||nrdconta, 1000 from crapass where cdcooper = 3;

	commit;

end;
