PL/SQL Developer Test script 3.0
122
-- Created on 26/12/2018 by F0030794 
declare 
  
  pr_cdcooper crapcop.cdcooper%TYPE := 1;
  pr_nrdconta crapass.nrdconta%TYPE := 8376670;
  pr_dtmvtolt crapdat.dtmvtolt%TYPE := to_date('22/02/2019','dd/mm/rrrr');
  vr_nraplica craprac.nraplica%TYPE := 8;
  pr_vlaplica craplcm.vllanmto%TYPE := 29.15;
  pr_cdhistor craplcm.cdhistor%TYPE := 2740;
  pr_cdhistor_lac craplcm.cdhistor%TYPE := 2743;
  
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
  
  CURSOR cr_craplot_lac IS
  select craplot.*
        ,rowid
  from craplot
 where cdcooper = pr_cdcooper
   and dtmvtolt = pr_dtmvtolt
   and cdagenci = 1
   and cdbccxlt = 100
   and nrdolote = 8500;
  rw_craplot_lac cr_craplot_lac%ROWTYPE; 
  
begin

  /* --------- Lancto LCM --------- */
  
  /* --------- Lancto LAC --------- */
  
  /* Abre o lote - LAC */
   OPEN cr_craplot_lac;
  FETCH cr_craplot_lac INTO rw_craplot_lac;
  IF cr_craplot_lac%NOTFOUND THEN
    CLOSE cr_craplot_lac;
    vr_dscritic := 'Lote LAC nao encontrado!';
    raise vr_excerro;
  END IF;
  CLOSE cr_craplot_lac;

  /* Atualiza capa do lote - LAC */  
  BEGIN
    UPDATE craplot
       SET craplot.nrseqdig = rw_craplot_lac.nrseqdig + 1
          ,craplot.qtinfoln = rw_craplot_lac.qtinfoln + 1
          ,craplot.qtcompln = rw_craplot_lac.qtcompln + 1
          ,craplot.vlinfodb = rw_craplot_lac.vlinfodb + pr_vlaplica
          ,craplot.vlcompdb = rw_craplot_lac.vlcompdb + pr_vlaplica
     WHERE craplot.rowid = rw_craplot_lac.rowid
     RETURNING craplot.dtmvtolt, craplot.cdagenci
              ,craplot.cdbccxlt, craplot.nrdolote
              ,craplot.nrseqdig, craplot.rowid
          INTO rw_craplot_lac.dtmvtolt, rw_craplot_lac.cdagenci
              ,rw_craplot_lac.cdbccxlt, rw_craplot_lac.nrdolote
              ,rw_craplot_lac.nrseqdig, rw_craplot_lac.rowid;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro atualizando lote LAC - '||sqlerrm;
      RAISE vr_excerro;
  END;
  
  /* Cria credito craplac - hist. 2743 */
  BEGIN
    INSERT INTO
          craplac(
            cdcooper
           ,dtmvtolt
           ,cdagenci
           ,cdbccxlt
           ,nrdolote
           ,nrdconta
           ,nraplica
           ,nrdocmto
           ,nrseqdig
           ,vllanmto
           ,cdhistor
        )VALUES(
           pr_cdcooper
          ,rw_craplot_lac.dtmvtolt
          ,rw_craplot_lac.cdagenci
          ,rw_craplot_lac.cdbccxlt
          ,rw_craplot_lac.nrdolote
          ,pr_nrdconta
          ,vr_nraplica
          ,rw_craplot_lac.nrseqdig
          ,rw_craplot_lac.nrseqdig
          ,pr_vlaplica
          ,pr_cdhistor_lac);

  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao inserir LAC '|| SQLERRM;
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
1
dscritic
0
5
0
