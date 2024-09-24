begin
  UPDATE cecred.crapass c 
    SET  c.DTCNSCPF = SYSDATE - 3 
  WHERE  c.NRCPFCGC IN ( select distinct  ttl.nrcpfcgc
                         from cecred.tbcadast_pessoa pess
                             , cecred.crapttl ttl
                             , cecred.crapass pass
                         where pass.nrcpfcgc = pess.nrcpfcgc
                           AND pess.nrcpfcgc = ttl.nrcpfcgc
                           AND ttl.CDCOOPER IN ( 7,6,12,5,16,8,1,2,14,13,10,11,9)
                           and ttl.dtnasttl is not null
                           and ttl.dtnasttl != TRUNC( SYSDATE )
                           and ( 
								 ( lpad( extract(DAY from  ttl.dtnasttl ),2,'0') = lpad( extract(DAY from sysdate ),2,'0')
                                   and ( lpad( extract(MONTH from  ttl.dtnasttl ),2,'0') = lpad( extract(MONTH from sysdate ),2,'0') ) 
								  ) OR
                                 ttl.dtnasttl = ADD_MONTHS( TRUNC(SYSDATE ), - 6)
                                 )
                          AND  TRUNC(pass.DTCNSCPF) = TRUNC(SYSDATE));
  commit;
exception
  when others then
    rollback;
    raise_application_error(-20000, 'erro: ' || SQLERRM);
end;
