BEGIN

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr
    (DSCICLO_LIQUIDACAO_PCR
    ,NRORDEM
    ,DHINICIO_CICLO
    ,DHFIM_CICLO
    ,DHINICIO_VIGENCIA
    ,DHFIM_VIGENCIA)
  VALUES
    ('CICLO 01'
    ,1
    ,to_date('01-01-1900 13:30:00', 'dd-mm-yyyy hh24:mi:ss')
    ,to_date('01-01-1900 23:59:59', 'dd-mm-yyyy hh24:mi:ss')
    ,to_date('01-07-2023', 'dd-mm-yyyy')
    ,NULL);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr
    (DSCICLO_LIQUIDACAO_PCR
    ,NRORDEM
    ,DHINICIO_CICLO
    ,DHFIM_CICLO
    ,DHINICIO_VIGENCIA
    ,DHFIM_VIGENCIA)
  VALUES
    ('CICLO 02'
    ,2
    ,to_date('01-01-1900 00:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,to_date('01-01-1900 13:29:59', 'dd-mm-yyyy hh24:mi:ss')
    ,to_date('01-07-2023', 'dd-mm-yyyy')
    ,NULL);
    
    
  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((
    SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 01')
    ,10
    ,to_date('01-01-1900 16:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 01')
    ,11
    ,to_date('01-01-1900 17:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 01')
    ,12
    ,to_date('01-01-1900 18:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 01')
    ,13
    ,to_date('01-01-1900 19:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 01')
    ,14
    ,to_date('01-01-1900 20:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 01')
    ,15
    ,to_date('01-01-1900 21:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 01')
    ,16
    ,to_date('01-01-1900 22:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 01')
    ,17
    ,to_date('01-01-1900 23:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 01')
    ,18
    ,to_date('01-01-1900 23:30:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 01')
    ,19
    ,to_date('01-01-1900 01:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,1);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 02')
    ,1
    ,to_date('01-01-1900 06:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 02')
    ,2
    ,to_date('01-01-1900 07:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 02')
    ,3
    ,to_date('01-01-1900 08:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 02')
    ,4
    ,to_date('01-01-1900 09:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 02')
    ,5
    ,to_date('01-01-1900 10:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 02')
    ,6
    ,to_date('01-01-1900 11:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 02')
    ,7
    ,to_date('01-01-1900 12:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 02')
    ,8
    ,to_date('01-01-1900 13:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0);

  INSERT INTO cobranca.tbcobran_ciclo_liquidacao_pcr_parcial
    (IDCICLO_LIQUIDACAO_PCR
    ,NRPARCIAL
    ,DHPREVISTO
    ,FLGFIM_CICLO)
  VALUES
    ((SELECT c.idciclo_liquidacao_pcr FROM cobranca.tbcobran_ciclo_liquidacao_pcr c  WHERE c.DSCICLO_LIQUIDACAO_PCR = 'CICLO 02')
    ,9
    ,to_date('01-01-1900 14:00:00', 'dd-mm-yyyy hh24:mi:ss')
    ,1);   

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'PRJ0024441-Ciclos');
    RAISE;
END;
