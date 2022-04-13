 begin 
update crappfp set flsitcre = 1, 
       dthorcre = to_date('06/04/2022', 'dd/mm/rrrr')
where rowid = 'AAAS6XAJQAAAqL6ABk';

update craplfp set idsitlct = 'C' 
 WHERE ROWID IN ('AB+KJiAMsAAH/ngAAf'
                ,'AB+KJiAMsAAH/ngAAg'
                ,'AB+KJiAMsAAH/ngAAh'
                ,'AB+KJiAMsAAH/ngAAi'
                ,'AB+KJiAMsAAH/ngAAj'
                ,'AB+KJiAMsAAH/ngAAk'
                ,'AB+KJiAMsAAH/ngAAl');
commit;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
end; 
 