BEGIN
  alter table CECRED.GNCONVE drop column flmigrado ;
  commit;
END;