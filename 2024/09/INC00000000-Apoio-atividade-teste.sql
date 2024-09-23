begin
  UPDATE cecred.crapass c SET  c.DTCNSCPF = SYSDATE - 3 
  WHERE  c.NRCPFCGC IN ( select distinct ttl.nrcpfcgc
                        from cecred.crapttl ttl
                        , cecred.crapass pass
                        where ttl.CDCOOPER IN ( 1,2,5,6,7,8,9,10,11,12,13,14,16)
                         and ttl.dtnasttl is not null
                         and pass.nrcpfcgc = ttl.nrcpfcgc
                         and pass.INPESSOA = 1
                         and pass.dtdemiss is null
                         and (extract(DAY from  pass.DTNASCTL )=extract(DAY from sysdate ))
                         AND  TRUNC(pass.DTCNSCPF) = TRUNC(SYSDATE)
                       );
  commit;
exception
  when others then
    rollback;
    raise_application_error(-20000, 'erro: ' || SQLERRM);
end;
