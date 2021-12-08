begin

UPDATE PIX.TBPIX_PARAMETROS_GERAIS$ p SET p.vlmin_noturno_saque_troco = 0;
Commit;

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
end;

