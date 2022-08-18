BEGIN
    DECLARE
    CURSOR cr_imobiliario IS
      SELECT imo.cdcooper
            ,imo.nrdconta
            ,imo.nrctremp
            ,imo.protocolo_motor
        FROM credito.tbepr_contrato_imobiliario imo
       WHERE imo.data_envio_motor = to_date('16/08/2022', 'dd/mm/RRRR')
         AND imo.situacao_analise = 1;
  BEGIN
    FOR rw_imobiliario IN cr_imobiliario LOOP
      
      CECRED.ESTE0009.pc_solicita_retorno_analise(pr_cdcooper => rw_imobiliario.cdcooper
                                                 ,pr_nrdconta => rw_imobiliario.nrdconta
                                                 ,pr_nrctremp => rw_imobiliario.nrctremp
                                                 ,pr_dsprotoc => rw_imobiliario.protocolo_motor);
                                                 
    END LOOP;
                                                   
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      CECRED.pc_internal_exception(pr_cdcooper => 3);
  END;
  COMMIT;
END;