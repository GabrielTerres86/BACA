DECLARE
    CURSOR cr_titulos IS
        SELECT c.cdcooper
              ,c.nrdconta
              ,c.nrdocmto
              ,c.rowid
          FROM crapcol l
              ,crapcob c
         WHERE l.cdcooper = c.cdcooper
           AND l.nrdconta = c.nrdconta
           AND l.nrcnvcob = c.nrcnvcob
           AND l.nrdocmto = c.nrdocmto
              --
           AND c.incobran = 0
           AND c.inserasa = 6 -- 6 = Rejeicao Serasa
           AND l.dslogtit LIKE 'Boleto enviado para negativacao%'
           AND l.dtaltera BETWEEN to_date('04/09/2019 00:00:00', 'DD/MM/RRRR HH24:MI:SS') AND
               to_date('12/09/2019 23:59:59', 'DD/MM/RRRR HH24:MI:SS')
           AND l.cdcooper = 16
         ORDER BY l.dtaltera;
    rw_titulos cr_titulos%ROWTYPE;

BEGIN
		dbms_output.put_line('Processamento iniciado.');	
    FOR rw_titulos IN cr_titulos LOOP
       UPDATE crapcob SET inserasa = 1 WHERE ROWID = rw_titulos.rowid;
			 dbms_output.put_line('Atualizando documento. Conta: ' || rw_titulos.nrdconta || ' - Documento: ' || rw_titulos.nrdocmto);
    END LOOP;
		dbms_output.put_line('Processamento finalizado.');
END;
