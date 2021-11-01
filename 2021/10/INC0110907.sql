declare
  vr_nrsequenlgi INTEGER;
  vr_nrsequenlgm INTEGER;

  CURSOR cr_tbrecarga_operacao is
    SELECT *
      from CECRED.tbrecarga_operacao a
     WHERE a.cdcooper = 1
       AND a.idoperacao = 1254903
       AND a.nrdconta = 10115030;

  rg_tbrecarga_operacao cr_tbrecarga_operacao%rowtype;

begin

  vr_nrsequenlgi := 1;
  vr_nrsequenlgm := 1;

  open cr_tbrecarga_operacao;
  fetch cr_tbrecarga_operacao
    into rg_tbrecarga_operacao;

  UPDATE CECRED.tbrecarga_operacao
     SET insit_operacao = 5
   WHERE cdcooper = rg_tbrecarga_operacao.cdcooper
     AND idoperacao = rg_tbrecarga_operacao.idoperacao
     AND nrdconta = rg_tbrecarga_operacao.nrdconta;

  INSERT INTO cecred.craplgm
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     dstransa,
     dsorigem,
     nmdatela,
     flgtrans,
     dscritic,
     cdoperad,
     nmendter)
  VALUES
    (rg_tbrecarga_operacao.cdcooper,
     rg_tbrecarga_operacao.nrdconta,
     1,
     vr_nrsequenlgm,
     rg_tbrecarga_operacao.dtrecarga,
     'INC0110907 - Lançamento futuro de recarga da TIM não está sendo possível a exclusão.',
     'AIMARO',
     '',
     1,
     ' ',
     1,
     ' ');

  vr_nrsequenlgm := vr_nrsequenlgm + 1;

  INSERT INTO cecred.craplgi
    (cdcooper,
     nrdconta,
     idseqttl,
     nrsequen,
     dttransa,
     nmdcampo,
     dsdadant,
     dsdadatu)
  VALUES
    (rg_tbrecarga_operacao.cdcooper,
     rg_tbrecarga_operacao.nrdconta,
     1,
     rg_tbrecarga_operacao.idoperacao,
     rg_tbrecarga_operacao.dtrecarga,
     'tbrecarga_operacao.insit_operacao',
     rg_tbrecarga_operacao.insit_operacao,
     null);

  vr_nrsequenlgi := vr_nrsequenlgi + 1;

  close cr_tbrecarga_operacao;

  --COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
END;
