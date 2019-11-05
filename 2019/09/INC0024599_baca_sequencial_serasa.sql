DECLARE
    CURSOR cr_sequencia IS
        SELECT t.nrseqatu
          FROM crapsqu t
         WHERE t.nmtabela = 'CRAPCOB'
           AND t.nmdcampo = 'NRSEQARQ'
           AND t.dsdchave = '16';

    vr_sequencia INTEGER := 0;
    vr_esperado  INTEGER := 839;
    vr_atual     crapsqu.nrseqatu%TYPE;
BEGIN
    OPEN cr_sequencia;
    FETCH cr_sequencia
        INTO vr_atual;
    CLOSE cr_sequencia;
	dbms_output.put_line('Iniciando... Atual: ' || vr_atual || ' - Esperado: ' || vr_esperado);

    WHILE vr_atual <> (vr_esperado-1) LOOP
        vr_sequencia := fn_sequence(pr_nmtabela => 'CRAPCOB'
                                   ,pr_nmdcampo => 'NRSEQARQ'
                                   ,pr_dsdchave => 16
                                   ,pr_flgdecre => 'S');
        OPEN cr_sequencia;
        FETCH cr_sequencia
            INTO vr_atual;
        CLOSE cr_sequencia;
    
        IF vr_sequencia <> vr_atual THEN
            dbms_output.put_line('Deu ruim... Atual: ' || vr_atual || ' - Retornado: ' || vr_sequencia);
				ELSE
					dbms_output.put_line('Decrementando... Atual: ' || vr_atual);
        END IF;
    END LOOP;
	dbms_output.put_line('Finalizado. Atual: ' || (vr_atual+1) || ' - Esperado: ' || vr_esperado);
	COMMIT;
END;
