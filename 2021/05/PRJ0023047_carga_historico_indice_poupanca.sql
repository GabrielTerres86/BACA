DECLARE
  --
  vr_qtincluidos number := 0;
  vr_qtalterados number := 0;
  --
BEGIN
  --
  FOR r_idx IN (SELECT 6 cddindex
                      ,mfx.dtmvtolt dtiniper
                      ,mfx.dtmvtolt dtfimper
                      ,round(mfx.vlmoefix, 4) vlrdtaxa
                      ,mfx.dtmvtolt dtcadast
                  FROM crapmfx mfx
                 WHERE mfx.tpmoefix = 20
                   AND mfx.dtmvtolt >= to_date('01012015', 'ddmmyyyy')
                   AND mfx.cdcooper = 1)
  LOOP
    --
    BEGIN
      --
      INSERT INTO craptxi
        (cddindex
        ,dtiniper
        ,dtfimper
        ,vlrdtaxa
        ,dtcadast)
      VALUES
        (r_idx.cddindex
        ,r_idx.dtiniper
        ,r_idx.dtfimper
        ,r_idx.vlrdtaxa
        ,r_idx.dtcadast);
      --
      vr_qtincluidos := vr_qtincluidos + 1;
      --
    EXCEPTION
      WHEN OTHERS THEN
        IF UPPER(SQLERRM) LIKE UPPER('%CECRED.CRAPTXI##CRAPTXI1%') THEN
          UPDATE craptxi txi
             SET txi.vlrdtaxa = r_idx.vlrdtaxa
                ,txi.dtcadast = r_idx.dtcadast
           WHERE txi.dtfimper = r_idx.dtfimper
             AND txi.dtiniper = r_idx.dtiniper
             AND txi.cddindex = r_idx.cddindex
             AND txi.vlrdtaxa <> r_idx.vlrdtaxa;
           vr_qtalterados := vr_qtalterados + sql%rowcount;
        END IF;
    END;
    --
  END LOOP;
  --
  commit;
  --
  dbms_output.put_line('vr_qtincluidos:'||vr_qtincluidos);
  dbms_output.put_line('vr_qtalterados:'||vr_qtalterados);
  --
END;
