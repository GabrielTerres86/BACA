DECLARE
  vr_dsplsql VARCHAR2(15000) := NULL;
  vr_dsjob   VARCHAR2(150) := NULL;
BEGIN

  vr_dsplsql :=
'DECLARE
  PROCEDURE pc_log(pr_cdprograma IN tbgen_prglog.cdprograma%TYPE
                  ,pr_dsmensagem IN tbgen_prglog_ocorrencia.dsmensagem%TYPE DEFAULT NULL
                  ,pr_idprglog   IN OUT tbgen_prglog.idprglog%TYPE) IS
  BEGIN
    pc_log_programa(pr_dstiplog      => ''O''
                   ,pr_cdprograma    => pr_cdprograma
                   ,pr_cdcooper      => 3
                   ,pr_tpexecucao    => 0
                   ,pr_tpocorrencia  => 3
                   ,pr_cdcriticidade => 0
                   ,pr_cdmensagem    => 0
                   ,pr_dsmensagem    => pr_dsmensagem
                   ,pr_idprglog      => pr_idprglog);
  END pc_log;
BEGIN
  DECLARE
    TYPE typ_reg_npc IS RECORD(
       idoperjd NUMBER(38));
    TYPE typ_tab_npc IS TABLE OF typ_reg_npc INDEX BY PLS_INTEGER;
    vr_tab_npc     typ_tab_npc;
    vr_qtregistros NUMBER := 0;
    vr_cdprogra    VARCHAR2(100) := ''scriptLimpezaJdnpcbi'';
    vr_idprglog    NUMBER := 0;
  BEGIN

    pc_log(vr_cdprogra, ''Inicio'', vr_idprglog);

    SELECT to_number(TRIM(to_char(to_date(dtreferencia, ''yyyymmdd'') + 1, ''yyyymmdd'')) || ''000000000000'') IdOpJD
      BULK COLLECT
      INTO vr_tab_npc
      FROM (SELECT substr("IdOpJD", 1, 8) dtreferencia
              FROM TBJDNPCDSTLEG_JD2LG_OpTit_Ctrl@Jdnpcbisql
             WHERE "IdOpJD" < 20240601000000000000)
     GROUP BY dtreferencia
     ORDER BY 1;

    COMMIT;

    pc_log(vr_cdprogra, ''Apos select de data de referencia. Qtd dias: '' || nvl(vr_tab_npc.count, 0), vr_idprglog);

    IF nvl(vr_tab_npc.count, 0) > 0 THEN
      FOR i IN vr_tab_npc.first .. vr_tab_npc.last
      LOOP

        DELETE FROM TBJDNPCDSTLEG_JD2LG_OpTit_ERR@Jdnpcbisql
         WHERE "IdOpJD" < vr_tab_npc(i).idoperjd;

        pc_log(vr_cdprogra
              ,''TBJDNPCDSTLEG_JD2LG_OpTit_ERR. Dia: '' || TRIM(to_char(vr_tab_npc(i).idoperjd)) || ''Reg.: '' ||
               nvl(SQL%ROWCOUNT, 0)
              ,vr_idprglog);

        COMMIT;

        DELETE FROM TBJDNPCDSTLEG_JD2LG_OpTit@Jdnpcbisql
         WHERE "IdOpJD" < vr_tab_npc(i).idoperjd;

        pc_log(vr_cdprogra
              ,''TBJDNPCDSTLEG_JD2LG_OpTit. Dia: '' || TRIM(to_char(vr_tab_npc(i).idoperjd)) || ''Reg.: '' ||
               nvl(SQL%ROWCOUNT, 0)
              ,vr_idprglog);

        COMMIT;

        DELETE FROM TBJDNPCDSTLEG_JD2LG_OpTit_Ctrl@Jdnpcbisql
         WHERE "IdOpJD" < vr_tab_npc(i).idoperjd;

        pc_log(vr_cdprogra
              ,''TBJDNPCDSTLEG_JD2LG_OpTit_Ctrl. Dia: '' || TRIM(to_char(vr_tab_npc(i).idoperjd)) || ''Reg.: '' ||
               nvl(SQL%ROWCOUNT, 0)
              ,vr_idprglog);

        vr_qtregistros := vr_qtregistros + 1;

        COMMIT;

      END LOOP;
    END IF;

    COMMIT;

    pc_log(vr_cdprogra, ''Fim com sucesso. Dias processados: '' || vr_qtregistros, vr_idprglog);

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => vr_cdprogra);
      pc_log(vr_cdprogra, ''Fim com erro: '' || SQLERRM, vr_idprglog);
      COMMIT;
      RAISE;
  END;
END;';

  vr_dsjob := dbms_scheduler.generate_job_name(substr('JB_LPZJDNPCBI$', 1, 18));

  dbms_scheduler.create_job(job_name        => vr_dsjob
                           ,job_type        => 'PLSQL_BLOCK'
                           ,job_action      => vr_dsplsql
                           ,start_date      => SYSDATE
                           ,repeat_interval => NULL
                           ,auto_drop       => TRUE
                           ,enabled         => TRUE);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => vr_cdprogra);
    RAISE;
END;
