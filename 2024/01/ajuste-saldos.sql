BEGIN
  
    DELETE FROM crapsda a 
    WHERE a.cdcooper = 6 
    AND a.dtmvtolt = to_date('10/01/2024','DD/MM/YYYY');

    UPDATE crapsld a 
    SET A.DTREFERE = to_date('09/01/2024','DD/MM/YYYY')
    where a.cdcooper = 6;

    DELETE FROM crapris a 
    where a.cdcooper = 6 
    and a.dtrefere = to_date('10/01/2024','DD/MM/YYYY');
    
    COMMIT;
    
    delete from credito.tbepr_reserva_atraso;
    delete from credito.tbepr_reserva_lancamento;
    
    COMMIT;
END;
