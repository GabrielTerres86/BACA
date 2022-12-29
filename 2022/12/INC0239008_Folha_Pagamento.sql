begin 
  
update cecred.craplfp f set f.idsitlct = 'C', f.dsobslct = NULL
 WHERE f.PROGRESS_RECID in (6111378,6111379);
commit;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
end;