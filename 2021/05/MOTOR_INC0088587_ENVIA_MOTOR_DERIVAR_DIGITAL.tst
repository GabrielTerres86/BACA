PL/SQL Developer Test script 3.0
128

declare
  CURSOR cr_emprestimos IS
    SELECT t.rowid,t.* 
      FROM crawepr t
     WHERE ((t.cdcooper = 1 AND t.nrdconta = 2828006 AND t.nrctremp = 3882656) OR
            (t.cdcooper = 1 AND t.nrdconta = 2974223 AND t.nrctremp = 3883135) OR
            (t.cdcooper = 1 AND t.nrdconta = 3102840 AND t.nrctremp = 3883267) OR
            (t.cdcooper = 1 AND t.nrdconta = 3518752 AND t.nrctremp = 3882697) OR
            (t.cdcooper = 1 AND t.nrdconta = 3738493 AND t.nrctremp = 3882931) OR
            (t.cdcooper = 1 AND t.nrdconta = 3871274 AND t.nrctremp = 3883260) OR
            (t.cdcooper = 1 AND t.nrdconta = 4019415 AND t.nrctremp = 3883274) OR
            (t.cdcooper = 1 AND t.nrdconta = 6371841 AND t.nrctremp = 3883566) OR
            (t.cdcooper = 1 AND t.nrdconta = 7014040 AND t.nrctremp = 3883066) OR
            (t.cdcooper = 1 AND t.nrdconta = 7085613 AND t.nrctremp = 3882822) OR
            (t.cdcooper = 1 AND t.nrdconta = 7764057 AND t.nrctremp = 3883280) OR
            (t.cdcooper = 1 AND t.nrdconta = 7768559 AND t.nrctremp = 3883827) OR
            (t.cdcooper = 1 AND t.nrdconta = 8171726 AND t.nrctremp = 3883568) OR
            (t.cdcooper = 1 AND t.nrdconta = 8199558 AND t.nrctremp = 3882694) OR
            (t.cdcooper = 1 AND t.nrdconta = 8662355 AND t.nrctremp = 3882923) OR
            (t.cdcooper = 1 AND t.nrdconta = 9362657 AND t.nrctremp = 3882815) OR
            (t.cdcooper = 1 AND t.nrdconta = 9384448 AND t.nrctremp = 3883194) OR
            (t.cdcooper = 1 AND t.nrdconta = 9394354 AND t.nrctremp = 3883088) OR
            (t.cdcooper = 1 AND t.nrdconta = 9476016 AND t.nrctremp = 3883565) OR
            (t.cdcooper = 1 AND t.nrdconta = 9563938 AND t.nrctremp = 3882848) OR
            (t.cdcooper = 1 AND t.nrdconta = 9617469 AND t.nrctremp = 3883234) OR
            (t.cdcooper = 1 AND t.nrdconta = 9628819 AND t.nrctremp = 3882904) OR
            (t.cdcooper = 1 AND t.nrdconta = 9799923 AND t.nrctremp = 3883085) OR
            (t.cdcooper = 1 AND t.nrdconta = 9942033 AND t.nrctremp = 3883096) OR
            (t.cdcooper = 1 AND t.nrdconta = 10033599 AND t.nrctremp = 3883173) OR
            (t.cdcooper = 1 AND t.nrdconta = 10079777 AND t.nrctremp = 3883224) OR
            (t.cdcooper = 1 AND t.nrdconta = 10271414 AND t.nrctremp = 3882832) OR
            (t.cdcooper = 1 AND t.nrdconta = 10784128 AND t.nrctremp = 3883229) OR
            (t.cdcooper = 1 AND t.nrdconta = 10858610 AND t.nrctremp = 3883578) OR
            (t.cdcooper = 1 AND t.nrdconta = 10983830 AND t.nrctremp = 3882820) OR
            (t.cdcooper = 1 AND t.nrdconta = 11060662 AND t.nrctremp = 3883077) OR
            (t.cdcooper = 1 AND t.nrdconta = 11091827 AND t.nrctremp = 3882915) OR
            (t.cdcooper = 1 AND t.nrdconta = 11178191 AND t.nrctremp = 3882913) OR
            (t.cdcooper = 1 AND t.nrdconta = 11290773 AND t.nrctremp = 3882662) OR
            (t.cdcooper = 1 AND t.nrdconta = 11423935 AND t.nrctremp = 3883140) OR
            (t.cdcooper = 1 AND t.nrdconta = 11429208 AND t.nrctremp = 3882866) OR
            (t.cdcooper = 1 AND t.nrdconta = 11440287 AND t.nrctremp = 3882855) OR
            (t.cdcooper = 1 AND t.nrdconta = 11449098 AND t.nrctremp = 3883123) OR
            (t.cdcooper = 1 AND t.nrdconta = 11684704 AND t.nrctremp = 3883552) OR
            (t.cdcooper = 1 AND t.nrdconta = 11724498 AND t.nrctremp = 3883561) OR
            (t.cdcooper = 1 AND t.nrdconta = 11892234 AND t.nrctremp = 3882817) OR
            (t.cdcooper = 1 AND t.nrdconta = 11987405 AND t.nrctremp = 3883215) OR
            (t.cdcooper = 1 AND t.nrdconta = 12035386 AND t.nrctremp = 3883832) OR
            (t.cdcooper = 1 AND t.nrdconta = 12069957 AND t.nrctremp = 3883217) OR
            (t.cdcooper = 1 AND t.nrdconta = 12320080 AND t.nrctremp = 3883162) OR
            (t.cdcooper = 1 AND t.nrdconta = 12493279 AND t.nrctremp = 3883823) OR
            (t.cdcooper = 1 AND t.nrdconta = 12548030 AND t.nrctremp = 3883097) OR
            (t.cdcooper = 1 AND t.nrdconta = 12559962 AND t.nrctremp = 3882636) OR
            (t.cdcooper = 1 AND t.nrdconta = 12629154 AND t.nrctremp = 3882896) OR
            (t.cdcooper = 1 AND t.nrdconta = 12629995 AND t.nrctremp = 3882918) OR
            (t.cdcooper = 7 AND t.nrdconta = 249246 AND t.nrctremp = 54660) OR
            (t.cdcooper = 10 AND t.nrdconta = 141224 AND t.nrctremp = 25278) OR
            (t.cdcooper = 11 AND t.nrdconta = 415731 AND t.nrctremp = 134687) OR
            (t.cdcooper = 11 AND t.nrdconta = 671118 AND t.nrctremp = 134720) OR
            (t.cdcooper = 11 AND t.nrdconta = 722766 AND t.nrctremp = 134673) OR
            (t.cdcooper = 13 AND t.nrdconta = 280135 AND t.nrctremp = 115911) OR
            (t.cdcooper = 13 AND t.nrdconta = 380563 AND t.nrctremp = 115870) OR
            (t.cdcooper = 14 AND t.nrdconta = 29718 AND t.nrctremp = 28229) OR
            (t.cdcooper = 14 AND t.nrdconta = 263079 AND t.nrctremp = 28241) OR
            (t.cdcooper = 16 AND t.nrdconta = 332780 AND t.nrctremp = 271658) OR
            (t.cdcooper = 16 AND t.nrdconta = 487201 AND t.nrctremp = 271598) OR
            (t.cdcooper = 16 AND t.nrdconta = 568236 AND t.nrctremp = 271585) OR
            (t.cdcooper = 16 AND t.nrdconta = 602191 AND t.nrctremp = 271587) OR
            (t.cdcooper = 16 AND t.nrdconta = 3541517 AND t.nrctremp = 271566) OR
            (t.cdcooper = 16 AND t.nrdconta = 3987680 AND t.nrctremp = 271593) 
            )
          AND t.insitest = 5
       AND NOT EXISTS (SELECT 1
                         FROM crapepr p
                        WHERE p.cdcooper = t.cdcooper
                          AND p.nrdconta = t.nrdconta
                          AND p.nrctremp = t.nrctremp);
 RW_EMPRESTIMO CR_EMPRESTIMOS%ROWTYPE; 

  i           integer := 0;
  vr_dscritic VARCHAR2(1000);
  vr_dsmensag VARCHAR2(4000);
  vr_cdcritic INTEGER;
  
