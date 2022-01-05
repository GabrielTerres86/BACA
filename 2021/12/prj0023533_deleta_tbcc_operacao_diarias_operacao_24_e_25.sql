BEGIN
  DECLARE
    vr_dtini DATE;
    vr_dtfim DATE;
  BEGIN
    FOR rw IN (SELECT cop.cdcooper
               FROM crapcop cop
               WHERE cop.cdcooper <> 3
               AND cop.flgativo = 1) LOOP
      FOR mes IN 1..12 LOOP
        vr_dtini := to_date('01/' || to_char(mes,'fm00') || '/2021', 'DD/MM/RRRR');
        vr_dtfim := last_day(vr_dtini);
        
        IF mes = 12 THEN
          vr_dtfim := TO_DATE('19/12/2021', 'DD/MM/RRRR');
        END IF;
        
        DELETE FROM tbcc_operacoes_diarias
        WHERE cdoperacao IN (24, 25)
          AND cdcooper = rw.cdcooper
          AND (dtoperacao >= vr_dtini AND dtoperacao <= vr_dtfim);
          
        COMMIT;
      END LOOP;
    END LOOP;
  END;
END;