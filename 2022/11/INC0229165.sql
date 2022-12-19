DECLARE
  vr_idpeac_operacao credito.tbcred_peac_operacao.idpeac_operacao%TYPE := 1521;
  vr_idpeac_contrato credito.tbcred_peac_contrato.idpeac_contrato%TYPE := 1164;
BEGIN
  DELETE 
    FROM credito.tbcred_peac_operacao_retorno a
   WHERE a.idpeac_operacao = vr_idpeac_operacao;

  DELETE 
    FROM credito.tbcred_peac_operacao a
   WHERE a.idpeac_operacao = vr_idpeac_operacao;

  UPDATE credito.tbcred_peac_contrato a
     SET a.vltotalrepassefgi =
         (SELECT SUM(b.vlrecuperacao)
            FROM credito.tbcred_peac_operacao b
           WHERE b.idpeac_contrato = a.idpeac_contrato
             AND b.tpoperacao = 2
             AND b.cdstatus = 'APROVADA')
   WHERE a.idpeac_contrato = vr_idpeac_contrato;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
