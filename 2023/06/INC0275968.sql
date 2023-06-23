DECLARE

 vr_dsmotivoaceite      CONSTANT VARCHAR2(30) := 'MOTVACTECOMPRIOPORTDDCTSALR';
 vr_des_rollback_xml    CLOB;
 vr_des_critic_xml      CLOB;
 vr_texto_cri_completo  VARCHAR2(32600);
 vr_texto_rb_completo   VARCHAR2(32600);
 
 vr_nmarqbkp            VARCHAR2(100) := 'INC0275968_script_rollback.sql';
 vr_nmarqcri            VARCHAR2(100) := 'INC0275968_script_log.txt';
 vr_exc_erro            EXCEPTION;
 vr_exc_clob            EXCEPTION;
 vr_des_erroGeral       VARCHAR2(4000);
 vr_rollback_path       VARCHAR2(1000):= cecred.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') ||'cpd/bacas/INC0275968';
 vr_exc_erro            EXCEPTION;
 vr_exc_clob            EXCEPTION;
 
 PROCEDURE pc_escreve_xml_rollback(pr_des_dados IN VARCHAR2,
                                   pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
 BEGIN
  CECRED.gene0002.pc_escreve_xml(vr_des_rollback_xml, vr_texto_rb_completo, pr_des_dados, pr_fecha_xml);
 END;
 
 PROCEDURE pc_escreve_xml_critica(pr_des_dados IN VARCHAR2,
                                  pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
 BEGIN
    CECRED.gene0002.pc_escreve_xml(vr_des_critic_xml, vr_texto_cri_completo, pr_des_dados, pr_fecha_xml);
 END;

BEGIN
 
  vr_des_rollback_xml := NULL;
  dbms_lob.createtemporary(vr_des_rollback_xml, TRUE);
  dbms_lob.open(vr_des_rollback_xml, dbms_lob.lob_readwrite);
  vr_texto_rb_completo := NULL;

  vr_des_critic_xml := NULL;
  dbms_lob.createtemporary(vr_des_critic_xml, TRUE);
  dbms_lob.open(vr_des_critic_xml, dbms_lob.lob_readwrite);
  vr_texto_cri_completo := NULL;

  pc_escreve_xml_critica('APCS108' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));  
  for rg_108 in (select t.nrnu_portabilidade
                       ,t.idsituacao
                       ,t.dsdominio_motivo
                       ,t.cdmotivo
                       ,t.dtretorno
                       ,t.dtavaliacao
                       ,t.nmarquivo_resposta
                    from cecred.tbcc_portabilidade_recebe t
                   where t.nrnu_portabilidade in (202305150000260487322
				                                 ,202305150000260487442
												 ,202305150000260488290
												 ,202305150000260364251
												 ,202305150000260367533
												 ,202305110000260124049
												 ,202305110000260149942
												 ,202305120000260206561
												 ,202305120000260207393
												 ,202305120000260210772
												 ,202305120000260214115
												 ,202305120000260237224
												 ,202305120000260239253
												 ,202305110000260046529
												 ,202305110000260102303
												 ,202305110000260103738
												 ,202305110000260112874
												 ,202305110000260163479
												 ,202305120000260245974
												 ,202305120000260305114
												 ,202305150000260372589
												 ,202305150000260373098
												 ,202305090000259783177
												 ,202305150000260374550
												 ,202305150000260412723
												 ,202305150000260461248)) loop
    pc_escreve_xml_rollback('UPDATE cecred.tbcc_portabilidade_recebe  t' || chr(10) ||
                            ' SET t.idsituacao        = ' || nvl(to_char(rg_108.idsituacao),'NULL') || chr(10) ||
                            ' ,t.dsdominio_motivo  = ''' || nvl(rg_108.dsdominio_motivo,'') || '''' || chr(10) ||
                            ' ,t.cdmotivo          = ''' || nvl(rg_108.cdmotivo,'') || '''' || chr(10) ||
                            case
                              when rg_108.dtretorno IS NULL THEN
                                ' ,t.dtretorno = NULL'
                              else
                                ' ,t.dtretorno = to_date('''||to_char(rg_108.dtretorno,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                            end || chr(10) ||
                            case
                              when rg_108.dtavaliacao IS NULL THEN
                                ' ,t.dtavaliacao = NULL'
                              else
                                ' ,t.dtavaliacao = to_date('''||to_char(rg_108.dtavaliacao,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                            end || chr(10) ||
                            ' ,t.nmarquivo_resposta = ''' || nvl(rg_108.nmarquivo_resposta,'') || '''' || chr(10) ||
                            ' WHERE t.nrnu_portabilidade = ' || to_char(rg_108.nrnu_portabilidade) || ';' || chr(10) ||chr(10));   
    
    UPDATE cecred.tbcc_portabilidade_recebe t
      SET t.idsituacao         = 2
        , t.dsdominio_motivo   = vr_dsmotivoaceite
        , t.cdmotivo           = 1
        , t.dtretorno          = to_date('20/06/2023','dd/mm/yyyy') 
        , t.dtavaliacao        = to_date('20/06/2023','dd/mm/yyyy') 
        , t.nmarquivo_resposta = 'APCS108'
    WHERE t.nrnu_portabilidade = rg_108.nrnu_portabilidade;
    pc_escreve_xml_critica('Registro Portabilidade ' || rg_108.nrnu_portabilidade || ' - Atualizado ' || sql%rowcount || ' registros.' || chr(10));
  end loop;
  
  for rg_108 in (select t.nrnu_portabilidade
                       ,t.idsituacao
                       ,t.dsdominio_motivo
                       ,t.cdmotivo
                       ,t.dtretorno
                       ,t.nmarquivo_retorno
                    from cecred.tbcc_portabilidade_envia t
                   where t.nrnu_portabilidade in (202305150000260487322
				                                 ,202305150000260487442
												 ,202305150000260488290
												 ,202305150000260364251
												 ,202305150000260367533
												 ,202305110000260124049
												 ,202305110000260149942
												 ,202305120000260206561
												 ,202305120000260207393
												 ,202305120000260210772
												 ,202305120000260214115
												 ,202305120000260237224
												 ,202305120000260239253
												 ,202305110000260046529
												 ,202305110000260102303
												 ,202305110000260103738
												 ,202305110000260112874
												 ,202305110000260163479
												 ,202305120000260245974
												 ,202305120000260305114
												 ,202305150000260372589
												 ,202305150000260373098
												 ,202305090000259783177
												 ,202305150000260374550
												 ,202305150000260412723
												 ,202305150000260461248)) loop
    pc_escreve_xml_rollback('UPDATE cecred.tbcc_portabilidade_envia  t' || chr(10) ||
                            ' SET t.idsituacao        = ' || nvl(to_char(rg_108.idsituacao),'NULL') || chr(10) ||
                            ' ,t.dsdominio_motivo  = ''' || nvl(rg_108.dsdominio_motivo,'') || '''' || chr(10) ||
                            ' ,t.cdmotivo          = ''' || nvl(rg_108.cdmotivo,'') || '''' || chr(10) ||
                            case
                              when rg_108.dtretorno IS NULL THEN
                                ' ,t.dtretorno = NULL'
                              else
                                ' ,t.dtretorno = to_date('''||to_char(rg_108.dtretorno,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                            end || chr(10) ||
                            ' ,t.nmarquivo_retorno = ''' || nvl(rg_108.nmarquivo_retorno,'') || '''' || chr(10) ||
                            ' WHERE t.nrnu_portabilidade = ' || to_char(rg_108.nrnu_portabilidade) || ';' || chr(10) ||chr(10));   
                                
  UPDATE cecred.tbcc_portabilidade_envia t
    SET t.idsituacao        = 3
      , t.dsdominio_motivo  = vr_dsmotivoaceite
      , t.cdmotivo          = 1
      , t.dtretorno         = to_date('19/05/2023','dd/mm/yyyy') 
      , t.nmarquivo_retorno = 'APCS108'
  WHERE t.nrnu_portabilidade = rg_108.nrnu_portabilidade;   
    pc_escreve_xml_critica('Registro Portabilidade ' || rg_108.nrnu_portabilidade || ' - Atualizado ' || sql%rowcount || ' registros.' || chr(10));
  end loop;
  pc_escreve_xml_critica('APCS108' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10)); 
  
  pc_escreve_xml_rollback('COMMIT;');
  pc_escreve_xml_rollback(' ',TRUE);

  CECRED.GENE0002.pc_clob_para_arquivo(pr_clob  => vr_des_rollback_xml,
                                pr_caminho      => vr_rollback_path,
                                pr_arquivo      => vr_nmarqbkp,
                                pr_des_erro     => vr_des_erroGeral);
  IF (vr_des_erroGeral IS NOT NULL) THEN
    dbms_lob.close(vr_des_rollback_xml);
    dbms_lob.freetemporary(vr_des_rollback_xml);
    RAISE vr_exc_clob;
  END IF;   
  
  pc_escreve_xml_critica(' ',TRUE);
  CECRED.GENE0002.pc_clob_para_arquivo(pr_clob => vr_des_critic_xml,
                                pr_caminho     => vr_rollback_path,
                                pr_arquivo     => vr_nmarqcri,
                                pr_des_erro    => vr_des_erroGeral);
                                
  IF (vr_des_erroGeral IS NOT NULL) THEN
    dbms_lob.close(vr_des_critic_xml);
    dbms_lob.freetemporary(vr_des_critic_xml);
    RAISE vr_exc_clob;
  END IF;

  dbms_lob.close(vr_des_rollback_xml);
  dbms_lob.freetemporary(vr_des_rollback_xml);

  dbms_lob.close(vr_des_critic_xml);
  dbms_lob.freetemporary(vr_des_critic_xml);
  
  COMMIT;   

EXCEPTION
  When vr_exc_clob then
       dbms_output.putline(vr_des_erroGeral);
  When OThers then
  CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_rollback_xml,
                                pr_caminho  => vr_rollback_path,
                                pr_arquivo  => vr_nmarqbkp,
                                pr_des_erro => vr_des_erroGeral);
    IF (vr_des_erroGeral IS NOT NULL) THEN
      dbms_lob.close(vr_des_rollback_xml);
      dbms_lob.freetemporary(vr_des_rollback_xml);
      RAISE vr_exc_clob;
    END IF;   
    
    pc_escreve_xml_critica('Erro Geral: ' || sqlerrm);
    pc_escreve_xml_critica(' ',TRUE);
    CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_critic_xml,
                                  pr_caminho  => vr_rollback_path,
                                  pr_arquivo  => vr_nmarqcri,
                                  pr_des_erro => vr_des_erroGeral);
                                  
    IF (vr_des_erroGeral IS NOT NULL) THEN
      dbms_lob.close(vr_des_critic_xml);
      dbms_lob.freetemporary(vr_des_critic_xml);
      RAISE vr_exc_clob;
    END IF;

    dbms_lob.close(vr_des_rollback_xml);
    dbms_lob.freetemporary(vr_des_rollback_xml);

    dbms_lob.close(vr_des_critic_xml);
    dbms_lob.freetemporary(vr_des_critic_xml);
    
    ROLLBACK;

END;