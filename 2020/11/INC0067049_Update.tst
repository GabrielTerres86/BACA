PL/SQL Developer Test script 3.0
104
declare 
  vr_contador number;
  vr_dscritic varchar2(500);
  vr_excsaida EXCEPTION;  
  vr_linha varchar2(2000);
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0062986';
  vr_nmarqimp        VARCHAR2(100)  := 'INC0067049_ROLLBACK.txt';   
  vr_ind_arquiv      utl_file.file_type;
  
  cursor cr_seguros is
 with tb1 as (
select cdcooper, 
 gene0002.fn_char_para_number(replace(SUBSTR(tabe0001.fn_busca_dstextab(pr_cdcooper => cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'SEGPRESTAM'
                                               ,pr_tpregist => 0 ),27,12)
                                               ,',','.') ) vlmin from crapcop
) 
 select a.* from 
 (
     SELECT g.cdcooper, g.rowid , g.dtcancel, g.dtfimvig, ass.nrcpfcgc ,round (sum(r.vlsdeved) OVER (PARTITION BY  g.cdcooper, ass.nrcpfcgc),2)  vlsdeved
     FROM   crapseg g, crawseg a,
            crapepr r, craplcr b, crapass ass
                   where g.cdcooper >= 1
                     and g.dtcancel >= '08/09/2020'
                     AND g.dtfimvig >= '08/09/2020'      
                     and a.cdcooper = g.cdcooper
                     and g.nrdconta = A.nrdconta
                     and g.nrctrseg = a.nrctrseg
                     and a.nrctrato > 0                       
                     and r.cdcooper = a.cdcooper
                     and r.nrdconta = a.nrdconta
                     and r.nrctremp = a.nrctrato
                     and r.inliquid = 0
                     and b.cdcooper = r.cdcooper
                     and b.cdlcremp = r.cdlcremp
                     AND ass.cdcooper = r.cdcooper
                     AND ass.nrdconta = r.nrdconta
                     and b.flgsegpr = 1
                 and g.cdcooper >= 1
                 AND g.tpseguro = 4
                 AND g.cdsitseg = 2
                 AND g.dtcancel >= '08/09/2020'
                 AND g.dtfimvig >= '08/09/2020'  
                 AND EXISTS (SELECT 1 
                               FROM tbseg_prestamista a 
                              WHERE a.cdcooper = g.cdcooper
                                AND a.nrdconta = g.nrdconta
                                AND a.nrctrseg = g.nrctrseg)
 ) a , tb1 where a.cdcooper = tb1.cdcooper and  vlsdeved > tb1.vlmin
;
 
begin

  vr_contador:=0;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica---*
  IF vr_dscritic IS NOT NULL THEN        
    RAISE vr_excsaida;
  END IF;    
  
  FOR rw_seguros IN cr_seguros LOOP
    
    vr_contador:= vr_contador + 1;       
    vr_linha := 'update crapseg set cdsitseg = 2 , dtcancel = TO_DATE('''||TO_CHAR(rw_seguros.dtcancel,'DD/MM/YYYY')||''',''DD/MM/YYYY'') '
      ||' ,dtfimvig = TO_DATE('''||TO_CHAR(rw_seguros.dtfimvig,'DD/MM/YYYY') ||''',''DD/MM/YYYY'') where rowid = '''|| rw_seguros.rowid ||''';';    
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,  vr_linha);

    --dbms_output.put_line(vr_linha);
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
1
vr_dscritic
1
SUCESSO -> Registros atualizados: 25
5
0
