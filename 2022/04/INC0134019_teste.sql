 begin 
update crappfp set flsitcre = 1, 
       dthorcre = to_date('06/04/2022', 'dd/mm/rrrr')
where rowid = 'AAHOqDAAGAACGekAAe';

update craplfp set idsitlct = 'C' 
 WHERE ROWID IN ('AAHQxIAAHAAPdTDAAD');
commit;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
end; 
 