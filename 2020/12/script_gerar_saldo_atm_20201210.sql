DECLARE

  vr_qtd_ok  INTEGER := 0;
  vr_qtd_nok INTEGER := 0;
  vr_qtd_err INTEGER := 0;

  --CURSORES
  CURSOR cr_crapstf IS
    SELECT stf_a.dtmvtoan, --> Data do movimento anterior. 
           stf_a.dtmvtolt, --> Data do movimento atual. 
           stf_a.nrterfin, --> Numero do terminal financeiro.
           stf_a.vldsdini, --> Valor do saldo inicial anterior.
           stf_a.vldsdfin, --> Valor do saldo final anterior.
           stf_a.cdcooper, --> Codigo que identifica a Cooperativa.
           stf_a.vltotcas --> Novo valor do saldo final.
      FROM (SELECT dtc1.dtmvtoan AS dtmvtoan,
                   stf1.nrterfin AS nrterfin,
                   stf1.vldsdini AS vldsdini,
                   stf1.vldsdfin AS vldsdfin,
                   stf1.cdcooper AS cdcooper,
                   dtc1.dtmvtolt AS dtmvtolt,
                   (tfn.vltotcas##1 + tfn.vltotcas##2 + tfn.vltotcas##3 +
                   tfn.vltotcas##4 + tfn.vlnotcas##5) AS vltotcas -- Igual ao campo da tela CASH (vltotalG)
              FROM crapstf stf1, crapdat dtc1, craptfn tfn
             WHERE 1 = 1
               AND dtc1.dtmvtoan = stf1.dtmvtolt
               AND dtc1.cdcooper = stf1.cdcooper
               AND stf1.nrterfin = tfn.nrterfin
               AND stf1.cdcooper = tfn.cdcooper) stf_a
     WHERE NOT EXISTS (SELECT 1
              FROM crapstf stf2
             WHERE stf2.dtmvtolt = stf_a.dtmvtolt
               AND stf2.cdcooper = stf_a.cdcooper
               AND stf2.nrterfin = stf_a.nrterfin)
          
       AND (stf_a.nrterfin, stf_a.cdcooper) IN
           ((168, 1),
            (344, 1),
			(357, 1),
			(351, 1),
			(292, 1),
			(274, 1),
			(461, 1),
			(389, 1),
			(124, 1),
			(259, 1),
			(320, 1),
			(217, 1),
			(254, 1),
			(79, 1),
			(240, 1),
			(214, 1),
			(348, 1),
			(225, 1),
			(390, 1),
			(350, 1),
			(24, 11),
			(60, 1),
            (114, 1)) ;

BEGIN

  FOR crapstf IN cr_crapstf LOOP
  
    BEGIN
    
      INSERT INTO crapstf
        (dtmvtolt, nrterfin, vldsdini, vldsdfin, cdcooper)
      VALUES
        (to_date(to_char(crapstf.dtmvtolt, 'dd/mm/yyyy'), 'dd/mm/yyyy'),
         crapstf.nrterfin,
         crapstf.vldsdfin,
         crapstf.vltotcas,
         crapstf.cdcooper);
    
      COMMIT;
      
      IF crapstf.vldsdfin >= 0 THEN
      
        -- Cria o saldo para a nova data
        DBMS_OUTPUT.PUT_LINE(' OK dtmvtolt = ' || crapstf.dtmvtolt ||
                             ' nrterfin = ' || crapstf.nrterfin ||
                             ' vldsdini = ' || crapstf.vldsdfin ||
                             ' vldsdfin = ' || crapstf.vltotcas ||
                             ' cdcooper = ' || crapstf.cdcooper);
      
        vr_qtd_ok := vr_qtd_ok + 1;
      
      ELSE
        -- Cria o saldo para a nova data
        DBMS_OUTPUT.PUT_LINE(' NOK dtmvtolt = ' || crapstf.dtmvtolt ||
                             ' nrterfin = ' || crapstf.nrterfin ||
                             ' vldsdini = ' || crapstf.vldsdfin ||
                             ' vldsdfin = ' || crapstf.vltotcas ||
                             ' cdcooper = ' || crapstf.cdcooper);
      
        vr_qtd_nok := vr_qtd_nok + 1;
      
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        vr_qtd_err := vr_qtd_err + 1;
        DBMS_OUTPUT.PUT_LINE('ERRO dtmvtolt = ' || crapstf.dtmvtolt ||
                             ' nrterfin = ' || crapstf.nrterfin ||
                             ' vldsdini = ' || crapstf.vldsdfin ||
                             ' vldsdfin = ' || crapstf.vltotcas ||
                             ' cdcooper = ' || crapstf.cdcooper);
      
    END;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Total OK: ' || vr_qtd_ok);
  DBMS_OUTPUT.PUT_LINE('Total NOK: ' || vr_qtd_nok);
  DBMS_OUTPUT.PUT_LINE('Total ERR: ' || vr_qtd_err);
END;
