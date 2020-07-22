BEGIN

  BEGIN
    INSERT INTO crapcrd
               (cdcooper,
                nrdconta,
                nrcrcard,
                nrcpftit,
                nmtitcrd,
                dddebito,
                cdlimcrd,
                dtvalida,
                nrctrcrd,
                cdmotivo,
                nrprotoc,
                cdadmcrd,
                tpcartao,
                dtcancel,
                flgdebit,
                flgprovi)
            VALUES
               (13,
                14303,
                5474080160299903,
                5401317921,
                'WERNER WIND FILHO',
                11,
                65,
                to_date('31/03/2026','DD/MM/RRRR'),
                76503,
                0,
                0,
                15,
                2,
                NULL,
                1,
                0);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro ao inserir crapcrd: ' || SQLERRM);
      ROLLBACK;
  END;

  IF SQL%FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Inserção efetuada com sucesso!');
    COMMIT;
  END IF;

END;
