BEGIN

  UPDATE cecred.crawepr
     SET idquapro = 3
   WHERE ((cdcooper = 16 and nrdconta = 15811093 and nrctremp = 868982 )or
          (cdcooper = 16 and nrdconta = 468533   and nrctremp = 878054 )or
          (cdcooper = 13 and nrdconta = 17090547 and nrctremp = 382793 )or
          (cdcooper = 13 and nrdconta = 14843838 and nrctremp = 382988 )or
          (cdcooper = 13 and nrdconta = 734284   and nrctremp = 383003 )or
          (cdcooper =  1 and nrdconta = 2425980  and nrctremp = 8553950 )or
          (cdcooper =  1 and nrdconta = 2917122  and nrctremp = 8600931 )or
          (cdcooper =  1 and nrdconta = 6289924  and nrctremp = 8601758 )or
          (cdcooper =  1 and nrdconta = 11477210 and nrctremp = 8590859 )or
          (cdcooper =  1 and nrdconta = 11550716 and nrctremp = 8585166 )or
          (cdcooper =  1 and nrdconta = 11963050 and nrctremp = 8594854 )or
          (cdcooper =  1 and nrdconta = 14750260 and nrctremp = 8584990 )or
          (cdcooper =  1 and nrdconta = 14845938 and nrctremp = 8590317 )or
          (cdcooper =  1 and nrdconta = 16108469 and nrctremp = 8593413 )or
          (cdcooper =  1 and nrdconta = 80279856 and nrctremp = 8592430 )or
          (cdcooper =  2 and nrdconta = 875732   and nrctremp = 559526 )or
          (cdcooper = 10 and nrdconta = 17667194 and nrctremp = 59278 )or
          (cdcooper = 12 and nrdconta = 152021   and nrctremp = 109454 )or
          (cdcooper =  7 and nrdconta = 15684393 and nrctremp = 143458 )OR
          (cdcooper = 10 and nrdconta = 62618    and nrctremp = 58986));

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM || ' - ' || dbms_utility.format_error_backtrace);
END;
