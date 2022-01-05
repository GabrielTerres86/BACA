BEGIN
delete from tbepr_imovel_alienado where dtinclusao is null;
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
