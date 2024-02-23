BEGIN
update crapopi a 
set  a.FLGSITOP = 0
where a.cdcooper=6 and 
	  a.nrdconta=251356 and 
	  a.NRCPFOPE in (754799905,7725524959,5981510951);
  COMMIT;
END;