PL/SQL Developer Test script 3.0
565
declare 
  vr_cdcritic   crapcri.cdcritic%TYPE;
  vr_dscritic   varchar2(5000) := ' ';
  vr_excsaida EXCEPTION;
  
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0067690';
 -- vr_nmdireto        VARCHAR2(4000) := 'F://Documents/Testes/INC0067690';
  vr_nmarqimp        VARCHAR2(100)  := 'log.txt';
  vr_nmarqimp2       VARCHAR2(100)  := 'sucesso.txt';
  vr_nmarqimp3       VARCHAR2(100)  := 'falha.txt';
  vr_nmarqimp4       VARCHAR2(100)  := 'backup.txt';
  vr_ind_arquiv      utl_file.file_type;
  vr_ind_arquiv2     utl_file.file_type;
  vr_ind_arquiv3     utl_file.file_type;
  vr_ind_arquiv4     utl_file.file_type;
  
  cursor cr_crapcar IS
     SELECT crd.rowid, crd.nrconta_cartao, crd.dtmvtolt, crd.cdcooper, crd.nrdconta, 
           (select car.cdcooper from tbcrd_conta_cartao car where  crd.nrconta_cartao = car.nrconta_cartao) coop_certa,
           (select car.nrdconta from tbcrd_conta_cartao car where crd.nrconta_cartao = car.nrconta_cartao) conta_certa,
           crd.qttransa_debito, crd.qttransa_credito, crd.vltransa_debito, crd.vltransa_credito 
    from tbcrd_utilizacao_cartao crd
    where not exists(Select 1 from tbcrd_conta_cartao car where crd.cdcooper = car.cdcooper and crd.nrdconta = car.nrdconta and crd.nrconta_cartao = car.nrconta_cartao)
          and crd.dtmvtolt between '01/01/2020'  AND '31/12/2020';
  rw_crapcar cr_crapcar%ROWTYPE;

  vr_vlsppant_correto craprpp.vlsppant%TYPE;

  procedure loga(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, pr_msg);
  END;
    
  procedure sucesso(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv2, pr_msg);
  END;
  
  procedure falha(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv3, pr_msg);
    loga(pr_msg);
  END;
  
  procedure backup(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv4, pr_msg);
  END;

