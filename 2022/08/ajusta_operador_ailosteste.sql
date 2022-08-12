begin
  
  UPDATE crapope o
    set o.cdoperad = lower(o.cdoperad)
  where UPPER(o.cdoperad) = 'F0030832';
  
  commit;
  
exception 
  when others then
    raise_application_error(-20000, sqlerrm);
end;
