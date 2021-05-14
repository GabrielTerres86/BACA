 
declare
  vr_contador number;
  vr_dscritic varchar2(500);
  vr_excsaida EXCEPTION;
  vr_linha varchar2(2000);
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0081814';
  vr_nmarqimp        VARCHAR2(100)  := 'INC0081814_ROLLBACK.txt';
  vr_ind_arquiv      utl_file.file_type;

 Cursor cr_wseg is
 select CDCOOPER, NRDCONTA, NRCTRSEG, cdsegura, rowid  from crawseg
       where  cdsegura = 5011
          and tpseguro = 4
          and dtiniseg >= trunc(sysdate)  - 134 
          ;
  rw_wseg cr_wseg%rowtype;

  cursor cr_pseg is
  select CDCOOPER, NRDCONTA, TPSEGURO, NRCTRSEG, rowid  from crapseg
       where  cdsegura = 5011
--          AND cdsitseg IN (1,3) -- Ativo
          and tpseguro = 4
          and dtiniseg >= trunc(sysdate)  - 134  
          ;
  rw_pseg cr_pseg%rowtype;

begin
  vr_contador:=0;
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
 
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_excsaida;
  END IF;

  FOR rw_wseg IN cr_wseg LOOP

    vr_contador:= vr_contador + 1;
    vr_linha := 'update crawseg set  cdsegura = 5011 where rowid = '''|| rw_wseg.rowid ||''';';
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,  vr_linha);
 
    BEGIN
      UPDATE crawseg set cdsegura = 514  WHERE ROWID = rw_wseg.rowid;

    EXCEPTION
      WHEN OTHERS THEN
         close cr_wseg;
        vr_dscritic := 'Erro ao atualizar crapseg! rowid: '||
                       rw_wseg.rowid;
        RAISE vr_excsaida;
    END;

  END LOOP; 
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'commit;');
  vr_dscritic := 'SUCESSO -> Registros atualizados  CRAWSEG : '|| vr_contador;

 FOR rw_pseg IN cr_pseg LOOP

    vr_contador:= vr_contador + 1;
    vr_linha := 'update crapseg set  cdsegura = 5011 where rowid = '''|| rw_pseg.rowid ||''';';
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,  vr_linha);
 
    BEGIN
      UPDATE crapseg set cdsegura = 514  WHERE ROWID = rw_pseg.rowid;

    EXCEPTION
      WHEN OTHERS THEN
        close cr_pseg;
        vr_dscritic := 'Erro ao atualizar crapseg! rowid: '||
                       rw_pseg.rowid;
        RAISE vr_excsaida;
    END;

  END LOOP; 
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,'commit;');

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  commit;

   vr_dscritic := 'SUCESSO -> Registros atualizados: '|| vr_contador;
EXCEPTION
  WHEN vr_excsaida then
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
end;
