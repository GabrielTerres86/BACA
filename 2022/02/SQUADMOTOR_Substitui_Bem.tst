PL/SQL Developer Test script 3.0
139
DECLARE

 CURSOR cr_srw IS
   SELECT s.xmldadrq.getclobval() xmldadrq
     FROM crapsrw s
    WHERE s.nrseqsol = 2053488231--id prod
                     -- 2041412879 -- teste
    ;
  rw_srw   cr_srw%ROWTYPE;

  vr_excsaida EXCEPTION;
  vr_dscritic VARCHAR2(500);
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
  COMMIT;

  -- Executar a rotina que falhou, com os dados já trafegados naquele momento do erro.
  BEGIN
    cecred.gene0004.pc_xml_web(pr_xml_req => rw_srw.xmldadrq,
                               pr_xml_res => :pr_xml_res);
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro na pc_xml_web';
      RAISE vr_excsaida;
  END;
  COMMIT;

  -- Inserir os registros faltantes de gravames do contrato
  INSERT INTO tbgrv_registro_contrato
    (cdcooper
    ,nrdconta
    ,nrctrpro
    ,idseqbem
    ,tpregistro_contrato
    ,dtregistro_contrato
    ,cdsituacao_contrato
    ,dsretorno_contrato
    ,cdopereg
    ,dtinsori
    ,dtrefatu
    ,dsc_identificador
    ,dsc_identificador_registro)
  VALUES
    (10
    ,68500
    ,13561
    ,5
    ,1
    ,to_date('10-02-2022 16:30:01', 'dd-mm-yyyy hh24:mi:ss')
    ,0
    ,NULL
    ,'1'
    ,to_date('10-02-2022 16:30:01', 'dd-mm-yyyy hh24:mi:ss')
    ,NULL
    ,NULL
    ,NULL);
  -- Inserir os registros faltantes de gravames do contrato
  INSERT INTO tbgrv_registro_imagem
    (cdcooper
    ,nrdconta
    ,nrctrpro
    ,idseqbem
    ,tpregistro_imagem
    ,dtregistro_imagem
    ,cdsituacao_imagem
    ,dsretorno_imagem
    ,cdopereg
    ,dtinsori
    ,dtrefatu)
  VALUES
    (10
    ,68500
    ,13561
    ,5
    ,1
    ,to_date('10-02-2022 16:30:01', 'dd-mm-yyyy hh24:mi:ss')
    ,0
    ,NULL
    ,'1'
    ,to_date('10-02-2022 16:30:01', 'dd-mm-yyyy hh24:mi:ss')
    ,to_date('10-02-2022 16:30:01', 'dd-mm-yyyy hh24:mi:ss'));


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
1
pr_xml_res
1
<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro><Registro><cdagenci>1</cdagenci><nrdcaixa>0</nrdcaixa><nrsequen>1</nrsequen><cdcritic>55</cdcritic><dscritic>055 - Tabela nao cadastrada.</dscritic><erro>yes</erro><cdcooper>10</cdcooper></Registro></Erro></Root>
5
10
vr_sql
v_crapbpr.cdsitgrv
v_crapbpr.dsbemfin
par_cdcooper
par_nrdconta
par_tpctrato
par_nrctremp
par_idseqbem
par_dscritic
vr_dscritic
