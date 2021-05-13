begin
  
  -- Altera as configurações da Viacredi
  update crapprm set DSVLRPRM = DSVLRPRM || '6686230,3522857,2339501,8519064,2157560,2096099,6818706,7324146,'
  where NMSISTEM = 'CRED'
    and CDCOOPER = 1
    and CDACESSO = 'CONTA_PILOTO_POUPANCA_PF';


  -- Habilita Viacredi Alto Vale para produto poupança
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 16, 'COOP_PILOTO_POUPANCA_PF', 'Indica se a cooperativa habilita contratacao de POUPANCA (0=Inativa,1=Piloto para algumas contas,2=Ativa)', '1');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 16, 'CONTA_PILOTO_POUPANCA_PF', 'Indica as contas piloto para a POUPANCA', ',467391,34037,');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) 
  values ('CRED', 16, 'CAPT_POUPANCA_RENT_ATIVA', 'Indica se a rentabilidade da poupanca esta ativa para a cooperativa', '1');

  insert into crapdpc (CDCOOPER, CDMODALI, IDSITMOD, PROGRESS_RECID)
  values (16, (select CDMODALI from crapmpc where CDPRODUT = 1109), 1, null);



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
    --
    dbms_output.put_line('vr_qtincluidos:'||vr_qtincluidos);
    dbms_output.put_line('vr_qtalterados:'||vr_qtalterados);
    --
  END;

  commit;

end;

