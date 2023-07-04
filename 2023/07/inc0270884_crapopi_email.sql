begin
  UPDATE CECRED.CRAPOPI OPI
  SET OPI.DSDEMAIL = ' '
  where OPI.TPOPERAI in (1,2)
    and OPI.FLGSITOP = 1
    and OPI.DSDEMAIL is null;
    
  commit;
end;
