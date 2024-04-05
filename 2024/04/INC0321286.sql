DECLARE
  vr_dttransa                     cecred.craplgm.dttransa%type;
  vr_hrtransa                     cecred.craplgm.hrtransa%type;
  vr_nrdconta                     cecred.crapass.nrdconta%type;
  vr_cdcooper                     cecred.crapcop.cdcooper%type;
  vr_cdoperad                     cecred.craplgm.cdoperad%TYPE;
  vr_cdcritic                     cecred.crapcri.cdcritic%type;
  vr_dscritic                     cecred.crapcri.dscritic%TYPE;
  vr_nrdrowid                     ROWID;
  vr_des_reto                     VARCHAR2(3);
  
  vr_dtmvtolt                     DATE;
  vr_busca                        VARCHAR2(100);
  vr_nrdocmto                     INTEGER;
  vr_nrseqdig                     INTEGER;
  vr_vldcotas                     NUMBER;
  vr_vldcotas_crapcot             NUMBER;
  vr_vlsddisp                     cecred.crapsda.vlsddisp%type;
  vr_incrineg                     NUMBER;
  vr_index                        NUMBER;
  vr_cdhistor                     cecred.craphis.cdhistor%type;
  vr_globalname                   varchar2(100);
 
  
  vc_nrdolote_cota                CONSTANT cecred.craplct.nrdolote%type := 600040;
  vc_tpdevCotas                   CONSTANT NUMBER := 3;
  vc_tpdevDepVista                CONSTANT NUMBER := 4;
  vc_cdhistDepVistaPF             CONSTANT NUMBER := 2079;
  vc_cdhistDepVistaPJ             CONSTANT NUMBER := 2080;
  vc_cdhistCotasPF                CONSTANT NUMBER := 2079;
  vc_cdhistCotasPJ                CONSTANT NUMBER := 2080;  
  vc_dstransaStatusCC             CONSTANT VARCHAR2(4000) := 'Alteracao da situacao de conta por script - INC0321286';
  vc_dstransaDevCotas             CONSTANT VARCHAR2(4000) := 'Alteração de Cotas e devolução - INC0321286';
  vc_dstransaDevDepVista          CONSTANT VARCHAR2(4000) := 'Alteracao da devolução do Depósito a Vista - INC0321286';
  vc_inpessoaPF                   CONSTANT NUMBER := 1;
  vc_inpessoaPJ                   CONSTANT NUMBER := 2; 
  vc_nrdolote_lanc                CONSTANT NUMBER := 37000;
  vc_cdbccxlt                     CONSTANT NUMBER := 1;
  vc_cdsitdctProcesDemis          CONSTANT NUMBER := 8;
  vc_cdsitdctEncerrada            CONSTANT NUMBER := 4;
  vc_bdprod                       CONSTANT VARCHAR2(100) := 'AYLLOSP';
  
  CURSOR cr_crapass is
    SELECT t.cdagenci
          ,t.cdcooper
          ,t.nrdconta
          ,t.inpessoa
          ,t.vllimcre
          ,t.cdsitdct as cdsitdct_old
          ,a.cdsitdct as cdsitdct_new
          ,t.dtdemiss as dtdemiss_old
          ,a.dtdemiss as dtdemiss_new
          ,t.dtelimin as dtelimin_old
          ,a.dtelimin as dtelimin_new
          ,t.dtasitct as dtasitct_old
          ,a.dtasitct as dtasitct_new
          ,t.cdmotdem as cdmotdem_old
          ,a.cdmotdem as cdmotdem_new  
      FROM CECRED.CRAPASS t
         ,(select 5	as cdcooper, decode(vr_globalname, vc_bdprod,303380  ,99696550) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 2	as cdcooper, decode(vr_globalname, vc_bdprod,376779  ,98980335) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 2	as cdcooper, decode(vr_globalname, vc_bdprod,1019600 ,99623161) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 2	as cdcooper, decode(vr_globalname, vc_bdprod,986658  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 2	as cdcooper, decode(vr_globalname, vc_bdprod,950165  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 2	as cdcooper, decode(vr_globalname, vc_bdprod,379247  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 13	as cdcooper, decode(vr_globalname, vc_bdprod,34401   ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 13	as cdcooper, decode(vr_globalname, vc_bdprod,422967  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 13	as cdcooper, decode(vr_globalname, vc_bdprod,585130  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 7	as cdcooper, decode(vr_globalname, vc_bdprod,92061   ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 7	as cdcooper, decode(vr_globalname, vc_bdprod,191990  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 7	as cdcooper, decode(vr_globalname, vc_bdprod,71773   ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 7	as cdcooper, decode(vr_globalname, vc_bdprod,47260   ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 7	as cdcooper, decode(vr_globalname, vc_bdprod,85049   ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 7	as cdcooper, decode(vr_globalname, vc_bdprod,425397  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 7	as cdcooper, decode(vr_globalname, vc_bdprod,188867  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 7	as cdcooper, decode(vr_globalname, vc_bdprod,335134  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 7	as cdcooper, decode(vr_globalname, vc_bdprod,15148   ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 10	as cdcooper, decode(vr_globalname, vc_bdprod,17272   ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 10	as cdcooper, decode(vr_globalname, vc_bdprod,180602  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,128317  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,530077  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,265276  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,354716  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,292940  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,232785  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,479519  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,532517  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,317144  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,116874  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,191086  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,108960  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,173347  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,486434  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,148580  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,173460  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,229350  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,546143  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,265284  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,232742  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,174564  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,169943  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,168211  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,286419  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,149381  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,127302  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,169536  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,222763  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,170798  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,109444  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,271195  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,169471  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,601586  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,581909  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,339962  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,557226  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,475041  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,164925  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,474002  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,190683  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,303038  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,167142  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,548669  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,551430  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,514187  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,318680  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,403229  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,581461  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,517780  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,86258   ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,483630  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,491020  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,205141  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,546747  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,542350  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,512893  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,551775  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,124907  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,583561  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,341240  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,386448  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,338192  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,366862  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,65730   ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,567370  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,112526  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,530859  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,306207  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,354660  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,493520  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,281271  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,172294  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,201120  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,117013  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,203327  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,228214  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,170445  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,348589  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,430463  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,349518  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,272485  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,225541  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,102105  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,355232  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,559393  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,312550  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,483508  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,171328  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,148776  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,460664  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,432903  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,226238  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,425800  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,224499  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,448826  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,171670  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,221430  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,495182  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,617512  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,474177  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,285501  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,325899  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,556505  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,275930  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,268020  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,362352  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,261076  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,195790  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,228303  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,193712  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,599433  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,239950  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,276243  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,344745  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,488160  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,279684  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,29564   ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,132918  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,532487  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,313203  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,130990  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,327417  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,562530  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,250562  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,422916  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,584304  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,542849  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,527173  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,260029  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,310484  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,188565  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,188220  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,65285   ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,494607  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,398861  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,419826  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,478083  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,545430  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,301612  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,506443  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,226114  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,548391  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,150541  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,604488  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,118540  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,224138  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,276170  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,312789  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,492230  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,678058  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,239593  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,267201  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,535559  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,550531  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,309443  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,213446  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,335401  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,536415  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,346942  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,460206  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,186520  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,376167  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,659231  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,586927  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,548723  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,581658  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,546283  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,196096  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,118605  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,498068  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,247251  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,79880   ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,201944  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,332933  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,202118  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,225363  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,229563  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,331970  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,642665  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,200930  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,268607  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,377848  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,127299  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,517003  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,197564  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,453080  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,639435  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,550370  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,555207  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,312070  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,32328   ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,279617  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,162655  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,195278  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,443379  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,431834  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,418900  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,538167  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,310875  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,521140  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,482641  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,365971  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,268747  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,149918  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,499080  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,170097  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,126349  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,331805  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,455830  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,525111  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,542946  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,518964  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,450413  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,505005  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,148687  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,608092  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,257214  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,94595   ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,618233  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,320650  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,203149  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,158976  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,232840  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,202053  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,200492  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,534234  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,165492  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,275077  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,388572  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,109843  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,525057  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,8621    ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,876194  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,16099125,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,800163  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,250350  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,235601  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,149306  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 11	as cdcooper, decode(vr_globalname, vc_bdprod,796603  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 17	as cdcooper, decode(vr_globalname, vc_bdprod,307904  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 17	as cdcooper, decode(vr_globalname, vc_bdprod,333964  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 17	as cdcooper, decode(vr_globalname, vc_bdprod,349801  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 17	as cdcooper, decode(vr_globalname, vc_bdprod,438898  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 17	as cdcooper, decode(vr_globalname, vc_bdprod,123811  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 17	as cdcooper, decode(vr_globalname, vc_bdprod,418358  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 6	as cdcooper, decode(vr_globalname, vc_bdprod,76180   ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,14112523,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,8537127 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,8145199 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,10835741,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,10894349,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,15676889,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,12354651,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,11828510,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,8288445 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,3879798 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,13974602,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,14051699,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,12271306,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,12251330,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,7628005 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,11826860,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,8010749 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,12201880,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,6822290 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,8797714 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,2309378 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,8444846 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,2268647 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,8338779 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,9153560 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,8368031 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,8043884 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,1986899 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,3029395 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 1	as cdcooper, decode(vr_globalname, vc_bdprod,2666260 ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 16	as cdcooper, decode(vr_globalname, vc_bdprod,14460   ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 16	as cdcooper, decode(vr_globalname, vc_bdprod,374741  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 16	as cdcooper, decode(vr_globalname, vc_bdprod,298832  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 16	as cdcooper, decode(vr_globalname, vc_bdprod,804444  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 16	as cdcooper, decode(vr_globalname, vc_bdprod,915637  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual
           union
           select 16	as cdcooper, decode(vr_globalname, vc_bdprod,311456  ,00) as nrdconta, vc_cdsitdctEncerrada as cdsitdct, null as dtdemiss, null as dtelimin, null as dtasitct, null as  cdmotdem from dual

) a
     WHERE 1=1
       AND t.cdcooper = a.cdcooper
       AND t.nrdconta = a.nrdconta
     order by a.cdsitdct desc;
     
  rg_crapass                      cr_crapass%rowtype;
   
  rw_crapdat                      CECRED.BTCH0001.cr_crapdat%ROWTYPE;
  vr_tab_sald                     CECRED.EXTR0001.typ_tab_saldos;
  vr_tab_erro                     CECRED.GENE0001.typ_tab_erro;
  vr_tab_retorno                  cecred.LANC0001.typ_reg_retorno;
  vr_exc_sem_data_cooperativa     EXCEPTION;
  vr_exc_saldo                    EXCEPTION;
  vr_exc_lanc_conta               EXCEPTION;
  vr_inpessoa_invalido            EXCEPTION;
  
BEGIN
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := CECRED.GENE0002.fn_busca_time;

  SELECT GLOBAL_NAME
  INTO vr_globalname
  FROM GLOBAL_NAME;

  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => 16);
  FETCH cecred.btch0001.cr_crapdat INTO rw_crapdat;
  
  IF cecred.btch0001.cr_crapdat%NOTFOUND THEN
    CLOSE cecred.btch0001.cr_crapdat;
    raise vr_exc_sem_data_cooperativa;
  ELSE
    CLOSE cecred.btch0001.cr_crapdat;
  END IF;
  vr_dtmvtolt := rw_crapdat.dtmvtolt;
  
  
  FOR rg_crapass IN cr_crapass LOOP
    
    vr_cdcooper := rg_crapass.cdcooper;
    vr_nrdconta := rg_crapass.nrdconta;
              
    vr_nrdrowid := null;
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscritic => vr_dscritic,
                                pr_dsorigem => 'AIMARO',
                                pr_dstransa => vc_dstransaStatusCC,
                                pr_dttransa => vr_dttransa,
                                pr_flgtrans => 1,
                                pr_hrtransa => vr_hrtransa,
                                pr_idseqttl => 0,
                                pr_nmdatela => NULL,
                                pr_nrdconta => rg_crapass.nrdconta,
                                pr_nrdrowid => vr_nrdrowid);
                         
    IF (rg_crapass.cdsitdct_new IS NOT NULL) THEN
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapass.cdsitdct',
                                       pr_dsdadant => rg_crapass.cdsitdct_old,
                                       pr_dsdadatu => rg_crapass.cdsitdct_new);
    END IF;

    IF (rg_crapass.dtdemiss_new IS NOT NULL) THEN    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapass.dtdemiss',
                                       pr_dsdadant => rg_crapass.dtdemiss_old,
                                       pr_dsdadatu => rg_crapass.dtdemiss_new);
    END IF;
                              
    IF (rg_crapass.cdmotdem_new IS NOT NULL) THEN    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapass.dtelimin',
                                       pr_dsdadant => rg_crapass.dtelimin_old,
                                       pr_dsdadatu => rg_crapass.dtelimin_new);  
    END IF;
                                                            
    IF (rg_crapass.cdmotdem_new IS NOT NULL) THEN    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapass.cdmotdem',
                                       pr_dsdadant => rg_crapass.cdmotdem_old,
                                       pr_dsdadatu => rg_crapass.cdmotdem_new); 
    END IF;
                                                             
    IF (rg_crapass.dtasitct_new IS NOT NULL) THEN    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapass.dtasitct',
                                       pr_dsdadant => rg_crapass.dtasitct_old,
                                       pr_dsdadatu => rg_crapass.dtasitct_new);                                
    END IF;

   
    
    vr_vldcotas_crapcot := 0;
    
    BEGIN
      SELECT nvl(vldcotas,0)
        INTO vr_vldcotas_crapcot
        FROM CECRED.crapcot
       WHERE nrdconta = rg_crapass.nrdconta
         AND cdcooper = rg_crapass.cdcooper;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      
        dbms_output.put_line(chr(10) ||
                             'Não encontrado registro em crapcot para conta ' ||
                             rg_crapass.nrdconta);
        vr_vldcotas_crapcot := 0;
      
    END;
    
    IF vr_vldcotas_crapcot > 0 THEN
      
      
      vr_busca := TRIM(to_char(rg_crapass.cdcooper)) || ';' ||
                          TRIM(to_char(vr_dtmvtolt,'DD/MM/RRRR')) || ';' ||
                          TRIM(to_char(rg_crapass.cdagenci)) || ';' ||
                          '100;' || 
                          vc_nrdolote_cota;
                          
      vr_nrdocmto := cecred.fn_sequence('CRAPLCT','NRDOCMTO', vr_busca);
                                 
      vr_nrseqdig := cecred.fn_sequence('CRAPLOT','NRSEQDIG',''||rg_crapass.cdcooper||';'||
                                                                  TRIM(to_char(vr_dtmvtolt, 'DD/MM/RRRR'))||';'||
                                                                  rg_crapass.cdagenci||
                                                                  ';100;'|| 
                                                                  vc_nrdolote_cota);
    
      case rg_crapass.inpessoa
        when vc_inpessoaPF then
          vr_cdhistor := vc_cdhistCotasPF;
        when vc_inpessoaPJ then
          vr_cdhistor := vc_cdhistCotasPJ;
        else
          raise vr_inpessoa_invalido;
      end case;
      
      INSERT INTO CECRED.craplct
        (cdcooper,
         cdagenci,
         cdbccxlt,
         nrdolote,
         dtmvtolt,
         cdhistor,
         nrctrpla,
         nrdconta,
         nrdocmto,
         nrseqdig,
         vllanmto,
         CDOPEORI,
         DTINSORI)
      VALUES
        (rg_crapass.cdcooper,
         rg_crapass.cdagenci,
         100,
         vc_nrdolote_cota,
         vr_dtmvtolt,
         vr_cdhistor,
         0,
         rg_crapass.nrdconta,
         vr_nrdocmto,
         vr_nrseqdig,
         vr_vldcotas_crapcot,
         1,
         sysdate);
      
      vr_nrdrowid := null;
      
      CECRED.GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
                                  pr_cdoperad => vr_cdoperad,
                                  pr_dscritic => vr_dscritic,
                                  pr_dsorigem => 'AIMARO',
                                  pr_dstransa => vc_dstransaDevCotas,
                                  pr_dttransa => vr_dttransa,
                                  pr_flgtrans => 1,
                                  pr_hrtransa => vr_hrtransa,
                                  pr_idseqttl => 0,
                                  pr_nmdatela => NULL,
                                  pr_nrdconta => rg_crapass.nrdconta,
                                  pr_nrdrowid => vr_nrdrowid);
    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplct.dtmvtolt',
                                       pr_dsdadant => null,
                                       pr_dsdadatu => vr_dtmvtolt);
    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'craplct.vllanmto',
                                       pr_dsdadant => null,
                                       pr_dsdadatu => vr_vldcotas_crapcot);
    
      UPDATE CECRED.crapcot
         SET vldcotas = 0
       WHERE cdcooper = rg_crapass.cdcooper
         AND nrdconta = rg_crapass.nrdconta;
    
      CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                       pr_nmdcampo => 'crapcot.vldcotas',
                                       pr_dsdadant => vr_vldcotas_crapcot,
                                       pr_dsdadatu => 0);
                                
       MERGE INTO CECRED.TBCOTAS_DEVOLUCAO a
       USING (SELECT rg_crapass.cdcooper as cdcooper, rg_crapass.nrdconta as nrdconta, vc_tpdevCotas as tpdevolucao 
                FROM DUAL) b
         ON (a.cdcooper = b.cdcooper AND a.nrdconta = b.nrdconta AND a.tpdevolucao = b.tpdevolucao)
       WHEN MATCHED THEN UPDATE SET a.vlcapital =(a.vlcapital + vr_vldcotas_crapcot)
       WHEN NOT MATCHED THEN INSERT (a.cdcooper, a.nrdconta, a.tpdevolucao, a.vlcapital)
                             VALUES (b.cdcooper, b.nrdconta, b.tpdevolucao, vr_vldcotas_crapcot);
    
    END IF;
    
    
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_sem_data_cooperativa THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao buscar data da cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ');
  WHEN vr_exc_saldo THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20001,
                            'Erro ao buscar saldo da cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            'vr_cdcritic: ' || vr_cdcritic || ' - ' ||
                            'vr_dscritic: ' || vr_dscritic);
    
  WHEN vr_exc_lanc_conta THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20001,
                            'Erro ao realizar lançamento na cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            'vr_cdcritic: ' || vr_cdcritic || ' - ' ||
                            'vr_dscritic: ' || vr_dscritic);
  
  WHEN vr_inpessoa_invalido THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20002,
                            'Erro tipo de pessoa inválido da cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ');
    
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20003,
                            'Erro geral script -> cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            SQLERRM);
END;
/
