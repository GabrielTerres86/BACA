BEGIN

  INSERT INTO cobranca.tapcr_tipo_documento_compe_tarifa_rco
    (IDTIPO_DOCUMENTO_COMPENSACAO
    ,VL_TARIFA
    ,DTINICIO_VIGENCIA
    ,DTFIM_VIGENCIA)
  VALUES
    ((SELECT t.idtipo_documento_compensacao
       FROM cobranca.tapcr_tipo_documento_compensacao t
      WHERE t.dstipo_documento_compensacao = 'Ressarcimento Devolucao Cobranca')
    ,0.49000
    ,to_date('01-01-2023', 'dd-mm-yyyy')
    ,NULL);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'PRJ0024441-CanalPgtoTarifaRCO');
  
END;
