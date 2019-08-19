-- #551205 melhorias do crps e job PC_CRPS474_DIARIO_01
BEGIN

  sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBEPR_PGMTO_PARCS');

  sys.dbms_scheduler.create_job(job_name   => 'CECRED.JBEPR_PGMTO_PARCS',
                                job_type   => 'PLSQL_BLOCK',
                                job_action => 'DECLARE
CURSOR cr_crapcop IS
 SELECT cdcooper
 FROM crapcop
 WHERE flgativo = 1;
rw_crapdat btch0001.cr_crapdat%ROWTYPE;

vr_stprogra PLS_INTEGER;
vr_infimsol PLS_INTEGER;
vr_cdcritic crapcri.cdcritic%TYPE;
vr_dscritic VARCHAR2(4000);
BEGIN
FOR rw_crapcop IN cr_crapcop LOOP
  OPEN btch0001.cr_crapdat(rw_crapcop.cdcooper);
  FETCH btch0001.cr_crapdat  INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  IF rw_crapdat.inproces <> 1 OR (to_char(sysdate,''D'') IN (1,7)) THEN
    CONTINUE;
  END IF;
  pc_crps474(pr_cdcooper => rw_crapcop.cdcooper,
             pr_cdagenci => 0,
             pr_nmdatela => '''',
             pr_idparale => NULL,
             pr_stprogra => vr_stprogra,
             pr_infimsol => vr_infimsol,
             pr_cdcritic => vr_cdcritic,
             pr_dscritic => vr_dscritic);
  IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
    RAise_application_error(-20100,''Erro job JBEPR_PGMTO_PARCS: ''||NVL(vr_cdcritic,0)||'' -
                                                      ''||vr_dscritic);
  END IF;
END LOOP;
END;',
                                start_date      => '22/03/2017 11:00:00,000000 AMERICA/SAO_PAULO',
                                repeat_interval => 'Freq=daily;ByHour=11,17;BYDAY=MON,TUE,WED,THU,FRI',
                                end_date        => to_date(null),
                                job_class       => 'DEFAULT_JOB_CLASS',
                                enabled         => true,
                                auto_drop       => true,
                                comments        => 'Pagamento de parcelas dos emprestimos.');
END;
