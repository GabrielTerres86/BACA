DECLARE

 CURSOR cr_srw IS
   SELECT s.xmldadrq.getclobval() xmldadrq
     FROM crapsrw s
    WHERE s.nrseqsol = 2053488231--id prod
                     -- 2041412879 -- teste
    ;
  rw_srw   cr_srw%ROWTYPE;

  vr_excsaida EXCEPTION;
  vr_excsair  EXCEPTION;
  vr_dscritic VARCHAR2(500);
  pr_xml_res  CLOB;
BEGIN

    btch0001.pc_gera_log_batch(pr_cdcooper     => 10
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || 'SCRITP/BACA: ' || ' --> '
                                               || 'INICIO' 
                              ,pr_nmarqlog     => 'proc_message');

  OPEN cr_srw;
  FETCH cr_srw INTO rw_srw;
  IF cr_srw%NOTFOUND THEN
    vr_dscritic := 'SRW nao encontrado';
    RAISE vr_excsaida;
  END IF;

  -- UPDATE para que dê erro novamente pelo mesmo motivo - integraSAS/rating
  BEGIN
    UPDATE gestaoderisco.risco_tbrisco_operacoes o
       SET o.flintegrar_sas = 0
     WHERE o.cdcooper = 10
       AND o.nrdconta = 68500
       AND o.nrctremp = 13561
       AND o.tpctrato = 90
       AND o.flintegrar_sas = 1;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro no update tbrisco_operacoes!';
      RAISE vr_excsaida;
  END;

  -- Executar a rotina que falhou, com os dados já trafegados naquele momento do erro.
  BEGIN
    cecred.gene0004.pc_xml_web(pr_xml_req => REPLACE(SRCSTR => rw_srw.xmldadrq,
                                                     OLDSUB => '<vlrdobem> 99572.00</vlrdobem>',
                                                     NEWSUB => '<vlrdobem> 99572,00</vlrdobem>'),
                               pr_xml_res => pr_xml_res);

    IF pr_xml_res LIKE '%<Erro>%' THEN
      vr_dscritic := 'Erro na rotina: ' || pr_xml_res;
      RAISE vr_excsair;
    END IF;
  EXCEPTION
    WHEN vr_excsair THEN
      RAISE vr_excsaida;
    WHEN OTHERS THEN
      vr_dscritic := 'Erro na pc_xml_web';
      RAISE vr_excsaida;
  END;
  COMMIT;


  btch0001.pc_gera_log_batch(pr_cdcooper     => 10
                            ,pr_ind_tipo_log => 2 -- Erro tratato
                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || 'SCRITP/BACA: ' || ' --> '
                                               || 'FIM - SUCESSO' 
                            ,pr_nmarqlog     => 'proc_message');

  COMMIT;


EXCEPTION
  WHEN vr_excsaida THEN
    btch0001.pc_gera_log_batch(pr_cdcooper     => 10
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || 'SCRITP/BACA: ' || ' --> FIM - ERRO -> '
                                               || vr_dscritic 
                              ,pr_nmarqlog     => 'proc_message');
    ROLLBACK;
  WHEN OTHERS THEN
    btch0001.pc_gera_log_batch(pr_cdcooper     => 10
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || 'SCRITP/BACA: ' || ' --> FIM - ERRO -> '
                                               || SQLERRM
                              ,pr_nmarqlog     => 'proc_message'); 
    ROLLBACK;
END;
