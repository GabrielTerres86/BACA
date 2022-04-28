DECLARE
  vr_dtsolicitacaohonra credito.tbcred_peac_contrato.dtsolicitacaohonra%TYPE;
  vr_cdsituacaohonra    credito.tbcred_peac_contrato.cdsituacaohonra%TYPE;
BEGIN
  vr_dtsolicitacaohonra := to_date('07/02/2022', 'DD/MM/RRRR');
  vr_cdsituacaohonra    := 2;

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 80350
        ,a.dtsolicitacaohonra = vr_dtsolicitacaohonra
        ,a.cdsituacaohonra    = vr_cdsituacaohonra
   WHERE (a.nrdconta, a.nrcontrato) IN ((11037, 3137268));

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 50300
        ,a.dtsolicitacaohonra = vr_dtsolicitacaohonra
        ,a.cdsituacaohonra    = vr_cdsituacaohonra
   WHERE (a.nrdconta, a.nrcontrato) IN ((1991680, 2979899));

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 30180
        ,a.dtsolicitacaohonra = vr_dtsolicitacaohonra
        ,a.cdsituacaohonra    = vr_cdsituacaohonra
   WHERE (a.nrdconta, a.nrcontrato) IN ((1991680, 3138529));

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 38228
        ,a.dtsolicitacaohonra = vr_dtsolicitacaohonra
        ,a.cdsituacaohonra    = vr_cdsituacaohonra
   WHERE (a.nrdconta, a.nrcontrato) IN ((502103, 235853));

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 88528
        ,a.dtsolicitacaohonra = vr_dtsolicitacaohonra
        ,a.cdsituacaohonra    = vr_cdsituacaohonra
   WHERE (a.nrdconta, a.nrcontrato) IN ((178845, 236037));

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 55330
        ,a.dtsolicitacaohonra = vr_dtsolicitacaohonra
        ,a.cdsituacaohonra    = vr_cdsituacaohonra
   WHERE (a.nrdconta, a.nrcontrato) IN ((148911, 235824));

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 101000
        ,a.dtsolicitacaohonra = vr_dtsolicitacaohonra
        ,a.cdsituacaohonra    = vr_cdsituacaohonra
   WHERE (a.nrdconta, a.nrcontrato) IN ((680, 97826));

  UPDATE credito.tbcred_peac_contrato a
     SET a.vlsolicitacaohonra = 301000
        ,a.dtsolicitacaohonra = vr_dtsolicitacaohonra
        ,a.cdsituacaohonra    = vr_cdsituacaohonra
   WHERE (a.nrdconta, a.nrcontrato) IN ((1040, 97323));

  COMMIT;

  INSERT INTO recuperacao.tbrecup_transf_entre_if
    (nr_controle_str
    ,cdcooper
    ,dh_bacen
    ,nr_ispb_if_debitada
    ,nr_ispb_if_creditada
    ,nr_agencia_creditada
    ,vl_lancamento
    ,cd_identificador_transf
    ,ds_finalidade_if
    ,ds_historico
    ,dt_movimento)
  VALUES
    ('STR20220307033189025'
    ,3
    ,to_date('07-03-2022 07:09:31', 'dd-mm-yyyy hh24:mi:ss')
    ,3365724800
    ,546321200
    ,100
    ,744916
    ,'PEACHONRA'
    ,'152'
    ,'FGI PEAC PAGTO HONRA CL'
    ,to_date('07-03-2022', 'dd-mm-yyyy'));

  COMMIT;
EXCEPTION
when dup_val_on_index then 
  rollback;
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
