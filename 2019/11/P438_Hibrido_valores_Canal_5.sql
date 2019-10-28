-- Insere valores máximos para contratação hibrida
BEGIN
  FOR rw_crapcop IN (SELECT cdcooper FROM crapcop c WHERE c.flgativo = 1) LOOP   
    begin
          
      insert into TBEPR_SEGMENTO_CANAIS_PERM (CDCOOPER, IDSEGMENTO, CDCANAL, TPPERMISSAO, VLMAX_AUTORIZADO)
      values (rw_crapcop.cdcooper, 2, 5, 2, 60000.00);

      insert into TBEPR_SEGMENTO_CANAIS_PERM (CDCOOPER, IDSEGMENTO, CDCANAL, TPPERMISSAO, VLMAX_AUTORIZADO)
      values (rw_crapcop.cdcooper, 1, 5, 2, 30000.00);
    
    exception
      when DUP_VAL_ON_INDEX THEN
        CONTINUE;
    END;
  END LOOP;
  COMMIT;
END;
