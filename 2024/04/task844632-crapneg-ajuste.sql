begin

	delete
	from crapsqu
	where UPPER(nmtabela) = upper('CRAPNEG')
	and UPPER(nmdcampo) = upper('NRSEQDIG')
	and UPPER(dsdchave) like upper('16;%');

	insert into crapsqu (nmtabela, nmdcampo, dsdchave, nrseqatu)
	select 'CRAPNEG', 'NRSEQDIG', '16;'||nrdconta, 2000 from crapass where cdcooper = 16;

	commit;

end;
