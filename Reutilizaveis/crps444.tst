PL/SQL Developer Test script 3.0
136
-- inc0029059 apagar lançamentos registros duplicados pelo programa crps444 (Carlos)
declare 
  
  TYPE typ_split IS TABLE OF VARCHAR2(32767);
  vr_tab gene0002.typ_split;

  vr_arquivo      CLOB;
  vr_dsnmarq      VARCHAR2(100) := 'craplcm_crps444.csv';
  vr_caminho_arq  VARCHAR2(200);

  vr_string varchar2(100);

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;  
  vr_dscritic     VARCHAR2(10000);
  
  CURSOR cr_craplcm is
    SELECT  l.cdcooper, l.nrdconta, l.cdagenci, l.cdbccxlt, l.nrdocmto,
           LISTAGG(l.progress_recid, ',') WITHIN GROUP (ORDER BY l.progress_recid desc) progressrecs
            FROM craplcm l
           WHERE l.cdcooper = 1
             AND l.dtmvtolt = '12/12/2018'
             AND l.dtrefere = '11/12/2018'
           GROUP BY l.cdcooper, l.nrdconta, l.cdagenci, l.cdbccxlt, l.nrdocmto
           HAVING COUNT(*) = 4;

  CURSOR cr_reg(recid craplcm.progress_recid%type) IS 
  SELECT *
    FROM craplcm
   WHERE craplcm.progress_recid = recid;
  rw_reg cr_reg%rowtype;
  
  --Escrever no arquivo CLOB
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
  BEGIN
    dbms_lob.writeappend(vr_arquivo,length(pr_des_dados),pr_des_dados);
  END;

begin
 
  -- Inicializar o CLOB
  dbms_lob.createtemporary(vr_arquivo, TRUE);
  dbms_lob.open(vr_arquivo, dbms_lob.lob_readwrite);

  for rw_craplcm in cr_craplcm loop
    vr_tab := gene0002.fn_quebra_string(pr_string => rw_craplcm.progressrecs);
    for vr_string in vr_tab.FIRST..vr_tab.LAST loop
      
      if cr_reg%isopen then
        close cr_reg;
      end if;
      
      open cr_reg(vr_tab(vr_string));
      fetch cr_reg into rw_reg;

      if cr_reg%FOUND THEN        
        pc_escreve_xml(
          rw_reg.dtmvtolt || ';' ||
          rw_reg.cdagenci || ';' ||
          rw_reg.cdbccxlt || ';' ||
          rw_reg.nrdolote || ';' ||
          rw_reg.nrdconta || ';' ||
          rw_reg.nrdocmto || ';' ||
          rw_reg.cdhistor || ';' ||
          rw_reg.nrseqdig || ';' ||
          rw_reg.vllanmto || ';' ||
          rw_reg.nrdctabb || ';' ||
          rw_reg.cdpesqbb || ';' ||
          rw_reg.vldoipmf || ';' ||
          rw_reg.nrautdoc || ';' ||
          rw_reg.nrsequni || ';' ||
          rw_reg.cdbanchq || ';' ||
          rw_reg.cdcmpchq || ';' ||
          rw_reg.cdagechq || ';' ||
          rw_reg.nrctachq || ';' ||
          rw_reg.nrlotchq || ';' ||
          rw_reg.sqlotchq || ';' ||
          rw_reg.dtrefere || ';' ||
          rw_reg.hrtransa || ';' ||
          rw_reg.cdoperad || ';' ||
          rw_reg.dsidenti || ';' ||
          rw_reg.cdcooper || ';' ||
          rw_reg.nrdctitg || ';' ||
          rw_reg.dscedent || ';' ||
          rw_reg.cdcoptfn || ';' ||
          rw_reg.cdagetfn || ';' ||
          rw_reg.nrterfin || ';' ||
          rw_reg.nrparepr || ';' ||
          rw_reg.progress_recid || ';' ||
          rw_reg.nrseqava || ';' ||
          rw_reg.nraplica  || ';' ||
          rw_reg.cdorigem || ';' ||
          rw_reg.idlautom || chr(13)     
        );
        --delete  vr_string    
        delete from craplcm where craplcm.progress_recid = vr_tab(vr_string);
        DELETE FROM craplot
           WHERE cdcooper = rw_reg.cdcooper
             AND dtmvtolt = rw_reg.dtmvtolt
             AND cdagenci = rw_reg.cdagenci
             AND cdbccxlt = rw_reg.cdbccxlt
             AND nrdolote = rw_reg.nrdolote;
      end if;
    end loop;
    if cr_reg%isopen then
      close cr_reg;
    end if;
  end loop;
  
  -- Busca o diretorio da cooperativa conectada
  vr_caminho_arq := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                           ,pr_cdcooper => 0
                                           ,pr_cdacesso => 'ROOT_MICROS')||'cecred/carlos/';

  --vr_caminho_arq := '/usr/coopd/sistemad/equipe/tiago/';
  -- Escreve o clob no arquivo físico
  gene0002.pc_clob_para_arquivo(pr_clob => vr_arquivo
                               ,pr_caminho => vr_caminho_arq
                               ,pr_arquivo => vr_dsnmarq
                               ,pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;    

  commit;

 EXCEPTION
  WHEN vr_exc_saida THEN
     dbms_output.put_line('Erro: exc_saida');
    ROLLBACK;
  WHEN OTHERS THEN
     cecred.pc_internal_exception;
     dbms_output.put_line('Erro: Others');
    ROLLBACK;  
 
end;
0
0
