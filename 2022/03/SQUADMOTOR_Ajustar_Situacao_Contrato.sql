BEGIN
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
    (1
    ,1522280
    ,5301601
    ,1
    ,1
    ,to_date('10-03-2022 16:45:00', 'dd-mm-yyyy hh24:mi:ss')
    ,2
    ,'REGISTRADA'
    ,'1'
    ,to_date('10-03-2022 16:45:00', 'dd-mm-yyyy hh24:mi:ss')
    ,to_date('10-03-2022 16:45:00', 'dd-mm-yyyy hh24:mi:ss')
    ,'20220026001281'
    ,'2022002600128120220026001281');

  COMMIT;

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
    (1
    ,1522280
    ,5301601
    ,1
    ,1
    ,to_date('10-03-2022 16:45:00', 'dd-mm-yyyy hh24:mi:ss')
    ,0
    ,NULL
    ,'1'
    ,to_date('10-03-2022 16:45:00', 'dd-mm-yyyy hh24:mi:ss')
    ,to_date('10-03-2022 16:45:00', 'dd-mm-yyyy hh24:mi:ss')
    );
    
  commit;

EXCEPTION
  WHEN OTHERS THEN
    btch0001.pc_gera_log_batch(pr_cdcooper     => 1
                              ,pr_ind_tipo_log => 2 
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || 'SCRITP/BACA: ' || ' ==> FIM - ERRO -> '
                                               || SQLERRM
                              ,pr_nmarqlog     => 'proc_message'); 
    ROLLBACK;
END;