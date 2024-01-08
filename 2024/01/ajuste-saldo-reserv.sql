BEGIN
  
  UPDATE credito.tbepr_reserva_atraso a
     SET a.vlreserva = 3250.00
   WHERE a.id_reserva_atraso = 9750;
  
  COMMIT;
EXCEPTION                                         
  WHEN OTHERS THEN
    ROLLBACK; 
    RAISE_application_error(-20500, 'Erro: ' || SQLERRM);
END;
