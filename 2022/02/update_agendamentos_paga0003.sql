BEGIN
  UPDATE craplau
        SET craplau.dtmvtopg = '01/02/2022'
      WHERE craplau.cdcooper = 1
        AND craplau.insitlau = 1
        AND craplau.tpdvalor = 2
        AND (
          (craplau.dtmvtopg = '02/02/2022' AND
          craplau.dsorigem IN ('INTERNET', 'TAA', 'CAIXA'))
          OR (craplau.dtmvtopg =  '02/02/2022' AND
          craplau.cdhistor = 3292))
          AND ROWNUM <= 600;
COMMIT;
END;
