BEGIN
  update craptab set DSTEXTAB = '28800 79200' where cdacesso = 'HRLMNOTURNO';
	COMMIT;	
END;