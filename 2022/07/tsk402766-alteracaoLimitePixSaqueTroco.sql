declare
begin
 FOR R IN (
   SELECT
    limite.idlimite_cooperado id,
    decode(limite.IDPERIODO, 1, parametros.VLMAX_DIURNO_SAQUE_TROCO, parametros.VLMAX_NOTURNO_SAQUE_TROCO) Maximo
    FROM PIX.TBPIX_LIMITE_COOPERADO limite
    INNER JOIN PIX.TBPIX_PARAMETROS_GERAIS parametros ON
         parametros.CDCOOPER = limite.CDCOOPER
    LEFT JOIN CECRED.CRAPSNH crapsnh ON
         crapsnh.CDCOOPER = limite.CDCOOPER
         AND crapsnh.NRDCONTA = limite.NRDCONTA
         AND crapsnh.TPDSENHA = 1
         AND crapsnh.CDSITSNH = 1
    LEFT JOIN PIX.TBPIX_LIMITE_COOPERADO solicitacao ON
         solicitacao.CDCOOPER = limite.CDCOOPER
         AND solicitacao.NRDCONTA = limite.NRDCONTA
         AND solicitacao.IDSEQTTL = limite.IDSEQTTL
         AND solicitacao.IDPERIODO = limite.IDPERIODO
         AND solicitacao.FLPOR_TRANSACAO = limite.FLPOR_TRANSACAO
         AND solicitacao.IDTIPO_LIMITE = limite.IDTIPO_LIMITE
         AND solicitacao.CDSITUACAO = 0
    WHERE
     limite.IDTIPO_LIMITE = 2
     AND limite.CDSITUACAO = 1
   )
   LOOP
     UPDATE PIX.TBPIX_LIMITE_COOPERADO
     SET VLLIMITE = R.MAXIMO  
     WHERE IDLIMITE_COOPERADO = R.id;
   end LOOP;
   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
end;