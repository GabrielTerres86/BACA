declare 
  CURSOR cr_crawepr_bak IS
     SELECT bak.progress_recid
           ,TRIM(bak.dtinclus) dtinclus
       FROM CECRED.CRAWEPR2503 bak
      WHERE bak.cdcooper = 1;
  vr_contador NUMBER := 0;
begin
  FOR rw_crawepr_bak IN cr_crawepr_bak LOOP
    UPDATE crawepr w
       SET w.dtinclus = rw_crawepr_bak.dtinclus
     WHERE w.progress_recid = rw_crawepr_bak.progress_recid;
    -- Salva a cada 10.000
    IF MOD(vr_contador,10000) = 0 THEN
       COMMIT;
    END IF;
    vr_contador := vr_contador + 1;
  END LOOP;
  COMMIT;
end;
