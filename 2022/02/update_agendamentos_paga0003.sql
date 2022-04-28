BEGIN
  UPDATE craplau
        SET craplau.dtmvtopg = to_date('01/02/2022', 'DD/MM/YYYY')
      WHERE craplau.cdcooper = 1
        AND craplau.insitlau = 1
        AND craplau.tpdvalor = 2
        AND (
          (craplau.dtmvtopg = to_date('02/02/2022', 'DD/MM/YYYY') AND
          craplau.dsorigem IN ('INTERNET', 'TAA', 'CAIXA'))
          OR (craplau.dtmvtopg =  to_date('02/02/2022', 'DD/MM/YYYY') AND
          craplau.cdhistor = 3292))
          AND ROWNUM <= 600;
COMMIT;
END;
