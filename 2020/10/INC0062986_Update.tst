PL/SQL Developer Test script 3.0
78
declare 
  vr_contador number;
  vr_dscritic varchar2(500);
  vr_excsaida EXCEPTION;  

  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0062986';
  vr_nmarqimp        VARCHAR2(100)  := 'INC0062986_ROLLBACK.txt';   
  vr_ind_arquiv      utl_file.file_type;
  
  cursor cr_seguros is
  SELECT g.rowid   FROM crapseg g
 WHERE g.cdcooper >= 1
   AND g.tpseguro = 4
   AND g.cdsitseg = 2
   AND g.dtcancel = '08/09/2020'
   AND g.dtfimvig = '08/09/2020'
   AND EXISTS (SELECT 1
          FROM crawseg wseg
         WHERE wseg.nrdconta = g.nrdconta
           AND wseg.cdcooper = g.cdcooper
           AND wseg.nrctrseg = g.nrctrseg
           AND wseg.nrctrato = 0)
   AND EXISTS (SELECT 1 
                 FROM tbseg_prestamista a 
                WHERE a.cdcooper = g.cdcooper
                  AND a.nrdconta = g.nrdconta
                  AND a.nrctrseg = g.nrctrseg
                  AND a.tpregist = 3);
  
begin

  vr_contador:=0;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_excsaida;
  END IF;    
  
  FOR rw_seguros IN cr_seguros LOOP
    
    vr_contador:= vr_contador + 1;       
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'update crapseg set cdsitseg = 2 , dtcancel = ''08/09/2020'''
    ||' ,dtfimvig = ''08/09/2020'' where rowid = '''|| rw_seguros.rowid ||''';');
  
    BEGIN
      UPDATE crapseg set cdsitseg = 1
                        ,dtcancel = null
                        ,dtfimvig = null
       WHERE ROWID = rw_seguros.rowid;
       
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar crapseg! rowid: '||
                       rw_seguros.rowid;
        RAISE vr_excsaida;
    END;
    
  END LOOP;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'commit;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  commit;
  
  :vr_dscritic := 'SUCESSO -> Registros atualizados: '|| vr_contador;
EXCEPTION
  WHEN vr_excsaida then 
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
end;
0
0
