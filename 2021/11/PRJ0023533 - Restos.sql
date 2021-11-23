BEGIN
  update crapprg
     set nrsolici = 1, nrordprg = 73
   where cdprogra = 'CRPS093'
   and cdcooper <> 3;
  commit;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao executar alteração dos programas (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            SQLERRM);
END;