begin
  --Conta cartão: 7563239067097
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 323791;
  
  --Conta cartão: 7563239519180
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1202685;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 16 AND c.nrdconta = 604011 AND c.nrconta_cartao = 7563239519180;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 16 AND d.nrdconta = 604011 AND d.nrconta_cartao = 7563239519180;
  
  --Conta cartão: 7563239527477
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 10874836 AND c.nrconta_cartao = 7563239527477;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 10874836 AND d.nrconta_cartao = 7563239527477;
  
  --Conta cartão: 7563239528713
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1226585;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 11 AND c.nrdconta = 569852 AND c.nrconta_cartao = 7563239528713;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 11 AND d.nrdconta = 569852 AND d.nrconta_cartao = 7563239528713;
  
  --Conta cartão: 7563239528850
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1228940;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 11 AND c.nrdconta = 535974 AND c.nrconta_cartao = 7563239528850;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 11 AND d.nrdconta = 535974 AND d.nrconta_cartao = 7563239528850;
  
  --Conta cartão: 7563239540499
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 8559961 AND c.nrconta_cartao = 7563239540499;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 8559961 AND d.nrconta_cartao = 7563239540499;
  
  --Conta cartão: 7563239541085
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1264396;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 7 AND c.nrdconta = 307068 AND c.nrconta_cartao = 7563239541085;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 7 AND d.nrdconta = 307068 AND d.nrconta_cartao = 7563239541085;
  
  --Conta cartão: 7563239542605
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1268487;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 16 AND c.nrdconta = 635251 AND c.nrconta_cartao = 7563239542605;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 16 AND d.nrdconta = 635251 AND d.nrconta_cartao = 7563239542605;
  
  --Conta cartão: 7563239545578
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1277769;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 2 AND c.nrdconta = 794988 AND c.nrconta_cartao = 7563239545578;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 2 AND d.nrdconta = 794988 AND d.nrconta_cartao = 7563239545578;
  
  --Conta cartão: 7563239548257
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1286020;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 9 AND c.nrdconta = 302244 AND c.nrconta_cartao = 7563239548257;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 9 AND d.nrdconta = 302244 AND d.nrconta_cartao = 7563239548257;
  
  --Conta cartão: 7563239549978
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11052392 AND c.nrconta_cartao = 7563239549978;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11052392 AND d.nrconta_cartao = 7563239549978;
  
  --Conta cartão: 7563239557884
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1317297;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 11 AND c.nrdconta = 600881 AND c.nrconta_cartao = 7563239557884;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 11 AND d.nrdconta = 600881 AND d.nrconta_cartao = 7563239557884;
  
  --Conta cartão: 7563239563885
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1339524;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 12 AND c.nrdconta = 146781 AND c.nrconta_cartao = 7563239563885;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 12 AND d.nrdconta = 146781 AND d.nrconta_cartao = 7563239563885;
  
  --Conta cartão: 7563239575540
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1379111;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 13 AND c.nrdconta = 443280 AND c.nrconta_cartao = 7563239575540;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 13 AND d.nrdconta = 443280 AND d.nrconta_cartao = 7563239575540;
  
  --Conta cartão: 7563239588985
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11381990 AND c.nrconta_cartao = 7563239588985;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11381990 AND d.nrconta_cartao = 7563239588985;
  
  --Conta cartão: 7563239590075
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1421897;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 2 AND c.nrdconta = 828548 AND c.nrconta_cartao = 7563239590075;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 2 AND d.nrdconta = 828548 AND d.nrconta_cartao = 7563239590075;
  
  --Conta cartão: 7563239594426
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1432303;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 6 AND c.nrdconta = 196827 AND c.nrconta_cartao = 7563239594426;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 6 AND d.nrdconta = 196827 AND d.nrconta_cartao = 7563239594426;
  
  --Conta cartão: 7563239597678
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1430863;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 2 AND c.nrdconta = 843784 AND c.nrconta_cartao = 7563239597678;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 2 AND d.nrdconta = 843784 AND d.nrconta_cartao = 7563239597678;
  
  --Conta cartão: 7563239611928
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1486876;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 16 AND c.nrdconta = 713988 AND c.nrconta_cartao = 7563239611928;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 16 AND d.nrdconta = 713988 AND d.nrconta_cartao = 7563239611928;
  
  --Conta cartão: 7563239615492
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1497544;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 2 AND c.nrdconta = 864234 AND c.nrconta_cartao = 7563239615492;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 2 AND d.nrdconta = 864234 AND d.nrconta_cartao = 7563239615492;
  
  --Conta cartão: 7563239615716
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1498006;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 13 AND c.nrdconta = 179019 AND c.nrconta_cartao = 7563239615716;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 13 AND d.nrdconta = 179019 AND d.nrconta_cartao = 7563239615716;
  
  --Conta cartão: 7563239615933
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1498793;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 12 AND c.nrdconta = 155098 AND c.nrconta_cartao = 7563239615933;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 12 AND d.nrdconta = 155098 AND d.nrconta_cartao = 7563239615933;
  
  --Conta cartão: 7563239627975
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1534597;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11732938 AND c.nrconta_cartao = 7563239627975;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11732938 AND d.nrconta_cartao = 7563239627975;
  
  --Conta cartão: 7563239628368
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1536079;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 10 AND c.nrdconta = 163856 AND c.nrconta_cartao = 7563239628368;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 10 AND d.nrdconta = 163856 AND d.nrconta_cartao = 7563239628368;
  
  --Conta cartão: 7563239630286
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1541278;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11750472 AND c.nrconta_cartao = 7563239630286;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11750472 AND d.nrconta_cartao = 7563239630286;
  
  --Conta cartão: 7563239630740
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1542198;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 6363989 AND c.nrconta_cartao = 7563239630740;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 6363989 AND d.nrconta_cartao = 7563239630740;
  
  --Conta cartão: 7563239631017
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1543423;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 13 AND c.nrdconta = 487899 AND c.nrconta_cartao = 7563239631017;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 13 AND d.nrdconta = 487899 AND d.nrconta_cartao = 7563239631017;
  
  --Conta cartão: 7563239631837
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1547037;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 11 AND c.nrdconta = 673021 AND c.nrconta_cartao = 7563239631837;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 11 AND d.nrdconta = 673021 AND d.nrconta_cartao = 7563239631837;
  
  --Conta cartão: 7563239633014
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1550366;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 6 AND c.nrdconta = 207543 AND c.nrconta_cartao = 7563239633014;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 6 AND d.nrdconta = 207543 AND d.nrconta_cartao = 7563239633014;
  
  --Conta cartão: 7563239634054
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1540303;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 6 AND c.nrdconta = 206237 AND c.nrconta_cartao = 7563239634054;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 6 AND d.nrdconta = 206237 AND d.nrconta_cartao = 7563239634054;
  
  --Conta cartão: 7563239634663
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1554878;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 9460322 AND c.nrconta_cartao = 7563239634663;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 9460322 AND d.nrconta_cartao = 7563239634663;
  
  --Conta cartão: 7563239638020
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1564102;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 11 AND c.nrdconta = 670006 AND c.nrconta_cartao = 7563239638020;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 11 AND d.nrdconta = 670006 AND d.nrconta_cartao = 7563239638020;
  
  --Conta cartão: 7563239639076
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1565282;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11822775 AND c.nrconta_cartao = 7563239639076;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11822775 AND d.nrconta_cartao = 7563239639076;
  
  --Conta cartão: 7563239640999
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1572031;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11398507 AND c.nrconta_cartao = 7563239640999;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11398507 AND d.nrconta_cartao = 7563239640999;
  
  --Conta cartão: 7563239641117
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1571054;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 9148531 AND c.nrconta_cartao = 7563239641117;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 9148531 AND d.nrconta_cartao = 7563239641117;
  
  --Conta cartão: 7563239642135
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1575763;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11855428 AND c.nrconta_cartao = 7563239642135;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11855428 AND d.nrconta_cartao = 7563239642135;
  
  --Conta cartão: 7563239642299
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1576106;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11847468 AND c.nrconta_cartao = 7563239642299;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11847468 AND d.nrconta_cartao = 7563239642299;
  
  --Conta cartão: 7563239643407
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1579441;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 10832637 AND c.nrconta_cartao = 7563239643407;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 10832637 AND d.nrconta_cartao = 7563239643407;
  
  --Conta cartão: 7563239643538
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1579749;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 2 AND c.nrdconta = 894010 AND c.nrconta_cartao = 7563239643538;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 2 AND d.nrdconta = 894010 AND d.nrconta_cartao = 7563239643538;
  
  --Conta cartão: 7563239644164
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1581480;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 8363560 AND c.nrconta_cartao = 7563239644164;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 8363560 AND d.nrconta_cartao = 7563239644164;
  
  --Conta cartão: 7563239644672
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1583259;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11877774 AND c.nrconta_cartao = 7563239644672;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11877774 AND d.nrconta_cartao = 7563239644672;
  
  --Conta cartão: 7563239653922
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1607397;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11961120 AND c.nrconta_cartao = 7563239653922;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11961120 AND d.nrconta_cartao = 7563239653922;
  
  --Conta cartão: 7563239653927
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1607403;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11850132 AND c.nrconta_cartao = 7563239653927;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11850132 AND d.nrconta_cartao = 7563239653927;
  
  --Conta cartão: 7563239657107
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1615963;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 2 AND c.nrdconta = 907774 AND c.nrconta_cartao = 7563239657107;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 2 AND d.nrdconta = 907774 AND d.nrconta_cartao = 7563239657107;
  
  --Conta cartão: 7563239661133
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1626756;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 12022055 AND c.nrconta_cartao = 7563239661133;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 12022055 AND d.nrconta_cartao = 7563239661133;
  
  --Conta cartão: 7563265039137
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1541504;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11751223 AND c.nrconta_cartao = 7563265039137;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11751223 AND d.nrconta_cartao = 7563265039137;
  
  --Conta cartão: 7563265039596
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1556762;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11797185 AND c.nrconta_cartao = 7563265039596;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11797185 AND d.nrconta_cartao = 7563265039596;
  
  --Conta cartão: 7563265040906
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1590162;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11899077 AND c.nrconta_cartao = 7563265040906;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11899077 AND d.nrconta_cartao = 7563265040906;
  
  --Conta cartão: 7563318012243
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1216298;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 16 AND c.nrdconta = 609862 AND c.nrconta_cartao = 7563318012243;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 16 AND d.nrdconta = 609862 AND d.nrconta_cartao = 7563318012243;
  
  --Conta cartão: 7563318016289
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1437857;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11455454 AND c.nrconta_cartao = 7563318016289;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11455454 AND d.nrconta_cartao = 7563318016289;
  
  --Conta cartão: 7563318017084
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1512462;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11665122 AND c.nrconta_cartao = 7563318017084;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11665122 AND d.nrconta_cartao = 7563318017084;
  
  --Conta cartão: 7564416007828
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 323831;
  
  --Conta cartão: 7564416020563
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1099468;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 7831501 AND c.nrconta_cartao = 7564416020563;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 7831501 AND d.nrconta_cartao = 7564416020563;
  
  --Conta cartão: 7564416021545
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1246479;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 7972105 AND c.nrconta_cartao = 7564416021545;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 7972105 AND d.nrconta_cartao = 7564416021545;
  
  --Conta cartão: 7564416022241
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1341879;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 9555145 AND c.nrconta_cartao = 7564416022241;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 9555145 AND d.nrconta_cartao = 7564416022241;
  
  --Conta cartão: 7564416023508
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1512461;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11661690 AND c.nrconta_cartao = 7564416023508;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11661690 AND d.nrconta_cartao = 7564416023508;
  
  --Conta cartão: 7564420052921
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1316186;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11116420 AND c.nrconta_cartao = 7564420052921;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11116420 AND d.nrconta_cartao = 7564420052921;
  
  --Conta cartão: 7564420054364
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1348730;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 10108017 AND c.nrconta_cartao = 7564420054364;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 10108017 AND d.nrconta_cartao = 7564420054364;
  
  --Conta cartão: 7564420056765
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1396804;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 9468552 AND c.nrconta_cartao = 7564420056765;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 9468552 AND d.nrconta_cartao = 7564420056765;
  
  --Conta cartão: 7564420057743
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1422354;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 14 AND c.nrdconta = 158836 AND c.nrconta_cartao = 7564420057743;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 14 AND d.nrdconta = 158836 AND d.nrconta_cartao = 7564420057743;
  
  --Conta cartão: 7564420057981
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1427777;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 9 AND c.nrdconta = 308544 AND c.nrconta_cartao = 7564420057981;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 9 AND d.nrdconta = 308544 AND d.nrconta_cartao = 7564420057981;
  
  --Conta cartão: 7564420061366
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1512845;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11666684 AND c.nrconta_cartao = 7564420061366;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11666684 AND d.nrconta_cartao = 7564420061366;
  
  --Conta cartão: 7564420062234
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1534300;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 8384207 AND c.nrconta_cartao = 7564420062234;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 8384207 AND d.nrconta_cartao = 7564420062234;
  
  --Conta cartão: 7564420063464
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1559948;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 11 AND c.nrdconta = 656348 AND c.nrconta_cartao = 7564420063464;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 11 AND d.nrdconta = 656348 AND d.nrconta_cartao = 7564420063464;
  
  --Conta cartão: 7564420066634
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1622886;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 12006840 AND c.nrconta_cartao = 7564420066634;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 12006840 AND d.nrconta_cartao = 7564420066634;
  
  --Conta cartão: 7564438007237
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 323842;
  
  --Conta cartão: 7564438007241
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 323843;
  
  --Conta cartão: 7564438018828
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 629613;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 11 AND c.nrdconta = 365742 AND c.nrconta_cartao = 7564438018828;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 11 AND d.nrdconta = 365742 AND d.nrconta_cartao = 7564438018828;
  
  --Conta cartão: 7564438043231
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 11 AND c.nrdconta = 596396 AND c.nrconta_cartao = 7564438043231;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 11 AND d.nrdconta = 596396 AND d.nrconta_cartao = 7564438043231;
  
  --Conta cartão: 7564438043849
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1314770;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11108991 AND c.nrconta_cartao = 7564438043849;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11108991 AND d.nrconta_cartao = 7564438043849;
  
  --Conta cartão: 7564438049926
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1519828;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 7195834 AND c.nrconta_cartao = 7564438049926;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 7195834 AND d.nrconta_cartao = 7564438049926;
  
  --Conta cartão: 7564438051327
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1555104;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11791365 AND c.nrconta_cartao = 7564438051327;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11791365 AND d.nrconta_cartao = 7564438051327;
  
  --Conta cartão: 7564438052099
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1572254;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 6 AND c.nrdconta = 204714 AND c.nrconta_cartao = 7564438052099;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 6 AND d.nrdconta = 204714 AND d.nrconta_cartao = 7564438052099;
  
  --Conta cartão: 7564438052169
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1574038;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11850337 AND c.nrconta_cartao = 7564438052169;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11850337 AND d.nrconta_cartao = 7564438052169;
  
  --Conta cartão: 7564444024077
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1457312;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 8272212 AND c.nrconta_cartao = 7564444024077;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 8272212 AND d.nrconta_cartao = 7564444024077;
  
  --Conta cartão: 7564449009468
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1265038;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 13 AND c.nrdconta = 414034 AND c.nrconta_cartao = 7564449009468;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 13 AND d.nrdconta = 414034 AND d.nrconta_cartao = 7564449009468;
  
  --Conta cartão: 7564457029451
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1284569;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 10980890 AND c.nrconta_cartao = 7564457029451;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 10980890 AND d.nrconta_cartao = 7564457029451;
  
  --Conta cartão: 7564457036676
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1553510;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11773367 AND c.nrconta_cartao = 7564457036676;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11773367 AND d.nrconta_cartao = 7564457036676;
  
  --Conta cartão: 7564457038158
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1609114;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 16 AND c.nrdconta = 44873 AND c.nrconta_cartao = 7564457038158;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 16 AND d.nrdconta = 44873 AND d.nrconta_cartao = 7564457038158;
  
  --Conta cartão: 7564468013650
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1457610;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 11508469 AND c.nrconta_cartao = 7564468013650;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 11508469 AND d.nrconta_cartao = 7564468013650;
  
  --Conta cartão: 7564468014784
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 1499821;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 1 AND c.nrdconta = 9016775 AND c.nrconta_cartao = 7564468014784;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 1 AND d.nrdconta = 9016775 AND d.nrconta_cartao = 7564468014784;
  
  --Conta cartão: 7564571000781
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 503822;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 9 AND c.nrdconta = 901423 AND c.nrconta_cartao = 7564571000781;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 9 AND d.nrdconta = 901423 AND d.nrconta_cartao = 7564571000781;
  
  --Conta cartão: 7564571000863
  update crawcrd a set a.insitcrd = 6, a.nrcrcard = 0, a.nrcctitg = 0 where a.progress_recid = 504575;
  DELETE tbcrd_alerta_atraso c WHERE c.cdcooper = 9 AND c.nrdconta = 911143 AND c.nrconta_cartao = 7564571000863;
  DELETE tbcrd_conta_cartao d WHERE d.cdcooper = 9 AND d.nrdconta = 911143 AND d.nrconta_cartao = 7564571000863;
  
  commit;
 
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
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp2       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv2     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp3       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv3     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp4       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv4     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  
  loga('Inicio Processo');
    
  FOR rw_crapcar IN cr_crapcar LOOP
    -- em caso de crítica
    IF vr_dscritic IS NOT NULL THEN        
      RAISE vr_excsaida;
    END IF;
  
    loga('Ajustando a conta ao cartão: Cooper Associada: '|| rw_crapcar.cdcooper || 
                                     ' Cooper Correta: '  || rw_crapcar.coop_certa ||
                                     ' Conta Associada: ' || rw_crapcar.nrdconta ||
                                     ' Conta Correta: '   || rw_crapcar.conta_certa);
 
    -- Gera backup com valor atual do campo - script de rollback
    backup('update tbcrd_utilizacao_cartao set nrdconta = '|| rw_crapcar.nrdconta || ', cdcooper = ' || rw_crapcar.cdcooper ||
           ' where tbcrd_utilizacao_cartao.rowid = '''|| rw_crapcar.rowid ||''';');    
    
    BEGIN
      UPDATE tbcrd_utilizacao_cartao
         SET nrdconta      = rw_crapcar.conta_certa,
             cdCooper      = rw_crapcar.coop_certa
       WHERE tbcrd_utilizacao_cartao.rowid = rw_crapcar.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := ' Erro atualizando tbcrd_utilizacao_cartao!' || 
                       ' Cooper Associada: '|| rw_crapcar.cdcooper || 
                       ' Cooper Correta: '  || rw_crapcar.coop_certa ||
                       ' Conta Associada: ' || rw_crapcar.nrdconta ||
                       ' Conta Correta: '   || rw_crapcar.conta_certa || ' SQLERRM: ' || SQLERRM;
        loga(vr_dscritic);
        falha(vr_dscritic);
        RAISE vr_excsaida;
    END;

    sucesso('Cartão associado a conta correta: Cooper: '|| rw_crapcar.cdcooper || 
            ' Cartão: ' ||rw_crapcar.nrconta_cartao || 
            ' Cooper Errada: '|| rw_crapcar.cdcooper || 
            ' Cooper Correta: '  || rw_crapcar.coop_certa ||
            ' Conta Errada: ' ||rw_crapcar.nrdconta || 
            ' Conta Certa: ' || rw_crapcar.Conta_certa);
  END LOOP;
  
  COMMIT;

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;  

  :vr_dscritic := 'SUCESSO';
  
EXCEPTION
  WHEN vr_excsaida then 
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;
    
  WHEN OTHERS then
    loga(vr_dscritic);
    loga(SQLERRM);
    :vr_dscritic := 'ERRO ' || vr_dscritic;
    rollback;
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv2); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv3); --> Handle do arquivo aberto;  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;
end;
0
0
