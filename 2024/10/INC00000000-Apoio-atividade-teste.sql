begin
  UPDATE CRAPASS  
    SET DTCNSCPF=  SYSDATE  - 3  
  WHERE NRCPFCGC IN (13648282948,10452553350,12211663958,2048044930,54350271953,14446626,7121269961,9740996,869787993,61504386949,8377928,7553978,16167902,4649966,75074974020,9884998,3056007);
  commit;
exception
  when others then
    rollback;
    raise_application_error(-20000, 'erro: ' || SQLERRM);
end;