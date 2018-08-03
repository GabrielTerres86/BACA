UPDATE crapseg seg
   SET seg.indebito = 0
 WHERE seg.cdcooper = 9
   AND seg.cdsitseg = 1
	 AND (
	   (seg.nrdconta = 40118 AND seg.nrctrseg = 48)
		 OR (seg.nrdconta = 52809 AND seg.nrctrseg = 503)
		 OR (seg.nrdconta = 56022 AND seg.nrctrseg = 494)
		 OR (seg.nrdconta = 62987 AND seg.nrctrseg = 509)
	 );
COMMIT;

