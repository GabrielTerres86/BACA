BEGIN

  UPDATE credito.tbepr_reserva_atraso a
     SET vlreserva = 0
   WHERE a.cdcooperativa = 1
     AND a.nrconta_corrente = 16281845;

  DELETE FROM credito.tbepr_reserva_lancamento a
   WHERE a.idtbepr_reserva_lancamento IN (218948, 219794);

  UPDATE credito.tbepr_reserva_atraso a
     SET vlreserva = 0
   WHERE a.cdcooperativa = 16
     AND a.nrconta_corrente = 241687;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
