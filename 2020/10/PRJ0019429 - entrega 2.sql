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

  --deletar configurações de limite
  DELETE FROM tbcrd_config_categoria a WHERE a.cdadmcrd = 19;
  --deletar configurações de grupo de afinidade
  DELETE FROM crapadc a WHERE a.cdadmcrd = 19;
  --atualizar nome da modalidade de cartão 18 - cartão expresso para cartão personalizado
  UPDATE crapadc a 
     SET a.nmadmcrd = 'AILOS MASTERCARD NOW PERSONALIZADO',
         a.nmresadm = 'AILOS NOW PERSONALIZADO'
   WHERE a.cdadmcrd = 18;
  --deletar grupo de afinidade da modalidade cartão expresso
  DELETE FROM crapacb a WHERE a.cdadmcrd = 18;
  --atualizar código da modalidade cartão personalizado para 18;	
   UPDATE crapacb a 
      SET a.cdadmcrd = 18
    WHERE a.cdadmcrd = 19;

  
  COMMIT;
END;
