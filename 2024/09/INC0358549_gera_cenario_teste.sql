begin
  
  update cecred.crapavt av
    set av.dsproftl = 'TESOUREIRO'
  WHERE AV.CDCOOPER = 1
    AND AV.NRDCONTA = 85513296
    AND AV.NRCPFCGC = 978991940;
  
  COMMIT;
  
exception
  when others then
    raise_application_error(-20000, 'erro: ' || sqlerrm);
end;
