BEGIN

  update cecred.crapass a set cdsitdct = 4
   where a.cdcooper = 1
     and a.nrdconta = 11984805;
   
   commit;
   
EXCEPTION
   WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao atualizar situação da conta '||sqlerrm);

end;