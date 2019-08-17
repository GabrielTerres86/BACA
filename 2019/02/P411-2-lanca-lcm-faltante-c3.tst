PL/SQL Developer Test script 3.0
110
-- Created on 26/12/2018 by F0030794 
declare 
  
  pr_cdcooper crapcop.cdcooper%TYPE := 1;
  pr_nrdconta crapass.nrdconta%TYPE := 8376670;
  pr_dtmvtolt crapdat.dtmvtolt%TYPE := to_date('12/02/2019','dd/mm/rrrr');
  vr_nraplica craprac.nraplica%TYPE := 8;
  pr_vlaplica craplcm.vllanmto%TYPE := 29.15;
  pr_cdhistor craplcm.cdhistor%TYPE := 2740;
  
  -- Local variables here
  vr_excerro  exception;
  vr_dscritic varchar2(5000);
  
  
  CURSOR cr_craplot IS
  select craplot.*
        ,rowid
  from craplot
 where cdcooper = pr_cdcooper
   and dtmvtolt = pr_dtmvtolt
   and cdagenci = 1
   and cdbccxlt = 100
   and nrdolote = 8501;
  rw_craplot cr_craplot%ROWTYPE;
  
  
begin

  /* Abre o lote */
   OPEN cr_craplot;
  FETCH cr_craplot INTO rw_craplot;
  IF cr_craplot%NOTFOUND THEN
    CLOSE cr_craplot;
    vr_dscritic := 'Lote nao encontrado!';
    raise vr_excerro;
  END IF;
  CLOSE cr_craplot;

  /* Atualiza capa do lote */  
  BEGIN
    UPDATE craplot
       SET craplot.nrseqdig = rw_craplot.nrseqdig + 1
          ,craplot.qtinfoln = rw_craplot.qtinfoln + 1
          ,craplot.qtcompln = rw_craplot.qtcompln + 1
          ,craplot.vlinfodb = rw_craplot.vlinfodb + pr_vlaplica
          ,craplot.vlcompdb = rw_craplot.vlcompdb + pr_vlaplica
     WHERE craplot.rowid = rw_craplot.rowid
     RETURNING craplot.dtmvtolt, craplot.cdagenci
              ,craplot.cdbccxlt, craplot.nrdolote
              ,craplot.nrseqdig, craplot.rowid
          INTO rw_craplot.dtmvtolt, rw_craplot.cdagenci
              ,rw_craplot.cdbccxlt, rw_craplot.nrdolote
              ,rw_craplot.nrseqdig, rw_craplot.rowid;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro atualizando lote - '||sqlerrm;
      RAISE vr_excerro;
  END;
  
  /* Cria debito craplcm - hist. 2740 */
  BEGIN
    INSERT INTO
      craplcm(
        cdcooper
       ,dtmvtolt
       ,cdagenci
       ,cdbccxlt
       ,nrdolote
       ,nrdconta
       ,nrdctabb
       ,nrdocmto
       ,nrseqdig
       ,dtrefere
       ,vllanmto
       ,cdhistor
       ,nraplica)
    VALUES(
      pr_cdcooper
     ,rw_craplot.dtmvtolt
     ,rw_craplot.cdagenci
     ,rw_craplot.cdbccxlt
     ,rw_craplot.nrdolote
     ,pr_nrdconta
     ,pr_nrdconta
     ,vr_nraplica
     ,rw_craplot.nrseqdig
     ,rw_craplot.dtmvtolt
     ,pr_vlaplica
     ,pr_cdhistor
     ,vr_nraplica);

  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao inserir LCM '|| SQLERRM;
      RAISE vr_excerro;
  END;

  COMMIT;
  :dscritic := 'SUCESSO';

exception
  when vr_excerro then
    rollback;
    :dscritic := vr_dscritic;
  when others then
    rollback;
    :dscritic := 'ERRO ' || SQLERRM;
  
end;
0
0
