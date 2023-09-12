BEGIN

  update cecred.crapass a set cdsitdct = 4
   where a.cdcooper = 1
     and a.nrdconta = 12389064;
   
  update cecred.crapass a set cdsitdct = 8
   where a.cdcooper = 9
     and a.nrdconta = 183660;
   
   
   commit;
   
EXCEPTION
   WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao atualizar situação da conta '||sqlerrm);

end;
/