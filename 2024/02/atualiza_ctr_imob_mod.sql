BEGIN
    update tbepr_imob_imp_arq_risco 
   set cdmodali = '09'
      ,cdsubmod = '02'
where contrt = 744011;
  COMMIT;
END;
