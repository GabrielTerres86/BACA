PL/SQL Developer Test script 3.0
223
declare 
  vr_contador number;
  vr_dscritic varchar2(500);
  vr_excsaida EXCEPTION;  

  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0054307';
  vr_nmarqimp        VARCHAR2(100)  := 'INC0054307_ROLLBACK.txt';     
  vr_ind_arquiv      utl_file.file_type;
  
  vr_nmarqimp2        VARCHAR2(100)  := 'INC0054307_atualizados.csv';   
  vr_ind_arquiv2      utl_file.file_type;
  
  TYPE typ_sicredi IS RECORD (idsicred number);  
  TYPE typ_tbsicredi IS TABLE OF typ_sicredi INDEX BY VARCHAR2(20);
  vr_tbsicredi typ_tbsicredi;
    
  cursor cr_protocolos_sic is
    SELECT t.cdcooper cdcooper_lft,
           t.cdagenci cdagenci_lft,
           t.nrdconta nrdconta_lft,
           t.dtmvtolt dtmvtolt_lft,
           t.vllanmto vllanmto_lft,
           t.idsicred idsicred_lft,
       o.*
  FROM craplft t, 
       crappro o
 WHERE o.cdcooper = t.cdcooper
   AND o.dtmvtolt = t.dtmvtolt
   AND o.nrdconta = t.nrdconta
   AND o.nrseqaut = t.nrautdoc
   AND o.vldocmto = t.vllanmto
   AND o.dsprotoc NOT LIKE '%ESTORNADO%'
   AND t.cdagenci <> 91
   AND t.idsicred IN (1304442,
                      1304443,
                      1292266,
                      1292267,
                      1292268,
                      1292269,
                      1292270,
                      1292271,
                      1292272,
                      1292273,
                      1292274,
                      1292275,
                      1292276,
                      1292277,
                      1292278,
                      1292279,
                      1292280,
                      1292281,
                      1292282,
                      1292283,
                      1292284,
                      1292285,
                      1292286,
                      1292456,
                      1292457,
                      1292458,
                      1292459,
                      1292460,
                      1292461,
                      1292462,
                      1292463,
                      1292464,
                      1292465,
                      1292466,
                      1292467,
                      1292513,
                      1292514,
                      1292551,
                      1292564,
                      1292565,
                      1297058,
                      1305783,
                      1292468,
                      1292405,
                      1292406,
                      1292469,
                      1292470,
                      1292471,
                      1292412,
                      1292413,
                      1292414,
                      1292472,
                      1292473,
                      1292474,
                      1292475,
                      1297006,
                      1292426,
                      1292476,
                      1292450,
                      1292477,
                      1309675,
                      1313252,
                      1313695,
                      1313697,
                      1309039,
                      1311414,
                      1318273,
                      1315666,
                      1316651,
                      1316654,
                      1319393,
                      1315536,
                      1315538,
                      1323616,
                      1323618,
                      1326070,
                      1325551,
                      1320253,
                      1320254,
                      1321780,
                      1321821,
                      1323269,
                      1323271,
                      1323285,
                      1323286,
                      1324497,
                      1330843,
                      1331615,
                      1329891,
                      1328823,
                      1329727,
                      1331532,
                      1336587,
                      1336597,
                      1340753,
                      1333411,
                      1333442,
                      1335848,
                      1336134,
                      1336575,
                      1336576,
                      1337999,
                      1338040,
                      1340804,
                      1343420,
                      1341042,
                      1341043,
                      1337259,
                      1337747);
 
begin
  vr_contador:=0;
  
  --Criar arquivo do rollback
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo dos registros atualizados
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp2        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv2      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_excsaida;
  END IF;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2,'Coop;PA;Conta;Data;Valor;IdSicredi;Protocolo');
  
  vr_tbsicredi.delete;
  
  FOR rw_protocolos_sic IN cr_protocolos_sic LOOP
    
    vr_tbsicredi(to_char(rw_protocolos_sic.idsicred_lft)).idsicred := rw_protocolos_sic.idsicred_lft;
    
    IF rw_protocolos_sic.dsprotoc LIKE '%ESTORNADO%' THEN
      CONTINUE;
    END IF;

    vr_contador:= vr_contador + 1;       
    
    -- Gerar arquivo dos comprovantes que serão atualizados 
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2,rw_protocolos_sic.cdcooper_lft||';'||
                                                  rw_protocolos_sic.cdagenci_lft||';'||
                                                  rw_protocolos_sic.nrdconta_lft||';'||
                                                  rw_protocolos_sic.dtmvtolt_lft||';'||
                                                  rw_protocolos_sic.vllanmto_lft||';'||
                                                  rw_protocolos_sic.idsicred_lft||';'||
                                                  rw_protocolos_sic.dsprotoc||chr(13));

    -- Gerar arquivo de rollback
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'UPDATE crappro o SET o.dsprotoc ='''|| rw_protocolos_sic.dsprotoc||''''||
                                                  'WHERE o.progress_recid = '||rw_protocolos_sic.progress_recid||';');
    
    BEGIN
      UPDATE crappro o
         SET o.dsprotoc = o.dsprotoc || ' ' ||'*** ESTORNADO ('||to_char(rw_protocolos_sic.dtmvtolt_lft,'DD/MM/RRRR')||')'
       WHERE o.progress_recid = rw_protocolos_sic.progress_recid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar crappro! progress_recid: '||
                       rw_protocolos_sic.progress_recid || ' - '|| SQLERRM;
        RAISE vr_excsaida;
    END;
    
  END LOOP; 
  -- Fim do protocolos sic
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'commit;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
  commit;
  
  :vr_dscritic := 'SUCESSO -> Registros atualizados: '|| vr_contador;
EXCEPTION
  WHEN vr_excsaida then 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
end;
0
0