begin
  FOR RW_EMPRESTIMO IN cr_emprestimos LOOP
    i := i + 1;

    UPDATE crawepr c
       SET c.qttentreenv = 0
     WHERE c.rowid = RW_EMPRESTIMO.rowid;

    ESTE0001.pc_incluir_proposta_est(pr_cdcooper => RW_EMPRESTIMO.cdcooper --> Codigo da cooperativa
                                    ,pr_cdagenci => RW_EMPRESTIMO.cdagenci --> Codigo da agencia
                                    ,pr_cdoperad => RW_EMPRESTIMO.cdoperad --> codigo do operador
                                    ,pr_cdorigem => RW_EMPRESTIMO.cdorigem --> Origem da operacao
                                    ,pr_nrdconta => RW_EMPRESTIMO.nrdconta --> Numero da conta do cooperado
                                    ,pr_nrctremp => RW_EMPRESTIMO.nrctremp --> Numero da proposta de emprestimo atual/antigo
                                    ,pr_dtmvtolt => trunc(sysdate) --> Data do movimento
                                    ,pr_nmarquiv => NULL
                                    ,pr_dsmensag => vr_dsmensag
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);

     IF vr_dscritic IS NOT NULL OR vr_cdcritic > 0 THEN
       i := i - 1;
       btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                  pr_ind_tipo_log => 2,
                                  pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                  || ' - SCRIPT --> Erro ao agendar envio ao motor: ' || RW_EMPRESTIMO.cdcooper || 
                                                     ' proposta: ' || RW_EMPRESTIMO.nrctremp || 
                                                     ' conta: ' || RW_EMPRESTIMO.NRDCONTA,
                                  pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'),
                                  pr_flnovlog     => 'N',
                                  pr_flfinmsg     => 'S',
                                  pr_dsdirlog     => NULL,
                                  pr_dstiplog     => 'O',
                                  PR_CDPROGRAMA   => NULL);
       ROLLBACK;
     ELSE
       COMMIT;
     END IF;

  END LOOP;

  DBMS_OUTPUT.put_line('total de registros:' || i);

end;
0
0
