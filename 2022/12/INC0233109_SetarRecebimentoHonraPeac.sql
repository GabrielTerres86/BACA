DECLARE
  CURSOR cr_transferencia IS
    SELECT rec.nr_controle_str
          ,rec.dt_movimento
      FROM tbrecup_transf_entre_if rec
     WHERE rec.ds_finalidade_if = '152'
       AND NOT EXISTS 
           (SELECT 1
              FROM credito.tbcred_peac_contrato
             WHERE nrcontrolestr = rec.nr_controle_str)
     ORDER BY 1;

  vr_dtinicio DATE;
  vr_dtfim    DATE;
BEGIN
  FOR rw_transferencia IN cr_transferencia LOOP
    vr_dtinicio := trunc(add_months(rw_transferencia.dt_movimento, -1), 'MM');
    vr_dtfim    := trunc(last_day(add_months(rw_transferencia.dt_movimento, -1)));
  
    UPDATE credito.tbcred_peac_contrato ctr
       SET nrcontrolestr = rw_transferencia.nr_controle_str
     WHERE ctr.cdsituacaohonra = 2
       AND trunc(ctr.dtsolicitacaohonra) BETWEEN vr_dtinicio AND vr_dtfim
       AND ctr.nrcontrolestr IS NULL;
  
    COMMIT;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
