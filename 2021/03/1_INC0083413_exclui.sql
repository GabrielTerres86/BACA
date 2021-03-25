DECLARE
  CURSOR cr_tcmt is
     SELECT  max(idseqmov) idseqmov, CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTMOVIMENTO, DTGRAVACAO, VLDEBITO, VLCREDITO, VLSALDO, INTPLANCAMENTO, INSTATUSPROCES, DSERROPROCES, IDINTEGRACAO, DSMOTIVO
     FROM    tbepr_consig_movimento_tmp
     WHERE dtmovimento     = to_date('19/03/2021', 'dd/mm;yyyy')
     and   instatusproces is null
     HAVING count(1) > 1
     GROUP BY  CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTMOVIMENTO, DTGRAVACAO, VLDEBITO, VLCREDITO, VLSALDO, INTPLANCAMENTO, INSTATUSPROCES, DSERROPROCES, IDINTEGRACAO, DSMOTIVO;
BEGIN
  dbms_output.enable(1000000);
  FOR rw_tcmt IN cr_tcmt LOOP

    DELETE tbepr_consig_movimento_tmp
    WHERE  idseqmov = rw_tcmt.idseqmov;

/*
    dbms_output.put_line('idseqmov:'       || rw_tcmt.idseqmov       || ' ' ||
                         'cdcooper:'       || rw_tcmt.CDCOOPER       || ' ' ||
                         'nrdconta:'       || rw_tcmt.NRDCONTA       || ' ' ||
                         'nrctremp:'       || rw_tcmt.NRCTREMP       || ' ' ||
                         'nrparcela:'      || rw_tcmt.NRPARCELA      || ' ' ||
                         'vldebito:'       || rw_tcmt.VLDEBITO       || ' ' ||
                         'vlcredito:'      || rw_tcmt.VLCREDITO      || ' ' ||
                         'intplancamento:' || rw_tcmt.INTPLANCAMENTO || ' ' ||
                         'instatusproces:' || rw_tcmt.INSTATUSPROCES);
*/                       
  END LOOP;
EXCEPTION
  WHEN others THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20501, SQLERRM);
END;
/
