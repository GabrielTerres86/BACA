begin

	delete from craptab
	where cdempres = 580
	and cdcooper = 13
	and cdacesso = 'EXECDEBEMP';

  commit;
end;
/