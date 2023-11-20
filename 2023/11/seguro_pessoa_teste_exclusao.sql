begin
	delete
	  from tbseg_prestamista p
	 where p.cdcooper = 1
	  and p.nrdconta = 90479998
	  and p.nrctrseg = 1555135;
	  
	delete
	  from crapseg p
	 where p.cdcooper = 1
	  and p.nrdconta = 90479998
	  and p.nrctrseg = 1555135;
	  
	  
	delete
	  from crawseg p
	 where p.cdcooper = 1
	  and p.nrdconta = 90479998
	  and p.nrctrseg = 1555135;
	  
insert into crapseg (NRDCONTA, NRCTRSEG, DTINIVIG, DTFIMVIG, DTMVTOLT, CDAGENCI, CDBCCXLT, CDSITSEG, DTALTSEG, DTCANCEL, DTDEBITO, DTINISEG, INDEBITO, NRDOLOTE, NRSEQDIG, QTPREPAG, VLPREPAG, VLPRESEG, DTULTPAG, TPSEGURO, TPPLASEG, QTPREVIG, CDSEGURA, LSCTRANT, NRCTRATU, FLGUNICA, DTPRIDEB, VLDIFSEG, NMBENVID##1, NMBENVID##2, NMBENVID##3, NMBENVID##4, NMBENVID##5, DSGRAUPR##1, DSGRAUPR##2, DSGRAUPR##3, DSGRAUPR##4, DSGRAUPR##5, TXPARTIC##1, TXPARTIC##2, TXPARTIC##3, TXPARTIC##4, TXPARTIC##5, DTULTALT, CDOPERAD, VLPREMIO, QTPARCEL, TPDPAGTO, CDCOOPER, FLGCONVE, FLGCLABE, CDMOTCAN, TPENDCOR, PROGRESS_RECID, CDOPECNL, DTRENOVA, CDOPEORI, CDAGEORI, DTINSORI, CDOPEEXC, CDAGEEXC, DTINSEXC, VLSLDDEV, IDIMPDPS)
values (90479998, 1520345, to_date('18-09-2023', 'dd-mm-yyyy'), to_date('10-11-2027', 'dd-mm-yyyy'), to_date('18-09-2023', 'dd-mm-yyyy'), 85, 0, 1, null, null, to_date('18-09-2023', 'dd-mm-yyyy'), to_date('18-09-2023', 'dd-mm-yyyy'), 0, 0, 1520345, 0, 0.00, 0.00, to_date('18-09-2023', 'dd-mm-yyyy'), 4, 1, 0, 514, null, 0, 0, to_date('18-09-2023', 'dd-mm-yyyy'), 0.00, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 0.00, 0.00, 0.00, 0.00, 0.00, null, '1', 0.00, 0, 0, 1, 0, 0, 0, 1, 1476639, ' ', null, '1', 85, to_date('16-09-2023 07:06:16', 'dd-mm-yyyy hh24:mi:ss'), ' ', 0, null, 279035.15, 1);

insert into crapseg (NRDCONTA, NRCTRSEG, DTINIVIG, DTFIMVIG, DTMVTOLT, CDAGENCI, CDBCCXLT, CDSITSEG, DTALTSEG, DTCANCEL, DTDEBITO, DTINISEG, INDEBITO, NRDOLOTE, NRSEQDIG, QTPREPAG, VLPREPAG, VLPRESEG, DTULTPAG, TPSEGURO, TPPLASEG, QTPREVIG, CDSEGURA, LSCTRANT, NRCTRATU, FLGUNICA, DTPRIDEB, VLDIFSEG, NMBENVID##1, NMBENVID##2, NMBENVID##3, NMBENVID##4, NMBENVID##5, DSGRAUPR##1, DSGRAUPR##2, DSGRAUPR##3, DSGRAUPR##4, DSGRAUPR##5, TXPARTIC##1, TXPARTIC##2, TXPARTIC##3, TXPARTIC##4, TXPARTIC##5, DTULTALT, CDOPERAD, VLPREMIO, QTPARCEL, TPDPAGTO, CDCOOPER, FLGCONVE, FLGCLABE, CDMOTCAN, TPENDCOR, PROGRESS_RECID, CDOPECNL, DTRENOVA, CDOPEORI, CDAGEORI, DTINSORI, CDOPEEXC, CDAGEEXC, DTINSEXC, VLSLDDEV, IDIMPDPS)
values (90479998, 1528126, to_date('25-09-2023', 'dd-mm-yyyy'), to_date('10-11-2027', 'dd-mm-yyyy'), to_date('25-09-2023', 'dd-mm-yyyy'), 85, 0, 1, null, null, to_date('25-09-2023', 'dd-mm-yyyy'), to_date('25-09-2023', 'dd-mm-yyyy'), 0, 0, 1528126, 0, 0.00, 0.00, to_date('25-09-2023', 'dd-mm-yyyy'), 4, 2, 0, 514, null, 0, 0, to_date('25-09-2023', 'dd-mm-yyyy'), 0.00, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 0.00, 0.00, 0.00, 0.00, 0.00, null, '1', 0.00, 0, 0, 1, 0, 0, 0, 1, 1480485, ' ', null, '1', 85, to_date('23-09-2023 07:06:19', 'dd-mm-yyyy hh24:mi:ss'), ' ', 0, null, 280197.89, 1);

insert into crapseg (NRDCONTA, NRCTRSEG, DTINIVIG, DTFIMVIG, DTMVTOLT, CDAGENCI, CDBCCXLT, CDSITSEG, DTALTSEG, DTCANCEL, DTDEBITO, DTINISEG, INDEBITO, NRDOLOTE, NRSEQDIG, QTPREPAG, VLPREPAG, VLPRESEG, DTULTPAG, TPSEGURO, TPPLASEG, QTPREVIG, CDSEGURA, LSCTRANT, NRCTRATU, FLGUNICA, DTPRIDEB, VLDIFSEG, NMBENVID##1, NMBENVID##2, NMBENVID##3, NMBENVID##4, NMBENVID##5, DSGRAUPR##1, DSGRAUPR##2, DSGRAUPR##3, DSGRAUPR##4, DSGRAUPR##5, TXPARTIC##1, TXPARTIC##2, TXPARTIC##3, TXPARTIC##4, TXPARTIC##5, DTULTALT, CDOPERAD, VLPREMIO, QTPARCEL, TPDPAGTO, CDCOOPER, FLGCONVE, FLGCLABE, CDMOTCAN, TPENDCOR, PROGRESS_RECID, CDOPECNL, DTRENOVA, CDOPEORI, CDAGEORI, DTINSORI, CDOPEEXC, CDAGEEXC, DTINSEXC, VLSLDDEV, IDIMPDPS)
values (90479998, 1535799, to_date('29-09-2023', 'dd-mm-yyyy'), to_date('10-11-2027', 'dd-mm-yyyy'), to_date('29-09-2023', 'dd-mm-yyyy'), 85, 0, 1, null, null, to_date('29-09-2023', 'dd-mm-yyyy'), to_date('29-09-2023', 'dd-mm-yyyy'), 0, 0, 1535799, 0, 0.00, 0.00, to_date('29-09-2023', 'dd-mm-yyyy'), 4, 3, 0, 514, null, 0, 0, to_date('29-09-2023', 'dd-mm-yyyy'), 0.00, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 0.00, 0.00, 0.00, 0.00, 0.00, null, '1', 0.00, 0, 0, 1, 0, 0, 0, 1, 1485088, ' ', null, '1', 85, to_date('30-09-2023 07:07:19', 'dd-mm-yyyy hh24:mi:ss'), ' ', 0, null, 281365.67, 1);
  commit;
  end;
  
