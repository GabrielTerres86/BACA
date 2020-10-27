/*
    Proxima execucao: 22/10/2020
    Gerar carga de dispositivos para o OFSAA ativos do ultimo ano ou sem data de ultimo acesso
*/
declare 
  -- Local variables here
  vr_dsdireto   VARCHAR2(4000) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                           ,pr_cdcooper => 0
                                                           ,pr_cdacesso => 'ROOT_DIRCOOP')||'cecred/arq/';

  vr_nmarquiv   VARCHAR2(100)  := 'carga_dispositivos.csv';
  
  vr_texto_carga CLOB;
  vr_texto_carga_aux VARCHAR2(32767);
  vr_dscritic VARCHAR2(4000);
  
  CURSOR cr_dispositivos IS
    SELECT DISTINCT dis.dispositivomobileid MOBILE_DEV_ID
                  , decode(ass.inpessoa,1,lpad(ass.nrcpfcgc,11,'0'),lpad(ass.nrcpfcgc,14,'0')) CNPJ_CPFCLIDEBTD
                  , to_char(TRUNC(SYSDATE),'RRRR-MM-DD HH24:MI:SS') START_DT
                  , to_char(to_date('31/12/2999', 'DD/MM/RRRR'), 'RRRR-MM-DD HH24:MI:SS') END_DT
                  , 0 SCORE
                  , 'Carga sistema' CMMNTS
                  , 'Approved' STATUS
                  , 'OFSADMN' MODIFIED_BY
                  , to_char(TRUNC(SYSDATE),'RRRR-MM-DD HH24:MI:SS') MODIFIED_DT
                  , 'OFSADMN' APPROVED_BY
                  , to_char(TRUNC(SYSDATE),'RRRR-MM-DD HH24:MI:SS') APPROVED_DT
  FROM dispositivomobile dis,
       crapass ass
 WHERE dis.cooperativaid = ass.cdcooper
   AND dis.numeroconta = ass.nrdconta
   AND ((dis.dataultimoacesso IS NOT NULL AND dis.dataultimoacesso >= add_months(trunc(sysdate),-12)) OR dis.dataultimoacesso IS NULL);
  
BEGIN
  
  -- Montar o início da tabela (Num clob para evitar estouro)
  dbms_lob.createtemporary(vr_texto_carga, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_texto_carga,dbms_lob.lob_readwrite);

  gene0002.pc_escreve_xml(vr_texto_carga,vr_texto_carga_aux, 'MOBILE_DEV_ID;' ||
                                                             'CNPJ_CPFCLIDEBTD;' ||
                                                             'START_DT;' ||
                                                             'END_DT;' ||
                                                             'SCORE;' ||
                                                             'CMMNTS;' ||
                                                             'STATUS;' ||
                                                             'MODIFIED_BY;' ||
                                                             'MODIFIED_DT;' ||
                                                             'APPROVED_BY;' ||
                                                             'APPROVED_DT' || CHR(10));    

  -- Test statements here
  FOR rw_dispositivos IN cr_dispositivos LOOP
      
    gene0002.pc_escreve_xml(vr_texto_carga,vr_texto_carga_aux, '"' || rw_dispositivos.mobile_dev_id     || '";"' ||
                                                                      rw_dispositivos.cnpj_cpfclidebtd  || '";' ||
                                                                      rw_dispositivos.start_dt          || ';' ||
                                                                      rw_dispositivos.end_dt            || ';' ||
                                                                      rw_dispositivos.score             || ';' ||
                                                                      rw_dispositivos.cmmnts            || ';' ||
                                                                      rw_dispositivos.status            || ';' ||
                                                                      rw_dispositivos.modified_by       || ';' ||
                                                                      rw_dispositivos.modified_dt       || ';' ||
                                                                      rw_dispositivos.approved_by       || ';' ||
                                                                      rw_dispositivos.approved_dt       || CHR(10));    
  END LOOP;
  
  gene0002.pc_escreve_xml(vr_texto_carga,vr_texto_carga_aux,'',true);

  -- Gerar o arquivo na pasta converte
  gene0002.pc_clob_para_arquivo(pr_clob     => vr_texto_carga
                               ,pr_caminho  => vr_dsdireto
                               ,pr_arquivo  => vr_nmarquiv
                               ,pr_des_erro => vr_dscritic);

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_texto_carga);
  dbms_lob.freetemporary(vr_texto_carga);

end;