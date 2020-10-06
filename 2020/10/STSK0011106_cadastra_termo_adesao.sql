BEGIN
  FOR coop IN (SELECT cdcooper FROM crapcop c WHERE c.flgativo = 1 AND c.cdcooper <> 3) LOOP
    
      INSERT INTO TBGEN_VERSAO_TERMO 
        VALUES (
          coop.cdcooper,
          'TERMO ADESAO CDC PF V2',
          to_date('01/01/2022', 'DD/MM/RRRR'),
          NULL,
          'termo_adesao_pf_now.jasper',
          TRUNC(sysdate),
          'Termo de adesão de cartão de Crédito AILOS para pessoa física da modalidade NOW'
        );
  END LOOP;
  
  COMMIT;
END;
