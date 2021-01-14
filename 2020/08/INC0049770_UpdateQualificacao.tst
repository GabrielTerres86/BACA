PL/SQL Developer Test script 3.0
2318
/*
Autor: Luiz Otávio Olinger Momm / AMCOM
Analista: Wagner da Silva / AILOS
Task 
Squad Riscos

Objetivo:

- Atualizar as qualidicações das operações efetivadas da conluna crawepr.idquapro
  coletado da tabela crapris_stg migrado no D3 até 30/06/2020 e a partir de 
  01/07/2020 da tabela tbrisco_central_ocr visto que ela tem 60 dias de dados.
*/

declare
  CURSOR cr_operacoes_efetivadas_ativas IS
    SELECT w.cdcooper
         , w.nrdconta
         , w.nrctremp
         , w.nrliquid
         , l.nrctrlim
         , e.dtmvtolt
         , gene0005.fn_valida_dia_util(pr_cdcooper => e.cdcooper
                                      ,pr_dtmvtolt => (e.dtmvtolt - 1)
                                      ,pr_tipo => 'A') diaAnterior
         , w.idquapro /* 2 (0 a 4) 3 (5 a 60) 4 (61 em diante) */
         , r1.qtdiaatr AS atrasoEmADP
         , r2.qtdiaatr AS atrasoEmADPcomLimite
      FROM crawepr w
      LEFT JOIN crapepr e ON w.cdcooper = e.cdcooper
                         AND w.nrdconta = e.nrdconta
                         AND w.nrctremp = e.nrctremp
      LEFT JOIN tbrisco_central_ocr r1 ON r1.dtrefere = gene0005.fn_valida_dia_util(pr_cdcooper => e.cdcooper
                                                                           ,pr_dtmvtolt => (e.dtmvtolt - 1)
                                                                           ,pr_tipo => 'A')
                              AND r1.inddocto = 1
                              AND r1.cdorigem = 1
                              AND r1.cdmodali = 101
                              AND r1.cdcooper = e.cdcooper
                              AND r1.nrdconta = e.nrdconta
                              AND r1.nrctremp = e.nrdconta
      LEFT JOIN tbrisco_central_ocr r2 ON r2.dtrefere = gene0005.fn_valida_dia_util(pr_cdcooper => e.cdcooper
                                                                           ,pr_dtmvtolt => (e.dtmvtolt - 1)
                                                                           ,pr_tipo => 'A')
                              AND r2.inddocto = 1
                              AND r2.cdorigem = 1
                              AND r2.cdmodali = 101
                              AND EXISTS (SELECT 1
                                            FROM tbrisco_central_ocr r3
                                           WHERE r3.cdcooper = r2.cdcooper
                                             AND r3.nrdconta = r2.nrdconta
                                             AND r3.nrctremp = w.nrliquid
                                             AND r3.cdmodali = 201)
                              AND r2.cdcooper = e.cdcooper
                              AND r2.nrdconta = e.nrdconta
                              AND r2.nrctremp = e.nrdconta
      LEFT JOIN craplim l ON w.cdcooper = l.cdcooper AND w.nrdconta = l.nrdconta AND w.nrliquid = l.nrctrlim AND l.tpctrlim = 1
     WHERE e.inliquid = 0
       AND w.nrliquid > 0
       AND w.dtmvtolt >= '01/07/2020' -- a partir dessa data pegar da OCR
       AND (w.nrctrliq##1 + w.nrctrliq##2 + w.nrctrliq##3 + w.nrctrliq##4 + w.nrctrliq##5 + 
            w.nrctrliq##6 + w.nrctrliq##7 + w.nrctrliq##8 + w .nrctrliq##9 + w.nrctrliq##10) = 0
       AND (r1.qtdiaatr IS NOT NULL OR r2.qtdiaatr IS NOT NULL);

  CURSOR cr_crawepr(pr_cdcooper crawepr.cdcooper%TYPE
                   ,pr_nrdconta crawepr.nrdconta%TYPE
                   ,pr_nrctremp crawepr.nrctremp%TYPE) IS
    SELECT w.cdcooper
          ,w.idquapro
      FROM crawepr w
     WHERE w.cdcooper = pr_cdcooper
       AND w.nrdconta = pr_nrdconta
       AND w.nrctremp = pr_nrctremp;
  rw_crawepr cr_crawepr%ROWTYPE;

  TYPE typ_contrato IS RECORD (
    cdcooper crawepr.cdcooper%TYPE,
    nrdconta crawepr.nrdconta%TYPE,
    nrctremp crawepr.nrctremp%TYPE,
    idquapro crawepr.idquapro%TYPE);

  TYPE typ_contratos IS
    TABLE OF typ_contrato
      INDEX BY VARCHAR2(50);

  qualContr    typ_contratos;
  vr_cdcritic  NUMBER;
  vr_dscritic  VARCHAR2(2000);

  vr_idquapro  NUMBER;
  vr_dsquapro  VARCHAR2(2000);

  vr_incidente VARCHAR2(50);
  vr_index     VARCHAR2(50);

  vr_dsdireto             VARCHAR2(4000);
  vr_dirname              VARCHAR2(100);

  vr_des_log              CLOB;
  vr_des_rel              CLOB;
  vr_des_erro             CLOB;

  vr_qualificacao         NUMBER;

  vr_texto_rollback       VARCHAR2(32600);
  vr_texto_relatorio      VARCHAR2(32600);
  vr_texto_erro           VARCHAR2(32600);

  vr_typ_saida            VARCHAR2(3);

  PROCEDURE pc_escreve_rollback(pr_des_dados IN VARCHAR2,
                                pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_log, vr_texto_rollback, pr_des_dados || chr(10), pr_fecha_xml);
  END;

  PROCEDURE pc_escreve_relatorio(pr_des_dados IN VARCHAR2,
                                 pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    dbms_output.put_line(pr_des_dados);
    gene0002.pc_escreve_xml(vr_des_rel, vr_texto_relatorio, pr_des_dados || chr(10), pr_fecha_xml);
  END;

  PROCEDURE pc_escreve_erro(pr_des_dados IN VARCHAR2,
                            pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_erro, vr_texto_erro, pr_des_dados || chr(10), pr_fecha_xml);
  END;

  PROCEDURE qualificarOperacao(qtdDiasADP          IN NUMBER DEFAULT NULL
                              ,qtdDiasADPComLimite IN NUMBER DEFAULT NULL
                              ,qualificacao       OUT NUMBER) IS
  BEGIN
    /*
       1 - Operacao Normal
       2 - Renovacao de credito     (0 a 4)
       3 - Renegociacao de credito  (5 a 60)
       4 - Composicao de divida     (61 em diante)
       5 - Cessao de cartao
    */

    qualificacao := 2;
    IF qtdDiasADP IS NOT NULL THEN
      IF qtdDiasADP BETWEEN 0 AND 4 THEN
        qualificacao := 2;
      ELSIF qtdDiasADP BETWEEN 5 AND 60 THEN
        qualificacao := 3;
      ELSE
        qualificacao := 4;
      END IF;
    END IF;

    IF qtdDiasADPComLimite IS NOT NULL THEN
      IF qtdDiasADPComLimite BETWEEN 0 AND 4 THEN
        qualificacao := 2;
      ELSIF qtdDiasADPComLimite BETWEEN 5 AND 60 THEN
        qualificacao := 3;
      ELSE
        qualificacao := 4;
      END IF;
    END IF;

  END qualificarOperacao;

  PROCEDURE pc_carrega_dados IS
  BEGIN
    qualContr('00100035285370001121564').cdcooper := 1;qualContr('00100035285370001121564').nrdconta := 3528537;qualContr('00100035285370001121564').nrctremp := 1121564;qualContr('00100035285370001121564').idquapro := 2;
    qualContr('00100082844900001129378').cdcooper := 1;qualContr('00100082844900001129378').nrdconta := 8284490;qualContr('00100082844900001129378').nrctremp := 1129378;qualContr('00100082844900001129378').idquapro := 3;
    qualContr('00100020756870001129827').cdcooper := 1;qualContr('00100020756870001129827').nrdconta := 2075687;qualContr('00100020756870001129827').nrctremp := 1129827;qualContr('00100020756870001129827').idquapro := 3;
    qualContr('00100008328800001137963').cdcooper := 1;qualContr('00100008328800001137963').nrdconta := 832880;qualContr('00100008328800001137963').nrctremp := 1137963;qualContr('00100008328800001137963').idquapro := 2;
    qualContr('00100040011090001142105').cdcooper := 1;qualContr('00100040011090001142105').nrdconta := 4001109;qualContr('00100040011090001142105').nrctremp := 1142105;qualContr('00100040011090001142105').idquapro := 4;
    qualContr('00100081587380001151913').cdcooper := 1;qualContr('00100081587380001151913').nrdconta := 8158738;qualContr('00100081587380001151913').nrctremp := 1151913;qualContr('00100081587380001151913').idquapro := 2;
    qualContr('00100084743620001156233').cdcooper := 1;qualContr('00100084743620001156233').nrdconta := 8474362;qualContr('00100084743620001156233').nrctremp := 1156233;qualContr('00100084743620001156233').idquapro := 2;
    qualContr('00100077209550000190421').cdcooper := 1;qualContr('00100077209550000190421').nrdconta := 7720955;qualContr('00100077209550000190421').nrctremp := 190421;qualContr('00100077209550000190421').idquapro := 3;
    qualContr('00100080470900001210029').cdcooper := 1;qualContr('00100080470900001210029').nrdconta := 8047090;qualContr('00100080470900001210029').nrctremp := 1210029;qualContr('00100080470900001210029').idquapro := 4;
    qualContr('00100022438900001210526').cdcooper := 1;qualContr('00100022438900001210526').nrdconta := 2243890;qualContr('00100022438900001210526').nrctremp := 1210526;qualContr('00100022438900001210526').idquapro := 3;
    qualContr('00100077470120001213438').cdcooper := 1;qualContr('00100077470120001213438').nrdconta := 7747012;qualContr('00100077470120001213438').nrctremp := 1213438;qualContr('00100077470120001213438').idquapro := 3;
    qualContr('00100022161320001217224').cdcooper := 1;qualContr('00100022161320001217224').nrdconta := 2216132;qualContr('00100022161320001217224').nrctremp := 1217224;qualContr('00100022161320001217224').idquapro := 3;
    qualContr('00100072274690001217163').cdcooper := 1;qualContr('00100072274690001217163').nrdconta := 7227469;qualContr('00100072274690001217163').nrctremp := 1217163;qualContr('00100072274690001217163').idquapro := 3;
    qualContr('00100061983090001224792').cdcooper := 1;qualContr('00100061983090001224792').nrdconta := 6198309;qualContr('00100061983090001224792').nrctremp := 1224792;qualContr('00100061983090001224792').idquapro := 3;
    qualContr('00100019717860001229996').cdcooper := 1;qualContr('00100019717860001229996').nrdconta := 1971786;qualContr('00100019717860001229996').nrctremp := 1229996;qualContr('00100019717860001229996').idquapro := 3;
    qualContr('00100024202010001230518').cdcooper := 1;qualContr('00100024202010001230518').nrdconta := 2420201;qualContr('00100024202010001230518').nrctremp := 1230518;qualContr('00100024202010001230518').idquapro := 3;
    qualContr('00100025205320001236626').cdcooper := 1;qualContr('00100025205320001236626').nrdconta := 2520532;qualContr('00100025205320001236626').nrctremp := 1236626;qualContr('00100025205320001236626').idquapro := 2;
    qualContr('00100072038530001239825').cdcooper := 1;qualContr('00100072038530001239825').nrdconta := 7203853;qualContr('00100072038530001239825').nrctremp := 1239825;qualContr('00100072038530001239825').idquapro := 3;
    qualContr('00100025328910001252192').cdcooper := 1;qualContr('00100025328910001252192').nrdconta := 2532891;qualContr('00100025328910001252192').nrctremp := 1252192;qualContr('00100025328910001252192').idquapro := 4;
    qualContr('00100086116700001261060').cdcooper := 1;qualContr('00100086116700001261060').nrdconta := 8611670;qualContr('00100086116700001261060').nrctremp := 1261060;qualContr('00100086116700001261060').idquapro := 3;
    qualContr('00100038159270001264249').cdcooper := 1;qualContr('00100038159270001264249').nrdconta := 3815927;qualContr('00100038159270001264249').nrctremp := 1264249;qualContr('00100038159270001264249').idquapro := 3;
    qualContr('00100024900300001269335').cdcooper := 1;qualContr('00100024900300001269335').nrdconta := 2490030;qualContr('00100024900300001269335').nrctremp := 1269335;qualContr('00100024900300001269335').idquapro := 2;
    qualContr('00100095560100001276999').cdcooper := 1;qualContr('00100095560100001276999').nrdconta := 9556010;qualContr('00100095560100001276999').nrctremp := 1276999;qualContr('00100095560100001276999').idquapro := 3;
    qualContr('00100088174210001279107').cdcooper := 1;qualContr('00100088174210001279107').nrdconta := 8817421;qualContr('00100088174210001279107').nrctremp := 1279107;qualContr('00100088174210001279107').idquapro := 3;
    qualContr('00100087231090001280568').cdcooper := 1;qualContr('00100087231090001280568').nrdconta := 8723109;qualContr('00100087231090001280568').nrctremp := 1280568;qualContr('00100087231090001280568').idquapro := 3;
    qualContr('00100013259900001282072').cdcooper := 1;qualContr('00100013259900001282072').nrdconta := 1325990;qualContr('00100013259900001282072').nrctremp := 1282072;qualContr('00100013259900001282072').idquapro := 3;
    qualContr('00100019936400001289775').cdcooper := 1;qualContr('00100019936400001289775').nrdconta := 1993640;qualContr('00100019936400001289775').nrctremp := 1289775;qualContr('00100019936400001289775').idquapro := 3;
    qualContr('00100030037280001290151').cdcooper := 1;qualContr('00100030037280001290151').nrdconta := 3003728;qualContr('00100030037280001290151').nrctremp := 1290151;qualContr('00100030037280001290151').idquapro := 3;
    qualContr('00100021836920001289673').cdcooper := 1;qualContr('00100021836920001289673').nrdconta := 2183692;qualContr('00100021836920001289673').nrctremp := 1289673;qualContr('00100021836920001289673').idquapro := 3;
    qualContr('00100000032550001293002').cdcooper := 1;qualContr('00100000032550001293002').nrdconta := 3255;qualContr('00100000032550001293002').nrctremp := 1293002;qualContr('00100000032550001293002').idquapro := 3;
    qualContr('00100038246750001303717').cdcooper := 1;qualContr('00100038246750001303717').nrdconta := 3824675;qualContr('00100038246750001303717').nrctremp := 1303717;qualContr('00100038246750001303717').idquapro := 3;
    qualContr('00100079994530001310909').cdcooper := 1;qualContr('00100079994530001310909').nrdconta := 7999453;qualContr('00100079994530001310909').nrctremp := 1310909;qualContr('00100079994530001310909').idquapro := 3;
    qualContr('00100078572500001314478').cdcooper := 1;qualContr('00100078572500001314478').nrdconta := 7857250;qualContr('00100078572500001314478').nrctremp := 1314478;qualContr('00100078572500001314478').idquapro := 3;
    qualContr('00100080219610001315734').cdcooper := 1;qualContr('00100080219610001315734').nrdconta := 8021961;qualContr('00100080219610001315734').nrctremp := 1315734;qualContr('00100080219610001315734').idquapro := 3;
    qualContr('00100027067760001315326').cdcooper := 1;qualContr('00100027067760001315326').nrdconta := 2706776;qualContr('00100027067760001315326').nrctremp := 1315326;qualContr('00100027067760001315326').idquapro := 3;
    qualContr('00100064613280001316510').cdcooper := 1;qualContr('00100064613280001316510').nrdconta := 6461328;qualContr('00100064613280001316510').nrctremp := 1316510;qualContr('00100064613280001316510').idquapro := 3;
    qualContr('00100093846500001322197').cdcooper := 1;qualContr('00100093846500001322197').nrdconta := 9384650;qualContr('00100093846500001322197').nrctremp := 1322197;qualContr('00100093846500001322197').idquapro := 3;
    qualContr('00100066378410001324654').cdcooper := 1;qualContr('00100066378410001324654').nrdconta := 6637841;qualContr('00100066378410001324654').nrctremp := 1324654;qualContr('00100066378410001324654').idquapro := 3;
    qualContr('00100037489520001324265').cdcooper := 1;qualContr('00100037489520001324265').nrdconta := 3748952;qualContr('00100037489520001324265').nrctremp := 1324265;qualContr('00100037489520001324265').idquapro := 3;
    qualContr('00100063446310001326229').cdcooper := 1;qualContr('00100063446310001326229').nrdconta := 6344631;qualContr('00100063446310001326229').nrctremp := 1326229;qualContr('00100063446310001326229').idquapro := 3;
    qualContr('00100072770590001333504').cdcooper := 1;qualContr('00100072770590001333504').nrdconta := 7277059;qualContr('00100072770590001333504').nrctremp := 1333504;qualContr('00100072770590001333504').idquapro := 3;
    qualContr('00100026041910001335953').cdcooper := 1;qualContr('00100026041910001335953').nrdconta := 2604191;qualContr('00100026041910001335953').nrctremp := 1335953;qualContr('00100026041910001335953').idquapro := 3;
    qualContr('00100061826580001339505').cdcooper := 1;qualContr('00100061826580001339505').nrdconta := 6182658;qualContr('00100061826580001339505').nrctremp := 1339505;qualContr('00100061826580001339505').idquapro := 3;
    qualContr('00100085014400001342820').cdcooper := 1;qualContr('00100085014400001342820').nrdconta := 8501440;qualContr('00100085014400001342820').nrctremp := 1342820;qualContr('00100085014400001342820').idquapro := 3;
    qualContr('00100069873110001342534').cdcooper := 1;qualContr('00100069873110001342534').nrdconta := 6987311;qualContr('00100069873110001342534').nrctremp := 1342534;qualContr('00100069873110001342534').idquapro := 3;
    qualContr('00100021485870001341958').cdcooper := 1;qualContr('00100021485870001341958').nrdconta := 2148587;qualContr('00100021485870001341958').nrctremp := 1341958;qualContr('00100021485870001341958').idquapro := 3;
    qualContr('00100023327870001346743').cdcooper := 1;qualContr('00100023327870001346743').nrdconta := 2332787;qualContr('00100023327870001346743').nrctremp := 1346743;qualContr('00100023327870001346743').idquapro := 3;
    qualContr('00100037279710001346644').cdcooper := 1;qualContr('00100037279710001346644').nrdconta := 3727971;qualContr('00100037279710001346644').nrctremp := 1346644;qualContr('00100037279710001346644').idquapro := 3;
    qualContr('00100075939290001350802').cdcooper := 1;qualContr('00100075939290001350802').nrdconta := 7593929;qualContr('00100075939290001350802').nrctremp := 1350802;qualContr('00100075939290001350802').idquapro := 3;
    qualContr('00100024887100001350714').cdcooper := 1;qualContr('00100024887100001350714').nrdconta := 2488710;qualContr('00100024887100001350714').nrctremp := 1350714;qualContr('00100024887100001350714').idquapro := 3;
    qualContr('00100074650090001352620').cdcooper := 1;qualContr('00100074650090001352620').nrdconta := 7465009;qualContr('00100074650090001352620').nrctremp := 1352620;qualContr('00100074650090001352620').idquapro := 3;
    qualContr('00100065172000001351796').cdcooper := 1;qualContr('00100065172000001351796').nrdconta := 6517200;qualContr('00100065172000001351796').nrctremp := 1351796;qualContr('00100065172000001351796').idquapro := 3;
    qualContr('00100037636330001352594').cdcooper := 1;qualContr('00100037636330001352594').nrdconta := 3763633;qualContr('00100037636330001352594').nrctremp := 1352594;qualContr('00100037636330001352594').idquapro := 3;
    qualContr('00100061682800001355452').cdcooper := 1;qualContr('00100061682800001355452').nrdconta := 6168280;qualContr('00100061682800001355452').nrctremp := 1355452;qualContr('00100061682800001355452').idquapro := 3;
    qualContr('00100069397400001356478').cdcooper := 1;qualContr('00100069397400001356478').nrdconta := 6939740;qualContr('00100069397400001356478').nrctremp := 1356478;qualContr('00100069397400001356478').idquapro := 3;
    qualContr('00100067600900001356741').cdcooper := 1;qualContr('00100067600900001356741').nrdconta := 6760090;qualContr('00100067600900001356741').nrctremp := 1356741;qualContr('00100067600900001356741').idquapro := 3;
    qualContr('00100091420960001357062').cdcooper := 1;qualContr('00100091420960001357062').nrdconta := 9142096;qualContr('00100091420960001357062').nrctremp := 1357062;qualContr('00100091420960001357062').idquapro := 3;
    qualContr('00100066790050001357823').cdcooper := 1;qualContr('00100066790050001357823').nrdconta := 6679005;qualContr('00100066790050001357823').nrctremp := 1357823;qualContr('00100066790050001357823').idquapro := 3;
    qualContr('00100066790050001357836').cdcooper := 1;qualContr('00100066790050001357836').nrdconta := 6679005;qualContr('00100066790050001357836').nrctremp := 1357836;qualContr('00100066790050001357836').idquapro := 3;
    qualContr('00100063913620001358283').cdcooper := 1;qualContr('00100063913620001358283').nrdconta := 6391362;qualContr('00100063913620001358283').nrctremp := 1358283;qualContr('00100063913620001358283').idquapro := 3;
    qualContr('00100085518390001358962').cdcooper := 1;qualContr('00100085518390001358962').nrdconta := 8551839;qualContr('00100085518390001358962').nrctremp := 1358962;qualContr('00100085518390001358962').idquapro := 3;
    qualContr('00100065844030001360772').cdcooper := 1;qualContr('00100065844030001360772').nrdconta := 6584403;qualContr('00100065844030001360772').nrctremp := 1360772;qualContr('00100065844030001360772').idquapro := 3;
    qualContr('00100071014650001361570').cdcooper := 1;qualContr('00100071014650001361570').nrdconta := 7101465;qualContr('00100071014650001361570').nrctremp := 1361570;qualContr('00100071014650001361570').idquapro := 3;
    qualContr('00100022735860001361923').cdcooper := 1;qualContr('00100022735860001361923').nrdconta := 2273586;qualContr('00100022735860001361923').nrctremp := 1361923;qualContr('00100022735860001361923').idquapro := 3;
    qualContr('00100094020710001367751').cdcooper := 1;qualContr('00100094020710001367751').nrdconta := 9402071;qualContr('00100094020710001367751').nrctremp := 1367751;qualContr('00100094020710001367751').idquapro := 3;
    qualContr('00100075923530001367797').cdcooper := 1;qualContr('00100075923530001367797').nrdconta := 7592353;qualContr('00100075923530001367797').nrctremp := 1367797;qualContr('00100075923530001367797').idquapro := 3;
    qualContr('00100061478950001369178').cdcooper := 1;qualContr('00100061478950001369178').nrdconta := 6147895;qualContr('00100061478950001369178').nrctremp := 1369178;qualContr('00100061478950001369178').idquapro := 3;
    qualContr('00100072007900001368826').cdcooper := 1;qualContr('00100072007900001368826').nrdconta := 7200790;qualContr('00100072007900001368826').nrctremp := 1368826;qualContr('00100072007900001368826').idquapro := 3;
    qualContr('00100030667030001370439').cdcooper := 1;qualContr('00100030667030001370439').nrdconta := 3066703;qualContr('00100030667030001370439').nrctremp := 1370439;qualContr('00100030667030001370439').idquapro := 3;
    qualContr('00100073682320001370118').cdcooper := 1;qualContr('00100073682320001370118').nrdconta := 7368232;qualContr('00100073682320001370118').nrctremp := 1370118;qualContr('00100073682320001370118').idquapro := 3;
    qualContr('00100022724070001371914').cdcooper := 1;qualContr('00100022724070001371914').nrdconta := 2272407;qualContr('00100022724070001371914').nrctremp := 1371914;qualContr('00100022724070001371914').idquapro := 3;
    qualContr('00100077146530001371983').cdcooper := 1;qualContr('00100077146530001371983').nrdconta := 7714653;qualContr('00100077146530001371983').nrctremp := 1371983;qualContr('00100077146530001371983').idquapro := 3;
    qualContr('00100084483290001378260').cdcooper := 1;qualContr('00100084483290001378260').nrdconta := 8448329;qualContr('00100084483290001378260').nrctremp := 1378260;qualContr('00100084483290001378260').idquapro := 3;
    qualContr('00100090664380001383869').cdcooper := 1;qualContr('00100090664380001383869').nrdconta := 9066438;qualContr('00100090664380001383869').nrctremp := 1383869;qualContr('00100090664380001383869').idquapro := 3;
    qualContr('00100086926880001384197').cdcooper := 1;qualContr('00100086926880001384197').nrdconta := 8692688;qualContr('00100086926880001384197').nrctremp := 1384197;qualContr('00100086926880001384197').idquapro := 4;
    qualContr('00100068350070001385937').cdcooper := 1;qualContr('00100068350070001385937').nrdconta := 6835007;qualContr('00100068350070001385937').nrctremp := 1385937;qualContr('00100068350070001385937').idquapro := 3;
    qualContr('00100078505220001386309').cdcooper := 1;qualContr('00100078505220001386309').nrdconta := 7850522;qualContr('00100078505220001386309').nrctremp := 1386309;qualContr('00100078505220001386309').idquapro := 3;
    qualContr('00100075422400001387254').cdcooper := 1;qualContr('00100075422400001387254').nrdconta := 7542240;qualContr('00100075422400001387254').nrctremp := 1387254;qualContr('00100075422400001387254').idquapro := 3;
    qualContr('00100080525300001388622').cdcooper := 1;qualContr('00100080525300001388622').nrdconta := 8052530;qualContr('00100080525300001388622').nrctremp := 1388622;qualContr('00100080525300001388622').idquapro := 3;
    qualContr('00100077184700001391540').cdcooper := 1;qualContr('00100077184700001391540').nrdconta := 7718470;qualContr('00100077184700001391540').nrctremp := 1391540;qualContr('00100077184700001391540').idquapro := 3;
    qualContr('00100076786730001393545').cdcooper := 1;qualContr('00100076786730001393545').nrdconta := 7678673;qualContr('00100076786730001393545').nrctremp := 1393545;qualContr('00100076786730001393545').idquapro := 3;
    qualContr('00100007121080001395932').cdcooper := 1;qualContr('00100007121080001395932').nrdconta := 712108;qualContr('00100007121080001395932').nrctremp := 1395932;qualContr('00100007121080001395932').idquapro := 3;
    qualContr('00100007121080001395923').cdcooper := 1;qualContr('00100007121080001395923').nrdconta := 712108;qualContr('00100007121080001395923').nrctremp := 1395923;qualContr('00100007121080001395923').idquapro := 3;
    qualContr('00100096243170001403045').cdcooper := 1;qualContr('00100096243170001403045').nrdconta := 9624317;qualContr('00100096243170001403045').nrctremp := 1403045;qualContr('00100096243170001403045').idquapro := 4;
    qualContr('00100085574540001408482').cdcooper := 1;qualContr('00100085574540001408482').nrdconta := 8557454;qualContr('00100085574540001408482').nrctremp := 1408482;qualContr('00100085574540001408482').idquapro := 3;
    qualContr('00100076599030001409973').cdcooper := 1;qualContr('00100076599030001409973').nrdconta := 7659903;qualContr('00100076599030001409973').nrctremp := 1409973;qualContr('00100076599030001409973').idquapro := 4;
    qualContr('00100083937450001411085').cdcooper := 1;qualContr('00100083937450001411085').nrdconta := 8393745;qualContr('00100083937450001411085').nrctremp := 1411085;qualContr('00100083937450001411085').idquapro := 3;
    qualContr('00100021212120001413057').cdcooper := 1;qualContr('00100021212120001413057').nrdconta := 2121212;qualContr('00100021212120001413057').nrctremp := 1413057;qualContr('00100021212120001413057').idquapro := 3;
    qualContr('00100021212120001413064').cdcooper := 1;qualContr('00100021212120001413064').nrdconta := 2121212;qualContr('00100021212120001413064').nrctremp := 1413064;qualContr('00100021212120001413064').idquapro := 3;
    qualContr('00100067887930001414994').cdcooper := 1;qualContr('00100067887930001414994').nrdconta := 6788793;qualContr('00100067887930001414994').nrctremp := 1414994;qualContr('00100067887930001414994').idquapro := 3;
    qualContr('00100063893680001417155').cdcooper := 1;qualContr('00100063893680001417155').nrdconta := 6389368;qualContr('00100063893680001417155').nrctremp := 1417155;qualContr('00100063893680001417155').idquapro := 3;
    qualContr('00100804700500001418966').cdcooper := 1;qualContr('00100804700500001418966').nrdconta := 80470050;qualContr('00100804700500001418966').nrctremp := 1418966;qualContr('00100804700500001418966').idquapro := 3;
    qualContr('00100070578140001419499').cdcooper := 1;qualContr('00100070578140001419499').nrdconta := 7057814;qualContr('00100070578140001419499').nrctremp := 1419499;qualContr('00100070578140001419499').idquapro := 3;
    qualContr('00100093676400001420176').cdcooper := 1;qualContr('00100093676400001420176').nrdconta := 9367640;qualContr('00100093676400001420176').nrctremp := 1420176;qualContr('00100093676400001420176').idquapro := 3;
    qualContr('00100077392730001421204').cdcooper := 1;qualContr('00100077392730001421204').nrdconta := 7739273;qualContr('00100077392730001421204').nrctremp := 1421204;qualContr('00100077392730001421204').idquapro := 3;
    qualContr('00100061998360001422251').cdcooper := 1;qualContr('00100061998360001422251').nrdconta := 6199836;qualContr('00100061998360001422251').nrctremp := 1422251;qualContr('00100061998360001422251').idquapro := 4;
    qualContr('00100093737640001425937').cdcooper := 1;qualContr('00100093737640001425937').nrdconta := 9373764;qualContr('00100093737640001425937').nrctremp := 1425937;qualContr('00100093737640001425937').idquapro := 4;
    qualContr('00100063494390001424826').cdcooper := 1;qualContr('00100063494390001424826').nrdconta := 6349439;qualContr('00100063494390001424826').nrctremp := 1424826;qualContr('00100063494390001424826').idquapro := 3;
    qualContr('00100098651100001427279').cdcooper := 1;qualContr('00100098651100001427279').nrdconta := 9865110;qualContr('00100098651100001427279').nrctremp := 1427279;qualContr('00100098651100001427279').idquapro := 3;
    qualContr('00100802719520001427674').cdcooper := 1;qualContr('00100802719520001427674').nrdconta := 80271952;qualContr('00100802719520001427674').nrctremp := 1427674;qualContr('00100802719520001427674').idquapro := 3;
    qualContr('00100022741240001431890').cdcooper := 1;qualContr('00100022741240001431890').nrdconta := 2274124;qualContr('00100022741240001431890').nrctremp := 1431890;qualContr('00100022741240001431890').idquapro := 3;
    qualContr('00100013255400001435140').cdcooper := 1;qualContr('00100013255400001435140').nrdconta := 1325540;qualContr('00100013255400001435140').nrctremp := 1435140;qualContr('00100013255400001435140').idquapro := 3;
    qualContr('00100009259770001435458').cdcooper := 1;qualContr('00100009259770001435458').nrdconta := 925977;qualContr('00100009259770001435458').nrctremp := 1435458;qualContr('00100009259770001435458').idquapro := 3;
    qualContr('00100038166050001439395').cdcooper := 1;qualContr('00100038166050001439395').nrdconta := 3816605;qualContr('00100038166050001439395').nrctremp := 1439395;qualContr('00100038166050001439395').idquapro := 3;
    qualContr('00100100327380001442487').cdcooper := 1;qualContr('00100100327380001442487').nrdconta := 10032738;qualContr('00100100327380001442487').nrctremp := 1442487;qualContr('00100100327380001442487').idquapro := 3;
    qualContr('00100093060640001441834').cdcooper := 1;qualContr('00100093060640001441834').nrdconta := 9306064;qualContr('00100093060640001441834').nrctremp := 1441834;qualContr('00100093060640001441834').idquapro := 4;
    qualContr('00100100320290001442728').cdcooper := 1;qualContr('00100100320290001442728').nrdconta := 10032029;qualContr('00100100320290001442728').nrctremp := 1442728;qualContr('00100100320290001442728').idquapro := 3;
    qualContr('00100038175120001445428').cdcooper := 1;qualContr('00100038175120001445428').nrdconta := 3817512;qualContr('00100038175120001445428').nrctremp := 1445428;qualContr('00100038175120001445428').idquapro := 3;
    qualContr('00100040870890001448867').cdcooper := 1;qualContr('00100040870890001448867').nrdconta := 4087089;qualContr('00100040870890001448867').nrctremp := 1448867;qualContr('00100040870890001448867').idquapro := 3;
    qualContr('00100082590030001448478').cdcooper := 1;qualContr('00100082590030001448478').nrdconta := 8259003;qualContr('00100082590030001448478').nrctremp := 1448478;qualContr('00100082590030001448478').idquapro := 3;
    qualContr('00100070477620001450960').cdcooper := 1;qualContr('00100070477620001450960').nrdconta := 7047762;qualContr('00100070477620001450960').nrctremp := 1450960;qualContr('00100070477620001450960').idquapro := 3;
    qualContr('00100030787280001451598').cdcooper := 1;qualContr('00100030787280001451598').nrdconta := 3078728;qualContr('00100030787280001451598').nrctremp := 1451598;qualContr('00100030787280001451598').idquapro := 4;
    qualContr('00100089415640001451102').cdcooper := 1;qualContr('00100089415640001451102').nrdconta := 8941564;qualContr('00100089415640001451102').nrctremp := 1451102;qualContr('00100089415640001451102').idquapro := 3;
    qualContr('00100073239990001451781').cdcooper := 1;qualContr('00100073239990001451781').nrdconta := 7323999;qualContr('00100073239990001451781').nrctremp := 1451781;qualContr('00100073239990001451781').idquapro := 3;
    qualContr('00100022952370001453419').cdcooper := 1;qualContr('00100022952370001453419').nrdconta := 2295237;qualContr('00100022952370001453419').nrctremp := 1453419;qualContr('00100022952370001453419').idquapro := 3;
    qualContr('00100024138840001453884').cdcooper := 1;qualContr('00100024138840001453884').nrdconta := 2413884;qualContr('00100024138840001453884').nrctremp := 1453884;qualContr('00100024138840001453884').idquapro := 3;
    qualContr('00100030003030001453230').cdcooper := 1;qualContr('00100030003030001453230').nrdconta := 3000303;qualContr('00100030003030001453230').nrctremp := 1453230;qualContr('00100030003030001453230').idquapro := 3;
    qualContr('00100089209660001452838').cdcooper := 1;qualContr('00100089209660001452838').nrdconta := 8920966;qualContr('00100089209660001452838').nrctremp := 1452838;qualContr('00100089209660001452838').idquapro := 3;
    qualContr('00100064963690001452477').cdcooper := 1;qualContr('00100064963690001452477').nrdconta := 6496369;qualContr('00100064963690001452477').nrctremp := 1452477;qualContr('00100064963690001452477').idquapro := 3;
    qualContr('00100069300690001452609').cdcooper := 1;qualContr('00100069300690001452609').nrdconta := 6930069;qualContr('00100069300690001452609').nrctremp := 1452609;qualContr('00100069300690001452609').idquapro := 3;
    qualContr('00100741379210001453703').cdcooper := 1;qualContr('00100741379210001453703').nrdconta := 74137921;qualContr('00100741379210001453703').nrctremp := 1453703;qualContr('00100741379210001453703').idquapro := 3;
    qualContr('00100022952370001453406').cdcooper := 1;qualContr('00100022952370001453406').nrdconta := 2295237;qualContr('00100022952370001453406').nrctremp := 1453406;qualContr('00100022952370001453406').idquapro := 3;
    qualContr('00100061923000001456468').cdcooper := 1;qualContr('00100061923000001456468').nrdconta := 6192300;qualContr('00100061923000001456468').nrctremp := 1456468;qualContr('00100061923000001456468').idquapro := 4;
    qualContr('00100101327080001455973').cdcooper := 1;qualContr('00100101327080001455973').nrdconta := 10132708;qualContr('00100101327080001455973').nrctremp := 1455973;qualContr('00100101327080001455973').idquapro := 3;
    qualContr('00100096016000001456062').cdcooper := 1;qualContr('00100096016000001456062').nrdconta := 9601600;qualContr('00100096016000001456062').nrctremp := 1456062;qualContr('00100096016000001456062').idquapro := 3;
    qualContr('00100067709160001455579').cdcooper := 1;qualContr('00100067709160001455579').nrdconta := 6770916;qualContr('00100067709160001455579').nrctremp := 1455579;qualContr('00100067709160001455579').idquapro := 3;
    qualContr('00100064666480001456769').cdcooper := 1;qualContr('00100064666480001456769').nrdconta := 6466648;qualContr('00100064666480001456769').nrctremp := 1456769;qualContr('00100064666480001456769').idquapro := 3;
    qualContr('00100100624830001457184').cdcooper := 1;qualContr('00100100624830001457184').nrdconta := 10062483;qualContr('00100100624830001457184').nrctremp := 1457184;qualContr('00100100624830001457184').idquapro := 3;
    qualContr('00100061411960001457262').cdcooper := 1;qualContr('00100061411960001457262').nrdconta := 6141196;qualContr('00100061411960001457262').nrctremp := 1457262;qualContr('00100061411960001457262').idquapro := 3;
    qualContr('00100035421810001458642').cdcooper := 1;qualContr('00100035421810001458642').nrdconta := 3542181;qualContr('00100035421810001458642').nrctremp := 1458642;qualContr('00100035421810001458642').idquapro := 3;
    qualContr('00100080520420001458877').cdcooper := 1;qualContr('00100080520420001458877').nrdconta := 8052042;qualContr('00100080520420001458877').nrctremp := 1458877;qualContr('00100080520420001458877').idquapro := 4;
    qualContr('00100005093290001460408').cdcooper := 1;qualContr('00100005093290001460408').nrdconta := 509329;qualContr('00100005093290001460408').nrctremp := 1460408;qualContr('00100005093290001460408').idquapro := 3;
    qualContr('00100030204870001464619').cdcooper := 1;qualContr('00100030204870001464619').nrdconta := 3020487;qualContr('00100030204870001464619').nrctremp := 1464619;qualContr('00100030204870001464619').idquapro := 3;
    qualContr('00100061273710001464448').cdcooper := 1;qualContr('00100061273710001464448').nrdconta := 6127371;qualContr('00100061273710001464448').nrctremp := 1464448;qualContr('00100061273710001464448').idquapro := 3;
    qualContr('00100038447730001466120').cdcooper := 1;qualContr('00100038447730001466120').nrdconta := 3844773;qualContr('00100038447730001466120').nrctremp := 1466120;qualContr('00100038447730001466120').idquapro := 3;
    qualContr('00100096676600001465415').cdcooper := 1;qualContr('00100096676600001465415').nrdconta := 9667660;qualContr('00100096676600001465415').nrctremp := 1465415;qualContr('00100096676600001465415').idquapro := 3;
    qualContr('00100061537040001469455').cdcooper := 1;qualContr('00100061537040001469455').nrdconta := 6153704;qualContr('00100061537040001469455').nrctremp := 1469455;qualContr('00100061537040001469455').idquapro := 3;
    qualContr('00100037557970001471009').cdcooper := 1;qualContr('00100037557970001471009').nrdconta := 3755797;qualContr('00100037557970001471009').nrctremp := 1471009;qualContr('00100037557970001471009').idquapro := 3;
    qualContr('00100090973170001470365').cdcooper := 1;qualContr('00100090973170001470365').nrdconta := 9097317;qualContr('00100090973170001470365').nrctremp := 1470365;qualContr('00100090973170001470365').idquapro := 3;
    qualContr('00100037557970001471003').cdcooper := 1;qualContr('00100037557970001471003').nrdconta := 3755797;qualContr('00100037557970001471003').nrctremp := 1471003;qualContr('00100037557970001471003').idquapro := 3;
    qualContr('00100031375970001470976').cdcooper := 1;qualContr('00100031375970001470976').nrdconta := 3137597;qualContr('00100031375970001470976').nrctremp := 1470976;qualContr('00100031375970001470976').idquapro := 3;
    qualContr('00100089151480001472311').cdcooper := 1;qualContr('00100089151480001472311').nrdconta := 8915148;qualContr('00100089151480001472311').nrctremp := 1472311;qualContr('00100089151480001472311').idquapro := 4;
    qualContr('00100098490090001473092').cdcooper := 1;qualContr('00100098490090001473092').nrdconta := 9849009;qualContr('00100098490090001473092').nrctremp := 1473092;qualContr('00100098490090001473092').idquapro := 3;
    qualContr('00100081597180001477638').cdcooper := 1;qualContr('00100081597180001477638').nrdconta := 8159718;qualContr('00100081597180001477638').nrctremp := 1477638;qualContr('00100081597180001477638').idquapro := 3;
    qualContr('00100086815700001478796').cdcooper := 1;qualContr('00100086815700001478796').nrdconta := 8681570;qualContr('00100086815700001478796').nrctremp := 1478796;qualContr('00100086815700001478796').idquapro := 3;
    qualContr('00100023715700001479022').cdcooper := 1;qualContr('00100023715700001479022').nrdconta := 2371570;qualContr('00100023715700001479022').nrctremp := 1479022;qualContr('00100023715700001479022').idquapro := 3;
    qualContr('00100098378920001477051').cdcooper := 1;qualContr('00100098378920001477051').nrdconta := 9837892;qualContr('00100098378920001477051').nrctremp := 1477051;qualContr('00100098378920001477051').idquapro := 3;
    qualContr('00100098410240001479415').cdcooper := 1;qualContr('00100098410240001479415').nrdconta := 9841024;qualContr('00100098410240001479415').nrctremp := 1479415;qualContr('00100098410240001479415').idquapro := 3;
    qualContr('00100023341350001481470').cdcooper := 1;qualContr('00100023341350001481470').nrdconta := 2334135;qualContr('00100023341350001481470').nrctremp := 1481470;qualContr('00100023341350001481470').idquapro := 4;
    qualContr('00100081823100001483254').cdcooper := 1;qualContr('00100081823100001483254').nrdconta := 8182310;qualContr('00100081823100001483254').nrctremp := 1483254;qualContr('00100081823100001483254').idquapro := 4;
    qualContr('00100069967520001484382').cdcooper := 1;qualContr('00100069967520001484382').nrdconta := 6996752;qualContr('00100069967520001484382').nrctremp := 1484382;qualContr('00100069967520001484382').idquapro := 3;
    qualContr('00100101127580001489181').cdcooper := 1;qualContr('00100101127580001489181').nrdconta := 10112758;qualContr('00100101127580001489181').nrctremp := 1489181;qualContr('00100101127580001489181').idquapro := 4;
    qualContr('00100067107940001487423').cdcooper := 1;qualContr('00100067107940001487423').nrdconta := 6710794;qualContr('00100067107940001487423').nrctremp := 1487423;qualContr('00100067107940001487423').idquapro := 3;
    qualContr('00100098585470001490283').cdcooper := 1;qualContr('00100098585470001490283').nrdconta := 9858547;qualContr('00100098585470001490283').nrctremp := 1490283;qualContr('00100098585470001490283').idquapro := 3;
    qualContr('00100069228480001490652').cdcooper := 1;qualContr('00100069228480001490652').nrdconta := 6922848;qualContr('00100069228480001490652').nrctremp := 1490652;qualContr('00100069228480001490652').idquapro := 3;
    qualContr('00100094042790001492801').cdcooper := 1;qualContr('00100094042790001492801').nrdconta := 9404279;qualContr('00100094042790001492801').nrctremp := 1492801;qualContr('00100094042790001492801').idquapro := 4;
    qualContr('00100028301400001492764').cdcooper := 1;qualContr('00100028301400001492764').nrdconta := 2830140;qualContr('00100028301400001492764').nrctremp := 1492764;qualContr('00100028301400001492764').idquapro := 3;
    qualContr('00100063600760001492301').cdcooper := 1;qualContr('00100063600760001492301').nrdconta := 6360076;qualContr('00100063600760001492301').nrctremp := 1492301;qualContr('00100063600760001492301').idquapro := 3;
    qualContr('00100083477940001493868').cdcooper := 1;qualContr('00100083477940001493868').nrdconta := 8347794;qualContr('00100083477940001493868').nrctremp := 1493868;qualContr('00100083477940001493868').idquapro := 3;
    qualContr('00100094998220001496953').cdcooper := 1;qualContr('00100094998220001496953').nrdconta := 9499822;qualContr('00100094998220001496953').nrctremp := 1496953;qualContr('00100094998220001496953').idquapro := 4;
    qualContr('00100090089930001496530').cdcooper := 1;qualContr('00100090089930001496530').nrdconta := 9008993;qualContr('00100090089930001496530').nrctremp := 1496530;qualContr('00100090089930001496530').idquapro := 3;
    qualContr('00100060106360001495978').cdcooper := 1;qualContr('00100060106360001495978').nrdconta := 6010636;qualContr('00100060106360001495978').nrctremp := 1495978;qualContr('00100060106360001495978').idquapro := 3;
    qualContr('00100804144860001496326').cdcooper := 1;qualContr('00100804144860001496326').nrdconta := 80414486;qualContr('00100804144860001496326').nrctremp := 1496326;qualContr('00100804144860001496326').idquapro := 3;
    qualContr('00100074202340001499849').cdcooper := 1;qualContr('00100074202340001499849').nrdconta := 7420234;qualContr('00100074202340001499849').nrctremp := 1499849;qualContr('00100074202340001499849').idquapro := 3;
    qualContr('00100063416240001501355').cdcooper := 1;qualContr('00100063416240001501355').nrdconta := 6341624;qualContr('00100063416240001501355').nrctremp := 1501355;qualContr('00100063416240001501355').idquapro := 4;
    qualContr('00100027147100001503272').cdcooper := 1;qualContr('00100027147100001503272').nrdconta := 2714710;qualContr('00100027147100001503272').nrctremp := 1503272;qualContr('00100027147100001503272').idquapro := 3;
    qualContr('00100088230570001505886').cdcooper := 1;qualContr('00100088230570001505886').nrdconta := 8823057;qualContr('00100088230570001505886').nrctremp := 1505886;qualContr('00100088230570001505886').idquapro := 3;
    qualContr('00100036944530001507271').cdcooper := 1;qualContr('00100036944530001507271').nrdconta := 3694453;qualContr('00100036944530001507271').nrctremp := 1507271;qualContr('00100036944530001507271').idquapro := 3;
    qualContr('00100037418690001507028').cdcooper := 1;qualContr('00100037418690001507028').nrdconta := 3741869;qualContr('00100037418690001507028').nrctremp := 1507028;qualContr('00100037418690001507028').idquapro := 3;
    qualContr('00100100130910001510348').cdcooper := 1;qualContr('00100100130910001510348').nrdconta := 10013091;qualContr('00100100130910001510348').nrctremp := 1510348;qualContr('00100100130910001510348').idquapro := 3;
    qualContr('00100020581970001511319').cdcooper := 1;qualContr('00100020581970001511319').nrdconta := 2058197;qualContr('00100020581970001511319').nrctremp := 1511319;qualContr('00100020581970001511319').idquapro := 4;
    qualContr('00100026527810001515537').cdcooper := 1;qualContr('00100026527810001515537').nrdconta := 2652781;qualContr('00100026527810001515537').nrctremp := 1515537;qualContr('00100026527810001515537').idquapro := 3;
    qualContr('00100071582030001514625').cdcooper := 1;qualContr('00100071582030001514625').nrdconta := 7158203;qualContr('00100071582030001514625').nrctremp := 1514625;qualContr('00100071582030001514625').idquapro := 4;
    qualContr('00100015058400001519133').cdcooper := 1;qualContr('00100015058400001519133').nrdconta := 1505840;qualContr('00100015058400001519133').nrctremp := 1519133;qualContr('00100015058400001519133').idquapro := 3;
    qualContr('00100067015580001519948').cdcooper := 1;qualContr('00100067015580001519948').nrdconta := 6701558;qualContr('00100067015580001519948').nrctremp := 1519948;qualContr('00100067015580001519948').idquapro := 3;
    qualContr('00100075865660001520146').cdcooper := 1;qualContr('00100075865660001520146').nrdconta := 7586566;qualContr('00100075865660001520146').nrctremp := 1520146;qualContr('00100075865660001520146').idquapro := 3;
    qualContr('00100030913330001523732').cdcooper := 1;qualContr('00100030913330001523732').nrdconta := 3091333;qualContr('00100030913330001523732').nrctremp := 1523732;qualContr('00100030913330001523732').idquapro := 3;
    qualContr('00100090207560001528672').cdcooper := 1;qualContr('00100090207560001528672').nrdconta := 9020756;qualContr('00100090207560001528672').nrctremp := 1528672;qualContr('00100090207560001528672').idquapro := 4;
    qualContr('00100084058400001528964').cdcooper := 1;qualContr('00100084058400001528964').nrdconta := 8405840;qualContr('00100084058400001528964').nrctremp := 1528964;qualContr('00100084058400001528964').idquapro := 4;
    qualContr('00100084221330001532399').cdcooper := 1;qualContr('00100084221330001532399').nrdconta := 8422133;qualContr('00100084221330001532399').nrctremp := 1532399;qualContr('00100084221330001532399').idquapro := 3;
    qualContr('00100065130690001531043').cdcooper := 1;qualContr('00100065130690001531043').nrdconta := 6513069;qualContr('00100065130690001531043').nrctremp := 1531043;qualContr('00100065130690001531043').idquapro := 3;
    qualContr('00100041913740001533517').cdcooper := 1;qualContr('00100041913740001533517').nrdconta := 4191374;qualContr('00100041913740001533517').nrctremp := 1533517;qualContr('00100041913740001533517').idquapro := 3;
    qualContr('00100070106210001536072').cdcooper := 1;qualContr('00100070106210001536072').nrdconta := 7010621;qualContr('00100070106210001536072').nrctremp := 1536072;qualContr('00100070106210001536072').idquapro := 3;
    qualContr('00100095743790001539659').cdcooper := 1;qualContr('00100095743790001539659').nrdconta := 9574379;qualContr('00100095743790001539659').nrctremp := 1539659;qualContr('00100095743790001539659').idquapro := 3;
    qualContr('00100091346700001540017').cdcooper := 1;qualContr('00100091346700001540017').nrdconta := 9134670;qualContr('00100091346700001540017').nrctremp := 1540017;qualContr('00100091346700001540017').idquapro := 3;
    qualContr('00100800198620001540830').cdcooper := 1;qualContr('00100800198620001540830').nrdconta := 80019862;qualContr('00100800198620001540830').nrctremp := 1540830;qualContr('00100800198620001540830').idquapro := 3;
    qualContr('00100098590800001540774').cdcooper := 1;qualContr('00100098590800001540774').nrdconta := 9859080;qualContr('00100098590800001540774').nrctremp := 1540774;qualContr('00100098590800001540774').idquapro := 3;
    qualContr('00100035902910001543587').cdcooper := 1;qualContr('00100035902910001543587').nrdconta := 3590291;qualContr('00100035902910001543587').nrctremp := 1543587;qualContr('00100035902910001543587').idquapro := 3;
    qualContr('00100040182220001545030').cdcooper := 1;qualContr('00100040182220001545030').nrdconta := 4018222;qualContr('00100040182220001545030').nrctremp := 1545030;qualContr('00100040182220001545030').idquapro := 3;
    qualContr('00100101536240001544866').cdcooper := 1;qualContr('00100101536240001544866').nrdconta := 10153624;qualContr('00100101536240001544866').nrctremp := 1544866;qualContr('00100101536240001544866').idquapro := 4;
    qualContr('00100085077750001546045').cdcooper := 1;qualContr('00100085077750001546045').nrdconta := 8507775;qualContr('00100085077750001546045').nrctremp := 1546045;qualContr('00100085077750001546045').idquapro := 3;
    qualContr('00100025436640001546162').cdcooper := 1;qualContr('00100025436640001546162').nrdconta := 2543664;qualContr('00100025436640001546162').nrctremp := 1546162;qualContr('00100025436640001546162').idquapro := 3;
    qualContr('00100100456270001547663').cdcooper := 1;qualContr('00100100456270001547663').nrdconta := 10045627;qualContr('00100100456270001547663').nrctremp := 1547663;qualContr('00100100456270001547663').idquapro := 4;
    qualContr('00100015045250001550458').cdcooper := 1;qualContr('00100015045250001550458').nrdconta := 1504525;qualContr('00100015045250001550458').nrctremp := 1550458;qualContr('00100015045250001550458').idquapro := 3;
    qualContr('00100100188080001552618').cdcooper := 1;qualContr('00100100188080001552618').nrdconta := 10018808;qualContr('00100100188080001552618').nrctremp := 1552618;qualContr('00100100188080001552618').idquapro := 3;
    qualContr('00100018284950001554834').cdcooper := 1;qualContr('00100018284950001554834').nrdconta := 1828495;qualContr('00100018284950001554834').nrctremp := 1554834;qualContr('00100018284950001554834').idquapro := 3;
    qualContr('00100084934800001556758').cdcooper := 1;qualContr('00100084934800001556758').nrdconta := 8493480;qualContr('00100084934800001556758').nrctremp := 1556758;qualContr('00100084934800001556758').idquapro := 3;
    qualContr('00100076121410001557151').cdcooper := 1;qualContr('00100076121410001557151').nrdconta := 7612141;qualContr('00100076121410001557151').nrctremp := 1557151;qualContr('00100076121410001557151').idquapro := 3;
    qualContr('00100086997710001560743').cdcooper := 1;qualContr('00100086997710001560743').nrdconta := 8699771;qualContr('00100086997710001560743').nrctremp := 1560743;qualContr('00100086997710001560743').idquapro := 3;
    qualContr('00100102412800001559742').cdcooper := 1;qualContr('00100102412800001559742').nrdconta := 10241280;qualContr('00100102412800001559742').nrctremp := 1559742;qualContr('00100102412800001559742').idquapro := 3;
    qualContr('00100095450420001560945').cdcooper := 1;qualContr('00100095450420001560945').nrdconta := 9545042;qualContr('00100095450420001560945').nrctremp := 1560945;qualContr('00100095450420001560945').idquapro := 3;
    qualContr('00100084146450001563756').cdcooper := 1;qualContr('00100084146450001563756').nrdconta := 8414645;qualContr('00100084146450001563756').nrctremp := 1563756;qualContr('00100084146450001563756').idquapro := 3;
    qualContr('00100101409720001562464').cdcooper := 1;qualContr('00100101409720001562464').nrdconta := 10140972;qualContr('00100101409720001562464').nrctremp := 1562464;qualContr('00100101409720001562464').idquapro := 3;
    qualContr('00100074625060001564252').cdcooper := 1;qualContr('00100074625060001564252').nrdconta := 7462506;qualContr('00100074625060001564252').nrctremp := 1564252;qualContr('00100074625060001564252').idquapro := 3;
    qualContr('00100019856470001565413').cdcooper := 1;qualContr('00100019856470001565413').nrdconta := 1985647;qualContr('00100019856470001565413').nrctremp := 1565413;qualContr('00100019856470001565413').idquapro := 3;
    qualContr('00100035282190001566370').cdcooper := 1;qualContr('00100035282190001566370').nrdconta := 3528219;qualContr('00100035282190001566370').nrctremp := 1566370;qualContr('00100035282190001566370').idquapro := 3;
    qualContr('00100083478320001568138').cdcooper := 1;qualContr('00100083478320001568138').nrdconta := 8347832;qualContr('00100083478320001568138').nrctremp := 1568138;qualContr('00100083478320001568138').idquapro := 3;
    qualContr('00100064774100001570111').cdcooper := 1;qualContr('00100064774100001570111').nrdconta := 6477410;qualContr('00100064774100001570111').nrctremp := 1570111;qualContr('00100064774100001570111').idquapro := 3;
    qualContr('00100101525800001572756').cdcooper := 1;qualContr('00100101525800001572756').nrdconta := 10152580;qualContr('00100101525800001572756').nrctremp := 1572756;qualContr('00100101525800001572756').idquapro := 3;
    qualContr('00100102921870001572612').cdcooper := 1;qualContr('00100102921870001572612').nrdconta := 10292187;qualContr('00100102921870001572612').nrctremp := 1572612;qualContr('00100102921870001572612').idquapro := 3;
    qualContr('00100092126390001573672').cdcooper := 1;qualContr('00100092126390001573672').nrdconta := 9212639;qualContr('00100092126390001573672').nrctremp := 1573672;qualContr('00100092126390001573672').idquapro := 3;
    qualContr('00100006143350001576805').cdcooper := 1;qualContr('00100006143350001576805').nrdconta := 614335;qualContr('00100006143350001576805').nrctremp := 1576805;qualContr('00100006143350001576805').idquapro := 3;
    qualContr('00100097705690001578213').cdcooper := 1;qualContr('00100097705690001578213').nrdconta := 9770569;qualContr('00100097705690001578213').nrctremp := 1578213;qualContr('00100097705690001578213').idquapro := 3;
    qualContr('00100102746180001579921').cdcooper := 1;qualContr('00100102746180001579921').nrdconta := 10274618;qualContr('00100102746180001579921').nrctremp := 1579921;qualContr('00100102746180001579921').idquapro := 3;
    qualContr('00100902631110001579463').cdcooper := 1;qualContr('00100902631110001579463').nrdconta := 90263111;qualContr('00100902631110001579463').nrctremp := 1579463;qualContr('00100902631110001579463').idquapro := 3;
    qualContr('00100094328680001580749').cdcooper := 1;qualContr('00100094328680001580749').nrdconta := 9432868;qualContr('00100094328680001580749').nrctremp := 1580749;qualContr('00100094328680001580749').idquapro := 3;
    qualContr('00100070594930001582822').cdcooper := 1;qualContr('00100070594930001582822').nrdconta := 7059493;qualContr('00100070594930001582822').nrctremp := 1582822;qualContr('00100070594930001582822').idquapro := 3;
    qualContr('00100085314470001582206').cdcooper := 1;qualContr('00100085314470001582206').nrdconta := 8531447;qualContr('00100085314470001582206').nrctremp := 1582206;qualContr('00100085314470001582206').idquapro := 3;
    qualContr('00100035714910001582120').cdcooper := 1;qualContr('00100035714910001582120').nrdconta := 3571491;qualContr('00100035714910001582120').nrctremp := 1582120;qualContr('00100035714910001582120').idquapro := 3;
    qualContr('00100080699720001583190').cdcooper := 1;qualContr('00100080699720001583190').nrdconta := 8069972;qualContr('00100080699720001583190').nrctremp := 1583190;qualContr('00100080699720001583190').idquapro := 3;
    qualContr('00100098400790001586369').cdcooper := 1;qualContr('00100098400790001586369').nrdconta := 9840079;qualContr('00100098400790001586369').nrctremp := 1586369;qualContr('00100098400790001586369').idquapro := 4;
    qualContr('00100022906690001587589').cdcooper := 1;qualContr('00100022906690001587589').nrdconta := 2290669;qualContr('00100022906690001587589').nrctremp := 1587589;qualContr('00100022906690001587589').idquapro := 3;
    qualContr('00100081215240001586355').cdcooper := 1;qualContr('00100081215240001586355').nrdconta := 8121524;qualContr('00100081215240001586355').nrctremp := 1586355;qualContr('00100081215240001586355').idquapro := 3;
    qualContr('00100060023660001588309').cdcooper := 1;qualContr('00100060023660001588309').nrdconta := 6002366;qualContr('00100060023660001588309').nrctremp := 1588309;qualContr('00100060023660001588309').idquapro := 3;
    qualContr('00100097083400001588242').cdcooper := 1;qualContr('00100097083400001588242').nrdconta := 9708340;qualContr('00100097083400001588242').nrctremp := 1588242;qualContr('00100097083400001588242').idquapro := 3;
    qualContr('00100008611540001590049').cdcooper := 1;qualContr('00100008611540001590049').nrdconta := 861154;qualContr('00100008611540001590049').nrctremp := 1590049;qualContr('00100008611540001590049').idquapro := 3;
    qualContr('00100097977690001590787').cdcooper := 1;qualContr('00100097977690001590787').nrdconta := 9797769;qualContr('00100097977690001590787').nrctremp := 1590787;qualContr('00100097977690001590787').idquapro := 3;
    qualContr('00100103325960001591489').cdcooper := 1;qualContr('00100103325960001591489').nrdconta := 10332596;qualContr('00100103325960001591489').nrctremp := 1591489;qualContr('00100103325960001591489').idquapro := 4;
    qualContr('00100077266430001591100').cdcooper := 1;qualContr('00100077266430001591100').nrdconta := 7726643;qualContr('00100077266430001591100').nrctremp := 1591100;qualContr('00100077266430001591100').idquapro := 3;
    qualContr('00100066192740001592769').cdcooper := 1;qualContr('00100066192740001592769').nrdconta := 6619274;qualContr('00100066192740001592769').nrctremp := 1592769;qualContr('00100066192740001592769').idquapro := 4;
    qualContr('00100804808370001592957').cdcooper := 1;qualContr('00100804808370001592957').nrdconta := 80480837;qualContr('00100804808370001592957').nrctremp := 1592957;qualContr('00100804808370001592957').idquapro := 3;
    qualContr('00100087520520001596588').cdcooper := 1;qualContr('00100087520520001596588').nrdconta := 8752052;qualContr('00100087520520001596588').nrctremp := 1596588;qualContr('00100087520520001596588').idquapro := 3;
    qualContr('00100102122720001595933').cdcooper := 1;qualContr('00100102122720001595933').nrdconta := 10212272;qualContr('00100102122720001595933').nrctremp := 1595933;qualContr('00100102122720001595933').idquapro := 3;
    qualContr('00100031350200001595065').cdcooper := 1;qualContr('00100031350200001595065').nrdconta := 3135020;qualContr('00100031350200001595065').nrctremp := 1595065;qualContr('00100031350200001595065').idquapro := 3;
    qualContr('00100026648790001595080').cdcooper := 1;qualContr('00100026648790001595080').nrdconta := 2664879;qualContr('00100026648790001595080').nrctremp := 1595080;qualContr('00100026648790001595080').idquapro := 3;
    qualContr('00100074354010001596886').cdcooper := 1;qualContr('00100074354010001596886').nrdconta := 7435401;qualContr('00100074354010001596886').nrctremp := 1596886;qualContr('00100074354010001596886').idquapro := 3;
    qualContr('00100087520520001596595').cdcooper := 1;qualContr('00100087520520001596595').nrdconta := 8752052;qualContr('00100087520520001596595').nrctremp := 1596595;qualContr('00100087520520001596595').idquapro := 3;
    qualContr('00100081176400001595423').cdcooper := 1;qualContr('00100081176400001595423').nrdconta := 8117640;qualContr('00100081176400001595423').nrctremp := 1595423;qualContr('00100081176400001595423').idquapro := 3;
    qualContr('00100022371480001597953').cdcooper := 1;qualContr('00100022371480001597953').nrdconta := 2237148;qualContr('00100022371480001597953').nrctremp := 1597953;qualContr('00100022371480001597953').idquapro := 3;
    qualContr('00100075269970001599733').cdcooper := 1;qualContr('00100075269970001599733').nrdconta := 7526997;qualContr('00100075269970001599733').nrctremp := 1599733;qualContr('00100075269970001599733').idquapro := 3;
    qualContr('00100086373930001601136').cdcooper := 1;qualContr('00100086373930001601136').nrdconta := 8637393;qualContr('00100086373930001601136').nrctremp := 1601136;qualContr('00100086373930001601136').idquapro := 3;
    qualContr('00100069967790001600402').cdcooper := 1;qualContr('00100069967790001600402').nrdconta := 6996779;qualContr('00100069967790001600402').nrctremp := 1600402;qualContr('00100069967790001600402').idquapro := 3;
    qualContr('00100103256970001601577').cdcooper := 1;qualContr('00100103256970001601577').nrdconta := 10325697;qualContr('00100103256970001601577').nrctremp := 1601577;qualContr('00100103256970001601577').idquapro := 3;
    qualContr('00100023467020001603002').cdcooper := 1;qualContr('00100023467020001603002').nrdconta := 2346702;qualContr('00100023467020001603002').nrctremp := 1603002;qualContr('00100023467020001603002').idquapro := 3;
    qualContr('00100096254700001602193').cdcooper := 1;qualContr('00100096254700001602193').nrdconta := 9625470;qualContr('00100096254700001602193').nrctremp := 1602193;qualContr('00100096254700001602193').idquapro := 3;
    qualContr('00100027006200001603126').cdcooper := 1;qualContr('00100027006200001603126').nrdconta := 2700620;qualContr('00100027006200001603126').nrctremp := 1603126;qualContr('00100027006200001603126').idquapro := 3;
    qualContr('00100024940270001603653').cdcooper := 1;qualContr('00100024940270001603653').nrdconta := 2494027;qualContr('00100024940270001603653').nrctremp := 1603653;qualContr('00100024940270001603653').idquapro := 3;
    qualContr('00100074831390001604890').cdcooper := 1;qualContr('00100074831390001604890').nrdconta := 7483139;qualContr('00100074831390001604890').nrctremp := 1604890;qualContr('00100074831390001604890').idquapro := 3;
    qualContr('00100015280760001606076').cdcooper := 1;qualContr('00100015280760001606076').nrdconta := 1528076;qualContr('00100015280760001606076').nrctremp := 1606076;qualContr('00100015280760001606076').idquapro := 3;
    qualContr('00100802743900001605171').cdcooper := 1;qualContr('00100802743900001605171').nrdconta := 80274390;qualContr('00100802743900001605171').nrctremp := 1605171;qualContr('00100802743900001605171').idquapro := 3;
    qualContr('00100072909500001606251').cdcooper := 1;qualContr('00100072909500001606251').nrdconta := 7290950;qualContr('00100072909500001606251').nrctremp := 1606251;qualContr('00100072909500001606251').idquapro := 3;
    qualContr('00100095909940001608975').cdcooper := 1;qualContr('00100095909940001608975').nrdconta := 9590994;qualContr('00100095909940001608975').nrctremp := 1608975;qualContr('00100095909940001608975').idquapro := 4;
    qualContr('00100083381590001609654').cdcooper := 1;qualContr('00100083381590001609654').nrdconta := 8338159;qualContr('00100083381590001609654').nrctremp := 1609654;qualContr('00100083381590001609654').idquapro := 3;
    qualContr('00100038847240001610463').cdcooper := 1;qualContr('00100038847240001610463').nrdconta := 3884724;qualContr('00100038847240001610463').nrctremp := 1610463;qualContr('00100038847240001610463').idquapro := 3;
    qualContr('00100072481210000072382').cdcooper := 1;qualContr('00100072481210000072382').nrdconta := 7248121;qualContr('00100072481210000072382').nrctremp := 72382;qualContr('00100072481210000072382').idquapro := 3;
    qualContr('00100095582920001611034').cdcooper := 1;qualContr('00100095582920001611034').nrdconta := 9558292;qualContr('00100095582920001611034').nrctremp := 1611034;qualContr('00100095582920001611034').idquapro := 4;
    qualContr('00100086117000001611849').cdcooper := 1;qualContr('00100086117000001611849').nrdconta := 8611700;qualContr('00100086117000001611849').nrctremp := 1611849;qualContr('00100086117000001611849').idquapro := 3;
    qualContr('00100023734830001614858').cdcooper := 1;qualContr('00100023734830001614858').nrdconta := 2373483;qualContr('00100023734830001614858').nrctremp := 1614858;qualContr('00100023734830001614858').idquapro := 3;
    qualContr('00100072038530001615262').cdcooper := 1;qualContr('00100072038530001615262').nrdconta := 7203853;qualContr('00100072038530001615262').nrctremp := 1615262;qualContr('00100072038530001615262').idquapro := 3;
    qualContr('00100064619130001615862').cdcooper := 1;qualContr('00100064619130001615862').nrdconta := 6461913;qualContr('00100064619130001615862').nrctremp := 1615862;qualContr('00100064619130001615862').idquapro := 4;
    qualContr('00100039916600001619196').cdcooper := 1;qualContr('00100039916600001619196').nrdconta := 3991660;qualContr('00100039916600001619196').nrctremp := 1619196;qualContr('00100039916600001619196').idquapro := 3;
    qualContr('00100092384090001620759').cdcooper := 1;qualContr('00100092384090001620759').nrdconta := 9238409;qualContr('00100092384090001620759').nrctremp := 1620759;qualContr('00100092384090001620759').idquapro := 4;
    qualContr('00100062815670001620394').cdcooper := 1;qualContr('00100062815670001620394').nrdconta := 6281567;qualContr('00100062815670001620394').nrctremp := 1620394;qualContr('00100062815670001620394').idquapro := 3;
    qualContr('00100104773060001621237').cdcooper := 1;qualContr('00100104773060001621237').nrdconta := 10477306;qualContr('00100104773060001621237').nrctremp := 1621237;qualContr('00100104773060001621237').idquapro := 3;
    qualContr('00100103383300001622885').cdcooper := 1;qualContr('00100103383300001622885').nrdconta := 10338330;qualContr('00100103383300001622885').nrctremp := 1622885;qualContr('00100103383300001622885').idquapro := 3;
    qualContr('00100023624730001623944').cdcooper := 1;qualContr('00100023624730001623944').nrdconta := 2362473;qualContr('00100023624730001623944').nrctremp := 1623944;qualContr('00100023624730001623944').idquapro := 3;
    qualContr('00100099672300001624786').cdcooper := 1;qualContr('00100099672300001624786').nrdconta := 9967230;qualContr('00100099672300001624786').nrctremp := 1624786;qualContr('00100099672300001624786').idquapro := 3;
    qualContr('00100088488310001624081').cdcooper := 1;qualContr('00100088488310001624081').nrdconta := 8848831;qualContr('00100088488310001624081').nrctremp := 1624081;qualContr('00100088488310001624081').idquapro := 3;
    qualContr('00100066073300001624632').cdcooper := 1;qualContr('00100066073300001624632').nrdconta := 6607330;qualContr('00100066073300001624632').nrctremp := 1624632;qualContr('00100066073300001624632').idquapro := 3;
    qualContr('00100078591040001625324').cdcooper := 1;qualContr('00100078591040001625324').nrdconta := 7859104;qualContr('00100078591040001625324').nrctremp := 1625324;qualContr('00100078591040001625324').idquapro := 3;
    qualContr('00100062862240001625752').cdcooper := 1;qualContr('00100062862240001625752').nrdconta := 6286224;qualContr('00100062862240001625752').nrctremp := 1625752;qualContr('00100062862240001625752').idquapro := 3;
    qualContr('00100093734700001625849').cdcooper := 1;qualContr('00100093734700001625849').nrdconta := 9373470;qualContr('00100093734700001625849').nrctremp := 1625849;qualContr('00100093734700001625849').idquapro := 3;
    qualContr('00100072210370001627039').cdcooper := 1;qualContr('00100072210370001627039').nrdconta := 7221037;qualContr('00100072210370001627039').nrctremp := 1627039;qualContr('00100072210370001627039').idquapro := 3;
    qualContr('00100091759460001628121').cdcooper := 1;qualContr('00100091759460001628121').nrdconta := 9175946;qualContr('00100091759460001628121').nrctremp := 1628121;qualContr('00100091759460001628121').idquapro := 3;
    qualContr('00100063198660001630099').cdcooper := 1;qualContr('00100063198660001630099').nrdconta := 6319866;qualContr('00100063198660001630099').nrctremp := 1630099;qualContr('00100063198660001630099').idquapro := 3;
    qualContr('00100104075530001630315').cdcooper := 1;qualContr('00100104075530001630315').nrdconta := 10407553;qualContr('00100104075530001630315').nrctremp := 1630315;qualContr('00100104075530001630315').idquapro := 4;
    qualContr('00100013278280001631247').cdcooper := 1;qualContr('00100013278280001631247').nrdconta := 1327828;qualContr('00100013278280001631247').nrctremp := 1631247;qualContr('00100013278280001631247').idquapro := 3;
    qualContr('00100074852120001632339').cdcooper := 1;qualContr('00100074852120001632339').nrdconta := 7485212;qualContr('00100074852120001632339').nrctremp := 1632339;qualContr('00100074852120001632339').idquapro := 3;
    qualContr('00100089997160001634203').cdcooper := 1;qualContr('00100089997160001634203').nrdconta := 8999716;qualContr('00100089997160001634203').nrctremp := 1634203;qualContr('00100089997160001634203').idquapro := 4;
    qualContr('00100074893580001635214').cdcooper := 1;qualContr('00100074893580001635214').nrdconta := 7489358;qualContr('00100074893580001635214').nrctremp := 1635214;qualContr('00100074893580001635214').idquapro := 3;
    qualContr('00100085310480001635305').cdcooper := 1;qualContr('00100085310480001635305').nrdconta := 8531048;qualContr('00100085310480001635305').nrctremp := 1635305;qualContr('00100085310480001635305').idquapro := 4;
    qualContr('00100073659930001636145').cdcooper := 1;qualContr('00100073659930001636145').nrdconta := 7365993;qualContr('00100073659930001636145').nrctremp := 1636145;qualContr('00100073659930001636145').idquapro := 3;
    qualContr('00100027160970001638157').cdcooper := 1;qualContr('00100027160970001638157').nrdconta := 2716097;qualContr('00100027160970001638157').nrctremp := 1638157;qualContr('00100027160970001638157').idquapro := 3;
    qualContr('00100101916900001639992').cdcooper := 1;qualContr('00100101916900001639992').nrdconta := 10191690;qualContr('00100101916900001639992').nrctremp := 1639992;qualContr('00100101916900001639992').idquapro := 3;
    qualContr('00100075408840001638535').cdcooper := 1;qualContr('00100075408840001638535').nrdconta := 7540884;qualContr('00100075408840001638535').nrctremp := 1638535;qualContr('00100075408840001638535').idquapro := 3;
    qualContr('00100104837990001641253').cdcooper := 1;qualContr('00100104837990001641253').nrdconta := 10483799;qualContr('00100104837990001641253').nrctremp := 1641253;qualContr('00100104837990001641253').idquapro := 3;
    qualContr('00100103513700001642929').cdcooper := 1;qualContr('00100103513700001642929').nrdconta := 10351370;qualContr('00100103513700001642929').nrctremp := 1642929;qualContr('00100103513700001642929').idquapro := 3;
    qualContr('00100085720700001642005').cdcooper := 1;qualContr('00100085720700001642005').nrdconta := 8572070;qualContr('00100085720700001642005').nrctremp := 1642005;qualContr('00100085720700001642005').idquapro := 3;
    qualContr('00100015289980001643167').cdcooper := 1;qualContr('00100015289980001643167').nrdconta := 1528998;qualContr('00100015289980001643167').nrctremp := 1643167;qualContr('00100015289980001643167').idquapro := 3;
    qualContr('00100090298500001642431').cdcooper := 1;qualContr('00100090298500001642431').nrdconta := 9029850;qualContr('00100090298500001642431').nrctremp := 1642431;qualContr('00100090298500001642431').idquapro := 3;
    qualContr('00100103017200001641880').cdcooper := 1;qualContr('00100103017200001641880').nrdconta := 10301720;qualContr('00100103017200001641880').nrctremp := 1641880;qualContr('00100103017200001641880').idquapro := 3;
    qualContr('00100028301240001643303').cdcooper := 1;qualContr('00100028301240001643303').nrdconta := 2830124;qualContr('00100028301240001643303').nrctremp := 1643303;qualContr('00100028301240001643303').idquapro := 3;
    qualContr('00100102921520001644377').cdcooper := 1;qualContr('00100102921520001644377').nrdconta := 10292152;qualContr('00100102921520001644377').nrctremp := 1644377;qualContr('00100102921520001644377').idquapro := 3;
    qualContr('00100035722180001645723').cdcooper := 1;qualContr('00100035722180001645723').nrdconta := 3572218;qualContr('00100035722180001645723').nrctremp := 1645723;qualContr('00100035722180001645723').idquapro := 3;
    qualContr('00100102719530001645189').cdcooper := 1;qualContr('00100102719530001645189').nrdconta := 10271953;qualContr('00100102719530001645189').nrctremp := 1645189;qualContr('00100102719530001645189').idquapro := 3;
    qualContr('00100065710930001645656').cdcooper := 1;qualContr('00100065710930001645656').nrdconta := 6571093;qualContr('00100065710930001645656').nrctremp := 1645656;qualContr('00100065710930001645656').idquapro := 3;
    qualContr('00100063890660001646690').cdcooper := 1;qualContr('00100063890660001646690').nrdconta := 6389066;qualContr('00100063890660001646690').nrctremp := 1646690;qualContr('00100063890660001646690').idquapro := 3;
    qualContr('00100023426000001649294').cdcooper := 1;qualContr('00100023426000001649294').nrdconta := 2342600;qualContr('00100023426000001649294').nrctremp := 1649294;qualContr('00100023426000001649294').idquapro := 3;
    qualContr('00100024933900001653077').cdcooper := 1;qualContr('00100024933900001653077').nrdconta := 2493390;qualContr('00100024933900001653077').nrctremp := 1653077;qualContr('00100024933900001653077').idquapro := 3;
    qualContr('00100023267360001655782').cdcooper := 1;qualContr('00100023267360001655782').nrdconta := 2326736;qualContr('00100023267360001655782').nrctremp := 1655782;qualContr('00100023267360001655782').idquapro := 3;
    qualContr('00100081360500001656315').cdcooper := 1;qualContr('00100081360500001656315').nrdconta := 8136050;qualContr('00100081360500001656315').nrctremp := 1656315;qualContr('00100081360500001656315').idquapro := 3;
    qualContr('00100065349610001657465').cdcooper := 1;qualContr('00100065349610001657465').nrdconta := 6534961;qualContr('00100065349610001657465').nrctremp := 1657465;qualContr('00100065349610001657465').idquapro := 3;
    qualContr('00100089961560001658279').cdcooper := 1;qualContr('00100089961560001658279').nrdconta := 8996156;qualContr('00100089961560001658279').nrctremp := 1658279;qualContr('00100089961560001658279').idquapro := 3;
    qualContr('00100082050190001659657').cdcooper := 1;qualContr('00100082050190001659657').nrdconta := 8205019;qualContr('00100082050190001659657').nrctremp := 1659657;qualContr('00100082050190001659657').idquapro := 3;
    qualContr('00100076306700001659799').cdcooper := 1;qualContr('00100076306700001659799').nrdconta := 7630670;qualContr('00100076306700001659799').nrctremp := 1659799;qualContr('00100076306700001659799').idquapro := 4;
    qualContr('00100024216230001659592').cdcooper := 1;qualContr('00100024216230001659592').nrdconta := 2421623;qualContr('00100024216230001659592').nrctremp := 1659592;qualContr('00100024216230001659592').idquapro := 3;
    qualContr('00100068488000001659656').cdcooper := 1;qualContr('00100068488000001659656').nrdconta := 6848800;qualContr('00100068488000001659656').nrctremp := 1659656;qualContr('00100068488000001659656').idquapro := 3;
    qualContr('00100093808500001661623').cdcooper := 1;qualContr('00100093808500001661623').nrdconta := 9380850;qualContr('00100093808500001661623').nrctremp := 1661623;qualContr('00100093808500001661623').idquapro := 3;
    qualContr('00100037135980001662634').cdcooper := 1;qualContr('00100037135980001662634').nrdconta := 3713598;qualContr('00100037135980001662634').nrctremp := 1662634;qualContr('00100037135980001662634').idquapro := 3;
    qualContr('00100019972110001662388').cdcooper := 1;qualContr('00100019972110001662388').nrdconta := 1997211;qualContr('00100019972110001662388').nrctremp := 1662388;qualContr('00100019972110001662388').idquapro := 3;
    qualContr('00100099272710001663043').cdcooper := 1;qualContr('00100099272710001663043').nrdconta := 9927271;qualContr('00100099272710001663043').nrctremp := 1663043;qualContr('00100099272710001663043').idquapro := 3;
    qualContr('00100037135980001662633').cdcooper := 1;qualContr('00100037135980001662633').nrdconta := 3713598;qualContr('00100037135980001662633').nrctremp := 1662633;qualContr('00100037135980001662633').idquapro := 3;
    qualContr('00100080100560001664205').cdcooper := 1;qualContr('00100080100560001664205').nrdconta := 8010056;qualContr('00100080100560001664205').nrctremp := 1664205;qualContr('00100080100560001664205').idquapro := 4;
    qualContr('00100040336550001665550').cdcooper := 1;qualContr('00100040336550001665550').nrdconta := 4033655;qualContr('00100040336550001665550').nrctremp := 1665550;qualContr('00100040336550001665550').idquapro := 3;
    qualContr('00100081123390001666010').cdcooper := 1;qualContr('00100081123390001666010').nrdconta := 8112339;qualContr('00100081123390001666010').nrctremp := 1666010;qualContr('00100081123390001666010').idquapro := 3;
    qualContr('00100040503710001668844').cdcooper := 1;qualContr('00100040503710001668844').nrdconta := 4050371;qualContr('00100040503710001668844').nrctremp := 1668844;qualContr('00100040503710001668844').idquapro := 3;
    qualContr('00100084646770001670194').cdcooper := 1;qualContr('00100084646770001670194').nrdconta := 8464677;qualContr('00100084646770001670194').nrctremp := 1670194;qualContr('00100084646770001670194').idquapro := 4;
    qualContr('00100028959350001670911').cdcooper := 1;qualContr('00100028959350001670911').nrdconta := 2895935;qualContr('00100028959350001670911').nrctremp := 1670911;qualContr('00100028959350001670911').idquapro := 3;
    qualContr('00100037620680001671672').cdcooper := 1;qualContr('00100037620680001671672').nrdconta := 3762068;qualContr('00100037620680001671672').nrctremp := 1671672;qualContr('00100037620680001671672').idquapro := 3;
    qualContr('00100092851050001672009').cdcooper := 1;qualContr('00100092851050001672009').nrdconta := 9285105;qualContr('00100092851050001672009').nrctremp := 1672009;qualContr('00100092851050001672009').idquapro := 3;
    qualContr('00100103404670001672540').cdcooper := 1;qualContr('00100103404670001672540').nrdconta := 10340467;qualContr('00100103404670001672540').nrctremp := 1672540;qualContr('00100103404670001672540').idquapro := 3;
    qualContr('00100008580640001671577').cdcooper := 1;qualContr('00100008580640001671577').nrdconta := 858064;qualContr('00100008580640001671577').nrctremp := 1671577;qualContr('00100008580640001671577').idquapro := 4;
    qualContr('00100103561850001674492').cdcooper := 1;qualContr('00100103561850001674492').nrdconta := 10356185;qualContr('00100103561850001674492').nrctremp := 1674492;qualContr('00100103561850001674492').idquapro := 3;
    qualContr('00100085048900001674348').cdcooper := 1;qualContr('00100085048900001674348').nrdconta := 8504890;qualContr('00100085048900001674348').nrctremp := 1674348;qualContr('00100085048900001674348').idquapro := 4;
    qualContr('00100070197260001674525').cdcooper := 1;qualContr('00100070197260001674525').nrdconta := 7019726;qualContr('00100070197260001674525').nrctremp := 1674525;qualContr('00100070197260001674525').idquapro := 3;
    qualContr('00100028492830001674115').cdcooper := 1;qualContr('00100028492830001674115').nrdconta := 2849283;qualContr('00100028492830001674115').nrctremp := 1674115;qualContr('00100028492830001674115').idquapro := 3;
    qualContr('00100020318330001676746').cdcooper := 1;qualContr('00100020318330001676746').nrdconta := 2031833;qualContr('00100020318330001676746').nrctremp := 1676746;qualContr('00100020318330001676746').idquapro := 3;
    qualContr('00100067721530000147245').cdcooper := 1;qualContr('00100067721530000147245').nrdconta := 6772153;qualContr('00100067721530000147245').nrctremp := 147245;qualContr('00100067721530000147245').idquapro := 3;
    qualContr('00100093047380001675947').cdcooper := 1;qualContr('00100093047380001675947').nrdconta := 9304738;qualContr('00100093047380001675947').nrctremp := 1675947;qualContr('00100093047380001675947').idquapro := 3;
    qualContr('00100099201880001675895').cdcooper := 1;qualContr('00100099201880001675895').nrdconta := 9920188;qualContr('00100099201880001675895').nrctremp := 1675895;qualContr('00100099201880001675895').idquapro := 4;
    qualContr('00100060045470001675361').cdcooper := 1;qualContr('00100060045470001675361').nrdconta := 6004547;qualContr('00100060045470001675361').nrctremp := 1675361;qualContr('00100060045470001675361').idquapro := 3;
    qualContr('00100026597780001677789').cdcooper := 1;qualContr('00100026597780001677789').nrdconta := 2659778;qualContr('00100026597780001677789').nrctremp := 1677789;qualContr('00100026597780001677789').idquapro := 3;
    qualContr('00100096666210001678952').cdcooper := 1;qualContr('00100096666210001678952').nrdconta := 9666621;qualContr('00100096666210001678952').nrctremp := 1678952;qualContr('00100096666210001678952').idquapro := 4;
    qualContr('00100070119890001680525').cdcooper := 1;qualContr('00100070119890001680525').nrdconta := 7011989;qualContr('00100070119890001680525').nrctremp := 1680525;qualContr('00100070119890001680525').idquapro := 3;
    qualContr('00100021416040001680371').cdcooper := 1;qualContr('00100021416040001680371').nrdconta := 2141604;qualContr('00100021416040001680371').nrctremp := 1680371;qualContr('00100021416040001680371').idquapro := 3;
    qualContr('00100064740710001680383').cdcooper := 1;qualContr('00100064740710001680383').nrdconta := 6474071;qualContr('00100064740710001680383').nrctremp := 1680383;qualContr('00100064740710001680383').idquapro := 3;
    qualContr('00100083904360001682810').cdcooper := 1;qualContr('00100083904360001682810').nrdconta := 8390436;qualContr('00100083904360001682810').nrctremp := 1682810;qualContr('00100083904360001682810').idquapro := 3;
    qualContr('00100102402090001682510').cdcooper := 1;qualContr('00100102402090001682510').nrdconta := 10240209;qualContr('00100102402090001682510').nrctremp := 1682510;qualContr('00100102402090001682510').idquapro := 4;
    qualContr('00100065639530001682548').cdcooper := 1;qualContr('00100065639530001682548').nrdconta := 6563953;qualContr('00100065639530001682548').nrctremp := 1682548;qualContr('00100065639530001682548').idquapro := 3;
    qualContr('00100083353200001684226').cdcooper := 1;qualContr('00100083353200001684226').nrdconta := 8335320;qualContr('00100083353200001684226').nrctremp := 1684226;qualContr('00100083353200001684226').idquapro := 4;
    qualContr('00100022808330001686776').cdcooper := 1;qualContr('00100022808330001686776').nrdconta := 2280833;qualContr('00100022808330001686776').nrctremp := 1686776;qualContr('00100022808330001686776').idquapro := 3;
    qualContr('00100106381130001685861').cdcooper := 1;qualContr('00100106381130001685861').nrdconta := 10638113;qualContr('00100106381130001685861').nrctremp := 1685861;qualContr('00100106381130001685861').idquapro := 3;
    qualContr('00100063682200001688291').cdcooper := 1;qualContr('00100063682200001688291').nrdconta := 6368220;qualContr('00100063682200001688291').nrctremp := 1688291;qualContr('00100063682200001688291').idquapro := 3;
    qualContr('00100039563340001700343').cdcooper := 1;qualContr('00100039563340001700343').nrdconta := 3956334;qualContr('00100039563340001700343').nrctremp := 1700343;qualContr('00100039563340001700343').idquapro := 3;
    qualContr('00100082333490001700939').cdcooper := 1;qualContr('00100082333490001700939').nrdconta := 8233349;qualContr('00100082333490001700939').nrctremp := 1700939;qualContr('00100082333490001700939').idquapro := 3;
    qualContr('00100094495580001699184').cdcooper := 1;qualContr('00100094495580001699184').nrdconta := 9449558;qualContr('00100094495580001699184').nrctremp := 1699184;qualContr('00100094495580001699184').idquapro := 3;
    qualContr('00100038567710001700649').cdcooper := 1;qualContr('00100038567710001700649').nrdconta := 3856771;qualContr('00100038567710001700649').nrctremp := 1700649;qualContr('00100038567710001700649').idquapro := 3;
    qualContr('00100009746840001702193').cdcooper := 1;qualContr('00100009746840001702193').nrdconta := 974684;qualContr('00100009746840001702193').nrctremp := 1702193;qualContr('00100009746840001702193').idquapro := 3;
    qualContr('00100105721200001707280').cdcooper := 1;qualContr('00100105721200001707280').nrdconta := 10572120;qualContr('00100105721200001707280').nrctremp := 1707280;qualContr('00100105721200001707280').idquapro := 3;
    qualContr('00100022212170001706165').cdcooper := 1;qualContr('00100022212170001706165').nrdconta := 2221217;qualContr('00100022212170001706165').nrctremp := 1706165;qualContr('00100022212170001706165').idquapro := 3;
    qualContr('00100069886950001708367').cdcooper := 1;qualContr('00100069886950001708367').nrdconta := 6988695;qualContr('00100069886950001708367').nrctremp := 1708367;qualContr('00100069886950001708367').idquapro := 3;
    qualContr('00100103257190001714302').cdcooper := 1;qualContr('00100103257190001714302').nrdconta := 10325719;qualContr('00100103257190001714302').nrctremp := 1714302;qualContr('00100103257190001714302').idquapro := 3;
    qualContr('00100068809830001716640').cdcooper := 1;qualContr('00100068809830001716640').nrdconta := 6880983;qualContr('00100068809830001716640').nrctremp := 1716640;qualContr('00100068809830001716640').idquapro := 4;
    qualContr('00100021411670001713911').cdcooper := 1;qualContr('00100021411670001713911').nrdconta := 2141167;qualContr('00100021411670001713911').nrctremp := 1713911;qualContr('00100021411670001713911').idquapro := 3;
    qualContr('00100103369740001720497').cdcooper := 1;qualContr('00100103369740001720497').nrdconta := 10336974;qualContr('00100103369740001720497').nrctremp := 1720497;qualContr('00100103369740001720497').idquapro := 3;
    qualContr('00100026963550001718442').cdcooper := 1;qualContr('00100026963550001718442').nrdconta := 2696355;qualContr('00100026963550001718442').nrctremp := 1718442;qualContr('00100026963550001718442').idquapro := 3;
    qualContr('00100104820080001719226').cdcooper := 1;qualContr('00100104820080001719226').nrdconta := 10482008;qualContr('00100104820080001719226').nrctremp := 1719226;qualContr('00100104820080001719226').idquapro := 3;
    qualContr('00100101983340001722603').cdcooper := 1;qualContr('00100101983340001722603').nrdconta := 10198334;qualContr('00100101983340001722603').nrctremp := 1722603;qualContr('00100101983340001722603').idquapro := 3;
    qualContr('00100022825420001724387').cdcooper := 1;qualContr('00100022825420001724387').nrdconta := 2282542;qualContr('00100022825420001724387').nrctremp := 1724387;qualContr('00100022825420001724387').idquapro := 3;
    qualContr('00100078839000001723957').cdcooper := 1;qualContr('00100078839000001723957').nrdconta := 7883900;qualContr('00100078839000001723957').nrctremp := 1723957;qualContr('00100078839000001723957').idquapro := 3;
    qualContr('00100103267580001724582').cdcooper := 1;qualContr('00100103267580001724582').nrdconta := 10326758;qualContr('00100103267580001724582').nrctremp := 1724582;qualContr('00100103267580001724582').idquapro := 3;
    qualContr('00100086408820001724545').cdcooper := 1;qualContr('00100086408820001724545').nrdconta := 8640882;qualContr('00100086408820001724545').nrctremp := 1724545;qualContr('00100086408820001724545').idquapro := 3;
    qualContr('00100103409390001728126').cdcooper := 1;qualContr('00100103409390001728126').nrdconta := 10340939;qualContr('00100103409390001728126').nrctremp := 1728126;qualContr('00100103409390001728126').idquapro := 3;
    qualContr('00100087777800001726598').cdcooper := 1;qualContr('00100087777800001726598').nrdconta := 8777780;qualContr('00100087777800001726598').nrctremp := 1726598;qualContr('00100087777800001726598').idquapro := 3;
    qualContr('00100081756910001730405').cdcooper := 1;qualContr('00100081756910001730405').nrdconta := 8175691;qualContr('00100081756910001730405').nrctremp := 1730405;qualContr('00100081756910001730405').idquapro := 3;
    qualContr('00100022042740001731001').cdcooper := 1;qualContr('00100022042740001731001').nrdconta := 2204274;qualContr('00100022042740001731001').nrctremp := 1731001;qualContr('00100022042740001731001').idquapro := 3;
    qualContr('00100083747590001730299').cdcooper := 1;qualContr('00100083747590001730299').nrdconta := 8374759;qualContr('00100083747590001730299').nrctremp := 1730299;qualContr('00100083747590001730299').idquapro := 3;
    qualContr('00100036096690001734418').cdcooper := 1;qualContr('00100036096690001734418').nrdconta := 3609669;qualContr('00100036096690001734418').nrctremp := 1734418;qualContr('00100036096690001734418').idquapro := 3;
    qualContr('00100087193900001735737').cdcooper := 1;qualContr('00100087193900001735737').nrdconta := 8719390;qualContr('00100087193900001735737').nrctremp := 1735737;qualContr('00100087193900001735737').idquapro := 3;
    qualContr('00100079794600001735734').cdcooper := 1;qualContr('00100079794600001735734').nrdconta := 7979460;qualContr('00100079794600001735734').nrctremp := 1735734;qualContr('00100079794600001735734').idquapro := 3;
    qualContr('00100090729340001734545').cdcooper := 1;qualContr('00100090729340001734545').nrdconta := 9072934;qualContr('00100090729340001734545').nrctremp := 1734545;qualContr('00100090729340001734545').idquapro := 3;
    qualContr('00100103584040001735839').cdcooper := 1;qualContr('00100103584040001735839').nrdconta := 10358404;qualContr('00100103584040001735839').nrctremp := 1735839;qualContr('00100103584040001735839').idquapro := 3;
    qualContr('00100100072290001736389').cdcooper := 1;qualContr('00100100072290001736389').nrdconta := 10007229;qualContr('00100100072290001736389').nrctremp := 1736389;qualContr('00100100072290001736389').idquapro := 3;
    qualContr('00100087206490001739824').cdcooper := 1;qualContr('00100087206490001739824').nrdconta := 8720649;qualContr('00100087206490001739824').nrctremp := 1739824;qualContr('00100087206490001739824').idquapro := 3;
    qualContr('00100099754110001740383').cdcooper := 1;qualContr('00100099754110001740383').nrdconta := 9975411;qualContr('00100099754110001740383').nrctremp := 1740383;qualContr('00100099754110001740383').idquapro := 4;
    qualContr('00100015139820001742764').cdcooper := 1;qualContr('00100015139820001742764').nrdconta := 1513982;qualContr('00100015139820001742764').nrctremp := 1742764;qualContr('00100015139820001742764').idquapro := 3;
    qualContr('00100061213220001747469').cdcooper := 1;qualContr('00100061213220001747469').nrdconta := 6121322;qualContr('00100061213220001747469').nrctremp := 1747469;qualContr('00100061213220001747469').idquapro := 3;
    qualContr('00100072545390001748928').cdcooper := 1;qualContr('00100072545390001748928').nrdconta := 7254539;qualContr('00100072545390001748928').nrctremp := 1748928;qualContr('00100072545390001748928').idquapro := 3;
    qualContr('00100073208920001748977').cdcooper := 1;qualContr('00100073208920001748977').nrdconta := 7320892;qualContr('00100073208920001748977').nrctremp := 1748977;qualContr('00100073208920001748977').idquapro := 3;
    qualContr('00100092928370001753307').cdcooper := 1;qualContr('00100092928370001753307').nrdconta := 9292837;qualContr('00100092928370001753307').nrctremp := 1753307;qualContr('00100092928370001753307').idquapro := 3;
    qualContr('00100083589740001758697').cdcooper := 1;qualContr('00100083589740001758697').nrdconta := 8358974;qualContr('00100083589740001758697').nrctremp := 1758697;qualContr('00100083589740001758697').idquapro := 3;
    qualContr('00100069995900001760324').cdcooper := 1;qualContr('00100069995900001760324').nrdconta := 6999590;qualContr('00100069995900001760324').nrctremp := 1760324;qualContr('00100069995900001760324').idquapro := 3;
    qualContr('00100100881800001764152').cdcooper := 1;qualContr('00100100881800001764152').nrdconta := 10088180;qualContr('00100100881800001764152').nrctremp := 1764152;qualContr('00100100881800001764152').idquapro := 3;
    qualContr('00100103720830001763423').cdcooper := 1;qualContr('00100103720830001763423').nrdconta := 10372083;qualContr('00100103720830001763423').nrctremp := 1763423;qualContr('00100103720830001763423').idquapro := 3;
    qualContr('00100070321450001764393').cdcooper := 1;qualContr('00100070321450001764393').nrdconta := 7032145;qualContr('00100070321450001764393').nrctremp := 1764393;qualContr('00100070321450001764393').idquapro := 3;
    qualContr('00100097505090001763436').cdcooper := 1;qualContr('00100097505090001763436').nrdconta := 9750509;qualContr('00100097505090001763436').nrctremp := 1763436;qualContr('00100097505090001763436').idquapro := 3;
    qualContr('00100064567660001763641').cdcooper := 1;qualContr('00100064567660001763641').nrdconta := 6456766;qualContr('00100064567660001763641').nrctremp := 1763641;qualContr('00100064567660001763641').idquapro := 3;
    qualContr('00100098305880001763733').cdcooper := 1;qualContr('00100098305880001763733').nrdconta := 9830588;qualContr('00100098305880001763733').nrctremp := 1763733;qualContr('00100098305880001763733').idquapro := 3;
    qualContr('00100018289830001763393').cdcooper := 1;qualContr('00100018289830001763393').nrdconta := 1828983;qualContr('00100018289830001763393').nrctremp := 1763393;qualContr('00100018289830001763393').idquapro := 3;
    qualContr('00100036394360001766143').cdcooper := 1;qualContr('00100036394360001766143').nrdconta := 3639436;qualContr('00100036394360001766143').nrctremp := 1766143;qualContr('00100036394360001766143').idquapro := 3;
    qualContr('00100077483880001765949').cdcooper := 1;qualContr('00100077483880001765949').nrdconta := 7748388;qualContr('00100077483880001765949').nrctremp := 1765949;qualContr('00100077483880001765949').idquapro := 3;
    qualContr('00100099818530001770645').cdcooper := 1;qualContr('00100099818530001770645').nrdconta := 9981853;qualContr('00100099818530001770645').nrctremp := 1770645;qualContr('00100099818530001770645').idquapro := 4;
    qualContr('00100094171170001774895').cdcooper := 1;qualContr('00100094171170001774895').nrdconta := 9417117;qualContr('00100094171170001774895').nrctremp := 1774895;qualContr('00100094171170001774895').idquapro := 4;
    qualContr('00100091396800001774892').cdcooper := 1;qualContr('00100091396800001774892').nrdconta := 9139680;qualContr('00100091396800001774892').nrctremp := 1774892;qualContr('00100091396800001774892').idquapro := 3;
    qualContr('00100104268090001778320').cdcooper := 1;qualContr('00100104268090001778320').nrdconta := 10426809;qualContr('00100104268090001778320').nrctremp := 1778320;qualContr('00100104268090001778320').idquapro := 3;
    qualContr('00100069836340001776967').cdcooper := 1;qualContr('00100069836340001776967').nrdconta := 6983634;qualContr('00100069836340001776967').nrctremp := 1776967;qualContr('00100069836340001776967').idquapro := 3;
    qualContr('00100025623080001779034').cdcooper := 1;qualContr('00100025623080001779034').nrdconta := 2562308;qualContr('00100025623080001779034').nrctremp := 1779034;qualContr('00100025623080001779034').idquapro := 3;
    qualContr('00100087027990001779729').cdcooper := 1;qualContr('00100087027990001779729').nrdconta := 8702799;qualContr('00100087027990001779729').nrctremp := 1779729;qualContr('00100087027990001779729').idquapro := 3;
    qualContr('00100103324480001783174').cdcooper := 1;qualContr('00100103324480001783174').nrdconta := 10332448;qualContr('00100103324480001783174').nrctremp := 1783174;qualContr('00100103324480001783174').idquapro := 3;
    qualContr('00100099028210001784254').cdcooper := 1;qualContr('00100099028210001784254').nrdconta := 9902821;qualContr('00100099028210001784254').nrctremp := 1784254;qualContr('00100099028210001784254').idquapro := 3;
    qualContr('00100103083500001783752').cdcooper := 1;qualContr('00100103083500001783752').nrdconta := 10308350;qualContr('00100103083500001783752').nrctremp := 1783752;qualContr('00100103083500001783752').idquapro := 4;
    qualContr('00100071111850001783032').cdcooper := 1;qualContr('00100071111850001783032').nrdconta := 7111185;qualContr('00100071111850001783032').nrctremp := 1783032;qualContr('00100071111850001783032').idquapro := 3;
    qualContr('00100088849000001787005').cdcooper := 1;qualContr('00100088849000001787005').nrdconta := 8884900;qualContr('00100088849000001787005').nrctremp := 1787005;qualContr('00100088849000001787005').idquapro := 3;
    qualContr('00100099665870001788152').cdcooper := 1;qualContr('00100099665870001788152').nrdconta := 9966587;qualContr('00100099665870001788152').nrctremp := 1788152;qualContr('00100099665870001788152').idquapro := 3;
    qualContr('00100093288310001791254').cdcooper := 1;qualContr('00100093288310001791254').nrdconta := 9328831;qualContr('00100093288310001791254').nrctremp := 1791254;qualContr('00100093288310001791254').idquapro := 4;
    qualContr('00100070391580001790885').cdcooper := 1;qualContr('00100070391580001790885').nrdconta := 7039158;qualContr('00100070391580001790885').nrctremp := 1790885;qualContr('00100070391580001790885').idquapro := 3;
    qualContr('00100072121430001790864').cdcooper := 1;qualContr('00100072121430001790864').nrdconta := 7212143;qualContr('00100072121430001790864').nrctremp := 1790864;qualContr('00100072121430001790864').idquapro := 3;
    qualContr('00100071927620001794172').cdcooper := 1;qualContr('00100071927620001794172').nrdconta := 7192762;qualContr('00100071927620001794172').nrctremp := 1794172;qualContr('00100071927620001794172').idquapro := 3;
    qualContr('00100081488480001796680').cdcooper := 1;qualContr('00100081488480001796680').nrdconta := 8148848;qualContr('00100081488480001796680').nrctremp := 1796680;qualContr('00100081488480001796680').idquapro := 4;
    qualContr('00100104967180001797713').cdcooper := 1;qualContr('00100104967180001797713').nrdconta := 10496718;qualContr('00100104967180001797713').nrctremp := 1797713;qualContr('00100104967180001797713').idquapro := 3;
    qualContr('00100100237980001796451').cdcooper := 1;qualContr('00100100237980001796451').nrdconta := 10023798;qualContr('00100100237980001796451').nrctremp := 1796451;qualContr('00100100237980001796451').idquapro := 3;
    qualContr('00100022273550001796882').cdcooper := 1;qualContr('00100022273550001796882').nrdconta := 2227355;qualContr('00100022273550001796882').nrctremp := 1796882;qualContr('00100022273550001796882').idquapro := 3;
    qualContr('00100084850620001800313').cdcooper := 1;qualContr('00100084850620001800313').nrdconta := 8485062;qualContr('00100084850620001800313').nrctremp := 1800313;qualContr('00100084850620001800313').idquapro := 3;
    qualContr('00100039175330001801823').cdcooper := 1;qualContr('00100039175330001801823').nrdconta := 3917533;qualContr('00100039175330001801823').nrctremp := 1801823;qualContr('00100039175330001801823').idquapro := 4;
    qualContr('00100073400010001808136').cdcooper := 1;qualContr('00100073400010001808136').nrdconta := 7340001;qualContr('00100073400010001808136').nrctremp := 1808136;qualContr('00100073400010001808136').idquapro := 3;
    qualContr('00100079117850001807056').cdcooper := 1;qualContr('00100079117850001807056').nrdconta := 7911785;qualContr('00100079117850001807056').nrctremp := 1807056;qualContr('00100079117850001807056').idquapro := 3;
    qualContr('00100082317530001805467').cdcooper := 1;qualContr('00100082317530001805467').nrdconta := 8231753;qualContr('00100082317530001805467').nrctremp := 1805467;qualContr('00100082317530001805467').idquapro := 3;
    qualContr('00100101337390001807702').cdcooper := 1;qualContr('00100101337390001807702').nrdconta := 10133739;qualContr('00100101337390001807702').nrctremp := 1807702;qualContr('00100101337390001807702').idquapro := 3;
    qualContr('00100100422370001805847').cdcooper := 1;qualContr('00100100422370001805847').nrdconta := 10042237;qualContr('00100100422370001805847').nrctremp := 1805847;qualContr('00100100422370001805847').idquapro := 3;
    qualContr('00100073809680001814458').cdcooper := 1;qualContr('00100073809680001814458').nrdconta := 7380968;qualContr('00100073809680001814458').nrctremp := 1814458;qualContr('00100073809680001814458').idquapro := 4;
    qualContr('00100078741890001815415').cdcooper := 1;qualContr('00100078741890001815415').nrdconta := 7874189;qualContr('00100078741890001815415').nrctremp := 1815415;qualContr('00100078741890001815415').idquapro := 4;
    qualContr('00100090636760001819146').cdcooper := 1;qualContr('00100090636760001819146').nrdconta := 9063676;qualContr('00100090636760001819146').nrctremp := 1819146;qualContr('00100090636760001819146').idquapro := 3;
    qualContr('00100071795290001818358').cdcooper := 1;qualContr('00100071795290001818358').nrdconta := 7179529;qualContr('00100071795290001818358').nrctremp := 1818358;qualContr('00100071795290001818358').idquapro := 3;
    qualContr('00100071905060001825852').cdcooper := 1;qualContr('00100071905060001825852').nrdconta := 7190506;qualContr('00100071905060001825852').nrctremp := 1825852;qualContr('00100071905060001825852').idquapro := 4;
    qualContr('00100080989300001823622').cdcooper := 1;qualContr('00100080989300001823622').nrdconta := 8098930;qualContr('00100080989300001823622').nrctremp := 1823622;qualContr('00100080989300001823622').idquapro := 3;
    qualContr('00100028206170001824780').cdcooper := 1;qualContr('00100028206170001824780').nrdconta := 2820617;qualContr('00100028206170001824780').nrctremp := 1824780;qualContr('00100028206170001824780').idquapro := 3;
    qualContr('00100031372100001823963').cdcooper := 1;qualContr('00100031372100001823963').nrdconta := 3137210;qualContr('00100031372100001823963').nrctremp := 1823963;qualContr('00100031372100001823963').idquapro := 3;
    qualContr('00100085552900001824057').cdcooper := 1;qualContr('00100085552900001824057').nrdconta := 8555290;qualContr('00100085552900001824057').nrctremp := 1824057;qualContr('00100085552900001824057').idquapro := 3;
    qualContr('00100019456290001822688').cdcooper := 1;qualContr('00100019456290001822688').nrdconta := 1945629;qualContr('00100019456290001822688').nrctremp := 1822688;qualContr('00100019456290001822688').idquapro := 3;
    qualContr('00100039525760001828113').cdcooper := 1;qualContr('00100039525760001828113').nrdconta := 3952576;qualContr('00100039525760001828113').nrctremp := 1828113;qualContr('00100039525760001828113').idquapro := 3;
    qualContr('00100061932930001828074').cdcooper := 1;qualContr('00100061932930001828074').nrdconta := 6193293;qualContr('00100061932930001828074').nrctremp := 1828074;qualContr('00100061932930001828074').idquapro := 3;
    qualContr('00100081569050001828559').cdcooper := 1;qualContr('00100081569050001828559').nrdconta := 8156905;qualContr('00100081569050001828559').nrctremp := 1828559;qualContr('00100081569050001828559').idquapro := 3;
    qualContr('00100074433150001830788').cdcooper := 1;qualContr('00100074433150001830788').nrdconta := 7443315;qualContr('00100074433150001830788').nrctremp := 1830788;qualContr('00100074433150001830788').idquapro := 4;
    qualContr('00100029814670001835293').cdcooper := 1;qualContr('00100029814670001835293').nrdconta := 2981467;qualContr('00100029814670001835293').nrctremp := 1835293;qualContr('00100029814670001835293').idquapro := 4;
    qualContr('00100094965300001834150').cdcooper := 1;qualContr('00100094965300001834150').nrdconta := 9496530;qualContr('00100094965300001834150').nrctremp := 1834150;qualContr('00100094965300001834150').idquapro := 4;
    qualContr('00100061234900001838320').cdcooper := 1;qualContr('00100061234900001838320').nrdconta := 6123490;qualContr('00100061234900001838320').nrctremp := 1838320;qualContr('00100061234900001838320').idquapro := 4;
    qualContr('00100030379400001838669').cdcooper := 1;qualContr('00100030379400001838669').nrdconta := 3037940;qualContr('00100030379400001838669').nrctremp := 1838669;qualContr('00100030379400001838669').idquapro := 3;
    qualContr('00100020903840001842176').cdcooper := 1;qualContr('00100020903840001842176').nrdconta := 2090384;qualContr('00100020903840001842176').nrctremp := 1842176;qualContr('00100020903840001842176').idquapro := 3;
    qualContr('00100043995870001843983').cdcooper := 1;qualContr('00100043995870001843983').nrdconta := 4399587;qualContr('00100043995870001843983').nrctremp := 1843983;qualContr('00100043995870001843983').idquapro := 3;
    qualContr('00100036528070001845537').cdcooper := 1;qualContr('00100036528070001845537').nrdconta := 3652807;qualContr('00100036528070001845537').nrctremp := 1845537;qualContr('00100036528070001845537').idquapro := 3;
    qualContr('00100091899980001846905').cdcooper := 1;qualContr('00100091899980001846905').nrdconta := 9189998;qualContr('00100091899980001846905').nrctremp := 1846905;qualContr('00100091899980001846905').idquapro := 4;
    qualContr('00100026488220001852426').cdcooper := 1;qualContr('00100026488220001852426').nrdconta := 2648822;qualContr('00100026488220001852426').nrctremp := 1852426;qualContr('00100026488220001852426').idquapro := 3;
    qualContr('00100106172560001856617').cdcooper := 1;qualContr('00100106172560001856617').nrdconta := 10617256;qualContr('00100106172560001856617').nrctremp := 1856617;qualContr('00100106172560001856617').idquapro := 3;
    qualContr('00100098180300001856459').cdcooper := 1;qualContr('00100098180300001856459').nrdconta := 9818030;qualContr('00100098180300001856459').nrctremp := 1856459;qualContr('00100098180300001856459').idquapro := 4;
    qualContr('00100105970420001855167').cdcooper := 1;qualContr('00100105970420001855167').nrdconta := 10597042;qualContr('00100105970420001855167').nrctremp := 1855167;qualContr('00100105970420001855167').idquapro := 3;
    qualContr('00100101741170001855911').cdcooper := 1;qualContr('00100101741170001855911').nrdconta := 10174117;qualContr('00100101741170001855911').nrctremp := 1855911;qualContr('00100101741170001855911').idquapro := 3;
    qualContr('00100067755780001856932').cdcooper := 1;qualContr('00100067755780001856932').nrdconta := 6775578;qualContr('00100067755780001856932').nrctremp := 1856932;qualContr('00100067755780001856932').idquapro := 4;
    qualContr('00100099581690001861772').cdcooper := 1;qualContr('00100099581690001861772').nrdconta := 9958169;qualContr('00100099581690001861772').nrctremp := 1861772;qualContr('00100099581690001861772').idquapro := 3;
    qualContr('00100079831400001859636').cdcooper := 1;qualContr('00100079831400001859636').nrdconta := 7983140;qualContr('00100079831400001859636').nrctremp := 1859636;qualContr('00100079831400001859636').idquapro := 3;
    qualContr('00100097545550001859403').cdcooper := 1;qualContr('00100097545550001859403').nrdconta := 9754555;qualContr('00100097545550001859403').nrctremp := 1859403;qualContr('00100097545550001859403').idquapro := 3;
    qualContr('00100079067570001860834').cdcooper := 1;qualContr('00100079067570001860834').nrdconta := 7906757;qualContr('00100079067570001860834').nrctremp := 1860834;qualContr('00100079067570001860834').idquapro := 4;
    qualContr('00100106214580001861909').cdcooper := 1;qualContr('00100106214580001861909').nrdconta := 10621458;qualContr('00100106214580001861909').nrctremp := 1861909;qualContr('00100106214580001861909').idquapro := 3;
    qualContr('00100060756900001863217').cdcooper := 1;qualContr('00100060756900001863217').nrdconta := 6075690;qualContr('00100060756900001863217').nrctremp := 1863217;qualContr('00100060756900001863217').idquapro := 3;
    qualContr('00100066887300001869813').cdcooper := 1;qualContr('00100066887300001869813').nrdconta := 6688730;qualContr('00100066887300001869813').nrctremp := 1869813;qualContr('00100066887300001869813').idquapro := 3;
    qualContr('00100100387950001873407').cdcooper := 1;qualContr('00100100387950001873407').nrdconta := 10038795;qualContr('00100100387950001873407').nrctremp := 1873407;qualContr('00100100387950001873407').idquapro := 3;
    qualContr('00100106412110001878695').cdcooper := 1;qualContr('00100106412110001878695').nrdconta := 10641211;qualContr('00100106412110001878695').nrctremp := 1878695;qualContr('00100106412110001878695').idquapro := 3;
    qualContr('00100019356900001884004').cdcooper := 1;qualContr('00100019356900001884004').nrdconta := 1935690;qualContr('00100019356900001884004').nrctremp := 1884004;qualContr('00100019356900001884004').idquapro := 3;
    qualContr('00100086519060001881590').cdcooper := 1;qualContr('00100086519060001881590').nrdconta := 8651906;qualContr('00100086519060001881590').nrctremp := 1881590;qualContr('00100086519060001881590').idquapro := 3;
    qualContr('00100099298350001883608').cdcooper := 1;qualContr('00100099298350001883608').nrdconta := 9929835;qualContr('00100099298350001883608').nrctremp := 1883608;qualContr('00100099298350001883608').idquapro := 3;
    qualContr('00100094157000001883480').cdcooper := 1;qualContr('00100094157000001883480').nrdconta := 9415700;qualContr('00100094157000001883480').nrctremp := 1883480;qualContr('00100094157000001883480').idquapro := 3;
    qualContr('00100098094810001886568').cdcooper := 1;qualContr('00100098094810001886568').nrdconta := 9809481;qualContr('00100098094810001886568').nrctremp := 1886568;qualContr('00100098094810001886568').idquapro := 4;
    qualContr('00100073414070001888353').cdcooper := 1;qualContr('00100073414070001888353').nrdconta := 7341407;qualContr('00100073414070001888353').nrctremp := 1888353;qualContr('00100073414070001888353').idquapro := 3;
    qualContr('00100102997260001893511').cdcooper := 1;qualContr('00100102997260001893511').nrdconta := 10299726;qualContr('00100102997260001893511').nrctremp := 1893511;qualContr('00100102997260001893511').idquapro := 3;
    qualContr('00100101472410001893999').cdcooper := 1;qualContr('00100101472410001893999').nrdconta := 10147241;qualContr('00100101472410001893999').nrctremp := 1893999;qualContr('00100101472410001893999').idquapro := 3;
    qualContr('00100107817220001893926').cdcooper := 1;qualContr('00100107817220001893926').nrdconta := 10781722;qualContr('00100107817220001893926').nrctremp := 1893926;qualContr('00100107817220001893926').idquapro := 3;
    qualContr('00100060878250001898876').cdcooper := 1;qualContr('00100060878250001898876').nrdconta := 6087825;qualContr('00100060878250001898876').nrctremp := 1898876;qualContr('00100060878250001898876').idquapro := 3;
    qualContr('00100065129170001897441').cdcooper := 1;qualContr('00100065129170001897441').nrdconta := 6512917;qualContr('00100065129170001897441').nrctremp := 1897441;qualContr('00100065129170001897441').idquapro := 3;
    qualContr('00100079773010001898109').cdcooper := 1;qualContr('00100079773010001898109').nrdconta := 7977301;qualContr('00100079773010001898109').nrctremp := 1898109;qualContr('00100079773010001898109').idquapro := 3;
    qualContr('00100009861000001902829').cdcooper := 1;qualContr('00100009861000001902829').nrdconta := 986100;qualContr('00100009861000001902829').nrctremp := 1902829;qualContr('00100009861000001902829').idquapro := 3;
    qualContr('00100063336210001906620').cdcooper := 1;qualContr('00100063336210001906620').nrdconta := 6333621;qualContr('00100063336210001906620').nrctremp := 1906620;qualContr('00100063336210001906620').idquapro := 3;
    qualContr('00100099634210001911542').cdcooper := 1;qualContr('00100099634210001911542').nrdconta := 9963421;qualContr('00100099634210001911542').nrctremp := 1911542;qualContr('00100099634210001911542').idquapro := 3;
    qualContr('00100097669600001910438').cdcooper := 1;qualContr('00100097669600001910438').nrdconta := 9766960;qualContr('00100097669600001910438').nrctremp := 1910438;qualContr('00100097669600001910438').idquapro := 3;
    qualContr('00100040026280001911689').cdcooper := 1;qualContr('00100040026280001911689').nrdconta := 4002628;qualContr('00100040026280001911689').nrctremp := 1911689;qualContr('00100040026280001911689').idquapro := 3;
    qualContr('00100070182400001910185').cdcooper := 1;qualContr('00100070182400001910185').nrdconta := 7018240;qualContr('00100070182400001910185').nrctremp := 1910185;qualContr('00100070182400001910185').idquapro := 3;
    qualContr('00100105244280001916134').cdcooper := 1;qualContr('00100105244280001916134').nrdconta := 10524428;qualContr('00100105244280001916134').nrctremp := 1916134;qualContr('00100105244280001916134').idquapro := 3;
    qualContr('00100097235600001915255').cdcooper := 1;qualContr('00100097235600001915255').nrdconta := 9723560;qualContr('00100097235600001915255').nrctremp := 1915255;qualContr('00100097235600001915255').idquapro := 4;
    qualContr('00100099822300001916982').cdcooper := 1;qualContr('00100099822300001916982').nrdconta := 9982230;qualContr('00100099822300001916982').nrctremp := 1916982;qualContr('00100099822300001916982').idquapro := 4;
    qualContr('00100072850510001919657').cdcooper := 1;qualContr('00100072850510001919657').nrdconta := 7285051;qualContr('00100072850510001919657').nrctremp := 1919657;qualContr('00100072850510001919657').idquapro := 3;
    qualContr('00100069931680001919785').cdcooper := 1;qualContr('00100069931680001919785').nrdconta := 6993168;qualContr('00100069931680001919785').nrctremp := 1919785;qualContr('00100069931680001919785').idquapro := 3;
    qualContr('00100038564450001923450').cdcooper := 1;qualContr('00100038564450001923450').nrdconta := 3856445;qualContr('00100038564450001923450').nrctremp := 1923450;qualContr('00100038564450001923450').idquapro := 4;
    qualContr('00100095910520001923410').cdcooper := 1;qualContr('00100095910520001923410').nrdconta := 9591052;qualContr('00100095910520001923410').nrctremp := 1923410;qualContr('00100095910520001923410').idquapro := 4;
    qualContr('00100078246020001932196').cdcooper := 1;qualContr('00100078246020001932196').nrdconta := 7824602;qualContr('00100078246020001932196').nrctremp := 1932196;qualContr('00100078246020001932196').idquapro := 3;
    qualContr('00100078246020001932196').cdcooper := 1;qualContr('00100078246020001932196').nrdconta := 7824602;qualContr('00100078246020001932196').nrctremp := 1932196;qualContr('00100078246020001932196').idquapro := 3;
    qualContr('00100078246020001932196').cdcooper := 1;qualContr('00100078246020001932196').nrdconta := 7824602;qualContr('00100078246020001932196').nrctremp := 1932196;qualContr('00100078246020001932196').idquapro := 3;
    qualContr('00100078246020001932196').cdcooper := 1;qualContr('00100078246020001932196').nrdconta := 7824602;qualContr('00100078246020001932196').nrctremp := 1932196;qualContr('00100078246020001932196').idquapro := 3;
    qualContr('00100036501620001932461').cdcooper := 1;qualContr('00100036501620001932461').nrdconta := 3650162;qualContr('00100036501620001932461').nrctremp := 1932461;qualContr('00100036501620001932461').idquapro := 4;
    qualContr('00100106993330001932511').cdcooper := 1;qualContr('00100106993330001932511').nrdconta := 10699333;qualContr('00100106993330001932511').nrctremp := 1932511;qualContr('00100106993330001932511').idquapro := 4;
    qualContr('00100102166420001931962').cdcooper := 1;qualContr('00100102166420001931962').nrdconta := 10216642;qualContr('00100102166420001931962').nrctremp := 1931962;qualContr('00100102166420001931962').idquapro := 3;
    qualContr('00100102166420001931962').cdcooper := 1;qualContr('00100102166420001931962').nrdconta := 10216642;qualContr('00100102166420001931962').nrctremp := 1931962;qualContr('00100102166420001931962').idquapro := 3;
    qualContr('00100102166420001931962').cdcooper := 1;qualContr('00100102166420001931962').nrdconta := 10216642;qualContr('00100102166420001931962').nrctremp := 1931962;qualContr('00100102166420001931962').idquapro := 3;
    qualContr('00100102166420001931962').cdcooper := 1;qualContr('00100102166420001931962').nrdconta := 10216642;qualContr('00100102166420001931962').nrctremp := 1931962;qualContr('00100102166420001931962').idquapro := 3;
    qualContr('00100095944690001940614').cdcooper := 1;qualContr('00100095944690001940614').nrdconta := 9594469;qualContr('00100095944690001940614').nrctremp := 1940614;qualContr('00100095944690001940614').idquapro := 4;
    qualContr('00100031357480001941300').cdcooper := 1;qualContr('00100031357480001941300').nrdconta := 3135748;qualContr('00100031357480001941300').nrctremp := 1941300;qualContr('00100031357480001941300').idquapro := 3;
    qualContr('00100104425880001940733').cdcooper := 1;qualContr('00100104425880001940733').nrdconta := 10442588;qualContr('00100104425880001940733').nrctremp := 1940733;qualContr('00100104425880001940733').idquapro := 3;
    qualContr('00100060395530001939626').cdcooper := 1;qualContr('00100060395530001939626').nrdconta := 6039553;qualContr('00100060395530001939626').nrctremp := 1939626;qualContr('00100060395530001939626').idquapro := 3;
    qualContr('00100101386920001943760').cdcooper := 1;qualContr('00100101386920001943760').nrdconta := 10138692;qualContr('00100101386920001943760').nrctremp := 1943760;qualContr('00100101386920001943760').idquapro := 3;
    qualContr('00100105982190001945607').cdcooper := 1;qualContr('00100105982190001945607').nrdconta := 10598219;qualContr('00100105982190001945607').nrctremp := 1945607;qualContr('00100105982190001945607').idquapro := 3;
    qualContr('00100081214350001943340').cdcooper := 1;qualContr('00100081214350001943340').nrdconta := 8121435;qualContr('00100081214350001943340').nrctremp := 1943340;qualContr('00100081214350001943340').idquapro := 3;
    qualContr('00100080751740001943362').cdcooper := 1;qualContr('00100080751740001943362').nrdconta := 8075174;qualContr('00100080751740001943362').nrctremp := 1943362;qualContr('00100080751740001943362').idquapro := 3;
    qualContr('00100074161560001949700').cdcooper := 1;qualContr('00100074161560001949700').nrdconta := 7416156;qualContr('00100074161560001949700').nrctremp := 1949700;qualContr('00100074161560001949700').idquapro := 3;
    qualContr('00100040092150001948463').cdcooper := 1;qualContr('00100040092150001948463').nrdconta := 4009215;qualContr('00100040092150001948463').nrctremp := 1948463;qualContr('00100040092150001948463').idquapro := 3;
    qualContr('00100066675030001949710').cdcooper := 1;qualContr('00100066675030001949710').nrdconta := 6667503;qualContr('00100066675030001949710').nrctremp := 1949710;qualContr('00100066675030001949710').idquapro := 3;
    qualContr('00100106669740001955607').cdcooper := 1;qualContr('00100106669740001955607').nrdconta := 10666974;qualContr('00100106669740001955607').nrctremp := 1955607;qualContr('00100106669740001955607').idquapro := 3;
    qualContr('00100104929680001957258').cdcooper := 1;qualContr('00100104929680001957258').nrdconta := 10492968;qualContr('00100104929680001957258').nrctremp := 1957258;qualContr('00100104929680001957258').idquapro := 3;
    qualContr('00100072223860001957835').cdcooper := 1;qualContr('00100072223860001957835').nrdconta := 7222386;qualContr('00100072223860001957835').nrctremp := 1957835;qualContr('00100072223860001957835').idquapro := 3;
    qualContr('00100030475550001958076').cdcooper := 1;qualContr('00100030475550001958076').nrdconta := 3047555;qualContr('00100030475550001958076').nrctremp := 1958076;qualContr('00100030475550001958076').idquapro := 3;
    qualContr('00100074329680001958428').cdcooper := 1;qualContr('00100074329680001958428').nrdconta := 7432968;qualContr('00100074329680001958428').nrctremp := 1958428;qualContr('00100074329680001958428').idquapro := 3;
    qualContr('00100070709180001955863').cdcooper := 1;qualContr('00100070709180001955863').nrdconta := 7070918;qualContr('00100070709180001955863').nrctremp := 1955863;qualContr('00100070709180001955863').idquapro := 3;
    qualContr('00100105163360001963767').cdcooper := 1;qualContr('00100105163360001963767').nrdconta := 10516336;qualContr('00100105163360001963767').nrctremp := 1963767;qualContr('00100105163360001963767').idquapro := 3;
    qualContr('00100070364180001962921').cdcooper := 1;qualContr('00100070364180001962921').nrdconta := 7036418;qualContr('00100070364180001962921').nrctremp := 1962921;qualContr('00100070364180001962921').idquapro := 3;
    qualContr('00100090387100001965738').cdcooper := 1;qualContr('00100090387100001965738').nrdconta := 9038710;qualContr('00100090387100001965738').nrctremp := 1965738;qualContr('00100090387100001965738').idquapro := 3;
    qualContr('00100081587380001967859').cdcooper := 1;qualContr('00100081587380001967859').nrdconta := 8158738;qualContr('00100081587380001967859').nrctremp := 1967859;qualContr('00100081587380001967859').idquapro := 3;
    qualContr('00100101086610001966008').cdcooper := 1;qualContr('00100101086610001966008').nrdconta := 10108661;qualContr('00100101086610001966008').nrctremp := 1966008;qualContr('00100101086610001966008').idquapro := 3;
    qualContr('00100107385760001966924').cdcooper := 1;qualContr('00100107385760001966924').nrdconta := 10738576;qualContr('00100107385760001966924').nrctremp := 1966924;qualContr('00100107385760001966924').idquapro := 3;
    qualContr('00100090874860001969841').cdcooper := 1;qualContr('00100090874860001969841').nrdconta := 9087486;qualContr('00100090874860001969841').nrctremp := 1969841;qualContr('00100090874860001969841').idquapro := 3;
    qualContr('00100091666100001971044').cdcooper := 1;qualContr('00100091666100001971044').nrdconta := 9166610;qualContr('00100091666100001971044').nrctremp := 1971044;qualContr('00100091666100001971044').idquapro := 3;
    qualContr('00100036847760001970259').cdcooper := 1;qualContr('00100036847760001970259').nrdconta := 3684776;qualContr('00100036847760001970259').nrctremp := 1970259;qualContr('00100036847760001970259').idquapro := 3;
    qualContr('00100024957750001969838').cdcooper := 1;qualContr('00100024957750001969838').nrdconta := 2495775;qualContr('00100024957750001969838').nrctremp := 1969838;qualContr('00100024957750001969838').idquapro := 3;
    qualContr('00100098868000001971327').cdcooper := 1;qualContr('00100098868000001971327').nrdconta := 9886800;qualContr('00100098868000001971327').nrctremp := 1971327;qualContr('00100098868000001971327').idquapro := 3;
    qualContr('00100026519120001971557').cdcooper := 1;qualContr('00100026519120001971557').nrdconta := 2651912;qualContr('00100026519120001971557').nrctremp := 1971557;qualContr('00100026519120001971557').idquapro := 3;
    qualContr('00100104492640001974768').cdcooper := 1;qualContr('00100104492640001974768').nrdconta := 10449264;qualContr('00100104492640001974768').nrctremp := 1974768;qualContr('00100104492640001974768').idquapro := 3;
    qualContr('00100015062850001976076').cdcooper := 1;qualContr('00100015062850001976076').nrdconta := 1506285;qualContr('00100015062850001976076').nrctremp := 1976076;qualContr('00100015062850001976076').idquapro := 3;
    qualContr('00100108349740001975308').cdcooper := 1;qualContr('00100108349740001975308').nrdconta := 10834974;qualContr('00100108349740001975308').nrctremp := 1975308;qualContr('00100108349740001975308').idquapro := 4;
    qualContr('00100065256790001978346').cdcooper := 1;qualContr('00100065256790001978346').nrdconta := 6525679;qualContr('00100065256790001978346').nrctremp := 1978346;qualContr('00100065256790001978346').idquapro := 3;
    qualContr('00100105304010001978253').cdcooper := 1;qualContr('00100105304010001978253').nrdconta := 10530401;qualContr('00100105304010001978253').nrctremp := 1978253;qualContr('00100105304010001978253').idquapro := 3;
    qualContr('00100039493380001983072').cdcooper := 1;qualContr('00100039493380001983072').nrdconta := 3949338;qualContr('00100039493380001983072').nrctremp := 1983072;qualContr('00100039493380001983072').idquapro := 4;
    qualContr('00100098631330001984671').cdcooper := 1;qualContr('00100098631330001984671').nrdconta := 9863133;qualContr('00100098631330001984671').nrctremp := 1984671;qualContr('00100098631330001984671').idquapro := 3;
    qualContr('00100085673600001984472').cdcooper := 1;qualContr('00100085673600001984472').nrdconta := 8567360;qualContr('00100085673600001984472').nrctremp := 1984472;qualContr('00100085673600001984472').idquapro := 3;
    qualContr('00100805721700001985257').cdcooper := 1;qualContr('00100805721700001985257').nrdconta := 80572170;qualContr('00100805721700001985257').nrctremp := 1985257;qualContr('00100805721700001985257').idquapro := 3;
    qualContr('00100037429970001988946').cdcooper := 1;qualContr('00100037429970001988946').nrdconta := 3742997;qualContr('00100037429970001988946').nrctremp := 1988946;qualContr('00100037429970001988946').idquapro := 3;
    qualContr('00100106355800001989480').cdcooper := 1;qualContr('00100106355800001989480').nrdconta := 10635580;qualContr('00100106355800001989480').nrctremp := 1989480;qualContr('00100106355800001989480').idquapro := 3;
    qualContr('00100100799980001988622').cdcooper := 1;qualContr('00100100799980001988622').nrdconta := 10079998;qualContr('00100100799980001988622').nrctremp := 1988622;qualContr('00100100799980001988622').idquapro := 3;
    qualContr('00100104791710001988292').cdcooper := 1;qualContr('00100104791710001988292').nrdconta := 10479171;qualContr('00100104791710001988292').nrctremp := 1988292;qualContr('00100104791710001988292').idquapro := 4;
    qualContr('00100082395760001992355').cdcooper := 1;qualContr('00100082395760001992355').nrdconta := 8239576;qualContr('00100082395760001992355').nrctremp := 1992355;qualContr('00100082395760001992355').idquapro := 3;
    qualContr('00100106536780001991979').cdcooper := 1;qualContr('00100106536780001991979').nrdconta := 10653678;qualContr('00100106536780001991979').nrctremp := 1991979;qualContr('00100106536780001991979').idquapro := 3;
    qualContr('00100076140630001992193').cdcooper := 1;qualContr('00100076140630001992193').nrdconta := 7614063;qualContr('00100076140630001992193').nrctremp := 1992193;qualContr('00100076140630001992193').idquapro := 4;
    qualContr('00100101743970001994144').cdcooper := 1;qualContr('00100101743970001994144').nrdconta := 10174397;qualContr('00100101743970001994144').nrctremp := 1994144;qualContr('00100101743970001994144').idquapro := 4;
    qualContr('00100082392740001995135').cdcooper := 1;qualContr('00100082392740001995135').nrdconta := 8239274;qualContr('00100082392740001995135').nrctremp := 1995135;qualContr('00100082392740001995135').idquapro := 3;
    qualContr('00100108076160001995745').cdcooper := 1;qualContr('00100108076160001995745').nrdconta := 10807616;qualContr('00100108076160001995745').nrctremp := 1995745;qualContr('00100108076160001995745').idquapro := 3;
    qualContr('00100037168210001997745').cdcooper := 1;qualContr('00100037168210001997745').nrdconta := 3716821;qualContr('00100037168210001997745').nrctremp := 1997745;qualContr('00100037168210001997745').idquapro := 4;
    qualContr('00100065304350001997622').cdcooper := 1;qualContr('00100065304350001997622').nrdconta := 6530435;qualContr('00100065304350001997622').nrctremp := 1997622;qualContr('00100065304350001997622').idquapro := 3;
    qualContr('00100108386270001999592').cdcooper := 1;qualContr('00100108386270001999592').nrdconta := 10838627;qualContr('00100108386270001999592').nrctremp := 1999592;qualContr('00100108386270001999592').idquapro := 3;
    qualContr('00100077108870002004710').cdcooper := 1;qualContr('00100077108870002004710').nrdconta := 7710887;qualContr('00100077108870002004710').nrctremp := 2004710;qualContr('00100077108870002004710').idquapro := 3;
    qualContr('00100082863290002003413').cdcooper := 1;qualContr('00100082863290002003413').nrdconta := 8286329;qualContr('00100082863290002003413').nrctremp := 2003413;qualContr('00100082863290002003413').idquapro := 3;
    qualContr('00100099108910002004856').cdcooper := 1;qualContr('00100099108910002004856').nrdconta := 9910891;qualContr('00100099108910002004856').nrctremp := 2004856;qualContr('00100099108910002004856').idquapro := 3;
    qualContr('00100086862030002004824').cdcooper := 1;qualContr('00100086862030002004824').nrdconta := 8686203;qualContr('00100086862030002004824').nrctremp := 2004824;qualContr('00100086862030002004824').idquapro := 3;
    qualContr('00100066200000002005421').cdcooper := 1;qualContr('00100066200000002005421').nrdconta := 6620000;qualContr('00100066200000002005421').nrctremp := 2005421;qualContr('00100066200000002005421').idquapro := 3;
    qualContr('00100028685200002005390').cdcooper := 1;qualContr('00100028685200002005390').nrdconta := 2868520;qualContr('00100028685200002005390').nrctremp := 2005390;qualContr('00100028685200002005390').idquapro := 3;
    qualContr('00100097501500002008045').cdcooper := 1;qualContr('00100097501500002008045').nrdconta := 9750150;qualContr('00100097501500002008045').nrctremp := 2008045;qualContr('00100097501500002008045').idquapro := 3;
    qualContr('00100035168140002006837').cdcooper := 1;qualContr('00100035168140002006837').nrdconta := 3516814;qualContr('00100035168140002006837').nrctremp := 2006837;qualContr('00100035168140002006837').idquapro := 3;
    qualContr('00100088133880002007113').cdcooper := 1;qualContr('00100088133880002007113').nrdconta := 8813388;qualContr('00100088133880002007113').nrctremp := 2007113;qualContr('00100088133880002007113').idquapro := 3;
    qualContr('00100082218710002008494').cdcooper := 1;qualContr('00100082218710002008494').nrdconta := 8221871;qualContr('00100082218710002008494').nrctremp := 2008494;qualContr('00100082218710002008494').idquapro := 3;
    qualContr('00100007455700002007413').cdcooper := 1;qualContr('00100007455700002007413').nrdconta := 745570;qualContr('00100007455700002007413').nrctremp := 2007413;qualContr('00100007455700002007413').idquapro := 4;
    qualContr('00100022788550002009312').cdcooper := 1;qualContr('00100022788550002009312').nrdconta := 2278855;qualContr('00100022788550002009312').nrctremp := 2009312;qualContr('00100022788550002009312').idquapro := 4;
    qualContr('00100097814800002007418').cdcooper := 1;qualContr('00100097814800002007418').nrdconta := 9781480;qualContr('00100097814800002007418').nrctremp := 2007418;qualContr('00100097814800002007418').idquapro := 3;
    qualContr('00100085795630002006958').cdcooper := 1;qualContr('00100085795630002006958').nrdconta := 8579563;qualContr('00100085795630002006958').nrctremp := 2006958;qualContr('00100085795630002006958').idquapro := 3;
    qualContr('00100091928240002010412').cdcooper := 1;qualContr('00100091928240002010412').nrdconta := 9192824;qualContr('00100091928240002010412').nrctremp := 2010412;qualContr('00100091928240002010412').idquapro := 3;
    qualContr('00100070701360002011239').cdcooper := 1;qualContr('00100070701360002011239').nrdconta := 7070136;qualContr('00100070701360002011239').nrctremp := 2011239;qualContr('00100070701360002011239').idquapro := 3;
    qualContr('00100080897440002012223').cdcooper := 1;qualContr('00100080897440002012223').nrdconta := 8089744;qualContr('00100080897440002012223').nrctremp := 2012223;qualContr('00100080897440002012223').idquapro := 3;
    qualContr('00100804941610002013263').cdcooper := 1;qualContr('00100804941610002013263').nrdconta := 80494161;qualContr('00100804941610002013263').nrctremp := 2013263;qualContr('00100804941610002013263').idquapro := 3;
    qualContr('00100032279440002010911').cdcooper := 1;qualContr('00100032279440002010911').nrdconta := 3227944;qualContr('00100032279440002010911').nrctremp := 2010911;qualContr('00100032279440002010911').idquapro := 3;
    qualContr('00100075350150002010667').cdcooper := 1;qualContr('00100075350150002010667').nrdconta := 7535015;qualContr('00100075350150002010667').nrctremp := 2010667;qualContr('00100075350150002010667').idquapro := 3;
    qualContr('00100095569230002013227').cdcooper := 1;qualContr('00100095569230002013227').nrdconta := 9556923;qualContr('00100095569230002013227').nrctremp := 2013227;qualContr('00100095569230002013227').idquapro := 3;
    qualContr('00100067590250002010621').cdcooper := 1;qualContr('00100067590250002010621').nrdconta := 6759025;qualContr('00100067590250002010621').nrctremp := 2010621;qualContr('00100067590250002010621').idquapro := 4;
    qualContr('00100104372660002015822').cdcooper := 1;qualContr('00100104372660002015822').nrdconta := 10437266;qualContr('00100104372660002015822').nrctremp := 2015822;qualContr('00100104372660002015822').idquapro := 4;
    qualContr('00100103180890002014259').cdcooper := 1;qualContr('00100103180890002014259').nrdconta := 10318089;qualContr('00100103180890002014259').nrctremp := 2014259;qualContr('00100103180890002014259').idquapro := 3;
    qualContr('00100077213740002016495').cdcooper := 1;qualContr('00100077213740002016495').nrdconta := 7721374;qualContr('00100077213740002016495').nrctremp := 2016495;qualContr('00100077213740002016495').idquapro := 3;
    qualContr('00100100279390002014975').cdcooper := 1;qualContr('00100100279390002014975').nrdconta := 10027939;qualContr('00100100279390002014975').nrctremp := 2014975;qualContr('00100100279390002014975').idquapro := 3;
    qualContr('00100027765100002014709').cdcooper := 1;qualContr('00100027765100002014709').nrdconta := 2776510;qualContr('00100027765100002014709').nrctremp := 2014709;qualContr('00100027765100002014709').idquapro := 3;
    qualContr('00100083999640002016518').cdcooper := 1;qualContr('00100083999640002016518').nrdconta := 8399964;qualContr('00100083999640002016518').nrctremp := 2016518;qualContr('00100083999640002016518').idquapro := 3;
    qualContr('00100082924180002015773').cdcooper := 1;qualContr('00100082924180002015773').nrdconta := 8292418;qualContr('00100082924180002015773').nrctremp := 2015773;qualContr('00100082924180002015773').idquapro := 3;
    qualContr('00100039109890002014726').cdcooper := 1;qualContr('00100039109890002014726').nrdconta := 3910989;qualContr('00100039109890002014726').nrctremp := 2014726;qualContr('00100039109890002014726').idquapro := 3;
    qualContr('00100085086400002019321').cdcooper := 1;qualContr('00100085086400002019321').nrdconta := 8508640;qualContr('00100085086400002019321').nrctremp := 2019321;qualContr('00100085086400002019321').idquapro := 4;
    qualContr('00100075802150002018423').cdcooper := 1;qualContr('00100075802150002018423').nrdconta := 7580215;qualContr('00100075802150002018423').nrctremp := 2018423;qualContr('00100075802150002018423').idquapro := 3;
    qualContr('00100099902750002019701').cdcooper := 1;qualContr('00100099902750002019701').nrdconta := 9990275;qualContr('00100099902750002019701').nrctremp := 2019701;qualContr('00100099902750002019701').idquapro := 4;
    qualContr('00100019494890002017878').cdcooper := 1;qualContr('00100019494890002017878').nrdconta := 1949489;qualContr('00100019494890002017878').nrctremp := 2017878;qualContr('00100019494890002017878').idquapro := 3;
    qualContr('00100028142690002018560').cdcooper := 1;qualContr('00100028142690002018560').nrdconta := 2814269;qualContr('00100028142690002018560').nrctremp := 2018560;qualContr('00100028142690002018560').idquapro := 4;
    qualContr('00100063762310002019600').cdcooper := 1;qualContr('00100063762310002019600').nrdconta := 6376231;qualContr('00100063762310002019600').nrctremp := 2019600;qualContr('00100063762310002019600').idquapro := 4;
    qualContr('00100072575970002019993').cdcooper := 1;qualContr('00100072575970002019993').nrdconta := 7257597;qualContr('00100072575970002019993').nrctremp := 2019993;qualContr('00100072575970002019993').idquapro := 3;
    qualContr('00100094950610002019789').cdcooper := 1;qualContr('00100094950610002019789').nrdconta := 9495061;qualContr('00100094950610002019789').nrctremp := 2019789;qualContr('00100094950610002019789').idquapro := 3;
    qualContr('00100086329100002017751').cdcooper := 1;qualContr('00100086329100002017751').nrdconta := 8632910;qualContr('00100086329100002017751').nrctremp := 2017751;qualContr('00100086329100002017751').idquapro := 2;
    qualContr('00100096542750002019448').cdcooper := 1;qualContr('00100096542750002019448').nrdconta := 9654275;qualContr('00100096542750002019448').nrctremp := 2019448;qualContr('00100096542750002019448').idquapro := 3;
    qualContr('00100070909270002019214').cdcooper := 1;qualContr('00100070909270002019214').nrdconta := 7090927;qualContr('00100070909270002019214').nrctremp := 2019214;qualContr('00100070909270002019214').idquapro := 3;
    qualContr('00100100103510002019342').cdcooper := 1;qualContr('00100100103510002019342').nrdconta := 10010351;qualContr('00100100103510002019342').nrctremp := 2019342;qualContr('00100100103510002019342').idquapro := 4;
    qualContr('00100070909190002018493').cdcooper := 1;qualContr('00100070909190002018493').nrdconta := 7090919;qualContr('00100070909190002018493').nrctremp := 2018493;qualContr('00100070909190002018493').idquapro := 4;
    qualContr('00100022627540002023869').cdcooper := 1;qualContr('00100022627540002023869').nrdconta := 2262754;qualContr('00100022627540002023869').nrctremp := 2023869;qualContr('00100022627540002023869').idquapro := 3;
    qualContr('00100084817500002025978').cdcooper := 1;qualContr('00100084817500002025978').nrdconta := 8481750;qualContr('00100084817500002025978').nrctremp := 2025978;qualContr('00100084817500002025978').idquapro := 3;
    qualContr('00100008581290002024182').cdcooper := 1;qualContr('00100008581290002024182').nrdconta := 858129;qualContr('00100008581290002024182').nrctremp := 2024182;qualContr('00100008581290002024182').idquapro := 3;
    qualContr('00100087820670002024912').cdcooper := 1;qualContr('00100087820670002024912').nrdconta := 8782067;qualContr('00100087820670002024912').nrctremp := 2024912;qualContr('00100087820670002024912').idquapro := 3;
    qualContr('00100089871490002024033').cdcooper := 1;qualContr('00100089871490002024033').nrdconta := 8987149;qualContr('00100089871490002024033').nrctremp := 2024033;qualContr('00100089871490002024033').idquapro := 3;
    qualContr('00100025725590002026405').cdcooper := 1;qualContr('00100025725590002026405').nrdconta := 2572559;qualContr('00100025725590002026405').nrctremp := 2026405;qualContr('00100025725590002026405').idquapro := 4;
    qualContr('00100101705700002023889').cdcooper := 1;qualContr('00100101705700002023889').nrdconta := 10170570;qualContr('00100101705700002023889').nrctremp := 2023889;qualContr('00100101705700002023889').idquapro := 3;
    qualContr('00100107521100002025776').cdcooper := 1;qualContr('00100107521100002025776').nrdconta := 10752110;qualContr('00100107521100002025776').nrctremp := 2025776;qualContr('00100107521100002025776').idquapro := 3;
    qualContr('00100086844210002026064').cdcooper := 1;qualContr('00100086844210002026064').nrdconta := 8684421;qualContr('00100086844210002026064').nrctremp := 2026064;qualContr('00100086844210002026064').idquapro := 3;
    qualContr('00100084008810002024971').cdcooper := 1;qualContr('00100084008810002024971').nrdconta := 8400881;qualContr('00100084008810002024971').nrctremp := 2024971;qualContr('00100084008810002024971').idquapro := 3;
    qualContr('00100073175730002024612').cdcooper := 1;qualContr('00100073175730002024612').nrdconta := 7317573;qualContr('00100073175730002024612').nrctremp := 2024612;qualContr('00100073175730002024612').idquapro := 3;
    qualContr('00100073216000002028793').cdcooper := 1;qualContr('00100073216000002028793').nrdconta := 7321600;qualContr('00100073216000002028793').nrctremp := 2028793;qualContr('00100073216000002028793').idquapro := 3;
    qualContr('00100097686020002029309').cdcooper := 1;qualContr('00100097686020002029309').nrdconta := 9768602;qualContr('00100097686020002029309').nrctremp := 2029309;qualContr('00100097686020002029309').idquapro := 3;
    qualContr('00100091993220002029305').cdcooper := 1;qualContr('00100091993220002029305').nrdconta := 9199322;qualContr('00100091993220002029305').nrctremp := 2029305;qualContr('00100091993220002029305').idquapro := 3;
    qualContr('00100079742990002028629').cdcooper := 1;qualContr('00100079742990002028629').nrdconta := 7974299;qualContr('00100079742990002028629').nrctremp := 2028629;qualContr('00100079742990002028629').idquapro := 4;
    qualContr('00100062161370002029438').cdcooper := 1;qualContr('00100062161370002029438').nrdconta := 6216137;qualContr('00100062161370002029438').nrctremp := 2029438;qualContr('00100062161370002029438').idquapro := 3;
    qualContr('00100084412350002029270').cdcooper := 1;qualContr('00100084412350002029270').nrdconta := 8441235;qualContr('00100084412350002029270').nrctremp := 2029270;qualContr('00100084412350002029270').idquapro := 3;
    qualContr('00100100225970002029399').cdcooper := 1;qualContr('00100100225970002029399').nrdconta := 10022597;qualContr('00100100225970002029399').nrctremp := 2029399;qualContr('00100100225970002029399').idquapro := 3;
    qualContr('00100073471200002030323').cdcooper := 1;qualContr('00100073471200002030323').nrdconta := 7347120;qualContr('00100073471200002030323').nrctremp := 2030323;qualContr('00100073471200002030323').idquapro := 3;
    qualContr('00100020857630002029644').cdcooper := 1;qualContr('00100020857630002029644').nrdconta := 2085763;qualContr('00100020857630002029644').nrctremp := 2029644;qualContr('00100020857630002029644').idquapro := 3;
    qualContr('00100105773000002029207').cdcooper := 1;qualContr('00100105773000002029207').nrdconta := 10577300;qualContr('00100105773000002029207').nrctremp := 2029207;qualContr('00100105773000002029207').idquapro := 3;
    qualContr('00100025292540002028508').cdcooper := 1;qualContr('00100025292540002028508').nrdconta := 2529254;qualContr('00100025292540002028508').nrctremp := 2028508;qualContr('00100025292540002028508').idquapro := 3;
    qualContr('00100096861770002028226').cdcooper := 1;qualContr('00100096861770002028226').nrdconta := 9686177;qualContr('00100096861770002028226').nrctremp := 2028226;qualContr('00100096861770002028226').idquapro := 3;
    qualContr('00100029905390002030237').cdcooper := 1;qualContr('00100029905390002030237').nrdconta := 2990539;qualContr('00100029905390002030237').nrctremp := 2030237;qualContr('00100029905390002030237').idquapro := 4;
    qualContr('00100088712560002030062').cdcooper := 1;qualContr('00100088712560002030062').nrdconta := 8871256;qualContr('00100088712560002030062').nrctremp := 2030062;qualContr('00100088712560002030062').idquapro := 4;
    qualContr('00100109919560002028266').cdcooper := 1;qualContr('00100109919560002028266').nrdconta := 10991956;qualContr('00100109919560002028266').nrctremp := 2028266;qualContr('00100109919560002028266').idquapro := 3;
    qualContr('00100095663840002032442').cdcooper := 1;qualContr('00100095663840002032442').nrdconta := 9566384;qualContr('00100095663840002032442').nrctremp := 2032442;qualContr('00100095663840002032442').idquapro := 4;
    qualContr('00100104724950002032692').cdcooper := 1;qualContr('00100104724950002032692').nrdconta := 10472495;qualContr('00100104724950002032692').nrctremp := 2032692;qualContr('00100104724950002032692').idquapro := 3;
    qualContr('00100088246730002032056').cdcooper := 1;qualContr('00100088246730002032056').nrdconta := 8824673;qualContr('00100088246730002032056').nrctremp := 2032056;qualContr('00100088246730002032056').idquapro := 3;
    qualContr('00100102842300002032715').cdcooper := 1;qualContr('00100102842300002032715').nrdconta := 10284230;qualContr('00100102842300002032715').nrctremp := 2032715;qualContr('00100102842300002032715').idquapro := 4;
    qualContr('00100091489900002033052').cdcooper := 1;qualContr('00100091489900002033052').nrdconta := 9148990;qualContr('00100091489900002033052').nrctremp := 2033052;qualContr('00100091489900002033052').idquapro := 3;
    qualContr('00100080310610002032718').cdcooper := 1;qualContr('00100080310610002032718').nrdconta := 8031061;qualContr('00100080310610002032718').nrctremp := 2032718;qualContr('00100080310610002032718').idquapro := 3;
    qualContr('00100089666210002033597').cdcooper := 1;qualContr('00100089666210002033597').nrdconta := 8966621;qualContr('00100089666210002033597').nrctremp := 2033597;qualContr('00100089666210002033597').idquapro := 3;
    qualContr('00100062042280002033879').cdcooper := 1;qualContr('00100062042280002033879').nrdconta := 6204228;qualContr('00100062042280002033879').nrctremp := 2033879;qualContr('00100062042280002033879').idquapro := 4;
    qualContr('00100102128760002032323').cdcooper := 1;qualContr('00100102128760002032323').nrdconta := 10212876;qualContr('00100102128760002032323').nrctremp := 2032323;qualContr('00100102128760002032323').idquapro := 3;
    qualContr('00100080587170002032630').cdcooper := 1;qualContr('00100080587170002032630').nrdconta := 8058717;qualContr('00100080587170002032630').nrctremp := 2032630;qualContr('00100080587170002032630').idquapro := 3;
    qualContr('00100900793450002032873').cdcooper := 1;qualContr('00100900793450002032873').nrdconta := 90079345;qualContr('00100900793450002032873').nrctremp := 2032873;qualContr('00100900793450002032873').idquapro := 3;
    qualContr('00100085392000002033656').cdcooper := 1;qualContr('00100085392000002033656').nrdconta := 8539200;qualContr('00100085392000002033656').nrctremp := 2033656;qualContr('00100085392000002033656').idquapro := 3;
    qualContr('00100019744240002037302').cdcooper := 1;qualContr('00100019744240002037302').nrdconta := 1974424;qualContr('00100019744240002037302').nrctremp := 2037302;qualContr('00100019744240002037302').idquapro := 3;
    qualContr('00100076289000002036011').cdcooper := 1;qualContr('00100076289000002036011').nrdconta := 7628900;qualContr('00100076289000002036011').nrctremp := 2036011;qualContr('00100076289000002036011').idquapro := 4;
    qualContr('00100105041090002035969').cdcooper := 1;qualContr('00100105041090002035969').nrdconta := 10504109;qualContr('00100105041090002035969').nrctremp := 2035969;qualContr('00100105041090002035969').idquapro := 3;
    qualContr('00100107701270002036663').cdcooper := 1;qualContr('00100107701270002036663').nrdconta := 10770127;qualContr('00100107701270002036663').nrctremp := 2036663;qualContr('00100107701270002036663').idquapro := 3;
    qualContr('00100105681820002035404').cdcooper := 1;qualContr('00100105681820002035404').nrdconta := 10568182;qualContr('00100105681820002035404').nrctremp := 2035404;qualContr('00100105681820002035404').idquapro := 3;
    qualContr('00100085392000002037728').cdcooper := 1;qualContr('00100085392000002037728').nrdconta := 8539200;qualContr('00100085392000002037728').nrctremp := 2037728;qualContr('00100085392000002037728').idquapro := 3;
    qualContr('00100037596600002036797').cdcooper := 1;qualContr('00100037596600002036797').nrdconta := 3759660;qualContr('00100037596600002036797').nrctremp := 2036797;qualContr('00100037596600002036797').idquapro := 3;
    qualContr('00100083166780002040219').cdcooper := 1;qualContr('00100083166780002040219').nrdconta := 8316678;qualContr('00100083166780002040219').nrctremp := 2040219;qualContr('00100083166780002040219').idquapro := 3;
    qualContr('00100104188220002040868').cdcooper := 1;qualContr('00100104188220002040868').nrdconta := 10418822;qualContr('00100104188220002040868').nrctremp := 2040868;qualContr('00100104188220002040868').idquapro := 3;
    qualContr('00100068295460002043320').cdcooper := 1;qualContr('00100068295460002043320').nrdconta := 6829546;qualContr('00100068295460002043320').nrctremp := 2043320;qualContr('00100068295460002043320').idquapro := 3;
    qualContr('00100030874250002041790').cdcooper := 1;qualContr('00100030874250002041790').nrdconta := 3087425;qualContr('00100030874250002041790').nrctremp := 2041790;qualContr('00100030874250002041790').idquapro := 3;
    qualContr('00100085447190002039797').cdcooper := 1;qualContr('00100085447190002039797').nrdconta := 8544719;qualContr('00100085447190002039797').nrctremp := 2039797;qualContr('00100085447190002039797').idquapro := 3;
    qualContr('00100093118820002050911').cdcooper := 1;qualContr('00100093118820002050911').nrdconta := 9311882;qualContr('00100093118820002050911').nrctremp := 2050911;qualContr('00100093118820002050911').idquapro := 3;
    qualContr('00100025745940002049867').cdcooper := 1;qualContr('00100025745940002049867').nrdconta := 2574594;qualContr('00100025745940002049867').nrctremp := 2049867;qualContr('00100025745940002049867').idquapro := 3;
    qualContr('00100073941360002050478').cdcooper := 1;qualContr('00100073941360002050478').nrdconta := 7394136;qualContr('00100073941360002050478').nrctremp := 2050478;qualContr('00100073941360002050478').idquapro := 3;
    qualContr('00100098639150002051185').cdcooper := 1;qualContr('00100098639150002051185').nrdconta := 9863915;qualContr('00100098639150002051185').nrctremp := 2051185;qualContr('00100098639150002051185').idquapro := 3;
    qualContr('00100071101200002047435').cdcooper := 1;qualContr('00100071101200002047435').nrdconta := 7110120;qualContr('00100071101200002047435').nrctremp := 2047435;qualContr('00100071101200002047435').idquapro := 3;
    qualContr('00100104392260002049954').cdcooper := 1;qualContr('00100104392260002049954').nrdconta := 10439226;qualContr('00100104392260002049954').nrctremp := 2049954;qualContr('00100104392260002049954').idquapro := 3;
    qualContr('00100066272770002050356').cdcooper := 1;qualContr('00100066272770002050356').nrdconta := 6627277;qualContr('00100066272770002050356').nrctremp := 2050356;qualContr('00100066272770002050356').idquapro := 3;
    qualContr('00100075308970002046823').cdcooper := 1;qualContr('00100075308970002046823').nrdconta := 7530897;qualContr('00100075308970002046823').nrctremp := 2046823;qualContr('00100075308970002046823').idquapro := 3;
    qualContr('00100038250190002049427').cdcooper := 1;qualContr('00100038250190002049427').nrdconta := 3825019;qualContr('00100038250190002049427').nrctremp := 2049427;qualContr('00100038250190002049427').idquapro := 4;
    qualContr('00100092351320002049750').cdcooper := 1;qualContr('00100092351320002049750').nrdconta := 9235132;qualContr('00100092351320002049750').nrctremp := 2049750;qualContr('00100092351320002049750').idquapro := 3;
    qualContr('00100107194900002046591').cdcooper := 1;qualContr('00100107194900002046591').nrdconta := 10719490;qualContr('00100107194900002046591').nrctremp := 2046591;qualContr('00100107194900002046591').idquapro := 3;
    qualContr('00100071056810002047235').cdcooper := 1;qualContr('00100071056810002047235').nrdconta := 7105681;qualContr('00100071056810002047235').nrctremp := 2047235;qualContr('00100071056810002047235').idquapro := 3;
    qualContr('00100037228640002052581').cdcooper := 1;qualContr('00100037228640002052581').nrdconta := 3722864;qualContr('00100037228640002052581').nrctremp := 2052581;qualContr('00100037228640002052581').idquapro := 3;
    qualContr('00100064457050002055193').cdcooper := 1;qualContr('00100064457050002055193').nrdconta := 6445705;qualContr('00100064457050002055193').nrctremp := 2055193;qualContr('00100064457050002055193').idquapro := 3;
    qualContr('00100093799830002052985').cdcooper := 1;qualContr('00100093799830002052985').nrdconta := 9379983;qualContr('00100093799830002052985').nrctremp := 2052985;qualContr('00100093799830002052985').idquapro := 4;
    qualContr('00100038369080002055354').cdcooper := 1;qualContr('00100038369080002055354').nrdconta := 3836908;qualContr('00100038369080002055354').nrctremp := 2055354;qualContr('00100038369080002055354').idquapro := 3;
    qualContr('00100061940950002053816').cdcooper := 1;qualContr('00100061940950002053816').nrdconta := 6194095;qualContr('00100061940950002053816').nrctremp := 2053816;qualContr('00100061940950002053816').idquapro := 3;
    qualContr('00100099223690002054569').cdcooper := 1;qualContr('00100099223690002054569').nrdconta := 9922369;qualContr('00100099223690002054569').nrctremp := 2054569;qualContr('00100099223690002054569').idquapro := 4;
    qualContr('00100097468620002054099').cdcooper := 1;qualContr('00100097468620002054099').nrdconta := 9746862;qualContr('00100097468620002054099').nrctremp := 2054099;qualContr('00100097468620002054099').idquapro := 3;
    qualContr('00100020418120002054551').cdcooper := 1;qualContr('00100020418120002054551').nrdconta := 2041812;qualContr('00100020418120002054551').nrctremp := 2054551;qualContr('00100020418120002054551').idquapro := 3;
    qualContr('00100039803240002054929').cdcooper := 1;qualContr('00100039803240002054929').nrdconta := 3980324;qualContr('00100039803240002054929').nrctremp := 2054929;qualContr('00100039803240002054929').idquapro := 3;
    qualContr('00100085783620002057367').cdcooper := 1;qualContr('00100085783620002057367').nrdconta := 8578362;qualContr('00100085783620002057367').nrctremp := 2057367;qualContr('00100085783620002057367').idquapro := 3;
    qualContr('00100089498910002057339').cdcooper := 1;qualContr('00100089498910002057339').nrdconta := 8949891;qualContr('00100089498910002057339').nrctremp := 2057339;qualContr('00100089498910002057339').idquapro := 3;
    qualContr('00100097216490002060524').cdcooper := 1;qualContr('00100097216490002060524').nrdconta := 9721649;qualContr('00100097216490002060524').nrctremp := 2060524;qualContr('00100097216490002060524').idquapro := 3;
    qualContr('00100099042040002059337').cdcooper := 1;qualContr('00100099042040002059337').nrdconta := 9904204;qualContr('00100099042040002059337').nrctremp := 2059337;qualContr('00100099042040002059337').idquapro := 3;
    qualContr('00100071674400002058713').cdcooper := 1;qualContr('00100071674400002058713').nrdconta := 7167440;qualContr('00100071674400002058713').nrctremp := 2058713;qualContr('00100071674400002058713').idquapro := 3;
    qualContr('00100063044350002058992').cdcooper := 1;qualContr('00100063044350002058992').nrdconta := 6304435;qualContr('00100063044350002058992').nrctremp := 2058992;qualContr('00100063044350002058992').idquapro := 3;
    qualContr('00100102144530002058174').cdcooper := 1;qualContr('00100102144530002058174').nrdconta := 10214453;qualContr('00100102144530002058174').nrctremp := 2058174;qualContr('00100102144530002058174').idquapro := 3;
    qualContr('00100077982020002059400').cdcooper := 1;qualContr('00100077982020002059400').nrdconta := 7798202;qualContr('00100077982020002059400').nrctremp := 2059400;qualContr('00100077982020002059400').idquapro := 3;
    qualContr('00100071016510002058449').cdcooper := 1;qualContr('00100071016510002058449').nrdconta := 7101651;qualContr('00100071016510002058449').nrctremp := 2058449;qualContr('00100071016510002058449').idquapro := 3;
    qualContr('00100090102970002058699').cdcooper := 1;qualContr('00100090102970002058699').nrdconta := 9010297;qualContr('00100090102970002058699').nrctremp := 2058699;qualContr('00100090102970002058699').idquapro := 4;
    qualContr('00100804814180002058322').cdcooper := 1;qualContr('00100804814180002058322').nrdconta := 80481418;qualContr('00100804814180002058322').nrctremp := 2058322;qualContr('00100804814180002058322').idquapro := 3;
    qualContr('00100067971800002063828').cdcooper := 1;qualContr('00100067971800002063828').nrdconta := 6797180;qualContr('00100067971800002063828').nrctremp := 2063828;qualContr('00100067971800002063828').idquapro := 3;
    qualContr('00100079175460002063162').cdcooper := 1;qualContr('00100079175460002063162').nrdconta := 7917546;qualContr('00100079175460002063162').nrctremp := 2063162;qualContr('00100079175460002063162').idquapro := 3;
    qualContr('00100029629850002064620').cdcooper := 1;qualContr('00100029629850002064620').nrdconta := 2962985;qualContr('00100029629850002064620').nrctremp := 2064620;qualContr('00100029629850002064620').idquapro := 3;
    qualContr('00100078266990002063234').cdcooper := 1;qualContr('00100078266990002063234').nrdconta := 7826699;qualContr('00100078266990002063234').nrctremp := 2063234;qualContr('00100078266990002063234').idquapro := 3;
    qualContr('00100031805650002063093').cdcooper := 1;qualContr('00100031805650002063093').nrdconta := 3180565;qualContr('00100031805650002063093').nrctremp := 2063093;qualContr('00100031805650002063093').idquapro := 3;
    qualContr('00100076839950002063665').cdcooper := 1;qualContr('00100076839950002063665').nrdconta := 7683995;qualContr('00100076839950002063665').nrctremp := 2063665;qualContr('00100076839950002063665').idquapro := 3;
    qualContr('00100106532440002062417').cdcooper := 1;qualContr('00100106532440002062417').nrdconta := 10653244;qualContr('00100106532440002062417').nrctremp := 2062417;qualContr('00100106532440002062417').idquapro := 3;
    qualContr('00100103701530002064051').cdcooper := 1;qualContr('00100103701530002064051').nrdconta := 10370153;qualContr('00100103701530002064051').nrctremp := 2064051;qualContr('00100103701530002064051').idquapro := 4;
    qualContr('00100105895890002061712').cdcooper := 1;qualContr('00100105895890002061712').nrdconta := 10589589;qualContr('00100105895890002061712').nrctremp := 2061712;qualContr('00100105895890002061712').idquapro := 4;
    qualContr('00100022482550002064058').cdcooper := 1;qualContr('00100022482550002064058').nrdconta := 2248255;qualContr('00100022482550002064058').nrctremp := 2064058;qualContr('00100022482550002064058').idquapro := 3;
    qualContr('00100102326300002063549').cdcooper := 1;qualContr('00100102326300002063549').nrdconta := 10232630;qualContr('00100102326300002063549').nrctremp := 2063549;qualContr('00100102326300002063549').idquapro := 4;
    qualContr('00100084066930002062779').cdcooper := 1;qualContr('00100084066930002062779').nrdconta := 8406693;qualContr('00100084066930002062779').nrctremp := 2062779;qualContr('00100084066930002062779').idquapro := 3;
    qualContr('00100097183700002065925').cdcooper := 1;qualContr('00100097183700002065925').nrdconta := 9718370;qualContr('00100097183700002065925').nrctremp := 2065925;qualContr('00100097183700002065925').idquapro := 3;
    qualContr('00100086669540002066429').cdcooper := 1;qualContr('00100086669540002066429').nrdconta := 8666954;qualContr('00100086669540002066429').nrctremp := 2066429;qualContr('00100086669540002066429').idquapro := 3;
    qualContr('00100075157820002065699').cdcooper := 1;qualContr('00100075157820002065699').nrdconta := 7515782;qualContr('00100075157820002065699').nrctremp := 2065699;qualContr('00100075157820002065699').idquapro := 3;
    qualContr('00100105460140002066620').cdcooper := 1;qualContr('00100105460140002066620').nrdconta := 10546014;qualContr('00100105460140002066620').nrctremp := 2066620;qualContr('00100105460140002066620').idquapro := 3;
    qualContr('00100025013840002067819').cdcooper := 1;qualContr('00100025013840002067819').nrdconta := 2501384;qualContr('00100025013840002067819').nrctremp := 2067819;qualContr('00100025013840002067819').idquapro := 3;
    qualContr('00100108411050002066422').cdcooper := 1;qualContr('00100108411050002066422').nrdconta := 10841105;qualContr('00100108411050002066422').nrctremp := 2066422;qualContr('00100108411050002066422').idquapro := 4;
    qualContr('00100107121600002071780').cdcooper := 1;qualContr('00100107121600002071780').nrdconta := 10712160;qualContr('00100107121600002071780').nrctremp := 2071780;qualContr('00100107121600002071780').idquapro := 4;
    qualContr('00100029629850002072405').cdcooper := 1;qualContr('00100029629850002072405').nrdconta := 2962985;qualContr('00100029629850002072405').nrctremp := 2072405;qualContr('00100029629850002072405').idquapro := 3;
    qualContr('00100105361240002074502').cdcooper := 1;qualContr('00100105361240002074502').nrdconta := 10536124;qualContr('00100105361240002074502').nrctremp := 2074502;qualContr('00100105361240002074502').idquapro := 3;
    qualContr('00100007676460002072430').cdcooper := 1;qualContr('00100007676460002072430').nrdconta := 767646;qualContr('00100007676460002072430').nrctremp := 2072430;qualContr('00100007676460002072430').idquapro := 3;
    qualContr('00100062851200002071777').cdcooper := 1;qualContr('00100062851200002071777').nrdconta := 6285120;qualContr('00100062851200002071777').nrctremp := 2071777;qualContr('00100062851200002071777').idquapro := 3;
    qualContr('00100077510520002075154').cdcooper := 1;qualContr('00100077510520002075154').nrdconta := 7751052;qualContr('00100077510520002075154').nrctremp := 2075154;qualContr('00100077510520002075154').idquapro := 3;
    qualContr('00100078002740002074393').cdcooper := 1;qualContr('00100078002740002074393').nrdconta := 7800274;qualContr('00100078002740002074393').nrctremp := 2074393;qualContr('00100078002740002074393').idquapro := 4;
    qualContr('00100036543970002077067').cdcooper := 1;qualContr('00100036543970002077067').nrdconta := 3654397;qualContr('00100036543970002077067').nrctremp := 2077067;qualContr('00100036543970002077067').idquapro := 4;
    qualContr('00100094646890002078194').cdcooper := 1;qualContr('00100094646890002078194').nrdconta := 9464689;qualContr('00100094646890002078194').nrctremp := 2078194;qualContr('00100094646890002078194').idquapro := 3;
    qualContr('00100102824670002076118').cdcooper := 1;qualContr('00100102824670002076118').nrdconta := 10282467;qualContr('00100102824670002076118').nrctremp := 2076118;qualContr('00100102824670002076118').idquapro := 3;
    qualContr('00100082539860002077342').cdcooper := 1;qualContr('00100082539860002077342').nrdconta := 8253986;qualContr('00100082539860002077342').nrctremp := 2077342;qualContr('00100082539860002077342').idquapro := 3;
    qualContr('00100027771500002077089').cdcooper := 1;qualContr('00100027771500002077089').nrdconta := 2777150;qualContr('00100027771500002077089').nrctremp := 2077089;qualContr('00100027771500002077089').idquapro := 3;
    qualContr('00100077211610002077308').cdcooper := 1;qualContr('00100077211610002077308').nrdconta := 7721161;qualContr('00100077211610002077308').nrctremp := 2077308;qualContr('00100077211610002077308').idquapro := 3;
    qualContr('00100085680060002078053').cdcooper := 1;qualContr('00100085680060002078053').nrdconta := 8568006;qualContr('00100085680060002078053').nrctremp := 2078053;qualContr('00100085680060002078053').idquapro := 3;
    qualContr('00100109878430002078183').cdcooper := 1;qualContr('00100109878430002078183').nrdconta := 10987843;qualContr('00100109878430002078183').nrctremp := 2078183;qualContr('00100109878430002078183').idquapro := 3;
    qualContr('00100083111530002077143').cdcooper := 1;qualContr('00100083111530002077143').nrdconta := 8311153;qualContr('00100083111530002077143').nrctremp := 2077143;qualContr('00100083111530002077143').idquapro := 3;
    qualContr('00100102201430002080848').cdcooper := 1;qualContr('00100102201430002080848').nrdconta := 10220143;qualContr('00100102201430002080848').nrctremp := 2080848;qualContr('00100102201430002080848').idquapro := 3;
    qualContr('00100099947690002083101').cdcooper := 1;qualContr('00100099947690002083101').nrdconta := 9994769;qualContr('00100099947690002083101').nrctremp := 2083101;qualContr('00100099947690002083101').idquapro := 4;
    qualContr('00100088182660002082056').cdcooper := 1;qualContr('00100088182660002082056').nrdconta := 8818266;qualContr('00100088182660002082056').nrctremp := 2082056;qualContr('00100088182660002082056').idquapro := 3;
    qualContr('00100101781390002084065').cdcooper := 1;qualContr('00100101781390002084065').nrdconta := 10178139;qualContr('00100101781390002084065').nrctremp := 2084065;qualContr('00100101781390002084065').idquapro := 3;
    qualContr('00100082315160002086654').cdcooper := 1;qualContr('00100082315160002086654').nrdconta := 8231516;qualContr('00100082315160002086654').nrctremp := 2086654;qualContr('00100082315160002086654').idquapro := 4;
    qualContr('00100022360360002085653').cdcooper := 1;qualContr('00100022360360002085653').nrdconta := 2236036;qualContr('00100022360360002085653').nrctremp := 2085653;qualContr('00100022360360002085653').idquapro := 3;
    qualContr('00100039330590002084629').cdcooper := 1;qualContr('00100039330590002084629').nrdconta := 3933059;qualContr('00100039330590002084629').nrctremp := 2084629;qualContr('00100039330590002084629').idquapro := 3;
    qualContr('00100100844520002085201').cdcooper := 1;qualContr('00100100844520002085201').nrdconta := 10084452;qualContr('00100100844520002085201').nrctremp := 2085201;qualContr('00100100844520002085201').idquapro := 3;
    qualContr('00100069898700002084633').cdcooper := 1;qualContr('00100069898700002084633').nrdconta := 6989870;qualContr('00100069898700002084633').nrctremp := 2084633;qualContr('00100069898700002084633').idquapro := 3;
    qualContr('00100067971800002084003').cdcooper := 1;qualContr('00100067971800002084003').nrdconta := 6797180;qualContr('00100067971800002084003').nrctremp := 2084003;qualContr('00100067971800002084003').idquapro := 3;
    qualContr('00100039646710002089577').cdcooper := 1;qualContr('00100039646710002089577').nrdconta := 3964671;qualContr('00100039646710002089577').nrctremp := 2089577;qualContr('00100039646710002089577').idquapro := 3;
    qualContr('00100098928000002087978').cdcooper := 1;qualContr('00100098928000002087978').nrdconta := 9892800;qualContr('00100098928000002087978').nrctremp := 2087978;qualContr('00100098928000002087978').idquapro := 3;
    qualContr('00100092890030002088846').cdcooper := 1;qualContr('00100092890030002088846').nrdconta := 9289003;qualContr('00100092890030002088846').nrctremp := 2088846;qualContr('00100092890030002088846').idquapro := 3;
    qualContr('00100107546950002090175').cdcooper := 1;qualContr('00100107546950002090175').nrdconta := 10754695;qualContr('00100107546950002090175').nrctremp := 2090175;qualContr('00100107546950002090175').idquapro := 3;
    qualContr('00100107116430002088505').cdcooper := 1;qualContr('00100107116430002088505').nrdconta := 10711643;qualContr('00100107116430002088505').nrctremp := 2088505;qualContr('00100107116430002088505').idquapro := 4;
    qualContr('00100087444670002090217').cdcooper := 1;qualContr('00100087444670002090217').nrdconta := 8744467;qualContr('00100087444670002090217').nrctremp := 2090217;qualContr('00100087444670002090217').idquapro := 3;
    qualContr('00100030193140002089723').cdcooper := 1;qualContr('00100030193140002089723').nrdconta := 3019314;qualContr('00100030193140002089723').nrctremp := 2089723;qualContr('00100030193140002089723').idquapro := 4;
    qualContr('00100096672530002088174').cdcooper := 1;qualContr('00100096672530002088174').nrdconta := 9667253;qualContr('00100096672530002088174').nrctremp := 2088174;qualContr('00100096672530002088174').idquapro := 3;
    qualContr('00100065273700002088190').cdcooper := 1;qualContr('00100065273700002088190').nrdconta := 6527370;qualContr('00100065273700002088190').nrctremp := 2088190;qualContr('00100065273700002088190').idquapro := 3;
    qualContr('00100009299990002097659').cdcooper := 1;qualContr('00100009299990002097659').nrdconta := 929999;qualContr('00100009299990002097659').nrctremp := 2097659;qualContr('00100009299990002097659').idquapro := 3;
    qualContr('00100072189820002099994').cdcooper := 1;qualContr('00100072189820002099994').nrdconta := 7218982;qualContr('00100072189820002099994').nrctremp := 2099994;qualContr('00100072189820002099994').idquapro := 4;
    qualContr('00100023600390002097493').cdcooper := 1;qualContr('00100023600390002097493').nrdconta := 2360039;qualContr('00100023600390002097493').nrctremp := 2097493;qualContr('00100023600390002097493').idquapro := 3;
    qualContr('00100039160300002099864').cdcooper := 1;qualContr('00100039160300002099864').nrdconta := 3916030;qualContr('00100039160300002099864').nrctremp := 2099864;qualContr('00100039160300002099864').idquapro := 3;
    qualContr('00100090729340002099111').cdcooper := 1;qualContr('00100090729340002099111').nrdconta := 9072934;qualContr('00100090729340002099111').nrctremp := 2099111;qualContr('00100090729340002099111').idquapro := 3;
    qualContr('00100078890620002099141').cdcooper := 1;qualContr('00100078890620002099141').nrdconta := 7889062;qualContr('00100078890620002099141').nrctremp := 2099141;qualContr('00100078890620002099141').idquapro := 3;
    qualContr('00100073223480002097725').cdcooper := 1;qualContr('00100073223480002097725').nrdconta := 7322348;qualContr('00100073223480002097725').nrctremp := 2097725;qualContr('00100073223480002097725').idquapro := 3;
    qualContr('00100093728810002097615').cdcooper := 1;qualContr('00100093728810002097615').nrdconta := 9372881;qualContr('00100093728810002097615').nrctremp := 2097615;qualContr('00100093728810002097615').idquapro := 3;
    qualContr('00100098785640002100091').cdcooper := 1;qualContr('00100098785640002100091').nrdconta := 9878564;qualContr('00100098785640002100091').nrctremp := 2100091;qualContr('00100098785640002100091').idquapro := 3;
    qualContr('00100081756590002101599').cdcooper := 1;qualContr('00100081756590002101599').nrdconta := 8175659;qualContr('00100081756590002101599').nrctremp := 2101599;qualContr('00100081756590002101599').idquapro := 3;
    qualContr('00100038855000002101716').cdcooper := 1;qualContr('00100038855000002101716').nrdconta := 3885500;qualContr('00100038855000002101716').nrctremp := 2101716;qualContr('00100038855000002101716').idquapro := 3;
    qualContr('00100071604450002103189').cdcooper := 1;qualContr('00100071604450002103189').nrdconta := 7160445;qualContr('00100071604450002103189').nrctremp := 2103189;qualContr('00100071604450002103189').idquapro := 3;
    qualContr('00100083322400002105147').cdcooper := 1;qualContr('00100083322400002105147').nrdconta := 8332240;qualContr('00100083322400002105147').nrctremp := 2105147;qualContr('00100083322400002105147').idquapro := 3;
    qualContr('00100107198490002103850').cdcooper := 1;qualContr('00100107198490002103850').nrdconta := 10719849;qualContr('00100107198490002103850').nrctremp := 2103850;qualContr('00100107198490002103850').idquapro := 3;
    qualContr('00100102712790002102531').cdcooper := 1;qualContr('00100102712790002102531').nrdconta := 10271279;qualContr('00100102712790002102531').nrctremp := 2102531;qualContr('00100102712790002102531').idquapro := 3;
    qualContr('00100068044700002102492').cdcooper := 1;qualContr('00100068044700002102492').nrdconta := 6804470;qualContr('00100068044700002102492').nrctremp := 2102492;qualContr('00100068044700002102492').idquapro := 3;
    qualContr('00100077289210002106449').cdcooper := 1;qualContr('00100077289210002106449').nrdconta := 7728921;qualContr('00100077289210002106449').nrctremp := 2106449;qualContr('00100077289210002106449').idquapro := 3;
    qualContr('00100105734020002108876').cdcooper := 1;qualContr('00100105734020002108876').nrdconta := 10573402;qualContr('00100105734020002108876').nrctremp := 2108876;qualContr('00100105734020002108876').idquapro := 3;
    qualContr('00100097782840002107372').cdcooper := 1;qualContr('00100097782840002107372').nrdconta := 9778284;qualContr('00100097782840002107372').nrctremp := 2107372;qualContr('00100097782840002107372').idquapro := 3;
    qualContr('00100070641520002107148').cdcooper := 1;qualContr('00100070641520002107148').nrdconta := 7064152;qualContr('00100070641520002107148').nrctremp := 2107148;qualContr('00100070641520002107148').idquapro := 3;
    qualContr('00100094041800002109777').cdcooper := 1;qualContr('00100094041800002109777').nrdconta := 9404180;qualContr('00100094041800002109777').nrctremp := 2109777;qualContr('00100094041800002109777').idquapro := 3;
    qualContr('00100099703120002108718').cdcooper := 1;qualContr('00100099703120002108718').nrdconta := 9970312;qualContr('00100099703120002108718').nrctremp := 2108718;qualContr('00100099703120002108718').idquapro := 3;
    qualContr('00100038660090002108181').cdcooper := 1;qualContr('00100038660090002108181').nrdconta := 3866009;qualContr('00100038660090002108181').nrctremp := 2108181;qualContr('00100038660090002108181').idquapro := 3;
    qualContr('00100094041800002109780').cdcooper := 1;qualContr('00100094041800002109780').nrdconta := 9404180;qualContr('00100094041800002109780').nrctremp := 2109780;qualContr('00100094041800002109780').idquapro := 3;
    qualContr('00100038523420002109071').cdcooper := 1;qualContr('00100038523420002109071').nrdconta := 3852342;qualContr('00100038523420002109071').nrctremp := 2109071;qualContr('00100038523420002109071').idquapro := 3;
    qualContr('00100035025620002108545').cdcooper := 1;qualContr('00100035025620002108545').nrdconta := 3502562;qualContr('00100035025620002108545').nrctremp := 2108545;qualContr('00100035025620002108545').idquapro := 3;
    qualContr('00100064583860002114075').cdcooper := 1;qualContr('00100064583860002114075').nrdconta := 6458386;qualContr('00100064583860002114075').nrctremp := 2114075;qualContr('00100064583860002114075').idquapro := 3;
    qualContr('00100106229260002112536').cdcooper := 1;qualContr('00100106229260002112536').nrdconta := 10622926;qualContr('00100106229260002112536').nrctremp := 2112536;qualContr('00100106229260002112536').idquapro := 4;
    qualContr('00100104949950002112761').cdcooper := 1;qualContr('00100104949950002112761').nrdconta := 10494995;qualContr('00100104949950002112761').nrctremp := 2112761;qualContr('00100104949950002112761').idquapro := 3;
    qualContr('00100805001960002113497').cdcooper := 1;qualContr('00100805001960002113497').nrdconta := 80500196;qualContr('00100805001960002113497').nrctremp := 2113497;qualContr('00100805001960002113497').idquapro := 3;
    qualContr('00100076510580002114949').cdcooper := 1;qualContr('00100076510580002114949').nrdconta := 7651058;qualContr('00100076510580002114949').nrctremp := 2114949;qualContr('00100076510580002114949').idquapro := 3;
    qualContr('00100061305340002114746').cdcooper := 1;qualContr('00100061305340002114746').nrdconta := 6130534;qualContr('00100061305340002114746').nrctremp := 2114746;qualContr('00100061305340002114746').idquapro := 3;
    qualContr('00100101299280002115256').cdcooper := 1;qualContr('00100101299280002115256').nrdconta := 10129928;qualContr('00100101299280002115256').nrctremp := 2115256;qualContr('00100101299280002115256').idquapro := 3;
    qualContr('00100029647830002112570').cdcooper := 1;qualContr('00100029647830002112570').nrdconta := 2964783;qualContr('00100029647830002112570').nrctremp := 2112570;qualContr('00100029647830002112570').idquapro := 3;
    qualContr('00100089158900002117408').cdcooper := 1;qualContr('00100089158900002117408').nrdconta := 8915890;qualContr('00100089158900002117408').nrctremp := 2117408;qualContr('00100089158900002117408').idquapro := 3;
    qualContr('00100104553960002117904').cdcooper := 1;qualContr('00100104553960002117904').nrdconta := 10455396;qualContr('00100104553960002117904').nrctremp := 2117904;qualContr('00100104553960002117904').idquapro := 3;
    qualContr('00100031928220002119193').cdcooper := 1;qualContr('00100031928220002119193').nrdconta := 3192822;qualContr('00100031928220002119193').nrctremp := 2119193;qualContr('00100031928220002119193').idquapro := 3;
    qualContr('00100095765250002120150').cdcooper := 1;qualContr('00100095765250002120150').nrdconta := 9576525;qualContr('00100095765250002120150').nrctremp := 2120150;qualContr('00100095765250002120150').idquapro := 3;
    qualContr('00100021214920002119236').cdcooper := 1;qualContr('00100021214920002119236').nrdconta := 2121492;qualContr('00100021214920002119236').nrctremp := 2119236;qualContr('00100021214920002119236').idquapro := 3;
    qualContr('00100076056090002118219').cdcooper := 1;qualContr('00100076056090002118219').nrdconta := 7605609;qualContr('00100076056090002118219').nrctremp := 2118219;qualContr('00100076056090002118219').idquapro := 3;
    qualContr('00100063321530002117290').cdcooper := 1;qualContr('00100063321530002117290').nrdconta := 6332153;qualContr('00100063321530002117290').nrctremp := 2117290;qualContr('00100063321530002117290').idquapro := 3;
    qualContr('00100038523420002119139').cdcooper := 1;qualContr('00100038523420002119139').nrdconta := 3852342;qualContr('00100038523420002119139').nrctremp := 2119139;qualContr('00100038523420002119139').idquapro := 3;
    qualContr('00100077527410002118745').cdcooper := 1;qualContr('00100077527410002118745').nrdconta := 7752741;qualContr('00100077527410002118745').nrctremp := 2118745;qualContr('00100077527410002118745').idquapro := 3;
    qualContr('00100109321940002119190').cdcooper := 1;qualContr('00100109321940002119190').nrdconta := 10932194;qualContr('00100109321940002119190').nrctremp := 2119190;qualContr('00100109321940002119190').idquapro := 3;
    qualContr('00100105580630002119590').cdcooper := 1;qualContr('00100105580630002119590').nrdconta := 10558063;qualContr('00100105580630002119590').nrctremp := 2119590;qualContr('00100105580630002119590').idquapro := 3;
    qualContr('00100079427370002119412').cdcooper := 1;qualContr('00100079427370002119412').nrdconta := 7942737;qualContr('00100079427370002119412').nrctremp := 2119412;qualContr('00100079427370002119412').idquapro := 3;
    qualContr('00100107173900002121583').cdcooper := 1;qualContr('00100107173900002121583').nrdconta := 10717390;qualContr('00100107173900002121583').nrctremp := 2121583;qualContr('00100107173900002121583').idquapro := 3;
    qualContr('00100092866830002123349').cdcooper := 1;qualContr('00100092866830002123349').nrdconta := 9286683;qualContr('00100092866830002123349').nrctremp := 2123349;qualContr('00100092866830002123349').idquapro := 3;
    qualContr('00100108100800002123421').cdcooper := 1;qualContr('00100108100800002123421').nrdconta := 10810080;qualContr('00100108100800002123421').nrctremp := 2123421;qualContr('00100108100800002123421').idquapro := 3;
    qualContr('00100007534830002123025').cdcooper := 1;qualContr('00100007534830002123025').nrdconta := 753483;qualContr('00100007534830002123025').nrctremp := 2123025;qualContr('00100007534830002123025').idquapro := 3;
    qualContr('00100085989670002123281').cdcooper := 1;qualContr('00100085989670002123281').nrdconta := 8598967;qualContr('00100085989670002123281').nrctremp := 2123281;qualContr('00100085989670002123281').idquapro := 4;
    qualContr('00100087692730002122408').cdcooper := 1;qualContr('00100087692730002122408').nrdconta := 8769273;qualContr('00100087692730002122408').nrctremp := 2122408;qualContr('00100087692730002122408').idquapro := 4;
    qualContr('00100107744590002122832').cdcooper := 1;qualContr('00100107744590002122832').nrdconta := 10774459;qualContr('00100107744590002122832').nrctremp := 2122832;qualContr('00100107744590002122832').idquapro := 3;
    qualContr('00100087079600002122562').cdcooper := 1;qualContr('00100087079600002122562').nrdconta := 8707960;qualContr('00100087079600002122562').nrctremp := 2122562;qualContr('00100087079600002122562').idquapro := 3;
    qualContr('00100087079790002122617').cdcooper := 1;qualContr('00100087079790002122617').nrdconta := 8707979;qualContr('00100087079790002122617').nrctremp := 2122617;qualContr('00100087079790002122617').idquapro := 4;
    qualContr('00100090146080002121438').cdcooper := 1;qualContr('00100090146080002121438').nrdconta := 9014608;qualContr('00100090146080002121438').nrctremp := 2121438;qualContr('00100090146080002121438').idquapro := 3;
    qualContr('00100083785500002122764').cdcooper := 1;qualContr('00100083785500002122764').nrdconta := 8378550;qualContr('00100083785500002122764').nrctremp := 2122764;qualContr('00100083785500002122764').idquapro := 4;
    qualContr('00100086934550002126562').cdcooper := 1;qualContr('00100086934550002126562').nrdconta := 8693455;qualContr('00100086934550002126562').nrctremp := 2126562;qualContr('00100086934550002126562').idquapro := 3;
    qualContr('00100078502120002124470').cdcooper := 1;qualContr('00100078502120002124470').nrdconta := 7850212;qualContr('00100078502120002124470').nrctremp := 2124470;qualContr('00100078502120002124470').idquapro := 3;
    qualContr('00100107134840002126153').cdcooper := 1;qualContr('00100107134840002126153').nrdconta := 10713484;qualContr('00100107134840002126153').nrctremp := 2126153;qualContr('00100107134840002126153').idquapro := 3;
    qualContr('00100000072180002127136').cdcooper := 1;qualContr('00100000072180002127136').nrdconta := 7218;qualContr('00100000072180002127136').nrctremp := 2127136;qualContr('00100000072180002127136').idquapro := 3;
    qualContr('00100086209030002127512').cdcooper := 1;qualContr('00100086209030002127512').nrdconta := 8620903;qualContr('00100086209030002127512').nrctremp := 2127512;qualContr('00100086209030002127512').idquapro := 3;
    qualContr('00100024837850002126758').cdcooper := 1;qualContr('00100024837850002126758').nrdconta := 2483785;qualContr('00100024837850002126758').nrctremp := 2126758;qualContr('00100024837850002126758').idquapro := 3;
    qualContr('00100081489450002125226').cdcooper := 1;qualContr('00100081489450002125226').nrdconta := 8148945;qualContr('00100081489450002125226').nrctremp := 2125226;qualContr('00100081489450002125226').idquapro := 3;
    qualContr('00100039591390002125844').cdcooper := 1;qualContr('00100039591390002125844').nrdconta := 3959139;qualContr('00100039591390002125844').nrctremp := 2125844;qualContr('00100039591390002125844').idquapro := 3;
    qualContr('00100076023320002126162').cdcooper := 1;qualContr('00100076023320002126162').nrdconta := 7602332;qualContr('00100076023320002126162').nrctremp := 2126162;qualContr('00100076023320002126162').idquapro := 3;
    qualContr('00100040528110002126309').cdcooper := 1;qualContr('00100040528110002126309').nrdconta := 4052811;qualContr('00100040528110002126309').nrctremp := 2126309;qualContr('00100040528110002126309').idquapro := 3;
    qualContr('00100107130850002124536').cdcooper := 1;qualContr('00100107130850002124536').nrdconta := 10713085;qualContr('00100107130850002124536').nrctremp := 2124536;qualContr('00100107130850002124536').idquapro := 3;
    qualContr('00100026892190002130164').cdcooper := 1;qualContr('00100026892190002130164').nrdconta := 2689219;qualContr('00100026892190002130164').nrctremp := 2130164;qualContr('00100026892190002130164').idquapro := 3;
    qualContr('00100040479400002129396').cdcooper := 1;qualContr('00100040479400002129396').nrdconta := 4047940;qualContr('00100040479400002129396').nrctremp := 2129396;qualContr('00100040479400002129396').idquapro := 3;
    qualContr('00100102661270002129026').cdcooper := 1;qualContr('00100102661270002129026').nrdconta := 10266127;qualContr('00100102661270002129026').nrctremp := 2129026;qualContr('00100102661270002129026').idquapro := 4;
    qualContr('00100027986700002131398').cdcooper := 1;qualContr('00100027986700002131398').nrdconta := 2798670;qualContr('00100027986700002131398').nrctremp := 2131398;qualContr('00100027986700002131398').idquapro := 4;
    qualContr('00100082983600002129624').cdcooper := 1;qualContr('00100082983600002129624').nrdconta := 8298360;qualContr('00100082983600002129624').nrctremp := 2129624;qualContr('00100082983600002129624').idquapro := 3;
    qualContr('00100099582740002130660').cdcooper := 1;qualContr('00100099582740002130660').nrdconta := 9958274;qualContr('00100099582740002130660').nrctremp := 2130660;qualContr('00100099582740002130660').idquapro := 3;
    qualContr('00100101029730002135374').cdcooper := 1;qualContr('00100101029730002135374').nrdconta := 10102973;qualContr('00100101029730002135374').nrctremp := 2135374;qualContr('00100101029730002135374').idquapro := 3;
    qualContr('00100102591470002137284').cdcooper := 1;qualContr('00100102591470002137284').nrdconta := 10259147;qualContr('00100102591470002137284').nrctremp := 2137284;qualContr('00100102591470002137284').idquapro := 3;
    qualContr('00100096633550002137325').cdcooper := 1;qualContr('00100096633550002137325').nrdconta := 9663355;qualContr('00100096633550002137325').nrctremp := 2137325;qualContr('00100096633550002137325').idquapro := 3;
    qualContr('00100101270970002138556').cdcooper := 1;qualContr('00100101270970002138556').nrdconta := 10127097;qualContr('00100101270970002138556').nrctremp := 2138556;qualContr('00100101270970002138556').idquapro := 3;
    qualContr('00100066617930002136743').cdcooper := 1;qualContr('00100066617930002136743').nrdconta := 6661793;qualContr('00100066617930002136743').nrctremp := 2136743;qualContr('00100066617930002136743').idquapro := 3;
    qualContr('00100008617740002136737').cdcooper := 1;qualContr('00100008617740002136737').nrdconta := 861774;qualContr('00100008617740002136737').nrctremp := 2136737;qualContr('00100008617740002136737').idquapro := 3;
    qualContr('00100088901450002138009').cdcooper := 1;qualContr('00100088901450002138009').nrdconta := 8890145;qualContr('00100088901450002138009').nrctremp := 2138009;qualContr('00100088901450002138009').idquapro := 3;
    qualContr('00100067993700002137132').cdcooper := 1;qualContr('00100067993700002137132').nrdconta := 6799370;qualContr('00100067993700002137132').nrctremp := 2137132;qualContr('00100067993700002137132').idquapro := 3;
    qualContr('00100079752870002136466').cdcooper := 1;qualContr('00100079752870002136466').nrdconta := 7975287;qualContr('00100079752870002136466').nrctremp := 2136466;qualContr('00100079752870002136466').idquapro := 4;
    qualContr('00100022987160002136257').cdcooper := 1;qualContr('00100022987160002136257').nrdconta := 2298716;qualContr('00100022987160002136257').nrctremp := 2136257;qualContr('00100022987160002136257').idquapro := 3;
    qualContr('00100103784990002137565').cdcooper := 1;qualContr('00100103784990002137565').nrdconta := 10378499;qualContr('00100103784990002137565').nrctremp := 2137565;qualContr('00100103784990002137565').idquapro := 3;
    qualContr('00100076851490002142995').cdcooper := 1;qualContr('00100076851490002142995').nrdconta := 7685149;qualContr('00100076851490002142995').nrctremp := 2142995;qualContr('00100076851490002142995').idquapro := 3;
    qualContr('00100061764530002145444').cdcooper := 1;qualContr('00100061764530002145444').nrdconta := 6176453;qualContr('00100061764530002145444').nrctremp := 2145444;qualContr('00100061764530002145444').idquapro := 3;
    qualContr('00100107772530002145514').cdcooper := 1;qualContr('00100107772530002145514').nrdconta := 10777253;qualContr('00100107772530002145514').nrctremp := 2145514;qualContr('00100107772530002145514').idquapro := 3;
    qualContr('00100099711060002144610').cdcooper := 1;qualContr('00100099711060002144610').nrdconta := 9971106;qualContr('00100099711060002144610').nrctremp := 2144610;qualContr('00100099711060002144610').idquapro := 3;
    qualContr('00100098671390002141904').cdcooper := 1;qualContr('00100098671390002141904').nrdconta := 9867139;qualContr('00100098671390002141904').nrctremp := 2141904;qualContr('00100098671390002141904').idquapro := 4;
    qualContr('00100028677450002145921').cdcooper := 1;qualContr('00100028677450002145921').nrdconta := 2867745;qualContr('00100028677450002145921').nrctremp := 2145921;qualContr('00100028677450002145921').idquapro := 4;
    qualContr('00100098649970002144421').cdcooper := 1;qualContr('00100098649970002144421').nrdconta := 9864997;qualContr('00100098649970002144421').nrctremp := 2144421;qualContr('00100098649970002144421').idquapro := 3;
    qualContr('00100076125670002144283').cdcooper := 1;qualContr('00100076125670002144283').nrdconta := 7612567;qualContr('00100076125670002144283').nrctremp := 2144283;qualContr('00100076125670002144283').idquapro := 3;
    qualContr('00100088453870002142096').cdcooper := 1;qualContr('00100088453870002142096').nrdconta := 8845387;qualContr('00100088453870002142096').nrctremp := 2142096;qualContr('00100088453870002142096').idquapro := 3;
    qualContr('00100108396400002143098').cdcooper := 1;qualContr('00100108396400002143098').nrdconta := 10839640;qualContr('00100108396400002143098').nrctremp := 2143098;qualContr('00100108396400002143098').idquapro := 3;
    qualContr('00100096900850002145303').cdcooper := 1;qualContr('00100096900850002145303').nrdconta := 9690085;qualContr('00100096900850002145303').nrctremp := 2145303;qualContr('00100096900850002145303').idquapro := 3;
    qualContr('00100070951710002148569').cdcooper := 1;qualContr('00100070951710002148569').nrdconta := 7095171;qualContr('00100070951710002148569').nrctremp := 2148569;qualContr('00100070951710002148569').idquapro := 3;
    qualContr('00100073820140002151612').cdcooper := 1;qualContr('00100073820140002151612').nrdconta := 7382014;qualContr('00100073820140002151612').nrctremp := 2151612;qualContr('00100073820140002151612').idquapro := 3;
    qualContr('00100098685180002147915').cdcooper := 1;qualContr('00100098685180002147915').nrdconta := 9868518;qualContr('00100098685180002147915').nrctremp := 2147915;qualContr('00100098685180002147915').idquapro := 3;
    qualContr('00100107964600002150521').cdcooper := 1;qualContr('00100107964600002150521').nrdconta := 10796460;qualContr('00100107964600002150521').nrctremp := 2150521;qualContr('00100107964600002150521').idquapro := 3;
    qualContr('00100015016900002150719').cdcooper := 1;qualContr('00100015016900002150719').nrdconta := 1501690;qualContr('00100015016900002150719').nrctremp := 2150719;qualContr('00100015016900002150719').idquapro := 3;
    qualContr('00100101667930002149186').cdcooper := 1;qualContr('00100101667930002149186').nrdconta := 10166793;qualContr('00100101667930002149186').nrctremp := 2149186;qualContr('00100101667930002149186').idquapro := 3;
    qualContr('00100075828200002150090').cdcooper := 1;qualContr('00100075828200002150090').nrdconta := 7582820;qualContr('00100075828200002150090').nrctremp := 2150090;qualContr('00100075828200002150090').idquapro := 3;
    qualContr('00100108675620002153767').cdcooper := 1;qualContr('00100108675620002153767').nrdconta := 10867562;qualContr('00100108675620002153767').nrctremp := 2153767;qualContr('00100108675620002153767').idquapro := 3;
    qualContr('00100107369130002154413').cdcooper := 1;qualContr('00100107369130002154413').nrdconta := 10736913;qualContr('00100107369130002154413').nrctremp := 2154413;qualContr('00100107369130002154413').idquapro := 3;
    qualContr('00100095883700002159338').cdcooper := 1;qualContr('00100095883700002159338').nrdconta := 9588370;qualContr('00100095883700002159338').nrctremp := 2159338;qualContr('00100095883700002159338').idquapro := 3;
    qualContr('00100090998910002158680').cdcooper := 1;qualContr('00100090998910002158680').nrdconta := 9099891;qualContr('00100090998910002158680').nrctremp := 2158680;qualContr('00100090998910002158680').idquapro := 3;
    qualContr('00100008997470002160643').cdcooper := 1;qualContr('00100008997470002160643').nrdconta := 899747;qualContr('00100008997470002160643').nrctremp := 2160643;qualContr('00100008997470002160643').idquapro := 4;
    qualContr('00100074079630002159578').cdcooper := 1;qualContr('00100074079630002159578').nrdconta := 7407963;qualContr('00100074079630002159578').nrctremp := 2159578;qualContr('00100074079630002159578').idquapro := 4;
    qualContr('00100086994100002159012').cdcooper := 1;qualContr('00100086994100002159012').nrdconta := 8699410;qualContr('00100086994100002159012').nrctremp := 2159012;qualContr('00100086994100002159012').idquapro := 3;
    qualContr('00100021444170002160768').cdcooper := 1;qualContr('00100021444170002160768').nrdconta := 2144417;qualContr('00100021444170002160768').nrctremp := 2160768;qualContr('00100021444170002160768').idquapro := 3;
    qualContr('00100031722100002160691').cdcooper := 1;qualContr('00100031722100002160691').nrdconta := 3172210;qualContr('00100031722100002160691').nrctremp := 2160691;qualContr('00100031722100002160691').idquapro := 3;
    qualContr('00100092868370002157862').cdcooper := 1;qualContr('00100092868370002157862').nrdconta := 9286837;qualContr('00100092868370002157862').nrctremp := 2157862;qualContr('00100092868370002157862').idquapro := 3;
    qualContr('00100089196660002160821').cdcooper := 1;qualContr('00100089196660002160821').nrdconta := 8919666;qualContr('00100089196660002160821').nrctremp := 2160821;qualContr('00100089196660002160821').idquapro := 3;
    qualContr('00100106679200002164331').cdcooper := 1;qualContr('00100106679200002164331').nrdconta := 10667920;qualContr('00100106679200002164331').nrctremp := 2164331;qualContr('00100106679200002164331').idquapro := 3;
    qualContr('00100076219060002164949').cdcooper := 1;qualContr('00100076219060002164949').nrdconta := 7621906;qualContr('00100076219060002164949').nrctremp := 2164949;qualContr('00100076219060002164949').idquapro := 3;
    qualContr('00100023488530002166494').cdcooper := 1;qualContr('00100023488530002166494').nrdconta := 2348853;qualContr('00100023488530002166494').nrctremp := 2166494;qualContr('00100023488530002166494').idquapro := 3;
    qualContr('00100104744550002166551').cdcooper := 1;qualContr('00100104744550002166551').nrdconta := 10474455;qualContr('00100104744550002166551').nrctremp := 2166551;qualContr('00100104744550002166551').idquapro := 3;
    qualContr('00100006889590002170001').cdcooper := 1;qualContr('00100006889590002170001').nrdconta := 688959;qualContr('00100006889590002170001').nrctremp := 2170001;qualContr('00100006889590002170001').idquapro := 3;
    qualContr('00100074063550002170508').cdcooper := 1;qualContr('00100074063550002170508').nrdconta := 7406355;qualContr('00100074063550002170508').nrctremp := 2170508;qualContr('00100074063550002170508').idquapro := 3;
    qualContr('00100109847630002172027').cdcooper := 1;qualContr('00100109847630002172027').nrdconta := 10984763;qualContr('00100109847630002172027').nrctremp := 2172027;qualContr('00100109847630002172027').idquapro := 3;
    qualContr('00100100858150002169750').cdcooper := 1;qualContr('00100100858150002169750').nrdconta := 10085815;qualContr('00100100858150002169750').nrctremp := 2169750;qualContr('00100100858150002169750').idquapro := 3;
    qualContr('00100108173010002172182').cdcooper := 1;qualContr('00100108173010002172182').nrdconta := 10817301;qualContr('00100108173010002172182').nrctremp := 2172182;qualContr('00100108173010002172182').idquapro := 3;
    qualContr('00100025833990002169980').cdcooper := 1;qualContr('00100025833990002169980').nrdconta := 2583399;qualContr('00100025833990002169980').nrctremp := 2169980;qualContr('00100025833990002169980').idquapro := 4;
    qualContr('00100088036250002170493').cdcooper := 1;qualContr('00100088036250002170493').nrdconta := 8803625;qualContr('00100088036250002170493').nrctremp := 2170493;qualContr('00100088036250002170493').idquapro := 4;
    qualContr('00100094759580002174296').cdcooper := 1;qualContr('00100094759580002174296').nrdconta := 9475958;qualContr('00100094759580002174296').nrctremp := 2174296;qualContr('00100094759580002174296').idquapro := 3;
    qualContr('00100019391900002178274').cdcooper := 1;qualContr('00100019391900002178274').nrdconta := 1939190;qualContr('00100019391900002178274').nrctremp := 2178274;qualContr('00100019391900002178274').idquapro := 4;
    qualContr('00100028747680002194723').cdcooper := 1;qualContr('00100028747680002194723').nrdconta := 2874768;qualContr('00100028747680002194723').nrctremp := 2194723;qualContr('00100028747680002194723').idquapro := 3;
    qualContr('00100022031380002194545').cdcooper := 1;qualContr('00100022031380002194545').nrdconta := 2203138;qualContr('00100022031380002194545').nrctremp := 2194545;qualContr('00100022031380002194545').idquapro := 3;
    qualContr('00100083246200002194708').cdcooper := 1;qualContr('00100083246200002194708').nrdconta := 8324620;qualContr('00100083246200002194708').nrctremp := 2194708;qualContr('00100083246200002194708').idquapro := 3;
    qualContr('00100107500610002198749').cdcooper := 1;qualContr('00100107500610002198749').nrdconta := 10750061;qualContr('00100107500610002198749').nrctremp := 2198749;qualContr('00100107500610002198749').idquapro := 3;
    qualContr('00100107813310002204454').cdcooper := 1;qualContr('00100107813310002204454').nrdconta := 10781331;qualContr('00100107813310002204454').nrctremp := 2204454;qualContr('00100107813310002204454').idquapro := 3;
    qualContr('00100091079830002205360').cdcooper := 1;qualContr('00100091079830002205360').nrdconta := 9107983;qualContr('00100091079830002205360').nrctremp := 2205360;qualContr('00100091079830002205360').idquapro := 3;
    qualContr('00100086527160002206079').cdcooper := 1;qualContr('00100086527160002206079').nrdconta := 8652716;qualContr('00100086527160002206079').nrctremp := 2206079;qualContr('00100086527160002206079').idquapro := 4;
    qualContr('00100108432130002204467').cdcooper := 1;qualContr('00100108432130002204467').nrdconta := 10843213;qualContr('00100108432130002204467').nrctremp := 2204467;qualContr('00100108432130002204467').idquapro := 3;
    qualContr('00100098757510002206441').cdcooper := 1;qualContr('00100098757510002206441').nrdconta := 9875751;qualContr('00100098757510002206441').nrctremp := 2206441;qualContr('00100098757510002206441').idquapro := 3;
    qualContr('00100092976000002215020').cdcooper := 1;qualContr('00100092976000002215020').nrdconta := 9297600;qualContr('00100092976000002215020').nrctremp := 2215020;qualContr('00100092976000002215020').idquapro := 3;
    qualContr('00100101184110002213566').cdcooper := 1;qualContr('00100101184110002213566').nrdconta := 10118411;qualContr('00100101184110002213566').nrctremp := 2213566;qualContr('00100101184110002213566').idquapro := 3;
    qualContr('00100007723720002212596').cdcooper := 1;qualContr('00100007723720002212596').nrdconta := 772372;qualContr('00100007723720002212596').nrctremp := 2212596;qualContr('00100007723720002212596').idquapro := 3;
    qualContr('00100080698080002213554').cdcooper := 1;qualContr('00100080698080002213554').nrdconta := 8069808;qualContr('00100080698080002213554').nrctremp := 2213554;qualContr('00100080698080002213554').idquapro := 3;
    qualContr('00100066542230002214099').cdcooper := 1;qualContr('00100066542230002214099').nrdconta := 6654223;qualContr('00100066542230002214099').nrctremp := 2214099;qualContr('00100066542230002214099').idquapro := 3;
    qualContr('00100104915380002215275').cdcooper := 1;qualContr('00100104915380002215275').nrdconta := 10491538;qualContr('00100104915380002215275').nrctremp := 2215275;qualContr('00100104915380002215275').idquapro := 3;
    qualContr('00100088319040002212629').cdcooper := 1;qualContr('00100088319040002212629').nrdconta := 8831904;qualContr('00100088319040002212629').nrctremp := 2212629;qualContr('00100088319040002212629').idquapro := 3;
    qualContr('00100061451160002211728').cdcooper := 1;qualContr('00100061451160002211728').nrdconta := 6145116;qualContr('00100061451160002211728').nrctremp := 2211728;qualContr('00100061451160002211728').idquapro := 3;
    qualContr('00100108294900002213498').cdcooper := 1;qualContr('00100108294900002213498').nrdconta := 10829490;qualContr('00100108294900002213498').nrctremp := 2213498;qualContr('00100108294900002213498').idquapro := 3;
    qualContr('00100066379650002214964').cdcooper := 1;qualContr('00100066379650002214964').nrdconta := 6637965;qualContr('00100066379650002214964').nrctremp := 2214964;qualContr('00100066379650002214964').idquapro := 4;
    qualContr('00100104866070002222599').cdcooper := 1;qualContr('00100104866070002222599').nrdconta := 10486607;qualContr('00100104866070002222599').nrctremp := 2222599;qualContr('00100104866070002222599').idquapro := 3;
    qualContr('00100105068880002218657').cdcooper := 1;qualContr('00100105068880002218657').nrdconta := 10506888;qualContr('00100105068880002218657').nrctremp := 2218657;qualContr('00100105068880002218657').idquapro := 3;
    qualContr('00100078894880002222428').cdcooper := 1;qualContr('00100078894880002222428').nrdconta := 7889488;qualContr('00100078894880002222428').nrctremp := 2222428;qualContr('00100078894880002222428').idquapro := 3;
    qualContr('00100084166130002219200').cdcooper := 1;qualContr('00100084166130002219200').nrdconta := 8416613;qualContr('00100084166130002219200').nrctremp := 2219200;qualContr('00100084166130002219200').idquapro := 3;
    qualContr('00100079849100002217484').cdcooper := 1;qualContr('00100079849100002217484').nrdconta := 7984910;qualContr('00100079849100002217484').nrctremp := 2217484;qualContr('00100079849100002217484').idquapro := 3;
    qualContr('00100060884570002218833').cdcooper := 1;qualContr('00100060884570002218833').nrdconta := 6088457;qualContr('00100060884570002218833').nrctremp := 2218833;qualContr('00100060884570002218833').idquapro := 4;
    qualContr('00100021601450002221115').cdcooper := 1;qualContr('00100021601450002221115').nrdconta := 2160145;qualContr('00100021601450002221115').nrctremp := 2221115;qualContr('00100021601450002221115').idquapro := 3;
    qualContr('00100026568920002217585').cdcooper := 1;qualContr('00100026568920002217585').nrdconta := 2656892;qualContr('00100026568920002217585').nrctremp := 2217585;qualContr('00100026568920002217585').idquapro := 3;
    qualContr('00100026215410002232492').cdcooper := 1;qualContr('00100026215410002232492').nrdconta := 2621541;qualContr('00100026215410002232492').nrctremp := 2232492;qualContr('00100026215410002232492').idquapro := 3;
    qualContr('00100080307580002232613').cdcooper := 1;qualContr('00100080307580002232613').nrdconta := 8030758;qualContr('00100080307580002232613').nrctremp := 2232613;qualContr('00100080307580002232613').idquapro := 3;
    qualContr('00100097305830002240766').cdcooper := 1;qualContr('00100097305830002240766').nrdconta := 9730583;qualContr('00100097305830002240766').nrctremp := 2240766;qualContr('00100097305830002240766').idquapro := 3;
    qualContr('00100040863170002234245').cdcooper := 1;qualContr('00100040863170002234245').nrdconta := 4086317;qualContr('00100040863170002234245').nrctremp := 2234245;qualContr('00100040863170002234245').idquapro := 3;
    qualContr('00100801137880002233195').cdcooper := 1;qualContr('00100801137880002233195').nrdconta := 80113788;qualContr('00100801137880002233195').nrctremp := 2233195;qualContr('00100801137880002233195').idquapro := 3;
    qualContr('00100105532740002256153').cdcooper := 1;qualContr('00100105532740002256153').nrdconta := 10553274;qualContr('00100105532740002256153').nrctremp := 2256153;qualContr('00100105532740002256153').idquapro := 3;
    qualContr('00100103649860002259177').cdcooper := 1;qualContr('00100103649860002259177').nrdconta := 10364986;qualContr('00100103649860002259177').nrctremp := 2259177;qualContr('00100103649860002259177').idquapro := 3;
    qualContr('00100092663300002256769').cdcooper := 1;qualContr('00100092663300002256769').nrdconta := 9266330;qualContr('00100092663300002256769').nrctremp := 2256769;qualContr('00100092663300002256769').idquapro := 3;
    qualContr('00100037897130002253401').cdcooper := 1;qualContr('00100037897130002253401').nrdconta := 3789713;qualContr('00100037897130002253401').nrctremp := 2253401;qualContr('00100037897130002253401').idquapro := 3;
    qualContr('00100071191190002247837').cdcooper := 1;qualContr('00100071191190002247837').nrdconta := 7119119;qualContr('00100071191190002247837').nrctremp := 2247837;qualContr('00100071191190002247837').idquapro := 3;
    qualContr('00100074831980002248864').cdcooper := 1;qualContr('00100074831980002248864').nrdconta := 7483198;qualContr('00100074831980002248864').nrctremp := 2248864;qualContr('00100074831980002248864').idquapro := 4;
    qualContr('00100069201950002264196').cdcooper := 1;qualContr('00100069201950002264196').nrdconta := 6920195;qualContr('00100069201950002264196').nrctremp := 2264196;qualContr('00100069201950002264196').idquapro := 3;
    qualContr('00100036057790002262988').cdcooper := 1;qualContr('00100036057790002262988').nrdconta := 3605779;qualContr('00100036057790002262988').nrctremp := 2262988;qualContr('00100036057790002262988').idquapro := 4;
    qualContr('00100027110100002281721').cdcooper := 1;qualContr('00100027110100002281721').nrdconta := 2711010;qualContr('00100027110100002281721').nrctremp := 2281721;qualContr('00100027110100002281721').idquapro := 3;
    qualContr('00100104556800002297002').cdcooper := 1;qualContr('00100104556800002297002').nrdconta := 10455680;qualContr('00100104556800002297002').nrctremp := 2297002;qualContr('00100104556800002297002').idquapro := 3;
    qualContr('00100100220740002300000').cdcooper := 1;qualContr('00100100220740002300000').nrdconta := 10022074;qualContr('00100100220740002300000').nrctremp := 2300000;qualContr('00100100220740002300000').idquapro := 3;
    qualContr('00100106780000002297342').cdcooper := 1;qualContr('00100106780000002297342').nrdconta := 10678000;qualContr('00100106780000002297342').nrctremp := 2297342;qualContr('00100106780000002297342').idquapro := 4;
    qualContr('00100096369350002298820').cdcooper := 1;qualContr('00100096369350002298820').nrdconta := 9636935;qualContr('00100096369350002298820').nrctremp := 2298820;qualContr('00100096369350002298820').idquapro := 4;
    qualContr('00100106931810002298651').cdcooper := 1;qualContr('00100106931810002298651').nrdconta := 10693181;qualContr('00100106931810002298651').nrctremp := 2298651;qualContr('00100106931810002298651').idquapro := 3;
    qualContr('00100108478710002300222').cdcooper := 1;qualContr('00100108478710002300222').nrdconta := 10847871;qualContr('00100108478710002300222').nrctremp := 2300222;qualContr('00100108478710002300222').idquapro := 3;
    qualContr('00100023945880002312945').cdcooper := 1;qualContr('00100023945880002312945').nrdconta := 2394588;qualContr('00100023945880002312945').nrctremp := 2312945;qualContr('00100023945880002312945').idquapro := 3;
    qualContr('00100108278110002323779').cdcooper := 1;qualContr('00100108278110002323779').nrdconta := 10827811;qualContr('00100108278110002323779').nrctremp := 2323779;qualContr('00100108278110002323779').idquapro := 3;
    qualContr('00100076972950002324413').cdcooper := 1;qualContr('00100076972950002324413').nrdconta := 7697295;qualContr('00100076972950002324413').nrctremp := 2324413;qualContr('00100076972950002324413').idquapro := 3;
    qualContr('00100109305310002327702').cdcooper := 1;qualContr('00100109305310002327702').nrdconta := 10930531;qualContr('00100109305310002327702').nrctremp := 2327702;qualContr('00100109305310002327702').idquapro := 4;
    qualContr('00100080624630002316984').cdcooper := 1;qualContr('00100080624630002316984').nrdconta := 8062463;qualContr('00100080624630002316984').nrctremp := 2316984;qualContr('00100080624630002316984').idquapro := 3;
    qualContr('00100802490510002317165').cdcooper := 1;qualContr('00100802490510002317165').nrdconta := 80249051;qualContr('00100802490510002317165').nrctremp := 2317165;qualContr('00100802490510002317165').idquapro := 3;
    qualContr('00100103706920002319855').cdcooper := 1;qualContr('00100103706920002319855').nrdconta := 10370692;qualContr('00100103706920002319855').nrctremp := 2319855;qualContr('00100103706920002319855').idquapro := 3;
    qualContr('00100090890040002319039').cdcooper := 1;qualContr('00100090890040002319039').nrdconta := 9089004;qualContr('00100090890040002319039').nrctremp := 2319039;qualContr('00100090890040002319039').idquapro := 4;
    qualContr('00100082577440002346921').cdcooper := 1;qualContr('00100082577440002346921').nrdconta := 8257744;qualContr('00100082577440002346921').nrctremp := 2346921;qualContr('00100082577440002346921').idquapro := 3;
    qualContr('00100108493600002346476').cdcooper := 1;qualContr('00100108493600002346476').nrdconta := 10849360;qualContr('00100108493600002346476').nrctremp := 2346476;qualContr('00100108493600002346476').idquapro := 3;
    qualContr('00100108231400002353391').cdcooper := 1;qualContr('00100108231400002353391').nrdconta := 10823140;qualContr('00100108231400002353391').nrctremp := 2353391;qualContr('00100108231400002353391').idquapro := 3;
    qualContr('00100081074160002343048').cdcooper := 1;qualContr('00100081074160002343048').nrdconta := 8107416;qualContr('00100081074160002343048').nrctremp := 2343048;qualContr('00100081074160002343048').idquapro := 3;
    qualContr('00100075235050002383856').cdcooper := 1;qualContr('00100075235050002383856').nrdconta := 7523505;qualContr('00100075235050002383856').nrctremp := 2383856;qualContr('00100075235050002383856').idquapro := 3;
    qualContr('00100023131620002377437').cdcooper := 1;qualContr('00100023131620002377437').nrdconta := 2313162;qualContr('00100023131620002377437').nrctremp := 2377437;qualContr('00100023131620002377437').idquapro := 3;
    qualContr('00100092026330002382552').cdcooper := 1;qualContr('00100092026330002382552').nrdconta := 9202633;qualContr('00100092026330002382552').nrctremp := 2382552;qualContr('00100092026330002382552').idquapro := 3;
    qualContr('00100083445740002385146').cdcooper := 1;qualContr('00100083445740002385146').nrdconta := 8344574;qualContr('00100083445740002385146').nrctremp := 2385146;qualContr('00100083445740002385146').idquapro := 3;
    qualContr('00100107023770002381488').cdcooper := 1;qualContr('00100107023770002381488').nrdconta := 10702377;qualContr('00100107023770002381488').nrctremp := 2381488;qualContr('00100107023770002381488').idquapro := 4;
    qualContr('00100109654320002382345').cdcooper := 1;qualContr('00100109654320002382345').nrdconta := 10965432;qualContr('00100109654320002382345').nrctremp := 2382345;qualContr('00100109654320002382345').idquapro := 4;
    qualContr('00100085257570002395526').cdcooper := 1;qualContr('00100085257570002395526').nrdconta := 8525757;qualContr('00100085257570002395526').nrctremp := 2395526;qualContr('00100085257570002395526').idquapro := 3;
    qualContr('00100108649700002397064').cdcooper := 1;qualContr('00100108649700002397064').nrdconta := 10864970;qualContr('00100108649700002397064').nrctremp := 2397064;qualContr('00100108649700002397064').idquapro := 4;
    qualContr('00100094144360002404426').cdcooper := 1;qualContr('00100094144360002404426').nrdconta := 9414436;qualContr('00100094144360002404426').nrctremp := 2404426;qualContr('00100094144360002404426').idquapro := 3;
    qualContr('00100026845430002400530').cdcooper := 1;qualContr('00100026845430002400530').nrdconta := 2684543;qualContr('00100026845430002400530').nrctremp := 2400530;qualContr('00100026845430002400530').idquapro := 3;
    qualContr('00100108386860002398542').cdcooper := 1;qualContr('00100108386860002398542').nrdconta := 10838686;qualContr('00100108386860002398542').nrctremp := 2398542;qualContr('00100108386860002398542').idquapro := 4;
    qualContr('00100036809670002396309').cdcooper := 1;qualContr('00100036809670002396309').nrdconta := 3680967;qualContr('00100036809670002396309').nrctremp := 2396309;qualContr('00100036809670002396309').idquapro := 3;
    qualContr('00100104828900002397317').cdcooper := 1;qualContr('00100104828900002397317').nrdconta := 10482890;qualContr('00100104828900002397317').nrctremp := 2397317;qualContr('00100104828900002397317').idquapro := 3;
    qualContr('00100105852490002406638').cdcooper := 1;qualContr('00100105852490002406638').nrdconta := 10585249;qualContr('00100105852490002406638').nrctremp := 2406638;qualContr('00100105852490002406638').idquapro := 4;
    qualContr('00100071929670002408732').cdcooper := 1;qualContr('00100071929670002408732').nrdconta := 7192967;qualContr('00100071929670002408732').nrctremp := 2408732;qualContr('00100071929670002408732').idquapro := 3;
    qualContr('00100105983080002411625').cdcooper := 1;qualContr('00100105983080002411625').nrdconta := 10598308;qualContr('00100105983080002411625').nrctremp := 2411625;qualContr('00100105983080002411625').idquapro := 3;
    qualContr('00100063740000002406332').cdcooper := 1;qualContr('00100063740000002406332').nrdconta := 6374000;qualContr('00100063740000002406332').nrctremp := 2406332;qualContr('00100063740000002406332').idquapro := 3;
    qualContr('00100106813960002407791').cdcooper := 1;qualContr('00100106813960002407791').nrdconta := 10681396;qualContr('00100106813960002407791').nrctremp := 2407791;qualContr('00100106813960002407791').idquapro := 3;
    qualContr('00100108509880002411448').cdcooper := 1;qualContr('00100108509880002411448').nrdconta := 10850988;qualContr('00100108509880002411448').nrctremp := 2411448;qualContr('00100108509880002411448').idquapro := 3;
    qualContr('00100100492740002416056').cdcooper := 1;qualContr('00100100492740002416056').nrdconta := 10049274;qualContr('00100100492740002416056').nrctremp := 2416056;qualContr('00100100492740002416056').idquapro := 4;
    qualContr('00100108813440002416240').cdcooper := 1;qualContr('00100108813440002416240').nrdconta := 10881344;qualContr('00100108813440002416240').nrctremp := 2416240;qualContr('00100108813440002416240').idquapro := 4;
    qualContr('00100063223790002417044').cdcooper := 1;qualContr('00100063223790002417044').nrdconta := 6322379;qualContr('00100063223790002417044').nrctremp := 2417044;qualContr('00100063223790002417044').idquapro := 3;
    qualContr('00100093464650002415261').cdcooper := 1;qualContr('00100093464650002415261').nrdconta := 9346465;qualContr('00100093464650002415261').nrctremp := 2415261;qualContr('00100093464650002415261').idquapro := 3;
    qualContr('00100078143800002414919').cdcooper := 1;qualContr('00100078143800002414919').nrdconta := 7814380;qualContr('00100078143800002414919').nrctremp := 2414919;qualContr('00100078143800002414919').idquapro := 3;
    qualContr('00100061745310002417336').cdcooper := 1;qualContr('00100061745310002417336').nrdconta := 6174531;qualContr('00100061745310002417336').nrctremp := 2417336;qualContr('00100061745310002417336').idquapro := 3;
    qualContr('00100077703080002417731').cdcooper := 1;qualContr('00100077703080002417731').nrdconta := 7770308;qualContr('00100077703080002417731').nrctremp := 2417731;qualContr('00100077703080002417731').idquapro := 3;
    qualContr('00100088129930002417614').cdcooper := 1;qualContr('00100088129930002417614').nrdconta := 8812993;qualContr('00100088129930002417614').nrctremp := 2417614;qualContr('00100088129930002417614').idquapro := 3;
    qualContr('00100092176140002414229').cdcooper := 1;qualContr('00100092176140002414229').nrdconta := 9217614;qualContr('00100092176140002414229').nrctremp := 2414229;qualContr('00100092176140002414229').idquapro := 3;
    qualContr('00100025859010002424244').cdcooper := 1;qualContr('00100025859010002424244').nrdconta := 2585901;qualContr('00100025859010002424244').nrctremp := 2424244;qualContr('00100025859010002424244').idquapro := 3;
    qualContr('00100066804020002420625').cdcooper := 1;qualContr('00100066804020002420625').nrdconta := 6680402;qualContr('00100066804020002420625').nrctremp := 2420625;qualContr('00100066804020002420625').idquapro := 3;
    qualContr('00100105189080002422362').cdcooper := 1;qualContr('00100105189080002422362').nrdconta := 10518908;qualContr('00100105189080002422362').nrctremp := 2422362;qualContr('00100105189080002422362').idquapro := 3;
    qualContr('00100028940760002424579').cdcooper := 1;qualContr('00100028940760002424579').nrdconta := 2894076;qualContr('00100028940760002424579').nrctremp := 2424579;qualContr('00100028940760002424579').idquapro := 3;
    qualContr('00100107445680002422214').cdcooper := 1;qualContr('00100107445680002422214').nrdconta := 10744568;qualContr('00100107445680002422214').nrctremp := 2422214;qualContr('00100107445680002422214').idquapro := 4;
    qualContr('00100095289200002423746').cdcooper := 1;qualContr('00100095289200002423746').nrdconta := 9528920;qualContr('00100095289200002423746').nrctremp := 2423746;qualContr('00100095289200002423746').idquapro := 4;
    qualContr('00100090751510002428702').cdcooper := 1;qualContr('00100090751510002428702').nrdconta := 9075151;qualContr('00100090751510002428702').nrctremp := 2428702;qualContr('00100090751510002428702').idquapro := 4;
    qualContr('00100103154200002432982').cdcooper := 1;qualContr('00100103154200002432982').nrdconta := 10315420;qualContr('00100103154200002432982').nrctremp := 2432982;qualContr('00100103154200002432982').idquapro := 3;
    qualContr('00100102044230002432191').cdcooper := 1;qualContr('00100102044230002432191').nrdconta := 10204423;qualContr('00100102044230002432191').nrctremp := 2432191;qualContr('00100102044230002432191').idquapro := 3;
    qualContr('00100038433270002430013').cdcooper := 1;qualContr('00100038433270002430013').nrdconta := 3843327;qualContr('00100038433270002430013').nrctremp := 2430013;qualContr('00100038433270002430013').idquapro := 3;
    qualContr('00100095539830002433341').cdcooper := 1;qualContr('00100095539830002433341').nrdconta := 9553983;qualContr('00100095539830002433341').nrctremp := 2433341;qualContr('00100095539830002433341').idquapro := 3;
    qualContr('00100085520450002428879').cdcooper := 1;qualContr('00100085520450002428879').nrdconta := 8552045;qualContr('00100085520450002428879').nrctremp := 2428879;qualContr('00100085520450002428879').idquapro := 3;
    qualContr('00100106368460002430996').cdcooper := 1;qualContr('00100106368460002430996').nrdconta := 10636846;qualContr('00100106368460002430996').nrctremp := 2430996;qualContr('00100106368460002430996').idquapro := 3;
    qualContr('00100078230610002433735').cdcooper := 1;qualContr('00100078230610002433735').nrdconta := 7823061;qualContr('00100078230610002433735').nrctremp := 2433735;qualContr('00100078230610002433735').idquapro := 3;
    qualContr('00100108088170002441568').cdcooper := 1;qualContr('00100108088170002441568').nrdconta := 10808817;qualContr('00100108088170002441568').nrctremp := 2441568;qualContr('00100108088170002441568').idquapro := 3;
    qualContr('00100099038520002441363').cdcooper := 1;qualContr('00100099038520002441363').nrdconta := 9903852;qualContr('00100099038520002441363').nrctremp := 2441363;qualContr('00100099038520002441363').idquapro := 3;
    qualContr('00100038307640002441341').cdcooper := 1;qualContr('00100038307640002441341').nrdconta := 3830764;qualContr('00100038307640002441341').nrctremp := 2441341;qualContr('00100038307640002441341').idquapro := 3;
    qualContr('00100009349840002437937').cdcooper := 1;qualContr('00100009349840002437937').nrdconta := 934984;qualContr('00100009349840002437937').nrctremp := 2437937;qualContr('00100009349840002437937').idquapro := 4;
    qualContr('00100106689180002438146').cdcooper := 1;qualContr('00100106689180002438146').nrdconta := 10668918;qualContr('00100106689180002438146').nrctremp := 2438146;qualContr('00100106689180002438146').idquapro := 3;
    qualContr('00100103496180002440396').cdcooper := 1;qualContr('00100103496180002440396').nrdconta := 10349618;qualContr('00100103496180002440396').nrctremp := 2440396;qualContr('00100103496180002440396').idquapro := 4;
    qualContr('00100100492230002440289').cdcooper := 1;qualContr('00100100492230002440289').nrdconta := 10049223;qualContr('00100100492230002440289').nrctremp := 2440289;qualContr('00100100492230002440289').idquapro := 3;
    qualContr('00100070265280002446135').cdcooper := 1;qualContr('00100070265280002446135').nrdconta := 7026528;qualContr('00100070265280002446135').nrctremp := 2446135;qualContr('00100070265280002446135').idquapro := 3;
    qualContr('00100037477000002446771').cdcooper := 1;qualContr('00100037477000002446771').nrdconta := 3747700;qualContr('00100037477000002446771').nrctremp := 2446771;qualContr('00100037477000002446771').idquapro := 3;
    qualContr('00100092866830002443798').cdcooper := 1;qualContr('00100092866830002443798').nrdconta := 9286683;qualContr('00100092866830002443798').nrctremp := 2443798;qualContr('00100092866830002443798').idquapro := 3;
    qualContr('00100109159900002446921').cdcooper := 1;qualContr('00100109159900002446921').nrdconta := 10915990;qualContr('00100109159900002446921').nrctremp := 2446921;qualContr('00100109159900002446921').idquapro := 3;
    qualContr('00100011159360002446401').cdcooper := 1;qualContr('00100011159360002446401').nrdconta := 1115936;qualContr('00100011159360002446401').nrctremp := 2446401;qualContr('00100011159360002446401').idquapro := 3;
    qualContr('00100099119280002444469').cdcooper := 1;qualContr('00100099119280002444469').nrdconta := 9911928;qualContr('00100099119280002444469').nrctremp := 2444469;qualContr('00100099119280002444469').idquapro := 3;
    qualContr('00100106720520002446902').cdcooper := 1;qualContr('00100106720520002446902').nrdconta := 10672052;qualContr('00100106720520002446902').nrctremp := 2446902;qualContr('00100106720520002446902').idquapro := 3;
    qualContr('00100084495380002445864').cdcooper := 1;qualContr('00100084495380002445864').nrdconta := 8449538;qualContr('00100084495380002445864').nrctremp := 2445864;qualContr('00100084495380002445864').idquapro := 3;
    qualContr('00100104016100002444458').cdcooper := 1;qualContr('00100104016100002444458').nrdconta := 10401610;qualContr('00100104016100002444458').nrctremp := 2444458;qualContr('00100104016100002444458').idquapro := 4;
    qualContr('00100068103570002445784').cdcooper := 1;qualContr('00100068103570002445784').nrdconta := 6810357;qualContr('00100068103570002445784').nrctremp := 2445784;qualContr('00100068103570002445784').idquapro := 3;
    qualContr('00100025709710002443473').cdcooper := 1;qualContr('00100025709710002443473').nrdconta := 2570971;qualContr('00100025709710002443473').nrctremp := 2443473;qualContr('00100025709710002443473').idquapro := 3;
    qualContr('00100019526170002444583').cdcooper := 1;qualContr('00100019526170002444583').nrdconta := 1952617;qualContr('00100019526170002444583').nrctremp := 2444583;qualContr('00100019526170002444583').idquapro := 3;
    qualContr('00100064661500002446705').cdcooper := 1;qualContr('00100064661500002446705').nrdconta := 6466150;qualContr('00100064661500002446705').nrctremp := 2446705;qualContr('00100064661500002446705').idquapro := 3;
    qualContr('00100079124120002451098').cdcooper := 1;qualContr('00100079124120002451098').nrdconta := 7912412;qualContr('00100079124120002451098').nrctremp := 2451098;qualContr('00100079124120002451098').idquapro := 3;
    qualContr('00100108013830002457316').cdcooper := 1;qualContr('00100108013830002457316').nrdconta := 10801383;qualContr('00100108013830002457316').nrctremp := 2457316;qualContr('00100108013830002457316').idquapro := 3;
    qualContr('00100088064460002460828').cdcooper := 1;qualContr('00100088064460002460828').nrdconta := 8806446;qualContr('00100088064460002460828').nrctremp := 2460828;qualContr('00100088064460002460828').idquapro := 3;
    qualContr('00100095071160002458748').cdcooper := 1;qualContr('00100095071160002458748').nrdconta := 9507116;qualContr('00100095071160002458748').nrctremp := 2458748;qualContr('00100095071160002458748').idquapro := 3;
    qualContr('00100086096830002456174').cdcooper := 1;qualContr('00100086096830002456174').nrdconta := 8609683;qualContr('00100086096830002456174').nrctremp := 2456174;qualContr('00100086096830002456174').idquapro := 4;
    qualContr('00100074471160002456880').cdcooper := 1;qualContr('00100074471160002456880').nrdconta := 7447116;qualContr('00100074471160002456880').nrctremp := 2456880;qualContr('00100074471160002456880').idquapro := 4;
    qualContr('00100086599400002463329').cdcooper := 1;qualContr('00100086599400002463329').nrdconta := 8659940;qualContr('00100086599400002463329').nrctremp := 2463329;qualContr('00100086599400002463329').idquapro := 3;
    qualContr('00100104838100002463993').cdcooper := 1;qualContr('00100104838100002463993').nrdconta := 10483810;qualContr('00100104838100002463993').nrctremp := 2463993;qualContr('00100104838100002463993').idquapro := 4;
    qualContr('00100063217390002466501').cdcooper := 1;qualContr('00100063217390002466501').nrdconta := 6321739;qualContr('00100063217390002466501').nrctremp := 2466501;qualContr('00100063217390002466501').idquapro := 3;
    qualContr('00100082736340002465351').cdcooper := 1;qualContr('00100082736340002465351').nrdconta := 8273634;qualContr('00100082736340002465351').nrctremp := 2465351;qualContr('00100082736340002465351').idquapro := 3;
    qualContr('00100100919040002464993').cdcooper := 1;qualContr('00100100919040002464993').nrdconta := 10091904;qualContr('00100100919040002464993').nrctremp := 2464993;qualContr('00100100919040002464993').idquapro := 4;
    qualContr('00100075634340002465344').cdcooper := 1;qualContr('00100075634340002465344').nrdconta := 7563434;qualContr('00100075634340002465344').nrctremp := 2465344;qualContr('00100075634340002465344').idquapro := 3;
    qualContr('00100107705500002464390').cdcooper := 1;qualContr('00100107705500002464390').nrdconta := 10770550;qualContr('00100107705500002464390').nrctremp := 2464390;qualContr('00100107705500002464390').idquapro := 3;
    qualContr('00100103366300002464912').cdcooper := 1;qualContr('00100103366300002464912').nrdconta := 10336630;qualContr('00100103366300002464912').nrctremp := 2464912;qualContr('00100103366300002464912').idquapro := 3;
    qualContr('00100102519950002470188').cdcooper := 1;qualContr('00100102519950002470188').nrdconta := 10251995;qualContr('00100102519950002470188').nrctremp := 2470188;qualContr('00100102519950002470188').idquapro := 3;
    qualContr('00100094268250002470955').cdcooper := 1;qualContr('00100094268250002470955').nrdconta := 9426825;qualContr('00100094268250002470955').nrctremp := 2470955;qualContr('00100094268250002470955').idquapro := 3;
    qualContr('00100090721950002472321').cdcooper := 1;qualContr('00100090721950002472321').nrdconta := 9072195;qualContr('00100090721950002472321').nrctremp := 2472321;qualContr('00100090721950002472321').idquapro := 3;
    qualContr('00100111534230002471495').cdcooper := 1;qualContr('00100111534230002471495').nrdconta := 11153423;qualContr('00100111534230002471495').nrctremp := 2471495;qualContr('00100111534230002471495').idquapro := 3;
    qualContr('00100085512600002470020').cdcooper := 1;qualContr('00100085512600002470020').nrdconta := 8551260;qualContr('00100085512600002470020').nrctremp := 2470020;qualContr('00100085512600002470020').idquapro := 3;
    qualContr('00100102958440002469413').cdcooper := 1;qualContr('00100102958440002469413').nrdconta := 10295844;qualContr('00100102958440002469413').nrctremp := 2469413;qualContr('00100102958440002469413').idquapro := 3;
    qualContr('00100063691700002468625').cdcooper := 1;qualContr('00100063691700002468625').nrdconta := 6369170;qualContr('00100063691700002468625').nrctremp := 2468625;qualContr('00100063691700002468625').idquapro := 3;
    qualContr('00100094928010002470031').cdcooper := 1;qualContr('00100094928010002470031').nrdconta := 9492801;qualContr('00100094928010002470031').nrctremp := 2470031;qualContr('00100094928010002470031').idquapro := 3;
    qualContr('00100084028170002469759').cdcooper := 1;qualContr('00100084028170002469759').nrdconta := 8402817;qualContr('00100084028170002469759').nrctremp := 2469759;qualContr('00100084028170002469759').idquapro := 3;
    qualContr('00100035812680002469220').cdcooper := 1;qualContr('00100035812680002469220').nrdconta := 3581268;qualContr('00100035812680002469220').nrctremp := 2469220;qualContr('00100035812680002469220').idquapro := 3;
    qualContr('00100026869100002472428').cdcooper := 1;qualContr('00100026869100002472428').nrdconta := 2686910;qualContr('00100026869100002472428').nrctremp := 2472428;qualContr('00100026869100002472428').idquapro := 3;
    qualContr('00100077048520002470521').cdcooper := 1;qualContr('00100077048520002470521').nrdconta := 7704852;qualContr('00100077048520002470521').nrctremp := 2470521;qualContr('00100077048520002470521').idquapro := 3;
    qualContr('00100039172150002476722').cdcooper := 1;qualContr('00100039172150002476722').nrdconta := 3917215;qualContr('00100039172150002476722').nrctremp := 2476722;qualContr('00100039172150002476722').idquapro := 3;
    qualContr('00100107668630002473660').cdcooper := 1;qualContr('00100107668630002473660').nrdconta := 10766863;qualContr('00100107668630002473660').nrctremp := 2473660;qualContr('00100107668630002473660').idquapro := 3;
    qualContr('00100026566040002476527').cdcooper := 1;qualContr('00100026566040002476527').nrdconta := 2656604;qualContr('00100026566040002476527').nrctremp := 2476527;qualContr('00100026566040002476527').idquapro := 3;
    qualContr('00100068407950002476909').cdcooper := 1;qualContr('00100068407950002476909').nrdconta := 6840795;qualContr('00100068407950002476909').nrctremp := 2476909;qualContr('00100068407950002476909').idquapro := 3;
    qualContr('00100025268750002478416').cdcooper := 1;qualContr('00100025268750002478416').nrdconta := 2526875;qualContr('00100025268750002478416').nrctremp := 2478416;qualContr('00100025268750002478416').idquapro := 3;
    qualContr('00100096905730002476068').cdcooper := 1;qualContr('00100096905730002476068').nrdconta := 9690573;qualContr('00100096905730002476068').nrctremp := 2476068;qualContr('00100096905730002476068').idquapro := 3;
    qualContr('00100106796260002477602').cdcooper := 1;qualContr('00100106796260002477602').nrdconta := 10679626;qualContr('00100106796260002477602').nrctremp := 2477602;qualContr('00100106796260002477602').idquapro := 3;
    qualContr('00100079962920002475092').cdcooper := 1;qualContr('00100079962920002475092').nrdconta := 7996292;qualContr('00100079962920002475092').nrctremp := 2475092;qualContr('00100079962920002475092').idquapro := 3;
    qualContr('00100107667820002473633').cdcooper := 1;qualContr('00100107667820002473633').nrdconta := 10766782;qualContr('00100107667820002473633').nrctremp := 2473633;qualContr('00100107667820002473633').idquapro := 3;
    qualContr('00100073368700002478059').cdcooper := 1;qualContr('00100073368700002478059').nrdconta := 7336870;qualContr('00100073368700002478059').nrctremp := 2478059;qualContr('00100073368700002478059').idquapro := 3;
    qualContr('00100107398310002476058').cdcooper := 1;qualContr('00100107398310002476058').nrdconta := 10739831;qualContr('00100107398310002476058').nrctremp := 2476058;qualContr('00100107398310002476058').idquapro := 3;
    qualContr('00100029140770002478052').cdcooper := 1;qualContr('00100029140770002478052').nrdconta := 2914077;qualContr('00100029140770002478052').nrctremp := 2478052;qualContr('00100029140770002478052').idquapro := 3;
    qualContr('00100021650230002484368').cdcooper := 1;qualContr('00100021650230002484368').nrdconta := 2165023;qualContr('00100021650230002484368').nrctremp := 2484368;qualContr('00100021650230002484368').idquapro := 3;
    qualContr('00100031277370002484528').cdcooper := 1;qualContr('00100031277370002484528').nrdconta := 3127737;qualContr('00100031277370002484528').nrctremp := 2484528;qualContr('00100031277370002484528').idquapro := 3;
    qualContr('00100023554500002486823').cdcooper := 1;qualContr('00100023554500002486823').nrdconta := 2355450;qualContr('00100023554500002486823').nrctremp := 2486823;qualContr('00100023554500002486823').idquapro := 3;
    qualContr('00100089552120002486553').cdcooper := 1;qualContr('00100089552120002486553').nrdconta := 8955212;qualContr('00100089552120002486553').nrctremp := 2486553;qualContr('00100089552120002486553').idquapro := 3;
    qualContr('00100080876520002485645').cdcooper := 1;qualContr('00100080876520002485645').nrdconta := 8087652;qualContr('00100080876520002485645').nrctremp := 2485645;qualContr('00100080876520002485645').idquapro := 4;
    qualContr('00100072857440002485164').cdcooper := 1;qualContr('00100072857440002485164').nrdconta := 7285744;qualContr('00100072857440002485164').nrctremp := 2485164;qualContr('00100072857440002485164').idquapro := 3;
    qualContr('00100109990510002484950').cdcooper := 1;qualContr('00100109990510002484950').nrdconta := 10999051;qualContr('00100109990510002484950').nrctremp := 2484950;qualContr('00100109990510002484950').idquapro := 3;
    qualContr('00100104791120002486179').cdcooper := 1;qualContr('00100104791120002486179').nrdconta := 10479112;qualContr('00100104791120002486179').nrctremp := 2486179;qualContr('00100104791120002486179').idquapro := 4;
    qualContr('00100068487370002486048').cdcooper := 1;qualContr('00100068487370002486048').nrdconta := 6848737;qualContr('00100068487370002486048').nrctremp := 2486048;qualContr('00100068487370002486048').idquapro := 3;
    qualContr('00100104694860002483975').cdcooper := 1;qualContr('00100104694860002483975').nrdconta := 10469486;qualContr('00100104694860002483975').nrctremp := 2483975;qualContr('00100104694860002483975').idquapro := 3;
    qualContr('00100103792070002487612').cdcooper := 1;qualContr('00100103792070002487612').nrdconta := 10379207;qualContr('00100103792070002487612').nrctremp := 2487612;qualContr('00100103792070002487612').idquapro := 3;
    qualContr('00100109676210002488852').cdcooper := 1;qualContr('00100109676210002488852').nrdconta := 10967621;qualContr('00100109676210002488852').nrctremp := 2488852;qualContr('00100109676210002488852').idquapro := 3;
    qualContr('00100072074760002487141').cdcooper := 1;qualContr('00100072074760002487141').nrdconta := 7207476;qualContr('00100072074760002487141').nrctremp := 2487141;qualContr('00100072074760002487141').idquapro := 3;
    qualContr('00100803458080002483748').cdcooper := 1;qualContr('00100803458080002483748').nrdconta := 80345808;qualContr('00100803458080002483748').nrctremp := 2483748;qualContr('00100803458080002483748').idquapro := 3;
    qualContr('00100064029840002490348').cdcooper := 1;qualContr('00100064029840002490348').nrdconta := 6402984;qualContr('00100064029840002490348').nrctremp := 2490348;qualContr('00100064029840002490348').idquapro := 4;
    qualContr('00100100251890002494012').cdcooper := 1;qualContr('00100100251890002494012').nrdconta := 10025189;qualContr('00100100251890002494012').nrctremp := 2494012;qualContr('00100100251890002494012').idquapro := 3;
    qualContr('00100063980490002492451').cdcooper := 1;qualContr('00100063980490002492451').nrdconta := 6398049;qualContr('00100063980490002492451').nrctremp := 2492451;qualContr('00100063980490002492451').idquapro := 3;
    qualContr('00100103603600002494191').cdcooper := 1;qualContr('00100103603600002494191').nrdconta := 10360360;qualContr('00100103603600002494191').nrctremp := 2494191;qualContr('00100103603600002494191').idquapro := 3;
    qualContr('00100020870140002490071').cdcooper := 1;qualContr('00100020870140002490071').nrdconta := 2087014;qualContr('00100020870140002490071').nrctremp := 2490071;qualContr('00100020870140002490071').idquapro := 3;
    qualContr('00100079713460002495756').cdcooper := 1;qualContr('00100079713460002495756').nrdconta := 7971346;qualContr('00100079713460002495756').nrctremp := 2495756;qualContr('00100079713460002495756').idquapro := 3;
    qualContr('00100098333070002498174').cdcooper := 1;qualContr('00100098333070002498174').nrdconta := 9833307;qualContr('00100098333070002498174').nrctremp := 2498174;qualContr('00100098333070002498174').idquapro := 3;
    qualContr('00100097451900002497097').cdcooper := 1;qualContr('00100097451900002497097').nrdconta := 9745190;qualContr('00100097451900002497097').nrctremp := 2497097;qualContr('00100097451900002497097').idquapro := 3;
    qualContr('00100078555590002495552').cdcooper := 1;qualContr('00100078555590002495552').nrdconta := 7855559;qualContr('00100078555590002495552').nrctremp := 2495552;qualContr('00100078555590002495552').idquapro := 3;
    qualContr('00100021848180002499332').cdcooper := 1;qualContr('00100021848180002499332').nrdconta := 2184818;qualContr('00100021848180002499332').nrctremp := 2499332;qualContr('00100021848180002499332').idquapro := 3;
    qualContr('00100037448250002497948').cdcooper := 1;qualContr('00100037448250002497948').nrdconta := 3744825;qualContr('00100037448250002497948').nrctremp := 2497948;qualContr('00100037448250002497948').idquapro := 3;
    qualContr('00100039383280002498972').cdcooper := 1;qualContr('00100039383280002498972').nrdconta := 3938328;qualContr('00100039383280002498972').nrctremp := 2498972;qualContr('00100039383280002498972').idquapro := 4;
    qualContr('00100096048200002499033').cdcooper := 1;qualContr('00100096048200002499033').nrdconta := 9604820;qualContr('00100096048200002499033').nrctremp := 2499033;qualContr('00100096048200002499033').idquapro := 3;
    qualContr('00100090188160002497624').cdcooper := 1;qualContr('00100090188160002497624').nrdconta := 9018816;qualContr('00100090188160002497624').nrctremp := 2497624;qualContr('00100090188160002497624').idquapro := 3;
    qualContr('00100078428560002501346').cdcooper := 1;qualContr('00100078428560002501346').nrdconta := 7842856;qualContr('00100078428560002501346').nrctremp := 2501346;qualContr('00100078428560002501346').idquapro := 3;
    qualContr('00100099309220002502763').cdcooper := 1;qualContr('00100099309220002502763').nrdconta := 9930922;qualContr('00100099309220002502763').nrctremp := 2502763;qualContr('00100099309220002502763').idquapro := 3;
    qualContr('00100096853750002503532').cdcooper := 1;qualContr('00100096853750002503532').nrdconta := 9685375;qualContr('00100096853750002503532').nrctremp := 2503532;qualContr('00100096853750002503532').idquapro := 3;
    qualContr('00100110475340002503027').cdcooper := 1;qualContr('00100110475340002503027').nrdconta := 11047534;qualContr('00100110475340002503027').nrctremp := 2503027;qualContr('00100110475340002503027').idquapro := 3;
    qualContr('00100077071850002502268').cdcooper := 1;qualContr('00100077071850002502268').nrdconta := 7707185;qualContr('00100077071850002502268').nrctremp := 2502268;qualContr('00100077071850002502268').idquapro := 3;
    qualContr('00100108178240002503221').cdcooper := 1;qualContr('00100108178240002503221').nrdconta := 10817824;qualContr('00100108178240002503221').nrctremp := 2503221;qualContr('00100108178240002503221').idquapro := 3;
    qualContr('00100029402210002501671').cdcooper := 1;qualContr('00100029402210002501671').nrdconta := 2940221;qualContr('00100029402210002501671').nrctremp := 2501671;qualContr('00100029402210002501671').idquapro := 3;
    qualContr('00100060224800002501753').cdcooper := 1;qualContr('00100060224800002501753').nrdconta := 6022480;qualContr('00100060224800002501753').nrctremp := 2501753;qualContr('00100060224800002501753').idquapro := 3;
    qualContr('00100096161950002501145').cdcooper := 1;qualContr('00100096161950002501145').nrdconta := 9616195;qualContr('00100096161950002501145').nrctremp := 2501145;qualContr('00100096161950002501145').idquapro := 3;
    qualContr('00100015192040002503915').cdcooper := 1;qualContr('00100015192040002503915').nrdconta := 1519204;qualContr('00100015192040002503915').nrctremp := 2503915;qualContr('00100015192040002503915').idquapro := 3;
    qualContr('00100106659510002503576').cdcooper := 1;qualContr('00100106659510002503576').nrdconta := 10665951;qualContr('00100106659510002503576').nrctremp := 2503576;qualContr('00100106659510002503576').idquapro := 3;
    qualContr('00100108464170002503615').cdcooper := 1;qualContr('00100108464170002503615').nrdconta := 10846417;qualContr('00100108464170002503615').nrctremp := 2503615;qualContr('00100108464170002503615').idquapro := 4;
    qualContr('00100108326610002500999').cdcooper := 1;qualContr('00100108326610002500999').nrdconta := 10832661;qualContr('00100108326610002500999').nrctremp := 2500999;qualContr('00100108326610002500999').idquapro := 3;
    qualContr('00100104414330002503071').cdcooper := 1;qualContr('00100104414330002503071').nrdconta := 10441433;qualContr('00100104414330002503071').nrctremp := 2503071;qualContr('00100104414330002503071').idquapro := 3;
    qualContr('00100079777940002501580').cdcooper := 1;qualContr('00100079777940002501580').nrdconta := 7977794;qualContr('00100079777940002501580').nrctremp := 2501580;qualContr('00100079777940002501580').idquapro := 3;
    qualContr('00100061002950002506849').cdcooper := 1;qualContr('00100061002950002506849').nrdconta := 6100295;qualContr('00100061002950002506849').nrctremp := 2506849;qualContr('00100061002950002506849').idquapro := 3;
    qualContr('00100105221740002509771').cdcooper := 1;qualContr('00100105221740002509771').nrdconta := 10522174;qualContr('00100105221740002509771').nrctremp := 2509771;qualContr('00100105221740002509771').idquapro := 3;
    qualContr('00100102419490002508746').cdcooper := 1;qualContr('00100102419490002508746').nrdconta := 10241949;qualContr('00100102419490002508746').nrctremp := 2508746;qualContr('00100102419490002508746').idquapro := 3;
    qualContr('00100078333690002507902').cdcooper := 1;qualContr('00100078333690002507902').nrdconta := 7833369;qualContr('00100078333690002507902').nrctremp := 2507902;qualContr('00100078333690002507902').idquapro := 3;
    qualContr('00100108844080002509097').cdcooper := 1;qualContr('00100108844080002509097').nrdconta := 10884408;qualContr('00100108844080002509097').nrctremp := 2509097;qualContr('00100108844080002509097').idquapro := 4;
    qualContr('00100098075510002505988').cdcooper := 1;qualContr('00100098075510002505988').nrdconta := 9807551;qualContr('00100098075510002505988').nrctremp := 2505988;qualContr('00100098075510002505988').idquapro := 3;
    qualContr('00100078045200002509535').cdcooper := 1;qualContr('00100078045200002509535').nrdconta := 7804520;qualContr('00100078045200002509535').nrctremp := 2509535;qualContr('00100078045200002509535').idquapro := 3;
    qualContr('00100066402140002509712').cdcooper := 1;qualContr('00100066402140002509712').nrdconta := 6640214;qualContr('00100066402140002509712').nrctremp := 2509712;qualContr('00100066402140002509712').idquapro := 4;
    qualContr('00100080477400002509199').cdcooper := 1;qualContr('00100080477400002509199').nrdconta := 8047740;qualContr('00100080477400002509199').nrctremp := 2509199;qualContr('00100080477400002509199').idquapro := 3;
    qualContr('00100104580500002514754').cdcooper := 1;qualContr('00100104580500002514754').nrdconta := 10458050;qualContr('00100104580500002514754').nrctremp := 2514754;qualContr('00100104580500002514754').idquapro := 3;
    qualContr('00100018816120002518430').cdcooper := 1;qualContr('00100018816120002518430').nrdconta := 1881612;qualContr('00100018816120002518430').nrctremp := 2518430;qualContr('00100018816120002518430').idquapro := 3;
    qualContr('00100066070200002514859').cdcooper := 1;qualContr('00100066070200002514859').nrdconta := 6607020;qualContr('00100066070200002514859').nrctremp := 2514859;qualContr('00100066070200002514859').idquapro := 3;
    qualContr('00100076650240002515000').cdcooper := 1;qualContr('00100076650240002515000').nrdconta := 7665024;qualContr('00100076650240002515000').nrctremp := 2515000;qualContr('00100076650240002515000').idquapro := 3;
    qualContr('00100106780500002514895').cdcooper := 1;qualContr('00100106780500002514895').nrdconta := 10678050;qualContr('00100106780500002514895').nrctremp := 2514895;qualContr('00100106780500002514895').idquapro := 3;
    qualContr('00100099552750002518298').cdcooper := 1;qualContr('00100099552750002518298').nrdconta := 9955275;qualContr('00100099552750002518298').nrctremp := 2518298;qualContr('00100099552750002518298').idquapro := 3;
    qualContr('00100084697170002517783').cdcooper := 1;qualContr('00100084697170002517783').nrdconta := 8469717;qualContr('00100084697170002517783').nrctremp := 2517783;qualContr('00100084697170002517783').idquapro := 3;
    qualContr('00100071274640002518693').cdcooper := 1;qualContr('00100071274640002518693').nrdconta := 7127464;qualContr('00100071274640002518693').nrctremp := 2518693;qualContr('00100071274640002518693').idquapro := 3;
    qualContr('00100081301080002514759').cdcooper := 1;qualContr('00100081301080002514759').nrdconta := 8130108;qualContr('00100081301080002514759').nrctremp := 2514759;qualContr('00100081301080002514759').idquapro := 3;
    qualContr('00100800392600002515934').cdcooper := 1;qualContr('00100800392600002515934').nrdconta := 80039260;qualContr('00100800392600002515934').nrctremp := 2515934;qualContr('00100800392600002515934').idquapro := 3;
    qualContr('00100085015300002517974').cdcooper := 1;qualContr('00100085015300002517974').nrdconta := 8501530;qualContr('00100085015300002517974').nrctremp := 2517974;qualContr('00100085015300002517974').idquapro := 3;
    qualContr('00100105496840002524116').cdcooper := 1;qualContr('00100105496840002524116').nrdconta := 10549684;qualContr('00100105496840002524116').nrctremp := 2524116;qualContr('00100105496840002524116').idquapro := 3;
    qualContr('00100085356120002522889').cdcooper := 1;qualContr('00100085356120002522889').nrdconta := 8535612;qualContr('00100085356120002522889').nrctremp := 2522889;qualContr('00100085356120002522889').idquapro := 3;
    qualContr('00100098909980002522238').cdcooper := 1;qualContr('00100098909980002522238').nrdconta := 9890998;qualContr('00100098909980002522238').nrctremp := 2522238;qualContr('00100098909980002522238').idquapro := 4;
    qualContr('00100084751800002522506').cdcooper := 1;qualContr('00100084751800002522506').nrdconta := 8475180;qualContr('00100084751800002522506').nrctremp := 2522506;qualContr('00100084751800002522506').idquapro := 3;
    qualContr('00100099848520002522109').cdcooper := 1;qualContr('00100099848520002522109').nrdconta := 9984852;qualContr('00100099848520002522109').nrctremp := 2522109;qualContr('00100099848520002522109').idquapro := 3;
    qualContr('00100093809570002528075').cdcooper := 1;qualContr('00100093809570002528075').nrdconta := 9380957;qualContr('00100093809570002528075').nrctremp := 2528075;qualContr('00100093809570002528075').idquapro := 3;
    qualContr('00100109378700002527810').cdcooper := 1;qualContr('00100109378700002527810').nrdconta := 10937870;qualContr('00100109378700002527810').nrctremp := 2527810;qualContr('00100109378700002527810').idquapro := 4;
    qualContr('00100096965980002529098').cdcooper := 1;qualContr('00100096965980002529098').nrdconta := 9696598;qualContr('00100096965980002529098').nrctremp := 2529098;qualContr('00100096965980002529098').idquapro := 3;
    qualContr('00100109187790002526603').cdcooper := 1;qualContr('00100109187790002526603').nrdconta := 10918779;qualContr('00100109187790002526603').nrctremp := 2526603;qualContr('00100109187790002526603').idquapro := 3;
    qualContr('00100105556330002526670').cdcooper := 1;qualContr('00100105556330002526670').nrdconta := 10555633;qualContr('00100105556330002526670').nrctremp := 2526670;qualContr('00100105556330002526670').idquapro := 3;
    qualContr('00100105084900002527154').cdcooper := 1;qualContr('00100105084900002527154').nrdconta := 10508490;qualContr('00100105084900002527154').nrctremp := 2527154;qualContr('00100105084900002527154').idquapro := 3;
    qualContr('00100085356120002532337').cdcooper := 1;qualContr('00100085356120002532337').nrdconta := 8535612;qualContr('00100085356120002532337').nrctremp := 2532337;qualContr('00100085356120002532337').idquapro := 3;
    qualContr('00100100230380002532940').cdcooper := 1;qualContr('00100100230380002532940').nrdconta := 10023038;qualContr('00100100230380002532940').nrctremp := 2532940;qualContr('00100100230380002532940').idquapro := 3;
    qualContr('00100087226500002533009').cdcooper := 1;qualContr('00100087226500002533009').nrdconta := 8722650;qualContr('00100087226500002533009').nrctremp := 2533009;qualContr('00100087226500002533009').idquapro := 3;
    qualContr('00100111341190002532341').cdcooper := 1;qualContr('00100111341190002532341').nrdconta := 11134119;qualContr('00100111341190002532341').nrctremp := 2532341;qualContr('00100111341190002532341').idquapro := 3;
    qualContr('00100079095860002530324').cdcooper := 1;qualContr('00100079095860002530324').nrdconta := 7909586;qualContr('00100079095860002530324').nrctremp := 2530324;qualContr('00100079095860002530324').idquapro := 3;
    qualContr('00100086434070002532944').cdcooper := 1;qualContr('00100086434070002532944').nrdconta := 8643407;qualContr('00100086434070002532944').nrctremp := 2532944;qualContr('00100086434070002532944').idquapro := 3;
    qualContr('00100085763430002530530').cdcooper := 1;qualContr('00100085763430002530530').nrdconta := 8576343;qualContr('00100085763430002530530').nrctremp := 2530530;qualContr('00100085763430002530530').idquapro := 3;
    qualContr('00100109190580002532409').cdcooper := 1;qualContr('00100109190580002532409').nrdconta := 10919058;qualContr('00100109190580002532409').nrctremp := 2532409;qualContr('00100109190580002532409').idquapro := 3;
    qualContr('00100098958920002530724').cdcooper := 1;qualContr('00100098958920002530724').nrdconta := 9895892;qualContr('00100098958920002530724').nrctremp := 2530724;qualContr('00100098958920002530724').idquapro := 3;
    qualContr('00100106404600002538385').cdcooper := 1;qualContr('00100106404600002538385').nrdconta := 10640460;qualContr('00100106404600002538385').nrctremp := 2538385;qualContr('00100106404600002538385').idquapro := 3;
    qualContr('00100024374300002537133').cdcooper := 1;qualContr('00100024374300002537133').nrdconta := 2437430;qualContr('00100024374300002537133').nrctremp := 2537133;qualContr('00100024374300002537133').idquapro := 4;
    qualContr('00100084452220002536971').cdcooper := 1;qualContr('00100084452220002536971').nrdconta := 8445222;qualContr('00100084452220002536971').nrctremp := 2536971;qualContr('00100084452220002536971').idquapro := 3;
    qualContr('00100089430790002535680').cdcooper := 1;qualContr('00100089430790002535680').nrdconta := 8943079;qualContr('00100089430790002535680').nrctremp := 2535680;qualContr('00100089430790002535680').idquapro := 3;
    qualContr('00100106963260002535097').cdcooper := 1;qualContr('00100106963260002535097').nrdconta := 10696326;qualContr('00100106963260002535097').nrctremp := 2535097;qualContr('00100106963260002535097').idquapro := 3;
    qualContr('00100067219820002535895').cdcooper := 1;qualContr('00100067219820002535895').nrdconta := 6721982;qualContr('00100067219820002535895').nrctremp := 2535895;qualContr('00100067219820002535895').idquapro := 3;
    qualContr('00100107438200002536285').cdcooper := 1;qualContr('00100107438200002536285').nrdconta := 10743820;qualContr('00100107438200002536285').nrctremp := 2536285;qualContr('00100107438200002536285').idquapro := 4;
    qualContr('00100025258100002534783').cdcooper := 1;qualContr('00100025258100002534783').nrdconta := 2525810;qualContr('00100025258100002534783').nrctremp := 2534783;qualContr('00100025258100002534783').idquapro := 3;
    qualContr('00100106390470002536679').cdcooper := 1;qualContr('00100106390470002536679').nrdconta := 10639047;qualContr('00100106390470002536679').nrctremp := 2536679;qualContr('00100106390470002536679').idquapro := 3;
    qualContr('00100075229160002545636').cdcooper := 1;qualContr('00100075229160002545636').nrdconta := 7522916;qualContr('00100075229160002545636').nrctremp := 2545636;qualContr('00100075229160002545636').idquapro := 3;
    qualContr('00100102801970002544180').cdcooper := 1;qualContr('00100102801970002544180').nrdconta := 10280197;qualContr('00100102801970002544180').nrctremp := 2544180;qualContr('00100102801970002544180').idquapro := 4;
    qualContr('00100087392500002545149').cdcooper := 1;qualContr('00100087392500002545149').nrdconta := 8739250;qualContr('00100087392500002545149').nrctremp := 2545149;qualContr('00100087392500002545149').idquapro := 3;
    qualContr('00100083185060002545282').cdcooper := 1;qualContr('00100083185060002545282').nrdconta := 8318506;qualContr('00100083185060002545282').nrctremp := 2545282;qualContr('00100083185060002545282').idquapro := 3;
    qualContr('00100111167730002544266').cdcooper := 1;qualContr('00100111167730002544266').nrdconta := 11116773;qualContr('00100111167730002544266').nrctremp := 2544266;qualContr('00100111167730002544266').idquapro := 3;
    qualContr('00100104374440002544145').cdcooper := 1;qualContr('00100104374440002544145').nrdconta := 10437444;qualContr('00100104374440002544145').nrctremp := 2544145;qualContr('00100104374440002544145').idquapro := 3;
    qualContr('00100900770080002544921').cdcooper := 1;qualContr('00100900770080002544921').nrdconta := 90077008;qualContr('00100900770080002544921').nrctremp := 2544921;qualContr('00100900770080002544921').idquapro := 4;
    qualContr('00100091895640002541997').cdcooper := 1;qualContr('00100091895640002541997').nrdconta := 9189564;qualContr('00100091895640002541997').nrctremp := 2541997;qualContr('00100091895640002541997').idquapro := 3;
    qualContr('00100065580460002547055').cdcooper := 1;qualContr('00100065580460002547055').nrdconta := 6558046;qualContr('00100065580460002547055').nrctremp := 2547055;qualContr('00100065580460002547055').idquapro := 3;
    qualContr('00100062269220002548151').cdcooper := 1;qualContr('00100062269220002548151').nrdconta := 6226922;qualContr('00100062269220002548151').nrctremp := 2548151;qualContr('00100062269220002548151').idquapro := 3;
    qualContr('00100101312720002549147').cdcooper := 1;qualContr('00100101312720002549147').nrdconta := 10131272;qualContr('00100101312720002549147').nrctremp := 2549147;qualContr('00100101312720002549147').idquapro := 3;
    qualContr('00100082318930002549165').cdcooper := 1;qualContr('00100082318930002549165').nrdconta := 8231893;qualContr('00100082318930002549165').nrctremp := 2549165;qualContr('00100082318930002549165').idquapro := 3;
    qualContr('00100097065340002549989').cdcooper := 1;qualContr('00100097065340002549989').nrdconta := 9706534;qualContr('00100097065340002549989').nrctremp := 2549989;qualContr('00100097065340002549989').idquapro := 3;
    qualContr('00100098778940002549852').cdcooper := 1;qualContr('00100098778940002549852').nrdconta := 9877894;qualContr('00100098778940002549852').nrctremp := 2549852;qualContr('00100098778940002549852').idquapro := 3;
    qualContr('00100106970470002548538').cdcooper := 1;qualContr('00100106970470002548538').nrdconta := 10697047;qualContr('00100106970470002548538').nrctremp := 2548538;qualContr('00100106970470002548538').idquapro := 4;
    qualContr('00100071318100002548265').cdcooper := 1;qualContr('00100071318100002548265').nrdconta := 7131810;qualContr('00100071318100002548265').nrctremp := 2548265;qualContr('00100071318100002548265').idquapro := 3;
    qualContr('00100103288230002550068').cdcooper := 1;qualContr('00100103288230002550068').nrdconta := 10328823;qualContr('00100103288230002550068').nrctremp := 2550068;qualContr('00100103288230002550068').idquapro := 4;
    qualContr('00100065450920002547491').cdcooper := 1;qualContr('00100065450920002547491').nrdconta := 6545092;qualContr('00100065450920002547491').nrctremp := 2547491;qualContr('00100065450920002547491').idquapro := 3;
    qualContr('00100104748110002553142').cdcooper := 1;qualContr('00100104748110002553142').nrdconta := 10474811;qualContr('00100104748110002553142').nrctremp := 2553142;qualContr('00100104748110002553142').idquapro := 3;
    qualContr('00100064518700002557472').cdcooper := 1;qualContr('00100064518700002557472').nrdconta := 6451870;qualContr('00100064518700002557472').nrctremp := 2557472;qualContr('00100064518700002557472').idquapro := 3;
    qualContr('00100030439670002558830').cdcooper := 1;qualContr('00100030439670002558830').nrdconta := 3043967;qualContr('00100030439670002558830').nrctremp := 2558830;qualContr('00100030439670002558830').idquapro := 3;
    qualContr('00100090048150002556638').cdcooper := 1;qualContr('00100090048150002556638').nrdconta := 9004815;qualContr('00100090048150002556638').nrctremp := 2556638;qualContr('00100090048150002556638').idquapro := 3;
    qualContr('00100099808570002560065').cdcooper := 1;qualContr('00100099808570002560065').nrdconta := 9980857;qualContr('00100099808570002560065').nrctremp := 2560065;qualContr('00100099808570002560065').idquapro := 3;
    qualContr('00100094916350002561062').cdcooper := 1;qualContr('00100094916350002561062').nrdconta := 9491635;qualContr('00100094916350002561062').nrctremp := 2561062;qualContr('00100094916350002561062').idquapro := 3;
    qualContr('00100090069150002561444').cdcooper := 1;qualContr('00100090069150002561444').nrdconta := 9006915;qualContr('00100090069150002561444').nrctremp := 2561444;qualContr('00100090069150002561444').idquapro := 3;
    qualContr('00100109244260002562097').cdcooper := 1;qualContr('00100109244260002562097').nrdconta := 10924426;qualContr('00100109244260002562097').nrctremp := 2562097;qualContr('00100109244260002562097').idquapro := 4;
    qualContr('00100099787390002560154').cdcooper := 1;qualContr('00100099787390002560154').nrdconta := 9978739;qualContr('00100099787390002560154').nrctremp := 2560154;qualContr('00100099787390002560154').idquapro := 3;
    qualContr('00100039469830002562176').cdcooper := 1;qualContr('00100039469830002562176').nrdconta := 3946983;qualContr('00100039469830002562176').nrctremp := 2562176;qualContr('00100039469830002562176').idquapro := 3;
    qualContr('00100106265650002560331').cdcooper := 1;qualContr('00100106265650002560331').nrdconta := 10626565;qualContr('00100106265650002560331').nrctremp := 2560331;qualContr('00100106265650002560331').idquapro := 3;
    qualContr('00100076687830002560447').cdcooper := 1;qualContr('00100076687830002560447').nrdconta := 7668783;qualContr('00100076687830002560447').nrctremp := 2560447;qualContr('00100076687830002560447').idquapro := 3;
    qualContr('00100093199800002562588').cdcooper := 1;qualContr('00100093199800002562588').nrdconta := 9319980;qualContr('00100093199800002562588').nrctremp := 2562588;qualContr('00100093199800002562588').idquapro := 3;
    qualContr('00100077541670002566357').cdcooper := 1;qualContr('00100077541670002566357').nrdconta := 7754167;qualContr('00100077541670002566357').nrctremp := 2566357;qualContr('00100077541670002566357').idquapro := 3;
    qualContr('00100073283380002566813').cdcooper := 1;qualContr('00100073283380002566813').nrdconta := 7328338;qualContr('00100073283380002566813').nrctremp := 2566813;qualContr('00100073283380002566813').idquapro := 3;
    qualContr('00100097691100002569283').cdcooper := 1;qualContr('00100097691100002569283').nrdconta := 9769110;qualContr('00100097691100002569283').nrctremp := 2569283;qualContr('00100097691100002569283').idquapro := 3;
    qualContr('00100096849720002567860').cdcooper := 1;qualContr('00100096849720002567860').nrdconta := 9684972;qualContr('00100096849720002567860').nrctremp := 2567860;qualContr('00100096849720002567860').idquapro := 3;
    qualContr('00100071499640002570895').cdcooper := 1;qualContr('00100071499640002570895').nrdconta := 7149964;qualContr('00100071499640002570895').nrctremp := 2570895;qualContr('00100071499640002570895').idquapro := 3;
    qualContr('00100018326200002571679').cdcooper := 1;qualContr('00100018326200002571679').nrdconta := 1832620;qualContr('00100018326200002571679').nrctremp := 2571679;qualContr('00100018326200002571679').idquapro := 3;
    qualContr('00100096816800002572556').cdcooper := 1;qualContr('00100096816800002572556').nrdconta := 9681680;qualContr('00100096816800002572556').nrctremp := 2572556;qualContr('00100096816800002572556').idquapro := 3;
    qualContr('00100095723920002572421').cdcooper := 1;qualContr('00100095723920002572421').nrdconta := 9572392;qualContr('00100095723920002572421').nrctremp := 2572421;qualContr('00100095723920002572421').idquapro := 3;
    qualContr('00100077504550002572256').cdcooper := 1;qualContr('00100077504550002572256').nrdconta := 7750455;qualContr('00100077504550002572256').nrctremp := 2572256;qualContr('00100077504550002572256').idquapro := 3;
    qualContr('00100030044810002573268').cdcooper := 1;qualContr('00100030044810002573268').nrdconta := 3004481;qualContr('00100030044810002573268').nrctremp := 2573268;qualContr('00100030044810002573268').idquapro := 3;
    qualContr('00100098986030002572984').cdcooper := 1;qualContr('00100098986030002572984').nrdconta := 9898603;qualContr('00100098986030002572984').nrctremp := 2572984;qualContr('00100098986030002572984').idquapro := 4;
    qualContr('00100071785650002572612').cdcooper := 1;qualContr('00100071785650002572612').nrdconta := 7178565;qualContr('00100071785650002572612').nrctremp := 2572612;qualContr('00100071785650002572612').idquapro := 3;
    qualContr('00100029155610002575236').cdcooper := 1;qualContr('00100029155610002575236').nrdconta := 2915561;qualContr('00100029155610002575236').nrctremp := 2575236;qualContr('00100029155610002575236').idquapro := 3;
    qualContr('00100093753170002574960').cdcooper := 1;qualContr('00100093753170002574960').nrdconta := 9375317;qualContr('00100093753170002574960').nrctremp := 2574960;qualContr('00100093753170002574960').idquapro := 4;
    qualContr('00100099314140002577013').cdcooper := 1;qualContr('00100099314140002577013').nrdconta := 9931414;qualContr('00100099314140002577013').nrctremp := 2577013;qualContr('00100099314140002577013').idquapro := 3;
    qualContr('00100106440400002577038').cdcooper := 1;qualContr('00100106440400002577038').nrdconta := 10644040;qualContr('00100106440400002577038').nrctremp := 2577038;qualContr('00100106440400002577038').idquapro := 3;
    qualContr('00100090681390002580216').cdcooper := 1;qualContr('00100090681390002580216').nrdconta := 9068139;qualContr('00100090681390002580216').nrctremp := 2580216;qualContr('00100090681390002580216').idquapro := 3;
    qualContr('00100102272290002579811').cdcooper := 1;qualContr('00100102272290002579811').nrdconta := 10227229;qualContr('00100102272290002579811').nrctremp := 2579811;qualContr('00100102272290002579811').idquapro := 3;
    qualContr('00100801799240002580985').cdcooper := 1;qualContr('00100801799240002580985').nrdconta := 80179924;qualContr('00100801799240002580985').nrctremp := 2580985;qualContr('00100801799240002580985').idquapro := 3;
    qualContr('00100096466980002579828').cdcooper := 1;qualContr('00100096466980002579828').nrdconta := 9646698;qualContr('00100096466980002579828').nrctremp := 2579828;qualContr('00100096466980002579828').idquapro := 3;
    qualContr('00100083920560002584391').cdcooper := 1;qualContr('00100083920560002584391').nrdconta := 8392056;qualContr('00100083920560002584391').nrctremp := 2584391;qualContr('00100083920560002584391').idquapro := 3;
    qualContr('00100079561000002584393').cdcooper := 1;qualContr('00100079561000002584393').nrdconta := 7956100;qualContr('00100079561000002584393').nrctremp := 2584393;qualContr('00100079561000002584393').idquapro := 3;
    qualContr('00100107273610002584399').cdcooper := 1;qualContr('00100107273610002584399').nrdconta := 10727361;qualContr('00100107273610002584399').nrctremp := 2584399;qualContr('00100107273610002584399').idquapro := 4;
    qualContr('00100074165980002582789').cdcooper := 1;qualContr('00100074165980002582789').nrdconta := 7416598;qualContr('00100074165980002582789').nrctremp := 2582789;qualContr('00100074165980002582789').idquapro := 3;
    qualContr('00100105493820002585754').cdcooper := 1;qualContr('00100105493820002585754').nrdconta := 10549382;qualContr('00100105493820002585754').nrctremp := 2585754;qualContr('00100105493820002585754').idquapro := 3;
    qualContr('00100102434700002585723').cdcooper := 1;qualContr('00100102434700002585723').nrdconta := 10243470;qualContr('00100102434700002585723').nrctremp := 2585723;qualContr('00100102434700002585723').idquapro := 3;
    qualContr('00100025823840002590224').cdcooper := 1;qualContr('00100025823840002590224').nrdconta := 2582384;qualContr('00100025823840002590224').nrctremp := 2590224;qualContr('00100025823840002590224').idquapro := 4;
    qualContr('00100104713910002589480').cdcooper := 1;qualContr('00100104713910002589480').nrdconta := 10471391;qualContr('00100104713910002589480').nrctremp := 2589480;qualContr('00100104713910002589480').idquapro := 3;
    qualContr('00100104189110002590087').cdcooper := 1;qualContr('00100104189110002590087').nrdconta := 10418911;qualContr('00100104189110002590087').nrctremp := 2590087;qualContr('00100104189110002590087').idquapro := 3;
    qualContr('00100109894710002590139').cdcooper := 1;qualContr('00100109894710002590139').nrdconta := 10989471;qualContr('00100109894710002590139').nrctremp := 2590139;qualContr('00100109894710002590139').idquapro := 3;
    qualContr('00100067798080002591855').cdcooper := 1;qualContr('00100067798080002591855').nrdconta := 6779808;qualContr('00100067798080002591855').nrctremp := 2591855;qualContr('00100067798080002591855').idquapro := 3;
    qualContr('00100086831230002590501').cdcooper := 1;qualContr('00100086831230002590501').nrdconta := 8683123;qualContr('00100086831230002590501').nrctremp := 2590501;qualContr('00100086831230002590501').idquapro := 3;
    qualContr('00100035619330002591557').cdcooper := 1;qualContr('00100035619330002591557').nrdconta := 3561933;qualContr('00100035619330002591557').nrctremp := 2591557;qualContr('00100035619330002591557').idquapro := 3;
    qualContr('00100062655020002590079').cdcooper := 1;qualContr('00100062655020002590079').nrdconta := 6265502;qualContr('00100062655020002590079').nrctremp := 2590079;qualContr('00100062655020002590079').idquapro := 3;
    qualContr('00100025842040002590228').cdcooper := 1;qualContr('00100025842040002590228').nrdconta := 2584204;qualContr('00100025842040002590228').nrctremp := 2590228;qualContr('00100025842040002590228').idquapro := 3;
    qualContr('00100093659900002594612').cdcooper := 1;qualContr('00100093659900002594612').nrdconta := 9365990;qualContr('00100093659900002594612').nrctremp := 2594612;qualContr('00100093659900002594612').idquapro := 3;
    qualContr('00100075133050002595088').cdcooper := 1;qualContr('00100075133050002595088').nrdconta := 7513305;qualContr('00100075133050002595088').nrctremp := 2595088;qualContr('00100075133050002595088').idquapro := 3;
    qualContr('00100103648970002594332').cdcooper := 1;qualContr('00100103648970002594332').nrdconta := 10364897;qualContr('00100103648970002594332').nrctremp := 2594332;qualContr('00100103648970002594332').idquapro := 3;
    qualContr('00100108299110002596700').cdcooper := 1;qualContr('00100108299110002596700').nrdconta := 10829911;qualContr('00100108299110002596700').nrctremp := 2596700;qualContr('00100108299110002596700').idquapro := 4;
    qualContr('00100060355900002594618').cdcooper := 1;qualContr('00100060355900002594618').nrdconta := 6035590;qualContr('00100060355900002594618').nrctremp := 2594618;qualContr('00100060355900002594618').idquapro := 3;
    qualContr('00100073326290002597955').cdcooper := 1;qualContr('00100073326290002597955').nrdconta := 7332629;qualContr('00100073326290002597955').nrctremp := 2597955;qualContr('00100073326290002597955').idquapro := 3;
    qualContr('00100064855960002598082').cdcooper := 1;qualContr('00100064855960002598082').nrdconta := 6485596;qualContr('00100064855960002598082').nrctremp := 2598082;qualContr('00100064855960002598082').idquapro := 3;
    qualContr('00100029163550002600085').cdcooper := 1;qualContr('00100029163550002600085').nrdconta := 2916355;qualContr('00100029163550002600085').nrctremp := 2600085;qualContr('00100029163550002600085').idquapro := 3;
    qualContr('00100025842040002599920').cdcooper := 1;qualContr('00100025842040002599920').nrdconta := 2584204;qualContr('00100025842040002599920').nrctremp := 2599920;qualContr('00100025842040002599920').idquapro := 3;
    qualContr('00100109847630002601884').cdcooper := 1;qualContr('00100109847630002601884').nrdconta := 10984763;qualContr('00100109847630002601884').nrctremp := 2601884;qualContr('00100109847630002601884').idquapro := 3;
    qualContr('00100015240620002602910').cdcooper := 1;qualContr('00100015240620002602910').nrdconta := 1524062;qualContr('00100015240620002602910').nrctremp := 2602910;qualContr('00100015240620002602910').idquapro := 3;
    qualContr('00100021638610002603764').cdcooper := 1;qualContr('00100021638610002603764').nrdconta := 2163861;qualContr('00100021638610002603764').nrctremp := 2603764;qualContr('00100021638610002603764').idquapro := 3;
    qualContr('00100023576740002602427').cdcooper := 1;qualContr('00100023576740002602427').nrdconta := 2357674;qualContr('00100023576740002602427').nrctremp := 2602427;qualContr('00100023576740002602427').idquapro := 3;
    qualContr('00100068714880002601743').cdcooper := 1;qualContr('00100068714880002601743').nrdconta := 6871488;qualContr('00100068714880002601743').nrctremp := 2601743;qualContr('00100068714880002601743').idquapro := 3;
    qualContr('00100110753680002604200').cdcooper := 1;qualContr('00100110753680002604200').nrdconta := 11075368;qualContr('00100110753680002604200').nrctremp := 2604200;qualContr('00100110753680002604200').idquapro := 3;
    qualContr('00100028695190002603374').cdcooper := 1;qualContr('00100028695190002603374').nrdconta := 2869519;qualContr('00100028695190002603374').nrctremp := 2603374;qualContr('00100028695190002603374').idquapro := 3;
    qualContr('00100099947690002603415').cdcooper := 1;qualContr('00100099947690002603415').nrdconta := 9994769;qualContr('00100099947690002603415').nrctremp := 2603415;qualContr('00100099947690002603415').idquapro := 3;
    qualContr('00100024849940002606055').cdcooper := 1;qualContr('00100024849940002606055').nrdconta := 2484994;qualContr('00100024849940002606055').nrctremp := 2606055;qualContr('00100024849940002606055').idquapro := 3;
    qualContr('00100030306280002607925').cdcooper := 1;qualContr('00100030306280002607925').nrdconta := 3030628;qualContr('00100030306280002607925').nrctremp := 2607925;qualContr('00100030306280002607925').idquapro := 3;
    qualContr('00100106568630002608552').cdcooper := 1;qualContr('00100106568630002608552').nrdconta := 10656863;qualContr('00100106568630002608552').nrctremp := 2608552;qualContr('00100106568630002608552').idquapro := 4;
    qualContr('00100107081970002606943').cdcooper := 1;qualContr('00100107081970002606943').nrdconta := 10708197;qualContr('00100107081970002606943').nrctremp := 2606943;qualContr('00100107081970002606943').idquapro := 3;
    qualContr('00100082092600002605532').cdcooper := 1;qualContr('00100082092600002605532').nrdconta := 8209260;qualContr('00100082092600002605532').nrctremp := 2605532;qualContr('00100082092600002605532').idquapro := 3;
    qualContr('00100092031090002606200').cdcooper := 1;qualContr('00100092031090002606200').nrdconta := 9203109;qualContr('00100092031090002606200').nrctremp := 2606200;qualContr('00100092031090002606200').idquapro := 3;
    qualContr('00100111090330002615499').cdcooper := 1;qualContr('00100111090330002615499').nrdconta := 11109033;qualContr('00100111090330002615499').nrctremp := 2615499;qualContr('00100111090330002615499').idquapro := 3;
    qualContr('00100023381220002612694').cdcooper := 1;qualContr('00100023381220002612694').nrdconta := 2338122;qualContr('00100023381220002612694').nrctremp := 2612694;qualContr('00100023381220002612694').idquapro := 3;
    qualContr('00100029761100002615476').cdcooper := 1;qualContr('00100029761100002615476').nrdconta := 2976110;qualContr('00100029761100002615476').nrctremp := 2615476;qualContr('00100029761100002615476').idquapro := 3;
    qualContr('00100039211820002613649').cdcooper := 1;qualContr('00100039211820002613649').nrdconta := 3921182;qualContr('00100039211820002613649').nrctremp := 2613649;qualContr('00100039211820002613649').idquapro := 3;
    qualContr('00100106568980002615883').cdcooper := 1;qualContr('00100106568980002615883').nrdconta := 10656898;qualContr('00100106568980002615883').nrctremp := 2615883;qualContr('00100106568980002615883').idquapro := 4;
    qualContr('00100073424460002618281').cdcooper := 1;qualContr('00100073424460002618281').nrdconta := 7342446;qualContr('00100073424460002618281').nrctremp := 2618281;qualContr('00100073424460002618281').idquapro := 3;
    qualContr('00100089794480002619605').cdcooper := 1;qualContr('00100089794480002619605').nrdconta := 8979448;qualContr('00100089794480002619605').nrctremp := 2619605;qualContr('00100089794480002619605').idquapro := 3;
    qualContr('00100021224130002619188').cdcooper := 1;qualContr('00100021224130002619188').nrdconta := 2122413;qualContr('00100021224130002619188').nrctremp := 2619188;qualContr('00100021224130002619188').idquapro := 4;
    qualContr('00100095959020002620417').cdcooper := 1;qualContr('00100095959020002620417').nrdconta := 9595902;qualContr('00100095959020002620417').nrctremp := 2620417;qualContr('00100095959020002620417').idquapro := 3;
    qualContr('00100803255990002623972').cdcooper := 1;qualContr('00100803255990002623972').nrdconta := 80325599;qualContr('00100803255990002623972').nrctremp := 2623972;qualContr('00100803255990002623972').idquapro := 4;
    qualContr('00100105267570002622729').cdcooper := 1;qualContr('00100105267570002622729').nrdconta := 10526757;qualContr('00100105267570002622729').nrctremp := 2622729;qualContr('00100105267570002622729').idquapro := 3;
    qualContr('00100108731630002623986').cdcooper := 1;qualContr('00100108731630002623986').nrdconta := 10873163;qualContr('00100108731630002623986').nrctremp := 2623986;qualContr('00100108731630002623986').idquapro := 3;
    qualContr('00100094595960002622870').cdcooper := 1;qualContr('00100094595960002622870').nrdconta := 9459596;qualContr('00100094595960002622870').nrctremp := 2622870;qualContr('00100094595960002622870').idquapro := 3;
    qualContr('00100102514640002623101').cdcooper := 1;qualContr('00100102514640002623101').nrdconta := 10251464;qualContr('00100102514640002623101').nrctremp := 2623101;qualContr('00100102514640002623101').idquapro := 3;
    qualContr('00100066027890002624237').cdcooper := 1;qualContr('00100066027890002624237').nrdconta := 6602789;qualContr('00100066027890002624237').nrctremp := 2624237;qualContr('00100066027890002624237').idquapro := 3;
    qualContr('00100074371450002624707').cdcooper := 1;qualContr('00100074371450002624707').nrdconta := 7437145;qualContr('00100074371450002624707').nrctremp := 2624707;qualContr('00100074371450002624707').idquapro := 3;
    qualContr('00100069558430002623189').cdcooper := 1;qualContr('00100069558430002623189').nrdconta := 6955843;qualContr('00100069558430002623189').nrctremp := 2623189;qualContr('00100069558430002623189').idquapro := 3;
    qualContr('00100102125740002629434').cdcooper := 1;qualContr('00100102125740002629434').nrdconta := 10212574;qualContr('00100102125740002629434').nrctremp := 2629434;qualContr('00100102125740002629434').idquapro := 3;
    qualContr('00100093672410002628557').cdcooper := 1;qualContr('00100093672410002628557').nrdconta := 9367241;qualContr('00100093672410002628557').nrctremp := 2628557;qualContr('00100093672410002628557').idquapro := 3;
    qualContr('00100099214270002633818').cdcooper := 1;qualContr('00100099214270002633818').nrdconta := 9921427;qualContr('00100099214270002633818').nrctremp := 2633818;qualContr('00100099214270002633818').idquapro := 3;
    qualContr('00100089082900002627696').cdcooper := 1;qualContr('00100089082900002627696').nrdconta := 8908290;qualContr('00100089082900002627696').nrctremp := 2627696;qualContr('00100089082900002627696').idquapro := 3;
    qualContr('00100096015540002638769').cdcooper := 1;qualContr('00100096015540002638769').nrdconta := 9601554;qualContr('00100096015540002638769').nrctremp := 2638769;qualContr('00100096015540002638769').idquapro := 3;
    qualContr('00100072002850002638156').cdcooper := 1;qualContr('00100072002850002638156').nrdconta := 7200285;qualContr('00100072002850002638156').nrctremp := 2638156;qualContr('00100072002850002638156').idquapro := 4;
    qualContr('00100111068080002638851').cdcooper := 1;qualContr('00100111068080002638851').nrdconta := 11106808;qualContr('00100111068080002638851').nrctremp := 2638851;qualContr('00100111068080002638851').idquapro := 3;
    qualContr('00100100749290002639576').cdcooper := 1;qualContr('00100100749290002639576').nrdconta := 10074929;qualContr('00100100749290002639576').nrctremp := 2639576;qualContr('00100100749290002639576').idquapro := 3;
    qualContr('00100067060880002641151').cdcooper := 1;qualContr('00100067060880002641151').nrdconta := 6706088;qualContr('00100067060880002641151').nrctremp := 2641151;qualContr('00100067060880002641151').idquapro := 3;
    qualContr('00100099214270002636556').cdcooper := 1;qualContr('00100099214270002636556').nrdconta := 9921427;qualContr('00100099214270002636556').nrctremp := 2636556;qualContr('00100099214270002636556').idquapro := 3;
    qualContr('00100000282230002628318').cdcooper := 1;qualContr('00100000282230002628318').nrdconta := 28223;qualContr('00100000282230002628318').nrctremp := 2628318;qualContr('00100000282230002628318').idquapro := 3;
    qualContr('00100079399060002640667').cdcooper := 1;qualContr('00100079399060002640667').nrdconta := 7939906;qualContr('00100079399060002640667').nrctremp := 2640667;qualContr('00100079399060002640667').idquapro := 3;
    qualContr('00100020246670002640869').cdcooper := 1;qualContr('00100020246670002640869').nrdconta := 2024667;qualContr('00100020246670002640869').nrctremp := 2640869;qualContr('00100020246670002640869').idquapro := 3;
    qualContr('00100108862570002642755').cdcooper := 1;qualContr('00100108862570002642755').nrdconta := 10886257;qualContr('00100108862570002642755').nrctremp := 2642755;qualContr('00100108862570002642755').idquapro := 3;
    qualContr('00100101849960002642641').cdcooper := 1;qualContr('00100101849960002642641').nrdconta := 10184996;qualContr('00100101849960002642641').nrctremp := 2642641;qualContr('00100101849960002642641').idquapro := 3;
    qualContr('00100104447420002630973').cdcooper := 1;qualContr('00100104447420002630973').nrdconta := 10444742;qualContr('00100104447420002630973').nrctremp := 2630973;qualContr('00100104447420002630973').idquapro := 3;
    qualContr('00100110608910002646653').cdcooper := 1;qualContr('00100110608910002646653').nrdconta := 11060891;qualContr('00100110608910002646653').nrctremp := 2646653;qualContr('00100110608910002646653').idquapro := 3;
    qualContr('00100089343470002638638').cdcooper := 1;qualContr('00100089343470002638638').nrdconta := 8934347;qualContr('00100089343470002638638').nrctremp := 2638638;qualContr('00100089343470002638638').idquapro := 3;
    qualContr('00100105716980002647900').cdcooper := 1;qualContr('00100105716980002647900').nrdconta := 10571698;qualContr('00100105716980002647900').nrctremp := 2647900;qualContr('00100105716980002647900').idquapro := 3;
    qualContr('00100040531090002648354').cdcooper := 1;qualContr('00100040531090002648354').nrdconta := 4053109;qualContr('00100040531090002648354').nrctremp := 2648354;qualContr('00100040531090002648354').idquapro := 3;
    qualContr('00100068596310002646056').cdcooper := 1;qualContr('00100068596310002646056').nrdconta := 6859631;qualContr('00100068596310002646056').nrctremp := 2646056;qualContr('00100068596310002646056').idquapro := 3;
    qualContr('00100076023830002645073').cdcooper := 1;qualContr('00100076023830002645073').nrdconta := 7602383;qualContr('00100076023830002645073').nrctremp := 2645073;qualContr('00100076023830002645073').idquapro := 3;
    qualContr('00100079333630002639516').cdcooper := 1;qualContr('00100079333630002639516').nrdconta := 7933363;qualContr('00100079333630002639516').nrctremp := 2639516;qualContr('00100079333630002639516').idquapro := 3;
    qualContr('00100031511580002648389').cdcooper := 1;qualContr('00100031511580002648389').nrdconta := 3151158;qualContr('00100031511580002648389').nrctremp := 2648389;qualContr('00100031511580002648389').idquapro := 3;
    qualContr('00100076609100002629850').cdcooper := 1;qualContr('00100076609100002629850').nrdconta := 7660910;qualContr('00100076609100002629850').nrctremp := 2629850;qualContr('00100076609100002629850').idquapro := 3;
    qualContr('00100090171510002629051').cdcooper := 1;qualContr('00100090171510002629051').nrdconta := 9017151;qualContr('00100090171510002629051').nrctremp := 2629051;qualContr('00100090171510002629051').idquapro := 3;
    qualContr('00100110610650002646957').cdcooper := 1;qualContr('00100110610650002646957').nrdconta := 11061065;qualContr('00100110610650002646957').nrctremp := 2646957;qualContr('00100110610650002646957').idquapro := 4;
    qualContr('00100108000850002646799').cdcooper := 1;qualContr('00100108000850002646799').nrdconta := 10800085;qualContr('00100108000850002646799').nrctremp := 2646799;qualContr('00100108000850002646799').idquapro := 3;
    qualContr('00100023471300002633785').cdcooper := 1;qualContr('00100023471300002633785').nrdconta := 2347130;qualContr('00100023471300002633785').nrctremp := 2633785;qualContr('00100023471300002633785').idquapro := 3;
    qualContr('00100004680610002651044').cdcooper := 1;qualContr('00100004680610002651044').nrdconta := 468061;qualContr('00100004680610002651044').nrctremp := 2651044;qualContr('00100004680610002651044').idquapro := 3;
    qualContr('00100108338200002651241').cdcooper := 1;qualContr('00100108338200002651241').nrdconta := 10833820;qualContr('00100108338200002651241').nrctremp := 2651241;qualContr('00100108338200002651241').idquapro := 4;
    qualContr('00100096050370002658094').cdcooper := 1;qualContr('00100096050370002658094').nrdconta := 9605037;qualContr('00100096050370002658094').nrctremp := 2658094;qualContr('00100096050370002658094').idquapro := 3;
    qualContr('00100102509720002657960').cdcooper := 1;qualContr('00100102509720002657960').nrdconta := 10250972;qualContr('00100102509720002657960').nrctremp := 2657960;qualContr('00100102509720002657960').idquapro := 3;
    qualContr('00100108284190002644775').cdcooper := 1;qualContr('00100108284190002644775').nrdconta := 10828419;qualContr('00100108284190002644775').nrctremp := 2644775;qualContr('00100108284190002644775').idquapro := 4;
    qualContr('00100022571810002655946').cdcooper := 1;qualContr('00100022571810002655946').nrdconta := 2257181;qualContr('00100022571810002655946').nrctremp := 2655946;qualContr('00100022571810002655946').idquapro := 3;
    qualContr('00100040084640002658462').cdcooper := 1;qualContr('00100040084640002658462').nrdconta := 4008464;qualContr('00100040084640002658462').nrctremp := 2658462;qualContr('00100040084640002658462').idquapro := 3;
    qualContr('00100071462640002642874').cdcooper := 1;qualContr('00100071462640002642874').nrdconta := 7146264;qualContr('00100071462640002642874').nrctremp := 2642874;qualContr('00100071462640002642874').idquapro := 3;
    qualContr('00100035772100002640313').cdcooper := 1;qualContr('00100035772100002640313').nrdconta := 3577210;qualContr('00100035772100002640313').nrctremp := 2640313;qualContr('00100035772100002640313').idquapro := 3;
    qualContr('00100111068080002647613').cdcooper := 1;qualContr('00100111068080002647613').nrdconta := 11106808;qualContr('00100111068080002647613').nrctremp := 2647613;qualContr('00100111068080002647613').idquapro := 3;
    qualContr('00100088386740002642792').cdcooper := 1;qualContr('00100088386740002642792').nrdconta := 8838674;qualContr('00100088386740002642792').nrctremp := 2642792;qualContr('00100088386740002642792').idquapro := 3;
    qualContr('00100089489500002649935').cdcooper := 1;qualContr('00100089489500002649935').nrdconta := 8948950;qualContr('00100089489500002649935').nrctremp := 2649935;qualContr('00100089489500002649935').idquapro := 3;
    qualContr('00100040084640002661969').cdcooper := 1;qualContr('00100040084640002661969').nrdconta := 4008464;qualContr('00100040084640002661969').nrctremp := 2661969;qualContr('00100040084640002661969').idquapro := 3;
    qualContr('00100068026210002640972').cdcooper := 1;qualContr('00100068026210002640972').nrdconta := 6802621;qualContr('00100068026210002640972').nrctremp := 2640972;qualContr('00100068026210002640972').idquapro := 3;
    qualContr('00100105435970002664828').cdcooper := 1;qualContr('00100105435970002664828').nrdconta := 10543597;qualContr('00100105435970002664828').nrctremp := 2664828;qualContr('00100105435970002664828').idquapro := 4;
    qualContr('00100099480400002665014').cdcooper := 1;qualContr('00100099480400002665014').nrdconta := 9948040;qualContr('00100099480400002665014').nrctremp := 2665014;qualContr('00100099480400002665014').idquapro := 3;
    qualContr('00100112063300002665596').cdcooper := 1;qualContr('00100112063300002665596').nrdconta := 11206330;qualContr('00100112063300002665596').nrctremp := 2665596;qualContr('00100112063300002665596').idquapro := 3;
    qualContr('00100103470200002663420').cdcooper := 1;qualContr('00100103470200002663420').nrdconta := 10347020;qualContr('00100103470200002663420').nrctremp := 2663420;qualContr('00100103470200002663420').idquapro := 3;
    qualContr('00100008767470002667959').cdcooper := 1;qualContr('00100008767470002667959').nrdconta := 876747;qualContr('00100008767470002667959').nrctremp := 2667959;qualContr('00100008767470002667959').idquapro := 3;
    qualContr('00100071310200002660477').cdcooper := 1;qualContr('00100071310200002660477').nrdconta := 7131020;qualContr('00100071310200002660477').nrctremp := 2660477;qualContr('00100071310200002660477').idquapro := 3;
    qualContr('00100066207600002667123').cdcooper := 1;qualContr('00100066207600002667123').nrdconta := 6620760;qualContr('00100066207600002667123').nrctremp := 2667123;qualContr('00100066207600002667123').idquapro := 3;
    qualContr('00100094791630002664399').cdcooper := 1;qualContr('00100094791630002664399').nrdconta := 9479163;qualContr('00100094791630002664399').nrctremp := 2664399;qualContr('00100094791630002664399').idquapro := 3;
    qualContr('00100107642750002666895').cdcooper := 1;qualContr('00100107642750002666895').nrdconta := 10764275;qualContr('00100107642750002666895').nrctremp := 2666895;qualContr('00100107642750002666895').idquapro := 4;
    qualContr('00100110185180002649455').cdcooper := 1;qualContr('00100110185180002649455').nrdconta := 11018518;qualContr('00100110185180002649455').nrctremp := 2649455;qualContr('00100110185180002649455').idquapro := 3;
    qualContr('00100070341990002666891').cdcooper := 1;qualContr('00100070341990002666891').nrdconta := 7034199;qualContr('00100070341990002666891').nrctremp := 2666891;qualContr('00100070341990002666891').idquapro := 3;
    qualContr('00100107495430002675528').cdcooper := 1;qualContr('00100107495430002675528').nrdconta := 10749543;qualContr('00100107495430002675528').nrctremp := 2675528;qualContr('00100107495430002675528').idquapro := 4;
    qualContr('00100072002850002638168').cdcooper := 1;qualContr('00100072002850002638168').nrdconta := 7200285;qualContr('00100072002850002638168').nrctremp := 2638168;qualContr('00100072002850002638168').idquapro := 4;
    qualContr('00100025182870002650952').cdcooper := 1;qualContr('00100025182870002650952').nrdconta := 2518287;qualContr('00100025182870002650952').nrctremp := 2650952;qualContr('00100025182870002650952').idquapro := 3;
    qualContr('00100103496180002668566').cdcooper := 1;qualContr('00100103496180002668566').nrdconta := 10349618;qualContr('00100103496180002668566').nrctremp := 2668566;qualContr('00100103496180002668566').idquapro := 4;
    qualContr('00100071410840002665590').cdcooper := 1;qualContr('00100071410840002665590').nrdconta := 7141084;qualContr('00100071410840002665590').nrctremp := 2665590;qualContr('00100071410840002665590').idquapro := 3;
    qualContr('00100083018670002656351').cdcooper := 1;qualContr('00100083018670002656351').nrdconta := 8301867;qualContr('00100083018670002656351').nrctremp := 2656351;qualContr('00100083018670002656351').idquapro := 3;
    qualContr('00100103668730002681811').cdcooper := 1;qualContr('00100103668730002681811').nrdconta := 10366873;qualContr('00100103668730002681811').nrctremp := 2681811;qualContr('00100103668730002681811').idquapro := 3;
    qualContr('00100108700320002657518').cdcooper := 1;qualContr('00100108700320002657518').nrdconta := 10870032;qualContr('00100108700320002657518').nrctremp := 2657518;qualContr('00100108700320002657518').idquapro := 4;
    qualContr('00100065513270002680796').cdcooper := 1;qualContr('00100065513270002680796').nrdconta := 6551327;qualContr('00100065513270002680796').nrctremp := 2680796;qualContr('00100065513270002680796').idquapro := 3;
    qualContr('00100025835770002675594').cdcooper := 1;qualContr('00100025835770002675594').nrdconta := 2583577;qualContr('00100025835770002675594').nrctremp := 2675594;qualContr('00100025835770002675594').idquapro := 4;
    qualContr('00200004792680000242493').cdcooper := 2;qualContr('00200004792680000242493').nrdconta := 479268;qualContr('00200004792680000242493').nrctremp := 242493;qualContr('00200004792680000242493').idquapro := 3;
    qualContr('00200006302410000245486').cdcooper := 2;qualContr('00200006302410000245486').nrdconta := 630241;qualContr('00200006302410000245486').nrctremp := 245486;qualContr('00200006302410000245486').idquapro := 4;
    qualContr('00200003315030000246504').cdcooper := 2;qualContr('00200003315030000246504').nrdconta := 331503;qualContr('00200003315030000246504').nrctremp := 246504;qualContr('00200003315030000246504').idquapro := 3;
    qualContr('00200006091100000246807').cdcooper := 2;qualContr('00200006091100000246807').nrdconta := 609110;qualContr('00200006091100000246807').nrctremp := 246807;qualContr('00200006091100000246807').idquapro := 3;
    qualContr('00200006391170000247730').cdcooper := 2;qualContr('00200006391170000247730').nrdconta := 639117;qualContr('00200006391170000247730').nrctremp := 247730;qualContr('00200006391170000247730').idquapro := 3;
    qualContr('00200006253880000248713').cdcooper := 2;qualContr('00200006253880000248713').nrdconta := 625388;qualContr('00200006253880000248713').nrctremp := 248713;qualContr('00200006253880000248713').idquapro := 3;
    qualContr('00200006435130000250028').cdcooper := 2;qualContr('00200006435130000250028').nrdconta := 643513;qualContr('00200006435130000250028').nrctremp := 250028;qualContr('00200006435130000250028').idquapro := 3;
    qualContr('00200006309180000250112').cdcooper := 2;qualContr('00200006309180000250112').nrdconta := 630918;qualContr('00200006309180000250112').nrctremp := 250112;qualContr('00200006309180000250112').idquapro := 3;
    qualContr('00200006669390000250428').cdcooper := 2;qualContr('00200006669390000250428').nrdconta := 666939;qualContr('00200006669390000250428').nrctremp := 250428;qualContr('00200006669390000250428').idquapro := 4;
    qualContr('00200005993440000250741').cdcooper := 2;qualContr('00200005993440000250741').nrdconta := 599344;qualContr('00200005993440000250741').nrctremp := 250741;qualContr('00200005993440000250741').idquapro := 4;
    qualContr('00200006105180000251150').cdcooper := 2;qualContr('00200006105180000251150').nrdconta := 610518;qualContr('00200006105180000251150').nrctremp := 251150;qualContr('00200006105180000251150').idquapro := 3;
    qualContr('00200006420100000251959').cdcooper := 2;qualContr('00200006420100000251959').nrdconta := 642010;qualContr('00200006420100000251959').nrctremp := 251959;qualContr('00200006420100000251959').idquapro := 3;
    qualContr('00200005866920000252135').cdcooper := 2;qualContr('00200005866920000252135').nrdconta := 586692;qualContr('00200005866920000252135').nrctremp := 252135;qualContr('00200005866920000252135').idquapro := 3;
    qualContr('00200006840740000252177').cdcooper := 2;qualContr('00200006840740000252177').nrdconta := 684074;qualContr('00200006840740000252177').nrctremp := 252177;qualContr('00200006840740000252177').idquapro := 3;
    qualContr('00200006102240000252179').cdcooper := 2;qualContr('00200006102240000252179').nrdconta := 610224;qualContr('00200006102240000252179').nrctremp := 252179;qualContr('00200006102240000252179').idquapro := 3;
    qualContr('00200006049680000252327').cdcooper := 2;qualContr('00200006049680000252327').nrdconta := 604968;qualContr('00200006049680000252327').nrctremp := 252327;qualContr('00200006049680000252327').idquapro := 4;
    qualContr('00200006897260000252391').cdcooper := 2;qualContr('00200006897260000252391').nrdconta := 689726;qualContr('00200006897260000252391').nrctremp := 252391;qualContr('00200006897260000252391').idquapro := 4;
    qualContr('00200002181540000252366').cdcooper := 2;qualContr('00200002181540000252366').nrdconta := 218154;qualContr('00200002181540000252366').nrctremp := 252366;qualContr('00200002181540000252366').idquapro := 3;
    qualContr('00200004045430000252932').cdcooper := 2;qualContr('00200004045430000252932').nrdconta := 404543;qualContr('00200004045430000252932').nrctremp := 252932;qualContr('00200004045430000252932').idquapro := 3;
    qualContr('00200004483620000253047').cdcooper := 2;qualContr('00200004483620000253047').nrdconta := 448362;qualContr('00200004483620000253047').nrctremp := 253047;qualContr('00200004483620000253047').idquapro := 3;
    qualContr('00200005949970000253263').cdcooper := 2;qualContr('00200005949970000253263').nrdconta := 594997;qualContr('00200005949970000253263').nrctremp := 253263;qualContr('00200005949970000253263').idquapro := 3;
    qualContr('00200005715200000253320').cdcooper := 2;qualContr('00200005715200000253320').nrdconta := 571520;qualContr('00200005715200000253320').nrctremp := 253320;qualContr('00200005715200000253320').idquapro := 3;
    qualContr('00200006522960000253902').cdcooper := 2;qualContr('00200006522960000253902').nrdconta := 652296;qualContr('00200006522960000253902').nrctremp := 253902;qualContr('00200006522960000253902').idquapro := 3;
    qualContr('00200005297530000254067').cdcooper := 2;qualContr('00200005297530000254067').nrdconta := 529753;qualContr('00200005297530000254067').nrctremp := 254067;qualContr('00200005297530000254067').idquapro := 3;
    qualContr('00200005774210000254158').cdcooper := 2;qualContr('00200005774210000254158').nrdconta := 577421;qualContr('00200005774210000254158').nrctremp := 254158;qualContr('00200005774210000254158').idquapro := 4;
    qualContr('00200006227100000254315').cdcooper := 2;qualContr('00200006227100000254315').nrdconta := 622710;qualContr('00200006227100000254315').nrctremp := 254315;qualContr('00200006227100000254315').idquapro := 4;
    qualContr('00200006917200000254579').cdcooper := 2;qualContr('00200006917200000254579').nrdconta := 691720;qualContr('00200006917200000254579').nrctremp := 254579;qualContr('00200006917200000254579').idquapro := 4;
    qualContr('00200007426430000254737').cdcooper := 2;qualContr('00200007426430000254737').nrdconta := 742643;qualContr('00200007426430000254737').nrctremp := 254737;qualContr('00200007426430000254737').idquapro := 3;
    qualContr('00200005655470000255088').cdcooper := 2;qualContr('00200005655470000255088').nrdconta := 565547;qualContr('00200005655470000255088').nrctremp := 255088;qualContr('00200005655470000255088').idquapro := 3;
    qualContr('00200004191090000255341').cdcooper := 2;qualContr('00200004191090000255341').nrdconta := 419109;qualContr('00200004191090000255341').nrctremp := 255341;qualContr('00200004191090000255341').idquapro := 4;
    qualContr('00200006944360000255433').cdcooper := 2;qualContr('00200006944360000255433').nrdconta := 694436;qualContr('00200006944360000255433').nrctremp := 255433;qualContr('00200006944360000255433').idquapro := 3;
    qualContr('00200006369750000255601').cdcooper := 2;qualContr('00200006369750000255601').nrdconta := 636975;qualContr('00200006369750000255601').nrctremp := 255601;qualContr('00200006369750000255601').idquapro := 4;
    qualContr('00200006494140000255643').cdcooper := 2;qualContr('00200006494140000255643').nrdconta := 649414;qualContr('00200006494140000255643').nrctremp := 255643;qualContr('00200006494140000255643').idquapro := 3;
    qualContr('00200006704480000255761').cdcooper := 2;qualContr('00200006704480000255761').nrdconta := 670448;qualContr('00200006704480000255761').nrctremp := 255761;qualContr('00200006704480000255761').idquapro := 3;
    qualContr('00200007306290000255983').cdcooper := 2;qualContr('00200007306290000255983').nrdconta := 730629;qualContr('00200007306290000255983').nrctremp := 255983;qualContr('00200007306290000255983').idquapro := 3;
    qualContr('00200001489030000256099').cdcooper := 2;qualContr('00200001489030000256099').nrdconta := 148903;qualContr('00200001489030000256099').nrctremp := 256099;qualContr('00200001489030000256099').idquapro := 4;
    qualContr('00200006453030000256364').cdcooper := 2;qualContr('00200006453030000256364').nrdconta := 645303;qualContr('00200006453030000256364').nrctremp := 256364;qualContr('00200006453030000256364').idquapro := 3;
    qualContr('00200006084320000257219').cdcooper := 2;qualContr('00200006084320000257219').nrdconta := 608432;qualContr('00200006084320000257219').nrctremp := 257219;qualContr('00200006084320000257219').idquapro := 3;
    qualContr('00200003984620000257329').cdcooper := 2;qualContr('00200003984620000257329').nrdconta := 398462;qualContr('00200003984620000257329').nrctremp := 257329;qualContr('00200003984620000257329').idquapro := 3;
    qualContr('00200007121590000257294').cdcooper := 2;qualContr('00200007121590000257294').nrdconta := 712159;qualContr('00200007121590000257294').nrctremp := 257294;qualContr('00200007121590000257294').idquapro := 4;
    qualContr('00200006553680000257360').cdcooper := 2;qualContr('00200006553680000257360').nrdconta := 655368;qualContr('00200006553680000257360').nrctremp := 257360;qualContr('00200006553680000257360').idquapro := 3;
    qualContr('00200007220570000257565').cdcooper := 2;qualContr('00200007220570000257565').nrdconta := 722057;qualContr('00200007220570000257565').nrctremp := 257565;qualContr('00200007220570000257565').idquapro := 3;
    qualContr('00200006106740000257841').cdcooper := 2;qualContr('00200006106740000257841').nrdconta := 610674;qualContr('00200006106740000257841').nrctremp := 257841;qualContr('00200006106740000257841').idquapro := 3;
    qualContr('00200006785620000257893').cdcooper := 2;qualContr('00200006785620000257893').nrdconta := 678562;qualContr('00200006785620000257893').nrctremp := 257893;qualContr('00200006785620000257893').idquapro := 4;
    qualContr('00200005930280000257872').cdcooper := 2;qualContr('00200005930280000257872').nrdconta := 593028;qualContr('00200005930280000257872').nrctremp := 257872;qualContr('00200005930280000257872').idquapro := 3;
    qualContr('00200006202700000257958').cdcooper := 2;qualContr('00200006202700000257958').nrdconta := 620270;qualContr('00200006202700000257958').nrctremp := 257958;qualContr('00200006202700000257958').idquapro := 4;
    qualContr('00200006563300000258012').cdcooper := 2;qualContr('00200006563300000258012').nrdconta := 656330;qualContr('00200006563300000258012').nrctremp := 258012;qualContr('00200006563300000258012').idquapro := 3;
    qualContr('00200006382340000258120').cdcooper := 2;qualContr('00200006382340000258120').nrdconta := 638234;qualContr('00200006382340000258120').nrctremp := 258120;qualContr('00200006382340000258120').idquapro := 4;
    qualContr('00200001263490000258172').cdcooper := 2;qualContr('00200001263490000258172').nrdconta := 126349;qualContr('00200001263490000258172').nrctremp := 258172;qualContr('00200001263490000258172').idquapro := 4;
    qualContr('00200005631450000258143').cdcooper := 2;qualContr('00200005631450000258143').nrdconta := 563145;qualContr('00200005631450000258143').nrctremp := 258143;qualContr('00200005631450000258143').idquapro := 4;
    qualContr('00200002052730000258217').cdcooper := 2;qualContr('00200002052730000258217').nrdconta := 205273;qualContr('00200002052730000258217').nrctremp := 258217;qualContr('00200002052730000258217').idquapro := 3;
    qualContr('00200005665350000258238').cdcooper := 2;qualContr('00200005665350000258238').nrdconta := 566535;qualContr('00200005665350000258238').nrctremp := 258238;qualContr('00200005665350000258238').idquapro := 3;
    qualContr('00200005891360000258375').cdcooper := 2;qualContr('00200005891360000258375').nrdconta := 589136;qualContr('00200005891360000258375').nrctremp := 258375;qualContr('00200005891360000258375').idquapro := 3;
    qualContr('00200004921080000258350').cdcooper := 2;qualContr('00200004921080000258350').nrdconta := 492108;qualContr('00200004921080000258350').nrctremp := 258350;qualContr('00200004921080000258350').idquapro := 3;
    qualContr('00200006591690000258440').cdcooper := 2;qualContr('00200006591690000258440').nrdconta := 659169;qualContr('00200006591690000258440').nrctremp := 258440;qualContr('00200006591690000258440').idquapro := 3;
    qualContr('00200001541990000258893').cdcooper := 2;qualContr('00200001541990000258893').nrdconta := 154199;qualContr('00200001541990000258893').nrctremp := 258893;qualContr('00200001541990000258893').idquapro := 3;
    qualContr('00200004870230000258937').cdcooper := 2;qualContr('00200004870230000258937').nrdconta := 487023;qualContr('00200004870230000258937').nrctremp := 258937;qualContr('00200004870230000258937').idquapro := 4;
    qualContr('00200005098170000259058').cdcooper := 2;qualContr('00200005098170000259058').nrdconta := 509817;qualContr('00200005098170000259058').nrctremp := 259058;qualContr('00200005098170000259058').idquapro := 3;
    qualContr('00200005841770000259057').cdcooper := 2;qualContr('00200005841770000259057').nrdconta := 584177;qualContr('00200005841770000259057').nrctremp := 259057;qualContr('00200005841770000259057').idquapro := 3;
    qualContr('00200005063460000259311').cdcooper := 2;qualContr('00200005063460000259311').nrdconta := 506346;qualContr('00200005063460000259311').nrctremp := 259311;qualContr('00200005063460000259311').idquapro := 3;
    qualContr('00200007104150000259296').cdcooper := 2;qualContr('00200007104150000259296').nrdconta := 710415;qualContr('00200007104150000259296').nrctremp := 259296;qualContr('00200007104150000259296').idquapro := 3;
    qualContr('00200006312050000259318').cdcooper := 2;qualContr('00200006312050000259318').nrdconta := 631205;qualContr('00200006312050000259318').nrctremp := 259318;qualContr('00200006312050000259318').idquapro := 3;
    qualContr('00200006504980000259962').cdcooper := 2;qualContr('00200006504980000259962').nrdconta := 650498;qualContr('00200006504980000259962').nrctremp := 259962;qualContr('00200006504980000259962').idquapro := 3;
    qualContr('00200007716430000260119').cdcooper := 2;qualContr('00200007716430000260119').nrdconta := 771643;qualContr('00200007716430000260119').nrctremp := 260119;qualContr('00200007716430000260119').idquapro := 3;
    qualContr('00200006596140000260193').cdcooper := 2;qualContr('00200006596140000260193').nrdconta := 659614;qualContr('00200006596140000260193').nrctremp := 260193;qualContr('00200006596140000260193').idquapro := 3;
    qualContr('00200004730900000260295').cdcooper := 2;qualContr('00200004730900000260295').nrdconta := 473090;qualContr('00200004730900000260295').nrctremp := 260295;qualContr('00200004730900000260295').idquapro := 3;
    qualContr('00200007489190000260426').cdcooper := 2;qualContr('00200007489190000260426').nrdconta := 748919;qualContr('00200007489190000260426').nrctremp := 260426;qualContr('00200007489190000260426').idquapro := 4;
    qualContr('00200006713120000260451').cdcooper := 2;qualContr('00200006713120000260451').nrdconta := 671312;qualContr('00200006713120000260451').nrctremp := 260451;qualContr('00200006713120000260451').idquapro := 3;
    qualContr('00200006941690000260660').cdcooper := 2;qualContr('00200006941690000260660').nrdconta := 694169;qualContr('00200006941690000260660').nrctremp := 260660;qualContr('00200006941690000260660').idquapro := 3;
    qualContr('00200006739510000260778').cdcooper := 2;qualContr('00200006739510000260778').nrdconta := 673951;qualContr('00200006739510000260778').nrctremp := 260778;qualContr('00200006739510000260778').idquapro := 3;
    qualContr('00200007574200000260982').cdcooper := 2;qualContr('00200007574200000260982').nrdconta := 757420;qualContr('00200007574200000260982').nrctremp := 260982;qualContr('00200007574200000260982').idquapro := 3;
    qualContr('00200006525120000261089').cdcooper := 2;qualContr('00200006525120000261089').nrdconta := 652512;qualContr('00200006525120000261089').nrctremp := 261089;qualContr('00200006525120000261089').idquapro := 3;
    qualContr('00200004289570000261379').cdcooper := 2;qualContr('00200004289570000261379').nrdconta := 428957;qualContr('00200004289570000261379').nrctremp := 261379;qualContr('00200004289570000261379').idquapro := 3;
    qualContr('00200001269770000261471').cdcooper := 2;qualContr('00200001269770000261471').nrdconta := 126977;qualContr('00200001269770000261471').nrctremp := 261471;qualContr('00200001269770000261471').idquapro := 3;
    qualContr('00200006640300000261708').cdcooper := 2;qualContr('00200006640300000261708').nrdconta := 664030;qualContr('00200006640300000261708').nrctremp := 261708;qualContr('00200006640300000261708').idquapro := 3;
    qualContr('00200003897490000261942').cdcooper := 2;qualContr('00200003897490000261942').nrdconta := 389749;qualContr('00200003897490000261942').nrctremp := 261942;qualContr('00200003897490000261942').idquapro := 3;
    qualContr('00200006089550000262052').cdcooper := 2;qualContr('00200006089550000262052').nrdconta := 608955;qualContr('00200006089550000262052').nrctremp := 262052;qualContr('00200006089550000262052').idquapro := 3;
    qualContr('00200006328560000262059').cdcooper := 2;qualContr('00200006328560000262059').nrdconta := 632856;qualContr('00200006328560000262059').nrctremp := 262059;qualContr('00200006328560000262059').idquapro := 3;
    qualContr('00200006958400000262182').cdcooper := 2;qualContr('00200006958400000262182').nrdconta := 695840;qualContr('00200006958400000262182').nrctremp := 262182;qualContr('00200006958400000262182').idquapro := 3;
    qualContr('00200007828230000262256').cdcooper := 2;qualContr('00200007828230000262256').nrdconta := 782823;qualContr('00200007828230000262256').nrctremp := 262256;qualContr('00200007828230000262256').idquapro := 3;
    qualContr('00200006912670000262503').cdcooper := 2;qualContr('00200006912670000262503').nrdconta := 691267;qualContr('00200006912670000262503').nrctremp := 262503;qualContr('00200006912670000262503').idquapro := 4;
    qualContr('00200006354990000262591').cdcooper := 2;qualContr('00200006354990000262591').nrdconta := 635499;qualContr('00200006354990000262591').nrctremp := 262591;qualContr('00200006354990000262591').idquapro := 3;
    qualContr('00200006371140000262478').cdcooper := 2;qualContr('00200006371140000262478').nrdconta := 637114;qualContr('00200006371140000262478').nrctremp := 262478;qualContr('00200006371140000262478').idquapro := 3;
    qualContr('00200006355290000262433').cdcooper := 2;qualContr('00200006355290000262433').nrdconta := 635529;qualContr('00200006355290000262433').nrctremp := 262433;qualContr('00200006355290000262433').idquapro := 3;
    qualContr('00200006246240000263042').cdcooper := 2;qualContr('00200006246240000263042').nrdconta := 624624;qualContr('00200006246240000263042').nrctremp := 263042;qualContr('00200006246240000263042').idquapro := 3;
    qualContr('00200007056080000263027').cdcooper := 2;qualContr('00200007056080000263027').nrdconta := 705608;qualContr('00200007056080000263027').nrctremp := 263027;qualContr('00200007056080000263027').idquapro := 3;
    qualContr('00200005631610000263056').cdcooper := 2;qualContr('00200005631610000263056').nrdconta := 563161;qualContr('00200005631610000263056').nrctremp := 263056;qualContr('00200005631610000263056').idquapro := 3;
    qualContr('00200006793300000263239').cdcooper := 2;qualContr('00200006793300000263239').nrdconta := 679330;qualContr('00200006793300000263239').nrctremp := 263239;qualContr('00200006793300000263239').idquapro := 4;
    qualContr('00200006472840000263232').cdcooper := 2;qualContr('00200006472840000263232').nrdconta := 647284;qualContr('00200006472840000263232').nrctremp := 263232;qualContr('00200006472840000263232').idquapro := 3;
    qualContr('00200006927600000263400').cdcooper := 2;qualContr('00200006927600000263400').nrdconta := 692760;qualContr('00200006927600000263400').nrctremp := 263400;qualContr('00200006927600000263400').idquapro := 4;
    qualContr('00200005092990000263337').cdcooper := 2;qualContr('00200005092990000263337').nrdconta := 509299;qualContr('00200005092990000263337').nrctremp := 263337;qualContr('00200005092990000263337').idquapro := 3;
    qualContr('00200007457310000263432').cdcooper := 2;qualContr('00200007457310000263432').nrdconta := 745731;qualContr('00200007457310000263432').nrctremp := 263432;qualContr('00200007457310000263432').idquapro := 3;
    qualContr('00200007707440000263442').cdcooper := 2;qualContr('00200007707440000263442').nrdconta := 770744;qualContr('00200007707440000263442').nrctremp := 263442;qualContr('00200007707440000263442').idquapro := 3;
    qualContr('00200005852200000263437').cdcooper := 2;qualContr('00200005852200000263437').nrdconta := 585220;qualContr('00200005852200000263437').nrctremp := 263437;qualContr('00200005852200000263437').idquapro := 4;
    qualContr('00200007299490000263650').cdcooper := 2;qualContr('00200007299490000263650').nrdconta := 729949;qualContr('00200007299490000263650').nrctremp := 263650;qualContr('00200007299490000263650').idquapro := 3;
    qualContr('00200007501660000263667').cdcooper := 2;qualContr('00200007501660000263667').nrdconta := 750166;qualContr('00200007501660000263667').nrctremp := 263667;qualContr('00200007501660000263667').idquapro := 3;
    qualContr('00200007219480000263985').cdcooper := 2;qualContr('00200007219480000263985').nrdconta := 721948;qualContr('00200007219480000263985').nrctremp := 263985;qualContr('00200007219480000263985').idquapro := 4;
    qualContr('00200002914120000264042').cdcooper := 2;qualContr('00200002914120000264042').nrdconta := 291412;qualContr('00200002914120000264042').nrctremp := 264042;qualContr('00200002914120000264042').idquapro := 3;
    qualContr('00200006839140000264152').cdcooper := 2;qualContr('00200006839140000264152').nrdconta := 683914;qualContr('00200006839140000264152').nrctremp := 264152;qualContr('00200006839140000264152').idquapro := 3;
    qualContr('00200006438740000264211').cdcooper := 2;qualContr('00200006438740000264211').nrdconta := 643874;qualContr('00200006438740000264211').nrctremp := 264211;qualContr('00200006438740000264211').idquapro := 3;
    qualContr('00200005874190000264241').cdcooper := 2;qualContr('00200005874190000264241').nrdconta := 587419;qualContr('00200005874190000264241').nrctremp := 264241;qualContr('00200005874190000264241').idquapro := 3;
    qualContr('00200008006270000264231').cdcooper := 2;qualContr('00200008006270000264231').nrdconta := 800627;qualContr('00200008006270000264231').nrctremp := 264231;qualContr('00200008006270000264231').idquapro := 3;
    qualContr('00200007210690000264317').cdcooper := 2;qualContr('00200007210690000264317').nrdconta := 721069;qualContr('00200007210690000264317').nrctremp := 264317;qualContr('00200007210690000264317').idquapro := 3;
    qualContr('00200007203800000264342').cdcooper := 2;qualContr('00200007203800000264342').nrdconta := 720380;qualContr('00200007203800000264342').nrctremp := 264342;qualContr('00200007203800000264342').idquapro := 3;
    qualContr('00200006990200000264638').cdcooper := 2;qualContr('00200006990200000264638').nrdconta := 699020;qualContr('00200006990200000264638').nrctremp := 264638;qualContr('00200006990200000264638').idquapro := 3;
    qualContr('00200005295240000264687').cdcooper := 2;qualContr('00200005295240000264687').nrdconta := 529524;qualContr('00200005295240000264687').nrctremp := 264687;qualContr('00200005295240000264687').idquapro := 4;
    qualContr('00200003508850000264655').cdcooper := 2;qualContr('00200003508850000264655').nrdconta := 350885;qualContr('00200003508850000264655').nrctremp := 264655;qualContr('00200003508850000264655').idquapro := 3;
    qualContr('00200005191970000264729').cdcooper := 2;qualContr('00200005191970000264729').nrdconta := 519197;qualContr('00200005191970000264729').nrctremp := 264729;qualContr('00200005191970000264729').idquapro := 3;
    qualContr('00200006815120000265119').cdcooper := 2;qualContr('00200006815120000265119').nrdconta := 681512;qualContr('00200006815120000265119').nrctremp := 265119;qualContr('00200006815120000265119').idquapro := 4;
    qualContr('00200005104240000265922').cdcooper := 2;qualContr('00200005104240000265922').nrdconta := 510424;qualContr('00200005104240000265922').nrctremp := 265922;qualContr('00200005104240000265922').idquapro := 3;
    qualContr('00200007054460000266612').cdcooper := 2;qualContr('00200007054460000266612').nrdconta := 705446;qualContr('00200007054460000266612').nrctremp := 266612;qualContr('00200007054460000266612').idquapro := 3;
    qualContr('00200006371570000267532').cdcooper := 2;qualContr('00200006371570000267532').nrdconta := 637157;qualContr('00200006371570000267532').nrctremp := 267532;qualContr('00200006371570000267532').idquapro := 3;
    qualContr('00500001423280000011984').cdcooper := 5;qualContr('00500001423280000011984').nrdconta := 142328;qualContr('00500001423280000011984').nrctremp := 11984;qualContr('00500001423280000011984').idquapro := 3;
    qualContr('00500001453430000012860').cdcooper := 5;qualContr('00500001453430000012860').nrdconta := 145343;qualContr('00500001453430000012860').nrctremp := 12860;qualContr('00500001453430000012860').idquapro := 4;
    qualContr('00500001360850000013612').cdcooper := 5;qualContr('00500001360850000013612').nrdconta := 136085;qualContr('00500001360850000013612').nrctremp := 13612;qualContr('00500001360850000013612').idquapro := 3;
    qualContr('00500001535400000014023').cdcooper := 5;qualContr('00500001535400000014023').nrdconta := 153540;qualContr('00500001535400000014023').nrctremp := 14023;qualContr('00500001535400000014023').idquapro := 4;
    qualContr('00500001761920000014133').cdcooper := 5;qualContr('00500001761920000014133').nrdconta := 176192;qualContr('00500001761920000014133').nrctremp := 14133;qualContr('00500001761920000014133').idquapro := 3;
    qualContr('00500001157460000014158').cdcooper := 5;qualContr('00500001157460000014158').nrdconta := 115746;qualContr('00500001157460000014158').nrctremp := 14158;qualContr('00500001157460000014158').idquapro := 3;
    qualContr('00500001535240000014546').cdcooper := 5;qualContr('00500001535240000014546').nrdconta := 153524;qualContr('00500001535240000014546').nrctremp := 14546;qualContr('00500001535240000014546').idquapro := 4;
    qualContr('00500000672100000015196').cdcooper := 5;qualContr('00500000672100000015196').nrdconta := 67210;qualContr('00500000672100000015196').nrctremp := 15196;qualContr('00500000672100000015196').idquapro := 3;
    qualContr('00500001152230000015586').cdcooper := 5;qualContr('00500001152230000015586').nrdconta := 115223;qualContr('00500001152230000015586').nrctremp := 15586;qualContr('00500001152230000015586').idquapro := 3;
    qualContr('00500001035940000015687').cdcooper := 5;qualContr('00500001035940000015687').nrdconta := 103594;qualContr('00500001035940000015687').nrctremp := 15687;qualContr('00500001035940000015687').idquapro := 3;
    qualContr('00500001633250000017365').cdcooper := 5;qualContr('00500001633250000017365').nrdconta := 163325;qualContr('00500001633250000017365').nrctremp := 17365;qualContr('00500001633250000017365').idquapro := 3;
    qualContr('00500000252750000017496').cdcooper := 5;qualContr('00500000252750000017496').nrdconta := 25275;qualContr('00500000252750000017496').nrctremp := 17496;qualContr('00500000252750000017496').idquapro := 3;
    qualContr('00500001800920000018050').cdcooper := 5;qualContr('00500001800920000018050').nrdconta := 180092;qualContr('00500001800920000018050').nrctremp := 18050;qualContr('00500001800920000018050').idquapro := 3;
    qualContr('00500001238540000018107').cdcooper := 5;qualContr('00500001238540000018107').nrdconta := 123854;qualContr('00500001238540000018107').nrctremp := 18107;qualContr('00500001238540000018107').idquapro := 4;
    qualContr('00500001816500000018264').cdcooper := 5;qualContr('00500001816500000018264').nrdconta := 181650;qualContr('00500001816500000018264').nrctremp := 18264;qualContr('00500001816500000018264').idquapro := 3;
    qualContr('00500001173580000018609').cdcooper := 5;qualContr('00500001173580000018609').nrdconta := 117358;qualContr('00500001173580000018609').nrctremp := 18609;qualContr('00500001173580000018609').idquapro := 3;
    qualContr('00500001656380000018885').cdcooper := 5;qualContr('00500001656380000018885').nrdconta := 165638;qualContr('00500001656380000018885').nrctremp := 18885;qualContr('00500001656380000018885').idquapro := 3;
    qualContr('00500001679670000019003').cdcooper := 5;qualContr('00500001679670000019003').nrdconta := 167967;qualContr('00500001679670000019003').nrctremp := 19003;qualContr('00500001679670000019003').idquapro := 3;
    qualContr('00500001631630000019083').cdcooper := 5;qualContr('00500001631630000019083').nrdconta := 163163;qualContr('00500001631630000019083').nrctremp := 19083;qualContr('00500001631630000019083').idquapro := 3;
    qualContr('00500001550550000019137').cdcooper := 5;qualContr('00500001550550000019137').nrdconta := 155055;qualContr('00500001550550000019137').nrctremp := 19137;qualContr('00500001550550000019137').idquapro := 3;
    qualContr('00500001548300000019193').cdcooper := 5;qualContr('00500001548300000019193').nrdconta := 154830;qualContr('00500001548300000019193').nrctremp := 19193;qualContr('00500001548300000019193').idquapro := 3;
    qualContr('00500001688150000019557').cdcooper := 5;qualContr('00500001688150000019557').nrdconta := 168815;qualContr('00500001688150000019557').nrctremp := 19557;qualContr('00500001688150000019557').idquapro := 3;
    qualContr('00500001627600000019610').cdcooper := 5;qualContr('00500001627600000019610').nrdconta := 162760;qualContr('00500001627600000019610').nrctremp := 19610;qualContr('00500001627600000019610').idquapro := 3;
    qualContr('00500002188120000019919').cdcooper := 5;qualContr('00500002188120000019919').nrdconta := 218812;qualContr('00500002188120000019919').nrctremp := 19919;qualContr('00500002188120000019919').idquapro := 3;
    qualContr('00500001518900000019896').cdcooper := 5;qualContr('00500001518900000019896').nrdconta := 151890;qualContr('00500001518900000019896').nrctremp := 19896;qualContr('00500001518900000019896').idquapro := 3;
    qualContr('00500001985790000020001').cdcooper := 5;qualContr('00500001985790000020001').nrdconta := 198579;qualContr('00500001985790000020001').nrctremp := 20001;qualContr('00500001985790000020001').idquapro := 3;
    qualContr('00500001239860000020095').cdcooper := 5;qualContr('00500001239860000020095').nrdconta := 123986;qualContr('00500001239860000020095').nrctremp := 20095;qualContr('00500001239860000020095').idquapro := 3;
    qualContr('00500001021800000020118').cdcooper := 5;qualContr('00500001021800000020118').nrdconta := 102180;qualContr('00500001021800000020118').nrctremp := 20118;qualContr('00500001021800000020118').idquapro := 3;
    qualContr('00500001714760000020284').cdcooper := 5;qualContr('00500001714760000020284').nrdconta := 171476;qualContr('00500001714760000020284').nrctremp := 20284;qualContr('00500001714760000020284').idquapro := 3;
    qualContr('00500001549030000020312').cdcooper := 5;qualContr('00500001549030000020312').nrdconta := 154903;qualContr('00500001549030000020312').nrctremp := 20312;qualContr('00500001549030000020312').idquapro := 3;
    qualContr('00500001247100000020365').cdcooper := 5;qualContr('00500001247100000020365').nrdconta := 124710;qualContr('00500001247100000020365').nrctremp := 20365;qualContr('00500001247100000020365').idquapro := 3;
    qualContr('00500001569570000020429').cdcooper := 5;qualContr('00500001569570000020429').nrdconta := 156957;qualContr('00500001569570000020429').nrctremp := 20429;qualContr('00500001569570000020429').idquapro := 3;
    qualContr('00500000341500000020648').cdcooper := 5;qualContr('00500000341500000020648').nrdconta := 34150;qualContr('00500000341500000020648').nrctremp := 20648;qualContr('00500000341500000020648').idquapro := 4;
    qualContr('00500001851160000020676').cdcooper := 5;qualContr('00500001851160000020676').nrdconta := 185116;qualContr('00500001851160000020676').nrctremp := 20676;qualContr('00500001851160000020676').idquapro := 4;
    qualContr('00500001839700000021024').cdcooper := 5;qualContr('00500001839700000021024').nrdconta := 183970;qualContr('00500001839700000021024').nrctremp := 21024;qualContr('00500001839700000021024').idquapro := 3;
    qualContr('00500001578640000021099').cdcooper := 5;qualContr('00500001578640000021099').nrdconta := 157864;qualContr('00500001578640000021099').nrctremp := 21099;qualContr('00500001578640000021099').idquapro := 4;
    qualContr('00500001456020000021298').cdcooper := 5;qualContr('00500001456020000021298').nrdconta := 145602;qualContr('00500001456020000021298').nrctremp := 21298;qualContr('00500001456020000021298').idquapro := 3;
    qualContr('00500001304780000021714').cdcooper := 5;qualContr('00500001304780000021714').nrdconta := 130478;qualContr('00500001304780000021714').nrctremp := 21714;qualContr('00500001304780000021714').idquapro := 3;
    qualContr('00500002272770000021715').cdcooper := 5;qualContr('00500002272770000021715').nrdconta := 227277;qualContr('00500002272770000021715').nrctremp := 21715;qualContr('00500002272770000021715').idquapro := 3;
    qualContr('00500001666930000021763').cdcooper := 5;qualContr('00500001666930000021763').nrdconta := 166693;qualContr('00500001666930000021763').nrctremp := 21763;qualContr('00500001666930000021763').idquapro := 3;
    qualContr('00500001740500000021805').cdcooper := 5;qualContr('00500001740500000021805').nrdconta := 174050;qualContr('00500001740500000021805').nrctremp := 21805;qualContr('00500001740500000021805').idquapro := 4;
    qualContr('00500001230480000021847').cdcooper := 5;qualContr('00500001230480000021847').nrdconta := 123048;qualContr('00500001230480000021847').nrctremp := 21847;qualContr('00500001230480000021847').idquapro := 4;
    qualContr('00500001006680000021864').cdcooper := 5;qualContr('00500001006680000021864').nrdconta := 100668;qualContr('00500001006680000021864').nrctremp := 21864;qualContr('00500001006680000021864').idquapro := 3;
    qualContr('00500000692480000021955').cdcooper := 5;qualContr('00500000692480000021955').nrdconta := 69248;qualContr('00500000692480000021955').nrctremp := 21955;qualContr('00500000692480000021955').idquapro := 3;
    qualContr('00500001363440000022026').cdcooper := 5;qualContr('00500001363440000022026').nrdconta := 136344;qualContr('00500001363440000022026').nrctremp := 22026;qualContr('00500001363440000022026').idquapro := 4;
    qualContr('00500001427350000022006').cdcooper := 5;qualContr('00500001427350000022006').nrdconta := 142735;qualContr('00500001427350000022006').nrctremp := 22006;qualContr('00500001427350000022006').idquapro := 3;
    qualContr('00500002271020000022018').cdcooper := 5;qualContr('00500002271020000022018').nrdconta := 227102;qualContr('00500002271020000022018').nrctremp := 22018;qualContr('00500002271020000022018').idquapro := 3;
    qualContr('00500001999070000022583').cdcooper := 5;qualContr('00500001999070000022583').nrdconta := 199907;qualContr('00500001999070000022583').nrctremp := 22583;qualContr('00500001999070000022583').idquapro := 3;
    qualContr('00500001399120000022602').cdcooper := 5;qualContr('00500001399120000022602').nrdconta := 139912;qualContr('00500001399120000022602').nrctremp := 22602;qualContr('00500001399120000022602').idquapro := 4;
    qualContr('00500000913670000022596').cdcooper := 5;qualContr('00500000913670000022596').nrdconta := 91367;qualContr('00500000913670000022596').nrctremp := 22596;qualContr('00500000913670000022596').idquapro := 4;
    qualContr('00600001247450000222398').cdcooper := 6;qualContr('00600001247450000222398').nrdconta := 124745;qualContr('00600001247450000222398').nrctremp := 222398;qualContr('00600001247450000222398').idquapro := 3;
    qualContr('00600001143080000222574').cdcooper := 6;qualContr('00600001143080000222574').nrdconta := 114308;qualContr('00600001143080000222574').nrctremp := 222574;qualContr('00600001143080000222574').idquapro := 3;
    qualContr('00600001039850000225833').cdcooper := 6;qualContr('00600001039850000225833').nrdconta := 103985;qualContr('00600001039850000225833').nrctremp := 225833;qualContr('00600001039850000225833').idquapro := 3;
    qualContr('00600000478480000227462').cdcooper := 6;qualContr('00600000478480000227462').nrdconta := 47848;qualContr('00600000478480000227462').nrctremp := 227462;qualContr('00600000478480000227462').idquapro := 3;
    qualContr('00600005057570000227472').cdcooper := 6;qualContr('00600005057570000227472').nrdconta := 505757;qualContr('00600005057570000227472').nrctremp := 227472;qualContr('00600005057570000227472').idquapro := 3;
    qualContr('00600001371620000227737').cdcooper := 6;qualContr('00600001371620000227737').nrdconta := 137162;qualContr('00600001371620000227737').nrctremp := 227737;qualContr('00600001371620000227737').idquapro := 3;
    qualContr('00600001229470000228828').cdcooper := 6;qualContr('00600001229470000228828').nrdconta := 122947;qualContr('00600001229470000228828').nrctremp := 228828;qualContr('00600001229470000228828').idquapro := 3;
    qualContr('00600001340400000228821').cdcooper := 6;qualContr('00600001340400000228821').nrdconta := 134040;qualContr('00600001340400000228821').nrctremp := 228821;qualContr('00600001340400000228821').idquapro := 3;
    qualContr('00600001121190000228837').cdcooper := 6;qualContr('00600001121190000228837').nrdconta := 112119;qualContr('00600001121190000228837').nrctremp := 228837;qualContr('00600001121190000228837').idquapro := 3;
    qualContr('00600000925330000228865').cdcooper := 6;qualContr('00600000925330000228865').nrdconta := 92533;qualContr('00600000925330000228865').nrctremp := 228865;qualContr('00600000925330000228865').idquapro := 3;
    qualContr('00600001224910000228916').cdcooper := 6;qualContr('00600001224910000228916').nrdconta := 122491;qualContr('00600001224910000228916').nrctremp := 228916;qualContr('00600001224910000228916').idquapro := 3;
    qualContr('00600001252960000229258').cdcooper := 6;qualContr('00600001252960000229258').nrdconta := 125296;qualContr('00600001252960000229258').nrctremp := 229258;qualContr('00600001252960000229258').idquapro := 3;
    qualContr('00600001711150000229473').cdcooper := 6;qualContr('00600001711150000229473').nrdconta := 171115;qualContr('00600001711150000229473').nrctremp := 229473;qualContr('00600001711150000229473').idquapro := 3;
    qualContr('00600001193180000229541').cdcooper := 6;qualContr('00600001193180000229541').nrdconta := 119318;qualContr('00600001193180000229541').nrctremp := 229541;qualContr('00600001193180000229541').idquapro := 3;
    qualContr('00600001642590000229996').cdcooper := 6;qualContr('00600001642590000229996').nrdconta := 164259;qualContr('00600001642590000229996').nrctremp := 229996;qualContr('00600001642590000229996').idquapro := 3;
    qualContr('00600001100510000230384').cdcooper := 6;qualContr('00600001100510000230384').nrdconta := 110051;qualContr('00600001100510000230384').nrctremp := 230384;qualContr('00600001100510000230384').idquapro := 3;
    qualContr('00600001807770000230505').cdcooper := 6;qualContr('00600001807770000230505').nrdconta := 180777;qualContr('00600001807770000230505').nrctremp := 230505;qualContr('00600001807770000230505').idquapro := 3;
    qualContr('00600001250590000231005').cdcooper := 6;qualContr('00600001250590000231005').nrdconta := 125059;qualContr('00600001250590000231005').nrctremp := 231005;qualContr('00600001250590000231005').idquapro := 3;
    qualContr('00600005739140000231236').cdcooper := 6;qualContr('00600005739140000231236').nrdconta := 573914;qualContr('00600005739140000231236').nrctremp := 231236;qualContr('00600005739140000231236').idquapro := 3;
    qualContr('00600001195630000231315').cdcooper := 6;qualContr('00600001195630000231315').nrdconta := 119563;qualContr('00600001195630000231315').nrctremp := 231315;qualContr('00600001195630000231315').idquapro := 3;
    qualContr('00700000009730000022833').cdcooper := 7;qualContr('00700000009730000022833').nrdconta := 973;qualContr('00700000009730000022833').nrctremp := 22833;qualContr('00700000009730000022833').idquapro := 3;
    qualContr('00700002306850000022958').cdcooper := 7;qualContr('00700002306850000022958').nrdconta := 230685;qualContr('00700002306850000022958').nrctremp := 22958;qualContr('00700002306850000022958').idquapro := 3;
    qualContr('00700000435400000025211').cdcooper := 7;qualContr('00700000435400000025211').nrdconta := 43540;qualContr('00700000435400000025211').nrctremp := 25211;qualContr('00700000435400000025211').idquapro := 4;
    qualContr('00700001864810000027584').cdcooper := 7;qualContr('00700001864810000027584').nrdconta := 186481;qualContr('00700001864810000027584').nrctremp := 27584;qualContr('00700001864810000027584').idquapro := 4;
    qualContr('00700001071230000027661').cdcooper := 7;qualContr('00700001071230000027661').nrdconta := 107123;qualContr('00700001071230000027661').nrctremp := 27661;qualContr('00700001071230000027661').idquapro := 3;
    qualContr('00700001023770000027691').cdcooper := 7;qualContr('00700001023770000027691').nrdconta := 102377;qualContr('00700001023770000027691').nrctremp := 27691;qualContr('00700001023770000027691').idquapro := 4;
    qualContr('00700001791160000027732').cdcooper := 7;qualContr('00700001791160000027732').nrdconta := 179116;qualContr('00700001791160000027732').nrctremp := 27732;qualContr('00700001791160000027732').idquapro := 3;
    qualContr('00700001618290000027824').cdcooper := 7;qualContr('00700001618290000027824').nrdconta := 161829;qualContr('00700001618290000027824').nrctremp := 27824;qualContr('00700001618290000027824').idquapro := 4;
    qualContr('00700003218930000027901').cdcooper := 7;qualContr('00700003218930000027901').nrdconta := 321893;qualContr('00700003218930000027901').nrctremp := 27901;qualContr('00700003218930000027901').idquapro := 4;
    qualContr('00700001498020000028495').cdcooper := 7;qualContr('00700001498020000028495').nrdconta := 149802;qualContr('00700001498020000028495').nrctremp := 28495;qualContr('00700001498020000028495').idquapro := 4;
    qualContr('00700002628200000029327').cdcooper := 7;qualContr('00700002628200000029327').nrdconta := 262820;qualContr('00700002628200000029327').nrctremp := 29327;qualContr('00700002628200000029327').idquapro := 4;
    qualContr('00700001945300000030201').cdcooper := 7;qualContr('00700001945300000030201').nrdconta := 194530;qualContr('00700001945300000030201').nrctremp := 30201;qualContr('00700001945300000030201').idquapro := 3;
    qualContr('00700003329920000030406').cdcooper := 7;qualContr('00700003329920000030406').nrdconta := 332992;qualContr('00700003329920000030406').nrctremp := 30406;qualContr('00700003329920000030406').idquapro := 3;
    qualContr('00700002716160000030637').cdcooper := 7;qualContr('00700002716160000030637').nrdconta := 271616;qualContr('00700002716160000030637').nrctremp := 30637;qualContr('00700002716160000030637').idquapro := 3;
    qualContr('00700000369350000030935').cdcooper := 7;qualContr('00700000369350000030935').nrdconta := 36935;qualContr('00700000369350000030935').nrctremp := 30935;qualContr('00700000369350000030935').idquapro := 4;
    qualContr('00700001137190000031530').cdcooper := 7;qualContr('00700001137190000031530').nrdconta := 113719;qualContr('00700001137190000031530').nrctremp := 31530;qualContr('00700001137190000031530').idquapro := 4;
    qualContr('00700002293770000032236').cdcooper := 7;qualContr('00700002293770000032236').nrdconta := 229377;qualContr('00700002293770000032236').nrctremp := 32236;qualContr('00700002293770000032236').idquapro := 3;
    qualContr('00700001242490000032252').cdcooper := 7;qualContr('00700001242490000032252').nrdconta := 124249;qualContr('00700001242490000032252').nrctremp := 32252;qualContr('00700001242490000032252').idquapro := 4;
    qualContr('00700000002050000032442').cdcooper := 7;qualContr('00700000002050000032442').nrdconta := 205;qualContr('00700000002050000032442').nrctremp := 32442;qualContr('00700000002050000032442').idquapro := 3;
    qualContr('00700002672010000032581').cdcooper := 7;qualContr('00700002672010000032581').nrdconta := 267201;qualContr('00700002672010000032581').nrctremp := 32581;qualContr('00700002672010000032581').idquapro := 4;
    qualContr('00700002509020000032659').cdcooper := 7;qualContr('00700002509020000032659').nrdconta := 250902;qualContr('00700002509020000032659').nrctremp := 32659;qualContr('00700002509020000032659').idquapro := 4;
    qualContr('00700002073220000033352').cdcooper := 7;qualContr('00700002073220000033352').nrdconta := 207322;qualContr('00700002073220000033352').nrctremp := 33352;qualContr('00700002073220000033352').idquapro := 4;
    qualContr('00700001021990000034788').cdcooper := 7;qualContr('00700001021990000034788').nrdconta := 102199;qualContr('00700001021990000034788').nrctremp := 34788;qualContr('00700001021990000034788').idquapro := 3;
    qualContr('00700000193480000035528').cdcooper := 7;qualContr('00700000193480000035528').nrdconta := 19348;qualContr('00700000193480000035528').nrctremp := 35528;qualContr('00700000193480000035528').idquapro := 3;
    qualContr('00700000560730000035607').cdcooper := 7;qualContr('00700000560730000035607').nrdconta := 56073;qualContr('00700000560730000035607').nrctremp := 35607;qualContr('00700000560730000035607').idquapro := 3;
    qualContr('00700000556110000035650').cdcooper := 7;qualContr('00700000556110000035650').nrdconta := 55611;qualContr('00700000556110000035650').nrctremp := 35650;qualContr('00700000556110000035650').idquapro := 4;
    qualContr('00700001436850000035743').cdcooper := 7;qualContr('00700001436850000035743').nrdconta := 143685;qualContr('00700001436850000035743').nrctremp := 35743;qualContr('00700001436850000035743').idquapro := 3;
    qualContr('00700002861170000035917').cdcooper := 7;qualContr('00700002861170000035917').nrdconta := 286117;qualContr('00700002861170000035917').nrctremp := 35917;qualContr('00700002861170000035917').idquapro := 4;
    qualContr('00700000202060000035963').cdcooper := 7;qualContr('00700000202060000035963').nrdconta := 20206;qualContr('00700000202060000035963').nrctremp := 35963;qualContr('00700000202060000035963').idquapro := 4;
    qualContr('00700002723100000035929').cdcooper := 7;qualContr('00700002723100000035929').nrdconta := 272310;qualContr('00700002723100000035929').nrctremp := 35929;qualContr('00700002723100000035929').idquapro := 3;
    qualContr('00700002627490000036114').cdcooper := 7;qualContr('00700002627490000036114').nrdconta := 262749;qualContr('00700002627490000036114').nrctremp := 36114;qualContr('00700002627490000036114').idquapro := 3;
    qualContr('00700001434800000036139').cdcooper := 7;qualContr('00700001434800000036139').nrdconta := 143480;qualContr('00700001434800000036139').nrctremp := 36139;qualContr('00700001434800000036139').idquapro := 3;
    qualContr('00700000013760000036232').cdcooper := 7;qualContr('00700000013760000036232').nrdconta := 1376;qualContr('00700000013760000036232').nrctremp := 36232;qualContr('00700000013760000036232').idquapro := 3;
    qualContr('00700001175010000036421').cdcooper := 7;qualContr('00700001175010000036421').nrdconta := 117501;qualContr('00700001175010000036421').nrctremp := 36421;qualContr('00700001175010000036421').idquapro := 3;
    qualContr('00700000718200000036583').cdcooper := 7;qualContr('00700000718200000036583').nrdconta := 71820;qualContr('00700000718200000036583').nrctremp := 36583;qualContr('00700000718200000036583').idquapro := 3;
    qualContr('00700000710560000036640').cdcooper := 7;qualContr('00700000710560000036640').nrdconta := 71056;qualContr('00700000710560000036640').nrctremp := 36640;qualContr('00700000710560000036640').idquapro := 3;
    qualContr('00700000893200000036696').cdcooper := 7;qualContr('00700000893200000036696').nrdconta := 89320;qualContr('00700000893200000036696').nrctremp := 36696;qualContr('00700000893200000036696').idquapro := 3;
    qualContr('00700002768980000036966').cdcooper := 7;qualContr('00700002768980000036966').nrdconta := 276898;qualContr('00700002768980000036966').nrctremp := 36966;qualContr('00700002768980000036966').idquapro := 3;
    qualContr('00700000988090000037039').cdcooper := 7;qualContr('00700000988090000037039').nrdconta := 98809;qualContr('00700000988090000037039').nrctremp := 37039;qualContr('00700000988090000037039').idquapro := 4;
    qualContr('00700000737500000037076').cdcooper := 7;qualContr('00700000737500000037076').nrdconta := 73750;qualContr('00700000737500000037076').nrctremp := 37076;qualContr('00700000737500000037076').idquapro := 3;
    qualContr('00700003113320000037081').cdcooper := 7;qualContr('00700003113320000037081').nrdconta := 311332;qualContr('00700003113320000037081').nrctremp := 37081;qualContr('00700003113320000037081').idquapro := 4;
    qualContr('00700000365950000037106').cdcooper := 7;qualContr('00700000365950000037106').nrdconta := 36595;qualContr('00700000365950000037106').nrctremp := 37106;qualContr('00700000365950000037106').idquapro := 3;
    qualContr('00700001987810000037162').cdcooper := 7;qualContr('00700001987810000037162').nrdconta := 198781;qualContr('00700001987810000037162').nrctremp := 37162;qualContr('00700001987810000037162').idquapro := 4;
    qualContr('00700001900120000037134').cdcooper := 7;qualContr('00700001900120000037134').nrdconta := 190012;qualContr('00700001900120000037134').nrctremp := 37134;qualContr('00700001900120000037134').idquapro := 3;
    qualContr('00700000115920000037219').cdcooper := 7;qualContr('00700000115920000037219').nrdconta := 11592;qualContr('00700000115920000037219').nrctremp := 37219;qualContr('00700000115920000037219').idquapro := 4;
    qualContr('00700001866190000037353').cdcooper := 7;qualContr('00700001866190000037353').nrdconta := 186619;qualContr('00700001866190000037353').nrctremp := 37353;qualContr('00700001866190000037353').idquapro := 4;
    qualContr('00700001040510000037444').cdcooper := 7;qualContr('00700001040510000037444').nrdconta := 104051;qualContr('00700001040510000037444').nrctremp := 37444;qualContr('00700001040510000037444').idquapro := 3;
    qualContr('00700000844250000037539').cdcooper := 7;qualContr('00700000844250000037539').nrdconta := 84425;qualContr('00700000844250000037539').nrctremp := 37539;qualContr('00700000844250000037539').idquapro := 4;
    qualContr('00700001689120000037597').cdcooper := 7;qualContr('00700001689120000037597').nrdconta := 168912;qualContr('00700001689120000037597').nrctremp := 37597;qualContr('00700001689120000037597').idquapro := 4;
    qualContr('00700002778000000037543').cdcooper := 7;qualContr('00700002778000000037543').nrdconta := 277800;qualContr('00700002778000000037543').nrctremp := 37543;qualContr('00700002778000000037543').idquapro := 4;
    qualContr('00700003334090000037581').cdcooper := 7;qualContr('00700003334090000037581').nrdconta := 333409;qualContr('00700003334090000037581').nrctremp := 37581;qualContr('00700003334090000037581').idquapro := 4;
    qualContr('00700001655900000037890').cdcooper := 7;qualContr('00700001655900000037890').nrdconta := 165590;qualContr('00700001655900000037890').nrctremp := 37890;qualContr('00700001655900000037890').idquapro := 4;
    qualContr('00700002928180000037912').cdcooper := 7;qualContr('00700002928180000037912').nrdconta := 292818;qualContr('00700002928180000037912').nrctremp := 37912;qualContr('00700002928180000037912').idquapro := 4;
    qualContr('00700003022280000037937').cdcooper := 7;qualContr('00700003022280000037937').nrdconta := 302228;qualContr('00700003022280000037937').nrctremp := 37937;qualContr('00700003022280000037937').idquapro := 4;
    qualContr('00700001917280000037991').cdcooper := 7;qualContr('00700001917280000037991').nrdconta := 191728;qualContr('00700001917280000037991').nrctremp := 37991;qualContr('00700001917280000037991').idquapro := 4;
    qualContr('00700002518100000038053').cdcooper := 7;qualContr('00700002518100000038053').nrdconta := 251810;qualContr('00700002518100000038053').nrctremp := 38053;qualContr('00700002518100000038053').idquapro := 4;
    qualContr('00800000094820000003944').cdcooper := 8;qualContr('00800000094820000003944').nrdconta := 9482;qualContr('00800000094820000003944').nrctremp := 3944;qualContr('00800000094820000003944').idquapro := 3;
    qualContr('00800000367650000005358').cdcooper := 8;qualContr('00800000367650000005358').nrdconta := 36765;qualContr('00800000367650000005358').nrctremp := 5358;qualContr('00800000367650000005358').idquapro := 3;
    qualContr('00800000308210000005566').cdcooper := 8;qualContr('00800000308210000005566').nrdconta := 30821;qualContr('00800000308210000005566').nrctremp := 5566;qualContr('00800000308210000005566').idquapro := 3;
    qualContr('00800000305540000005798').cdcooper := 8;qualContr('00800000305540000005798').nrdconta := 30554;qualContr('00800000305540000005798').nrctremp := 5798;qualContr('00800000305540000005798').idquapro := 3;
    qualContr('00800000295720000006379').cdcooper := 8;qualContr('00800000295720000006379').nrdconta := 29572;qualContr('00800000295720000006379').nrctremp := 6379;qualContr('00800000295720000006379').idquapro := 3;
    qualContr('00800000397050000006446').cdcooper := 8;qualContr('00800000397050000006446').nrdconta := 39705;qualContr('00800000397050000006446').nrctremp := 6446;qualContr('00800000397050000006446').idquapro := 3;
    qualContr('00800000408000000006464').cdcooper := 8;qualContr('00800000408000000006464').nrdconta := 40800;qualContr('00800000408000000006464').nrctremp := 6464;qualContr('00800000408000000006464').idquapro := 3;
    qualContr('00800000272000000006506').cdcooper := 8;qualContr('00800000272000000006506').nrdconta := 27200;qualContr('00800000272000000006506').nrctremp := 6506;qualContr('00800000272000000006506').idquapro := 3;
    qualContr('00800000389540000006551').cdcooper := 8;qualContr('00800000389540000006551').nrdconta := 38954;qualContr('00800000389540000006551').nrctremp := 6551;qualContr('00800000389540000006551').idquapro := 3;
    qualContr('00800000167300000006568').cdcooper := 8;qualContr('00800000167300000006568').nrdconta := 16730;qualContr('00800000167300000006568').nrctremp := 6568;qualContr('00800000167300000006568').idquapro := 3;
    qualContr('00800000011200000006631').cdcooper := 8;qualContr('00800000011200000006631').nrdconta := 1120;qualContr('00800000011200000006631').nrctremp := 6631;qualContr('00800000011200000006631').idquapro := 3;
    qualContr('00800000026150000006737').cdcooper := 8;qualContr('00800000026150000006737').nrdconta := 2615;qualContr('00800000026150000006737').nrctremp := 6737;qualContr('00800000026150000006737').idquapro := 3;
    qualContr('00900001791240000012172').cdcooper := 9;qualContr('00900001791240000012172').nrdconta := 179124;qualContr('00900001791240000012172').nrctremp := 12172;qualContr('00900001791240000012172').idquapro := 4;
    qualContr('00900000400610000012226').cdcooper := 9;qualContr('00900000400610000012226').nrdconta := 40061;qualContr('00900000400610000012226').nrctremp := 12226;qualContr('00900000400610000012226').idquapro := 3;
    qualContr('00900001437660000012416').cdcooper := 9;qualContr('00900001437660000012416').nrdconta := 143766;qualContr('00900001437660000012416').nrctremp := 12416;qualContr('00900001437660000012416').idquapro := 3;
    qualContr('00900000804030000013496').cdcooper := 9;qualContr('00900000804030000013496').nrdconta := 80403;qualContr('00900000804030000013496').nrctremp := 13496;qualContr('00900000804030000013496').idquapro := 3;
    qualContr('00900000737410000013618').cdcooper := 9;qualContr('00900000737410000013618').nrdconta := 73741;qualContr('00900000737410000013618').nrctremp := 13618;qualContr('00900000737410000013618').idquapro := 3;
    qualContr('00900001490040000014298').cdcooper := 9;qualContr('00900001490040000014298').nrdconta := 149004;qualContr('00900001490040000014298').nrctremp := 14298;qualContr('00900001490040000014298').idquapro := 3;
    qualContr('00900002064660000016867').cdcooper := 9;qualContr('00900002064660000016867').nrdconta := 206466;qualContr('00900002064660000016867').nrctremp := 16867;qualContr('00900002064660000016867').idquapro := 3;
    qualContr('00900002214490000018176').cdcooper := 9;qualContr('00900002214490000018176').nrdconta := 221449;qualContr('00900002214490000018176').nrctremp := 18176;qualContr('00900002214490000018176').idquapro := 3;
    qualContr('00900002330130000019211').cdcooper := 9;qualContr('00900002330130000019211').nrdconta := 233013;qualContr('00900002330130000019211').nrctremp := 19211;qualContr('00900002330130000019211').idquapro := 3;
    qualContr('00900000822440000021243').cdcooper := 9;qualContr('00900000822440000021243').nrdconta := 82244;qualContr('00900000822440000021243').nrctremp := 21243;qualContr('00900000822440000021243').idquapro := 3;
    qualContr('00900001753820000021333').cdcooper := 9;qualContr('00900001753820000021333').nrdconta := 175382;qualContr('00900001753820000021333').nrctremp := 21333;qualContr('00900001753820000021333').idquapro := 3;
    qualContr('00900001998340000021388').cdcooper := 9;qualContr('00900001998340000021388').nrdconta := 199834;qualContr('00900001998340000021388').nrctremp := 21388;qualContr('00900001998340000021388').idquapro := 3;
    qualContr('00900001458400000021536').cdcooper := 9;qualContr('00900001458400000021536').nrdconta := 145840;qualContr('00900001458400000021536').nrctremp := 21536;qualContr('00900001458400000021536').idquapro := 3;
    qualContr('00900001375700000021692').cdcooper := 9;qualContr('00900001375700000021692').nrdconta := 137570;qualContr('00900001375700000021692').nrctremp := 21692;qualContr('00900001375700000021692').idquapro := 3;
    qualContr('00900001808070000022142').cdcooper := 9;qualContr('00900001808070000022142').nrdconta := 180807;qualContr('00900001808070000022142').nrctremp := 22142;qualContr('00900001808070000022142').idquapro := 3;
    qualContr('00900001887430000022411').cdcooper := 9;qualContr('00900001887430000022411').nrdconta := 188743;qualContr('00900001887430000022411').nrctremp := 22411;qualContr('00900001887430000022411').idquapro := 4;
    qualContr('00900002146120000022841').cdcooper := 9;qualContr('00900002146120000022841').nrdconta := 214612;qualContr('00900002146120000022841').nrctremp := 22841;qualContr('00900002146120000022841').idquapro := 3;
    qualContr('00900000012790000023217').cdcooper := 9;qualContr('00900000012790000023217').nrdconta := 1279;qualContr('00900000012790000023217').nrctremp := 23217;qualContr('00900000012790000023217').idquapro := 3;
    qualContr('00900002474480000023351').cdcooper := 9;qualContr('00900002474480000023351').nrdconta := 247448;qualContr('00900002474480000023351').nrctremp := 23351;qualContr('00900002474480000023351').idquapro := 4;
    qualContr('00900002186000000023546').cdcooper := 9;qualContr('00900002186000000023546').nrdconta := 218600;qualContr('00900002186000000023546').nrctremp := 23546;qualContr('00900002186000000023546').idquapro := 3;
    qualContr('00900002440150000024034').cdcooper := 9;qualContr('00900002440150000024034').nrdconta := 244015;qualContr('00900002440150000024034').nrctremp := 24034;qualContr('00900002440150000024034').idquapro := 3;
    qualContr('00900001371200000024021').cdcooper := 9;qualContr('00900001371200000024021').nrdconta := 137120;qualContr('00900001371200000024021').nrctremp := 24021;qualContr('00900001371200000024021').idquapro := 3;
    qualContr('00900002761380000024355').cdcooper := 9;qualContr('00900002761380000024355').nrdconta := 276138;qualContr('00900002761380000024355').nrctremp := 24355;qualContr('00900002761380000024355').idquapro := 3;
    qualContr('00900002484950000024460').cdcooper := 9;qualContr('00900002484950000024460').nrdconta := 248495;qualContr('00900002484950000024460').nrctremp := 24460;qualContr('00900002484950000024460').idquapro := 3;
    qualContr('00900002085900000024620').cdcooper := 9;qualContr('00900002085900000024620').nrdconta := 208590;qualContr('00900002085900000024620').nrctremp := 24620;qualContr('00900002085900000024620').idquapro := 3;
    qualContr('00900001757900000024810').cdcooper := 9;qualContr('00900001757900000024810').nrdconta := 175790;qualContr('00900001757900000024810').nrctremp := 24810;qualContr('00900001757900000024810').idquapro := 3;
    qualContr('00900002352700000024816').cdcooper := 9;qualContr('00900002352700000024816').nrdconta := 235270;qualContr('00900002352700000024816').nrctremp := 24816;qualContr('00900002352700000024816').idquapro := 3;
    qualContr('00900002108970000024631').cdcooper := 9;qualContr('00900002108970000024631').nrdconta := 210897;qualContr('00900002108970000024631').nrctremp := 24631;qualContr('00900002108970000024631').idquapro := 3;
    qualContr('00900001855400000024710').cdcooper := 9;qualContr('00900001855400000024710').nrdconta := 185540;qualContr('00900001855400000024710').nrctremp := 24710;qualContr('00900001855400000024710').idquapro := 3;
    qualContr('00900001692340000024838').cdcooper := 9;qualContr('00900001692340000024838').nrdconta := 169234;qualContr('00900001692340000024838').nrctremp := 24838;qualContr('00900001692340000024838').idquapro := 3;
    qualContr('00900002545250000025044').cdcooper := 9;qualContr('00900002545250000025044').nrdconta := 254525;qualContr('00900002545250000025044').nrctremp := 25044;qualContr('00900002545250000025044').idquapro := 3;
    qualContr('00900002665310000025215').cdcooper := 9;qualContr('00900002665310000025215').nrdconta := 266531;qualContr('00900002665310000025215').nrctremp := 25215;qualContr('00900002665310000025215').idquapro := 4;
    qualContr('00900002080270000025218').cdcooper := 9;qualContr('00900002080270000025218').nrdconta := 208027;qualContr('00900002080270000025218').nrctremp := 25218;qualContr('00900002080270000025218').idquapro := 3;
    qualContr('00900002764300000025587').cdcooper := 9;qualContr('00900002764300000025587').nrdconta := 276430;qualContr('00900002764300000025587').nrctremp := 25587;qualContr('00900002764300000025587').idquapro := 4;
    qualContr('00900000878740000025687').cdcooper := 9;qualContr('00900000878740000025687').nrdconta := 87874;qualContr('00900000878740000025687').nrctremp := 25687;qualContr('00900000878740000025687').idquapro := 3;
    qualContr('00900002957100000026426').cdcooper := 9;qualContr('00900002957100000026426').nrdconta := 295710;qualContr('00900002957100000026426').nrctremp := 26426;qualContr('00900002957100000026426').idquapro := 3;
    qualContr('00900001559000000026434').cdcooper := 9;qualContr('00900001559000000026434').nrdconta := 155900;qualContr('00900001559000000026434').nrctremp := 26434;qualContr('00900001559000000026434').idquapro := 3;
    qualContr('00900002002040000026391').cdcooper := 9;qualContr('00900002002040000026391').nrdconta := 200204;qualContr('00900002002040000026391').nrctremp := 26391;qualContr('00900002002040000026391').idquapro := 3;
    qualContr('00900001287670000026464').cdcooper := 9;qualContr('00900001287670000026464').nrdconta := 128767;qualContr('00900001287670000026464').nrctremp := 26464;qualContr('00900001287670000026464').idquapro := 3;
    qualContr('00900002024790000026637').cdcooper := 9;qualContr('00900002024790000026637').nrdconta := 202479;qualContr('00900002024790000026637').nrctremp := 26637;qualContr('00900002024790000026637').idquapro := 4;
    qualContr('00900001908700000026632').cdcooper := 9;qualContr('00900001908700000026632').nrdconta := 190870;qualContr('00900001908700000026632').nrctremp := 26632;qualContr('00900001908700000026632').idquapro := 3;
    qualContr('00900001238890000027354').cdcooper := 9;qualContr('00900001238890000027354').nrdconta := 123889;qualContr('00900001238890000027354').nrctremp := 27354;qualContr('00900001238890000027354').idquapro := 3;
    qualContr('00900009050540000027308').cdcooper := 9;qualContr('00900009050540000027308').nrdconta := 905054;qualContr('00900009050540000027308').nrctremp := 27308;qualContr('00900009050540000027308').idquapro := 3;
    qualContr('00900002342810000027347').cdcooper := 9;qualContr('00900002342810000027347').nrdconta := 234281;qualContr('00900002342810000027347').nrctremp := 27347;qualContr('00900002342810000027347').idquapro := 3;
    qualContr('00900001911240000027350').cdcooper := 9;qualContr('00900001911240000027350').nrdconta := 191124;qualContr('00900001911240000027350').nrctremp := 27350;qualContr('00900001911240000027350').idquapro := 3;
    qualContr('00900002560130000027317').cdcooper := 9;qualContr('00900002560130000027317').nrdconta := 256013;qualContr('00900002560130000027317').nrctremp := 27317;qualContr('00900002560130000027317').idquapro := 3;
    qualContr('00900003004200000027646').cdcooper := 9;qualContr('00900003004200000027646').nrdconta := 300420;qualContr('00900003004200000027646').nrctremp := 27646;qualContr('00900003004200000027646').idquapro := 3;
    qualContr('00900002408260000028047').cdcooper := 9;qualContr('00900002408260000028047').nrdconta := 240826;qualContr('00900002408260000028047').nrctremp := 28047;qualContr('00900002408260000028047').idquapro := 3;
    qualContr('00900002331960000028253').cdcooper := 9;qualContr('00900002331960000028253').nrdconta := 233196;qualContr('00900002331960000028253').nrctremp := 28253;qualContr('00900002331960000028253').idquapro := 3;
    qualContr('00900001830320000028477').cdcooper := 9;qualContr('00900001830320000028477').nrdconta := 183032;qualContr('00900001830320000028477').nrctremp := 28477;qualContr('00900001830320000028477').idquapro := 3;
    qualContr('00900000961480000028718').cdcooper := 9;qualContr('00900000961480000028718').nrdconta := 96148;qualContr('00900000961480000028718').nrctremp := 28718;qualContr('00900000961480000028718').idquapro := 3;
    qualContr('00900000295560000028859').cdcooper := 9;qualContr('00900000295560000028859').nrdconta := 29556;qualContr('00900000295560000028859').nrctremp := 28859;qualContr('00900000295560000028859').idquapro := 3;
    qualContr('00900002723020000028939').cdcooper := 9;qualContr('00900002723020000028939').nrdconta := 272302;qualContr('00900002723020000028939').nrctremp := 28939;qualContr('00900002723020000028939').idquapro := 3;
    qualContr('00900001924650000029892').cdcooper := 9;qualContr('00900001924650000029892').nrdconta := 192465;qualContr('00900001924650000029892').nrctremp := 29892;qualContr('00900001924650000029892').idquapro := 3;
    qualContr('00900001016560000030171').cdcooper := 9;qualContr('00900001016560000030171').nrdconta := 101656;qualContr('00900001016560000030171').nrctremp := 30171;qualContr('00900001016560000030171').idquapro := 3;
    qualContr('00900002323940000030505').cdcooper := 9;qualContr('00900002323940000030505').nrdconta := 232394;qualContr('00900002323940000030505').nrctremp := 30505;qualContr('00900002323940000030505').idquapro := 3;
    qualContr('01000000177010000006064').cdcooper := 10;qualContr('01000000177010000006064').nrdconta := 17701;qualContr('01000000177010000006064').nrctremp := 6064;qualContr('01000000177010000006064').idquapro := 3;
    qualContr('01000000735040000009780').cdcooper := 10;qualContr('01000000735040000009780').nrdconta := 73504;qualContr('01000000735040000009780').nrctremp := 9780;qualContr('01000000735040000009780').idquapro := 3;
    qualContr('01000000708900000010284').cdcooper := 10;qualContr('01000000708900000010284').nrdconta := 70890;qualContr('01000000708900000010284').nrctremp := 10284;qualContr('01000000708900000010284').idquapro := 3;
    qualContr('01000000338120000010301').cdcooper := 10;qualContr('01000000338120000010301').nrdconta := 33812;qualContr('01000000338120000010301').nrctremp := 10301;qualContr('01000000338120000010301').idquapro := 3;
    qualContr('01000000504660000010605').cdcooper := 10;qualContr('01000000504660000010605').nrdconta := 50466;qualContr('01000000504660000010605').nrctremp := 10605;qualContr('01000000504660000010605').idquapro := 3;
    qualContr('01000000702970000010819').cdcooper := 10;qualContr('01000000702970000010819').nrdconta := 70297;qualContr('01000000702970000010819').nrctremp := 10819;qualContr('01000000702970000010819').idquapro := 3;
    qualContr('01000000524690000011012').cdcooper := 10;qualContr('01000000524690000011012').nrdconta := 52469;qualContr('01000000524690000011012').nrctremp := 11012;qualContr('01000000524690000011012').idquapro := 3;
    qualContr('01000001238030000011049').cdcooper := 10;qualContr('01000001238030000011049').nrdconta := 123803;qualContr('01000001238030000011049').nrctremp := 11049;qualContr('01000001238030000011049').idquapro := 4;
    qualContr('01000000589800000011182').cdcooper := 10;qualContr('01000000589800000011182').nrdconta := 58980;qualContr('01000000589800000011182').nrctremp := 11182;qualContr('01000000589800000011182').idquapro := 3;
    qualContr('01000000748450000011390').cdcooper := 10;qualContr('01000000748450000011390').nrdconta := 74845;qualContr('01000000748450000011390').nrctremp := 11390;qualContr('01000000748450000011390').idquapro := 3;
    qualContr('01000000811910000011610').cdcooper := 10;qualContr('01000000811910000011610').nrdconta := 81191;qualContr('01000000811910000011610').nrctremp := 11610;qualContr('01000000811910000011610').idquapro := 3;
    qualContr('01000001202600000011733').cdcooper := 10;qualContr('01000001202600000011733').nrdconta := 120260;qualContr('01000001202600000011733').nrctremp := 11733;qualContr('01000001202600000011733').idquapro := 3;
    qualContr('01000000940300000011742').cdcooper := 10;qualContr('01000000940300000011742').nrdconta := 94030;qualContr('01000000940300000011742').nrctremp := 11742;qualContr('01000000940300000011742').idquapro := 3;
    qualContr('01000001276470000011730').cdcooper := 10;qualContr('01000001276470000011730').nrdconta := 127647;qualContr('01000001276470000011730').nrctremp := 11730;qualContr('01000001276470000011730').idquapro := 3;
    qualContr('01000001188420000011973').cdcooper := 10;qualContr('01000001188420000011973').nrdconta := 118842;qualContr('01000001188420000011973').nrctremp := 11973;qualContr('01000001188420000011973').idquapro := 3;
    qualContr('01000000333590000012069').cdcooper := 10;qualContr('01000000333590000012069').nrdconta := 33359;qualContr('01000000333590000012069').nrctremp := 12069;qualContr('01000000333590000012069').idquapro := 4;
    qualContr('01000001213040000012109').cdcooper := 10;qualContr('01000001213040000012109').nrdconta := 121304;qualContr('01000001213040000012109').nrctremp := 12109;qualContr('01000001213040000012109').idquapro := 3;
    qualContr('01000001195630000012175').cdcooper := 10;qualContr('01000001195630000012175').nrdconta := 119563;qualContr('01000001195630000012175').nrctremp := 12175;qualContr('01000001195630000012175').idquapro := 3;
    qualContr('01000001114140000012195').cdcooper := 10;qualContr('01000001114140000012195').nrdconta := 111414;qualContr('01000001114140000012195').nrctremp := 12195;qualContr('01000001114140000012195').idquapro := 3;
    qualContr('01000000009900000012199').cdcooper := 10;qualContr('01000000009900000012199').nrdconta := 990;qualContr('01000000009900000012199').nrctremp := 12199;qualContr('01000000009900000012199').idquapro := 3;
    qualContr('01000000724510000012228').cdcooper := 10;qualContr('01000000724510000012228').nrdconta := 72451;qualContr('01000000724510000012228').nrctremp := 12228;qualContr('01000000724510000012228').idquapro := 3;
    qualContr('01000000406810000012249').cdcooper := 10;qualContr('01000000406810000012249').nrdconta := 40681;qualContr('01000000406810000012249').nrctremp := 12249;qualContr('01000000406810000012249').idquapro := 3;
    qualContr('01000000754000000012332').cdcooper := 10;qualContr('01000000754000000012332').nrdconta := 75400;qualContr('01000000754000000012332').nrctremp := 12332;qualContr('01000000754000000012332').idquapro := 3;
    qualContr('01000000717300000012355').cdcooper := 10;qualContr('01000000717300000012355').nrdconta := 71730;qualContr('01000000717300000012355').nrctremp := 12355;qualContr('01000000717300000012355').idquapro := 3;
    qualContr('01000000461400000012337').cdcooper := 10;qualContr('01000000461400000012337').nrdconta := 46140;qualContr('01000000461400000012337').nrctremp := 12337;qualContr('01000000461400000012337').idquapro := 3;
    qualContr('01000000662650000012386').cdcooper := 10;qualContr('01000000662650000012386').nrdconta := 66265;qualContr('01000000662650000012386').nrctremp := 12386;qualContr('01000000662650000012386').idquapro := 3;
    qualContr('01000000346300000012408').cdcooper := 10;qualContr('01000000346300000012408').nrdconta := 34630;qualContr('01000000346300000012408').nrctremp := 12408;qualContr('01000000346300000012408').idquapro := 3;
    qualContr('01000000137490000012458').cdcooper := 10;qualContr('01000000137490000012458').nrdconta := 13749;qualContr('01000000137490000012458').nrctremp := 12458;qualContr('01000000137490000012458').idquapro := 3;
    qualContr('01000000078460000012483').cdcooper := 10;qualContr('01000000078460000012483').nrdconta := 7846;qualContr('01000000078460000012483').nrctremp := 12483;qualContr('01000000078460000012483').idquapro := 3;
    qualContr('01000000414670000012551').cdcooper := 10;qualContr('01000000414670000012551').nrdconta := 41467;qualContr('01000000414670000012551').nrctremp := 12551;qualContr('01000000414670000012551').idquapro := 3;
    qualContr('01000000660010000012629').cdcooper := 10;qualContr('01000000660010000012629').nrdconta := 66001;qualContr('01000000660010000012629').nrctremp := 12629;qualContr('01000000660010000012629').idquapro := 4;
    qualContr('01000001156140000013161').cdcooper := 10;qualContr('01000001156140000013161').nrdconta := 115614;qualContr('01000001156140000013161').nrctremp := 13161;qualContr('01000001156140000013161').idquapro := 3;
    qualContr('01100002939970000041641').cdcooper := 11;qualContr('01100002939970000041641').nrdconta := 293997;qualContr('01100002939970000041641').nrctremp := 41641;qualContr('01100002939970000041641').idquapro := 4;
    qualContr('01100003821080000042719').cdcooper := 11;qualContr('01100003821080000042719').nrdconta := 382108;qualContr('01100003821080000042719').nrctremp := 42719;qualContr('01100003821080000042719').idquapro := 3;
    qualContr('01100003692680000043869').cdcooper := 11;qualContr('01100003692680000043869').nrdconta := 369268;qualContr('01100003692680000043869').nrctremp := 43869;qualContr('01100003692680000043869').idquapro := 3;
    qualContr('01100001446220000045713').cdcooper := 11;qualContr('01100001446220000045713').nrdconta := 144622;qualContr('01100001446220000045713').nrctremp := 45713;qualContr('01100001446220000045713').idquapro := 4;
    qualContr('01100002078020000046689').cdcooper := 11;qualContr('01100002078020000046689').nrdconta := 207802;qualContr('01100002078020000046689').nrctremp := 46689;qualContr('01100002078020000046689').idquapro := 3;
    qualContr('01100001493300000046696').cdcooper := 11;qualContr('01100001493300000046696').nrdconta := 149330;qualContr('01100001493300000046696').nrctremp := 46696;qualContr('01100001493300000046696').idquapro := 3;
    qualContr('01100003916970000053673').cdcooper := 11;qualContr('01100003916970000053673').nrdconta := 391697;qualContr('01100003916970000053673').nrctremp := 53673;qualContr('01100003916970000053673').idquapro := 3;
    qualContr('01100003418780000054242').cdcooper := 11;qualContr('01100003418780000054242').nrdconta := 341878;qualContr('01100003418780000054242').nrctremp := 54242;qualContr('01100003418780000054242').idquapro := 3;
    qualContr('01100002888450000056876').cdcooper := 11;qualContr('01100002888450000056876').nrdconta := 288845;qualContr('01100002888450000056876').nrctremp := 56876;qualContr('01100002888450000056876').idquapro := 3;
    qualContr('01100002942920000057057').cdcooper := 11;qualContr('01100002942920000057057').nrdconta := 294292;qualContr('01100002942920000057057').nrctremp := 57057;qualContr('01100002942920000057057').idquapro := 3;
    qualContr('01100004240050000057412').cdcooper := 11;qualContr('01100004240050000057412').nrdconta := 424005;qualContr('01100004240050000057412').nrctremp := 57412;qualContr('01100004240050000057412').idquapro := 3;
    qualContr('01100000776900000057385').cdcooper := 11;qualContr('01100000776900000057385').nrdconta := 77690;qualContr('01100000776900000057385').nrctremp := 57385;qualContr('01100000776900000057385').idquapro := 3;
    qualContr('01100000574950000057817').cdcooper := 11;qualContr('01100000574950000057817').nrdconta := 57495;qualContr('01100000574950000057817').nrctremp := 57817;qualContr('01100000574950000057817').idquapro := 3;
    qualContr('01100002727870000057897').cdcooper := 11;qualContr('01100002727870000057897').nrdconta := 272787;qualContr('01100002727870000057897').nrctremp := 57897;qualContr('01100002727870000057897').idquapro := 3;
    qualContr('01100002727870000057924').cdcooper := 11;qualContr('01100002727870000057924').nrdconta := 272787;qualContr('01100002727870000057924').nrctremp := 57924;qualContr('01100002727870000057924').idquapro := 3;
    qualContr('01100003898460000058313').cdcooper := 11;qualContr('01100003898460000058313').nrdconta := 389846;qualContr('01100003898460000058313').nrctremp := 58313;qualContr('01100003898460000058313').idquapro := 3;
    qualContr('01100002364110000059044').cdcooper := 11;qualContr('01100002364110000059044').nrdconta := 236411;qualContr('01100002364110000059044').nrctremp := 59044;qualContr('01100002364110000059044').idquapro := 3;
    qualContr('01100002784160000059292').cdcooper := 11;qualContr('01100002784160000059292').nrdconta := 278416;qualContr('01100002784160000059292').nrctremp := 59292;qualContr('01100002784160000059292').idquapro := 3;
    qualContr('01100001781010000059543').cdcooper := 11;qualContr('01100001781010000059543').nrdconta := 178101;qualContr('01100001781010000059543').nrctremp := 59543;qualContr('01100001781010000059543').idquapro := 4;
    qualContr('01100003514900000059612').cdcooper := 11;qualContr('01100003514900000059612').nrdconta := 351490;qualContr('01100003514900000059612').nrctremp := 59612;qualContr('01100003514900000059612').idquapro := 3;
    qualContr('01100003301160000059992').cdcooper := 11;qualContr('01100003301160000059992').nrdconta := 330116;qualContr('01100003301160000059992').nrctremp := 59992;qualContr('01100003301160000059992').idquapro := 3;
    qualContr('01100003043010000061141').cdcooper := 11;qualContr('01100003043010000061141').nrdconta := 304301;qualContr('01100003043010000061141').nrctremp := 61141;qualContr('01100003043010000061141').idquapro := 3;
    qualContr('01100000491070000061389').cdcooper := 11;qualContr('01100000491070000061389').nrdconta := 49107;qualContr('01100000491070000061389').nrctremp := 61389;qualContr('01100000491070000061389').idquapro := 3;
    qualContr('01100003966050000061774').cdcooper := 11;qualContr('01100003966050000061774').nrdconta := 396605;qualContr('01100003966050000061774').nrctremp := 61774;qualContr('01100003966050000061774').idquapro := 3;
    qualContr('01100004991610000061893').cdcooper := 11;qualContr('01100004991610000061893').nrdconta := 499161;qualContr('01100004991610000061893').nrctremp := 61893;qualContr('01100004991610000061893').idquapro := 3;
    qualContr('01100001739400000062219').cdcooper := 11;qualContr('01100001739400000062219').nrdconta := 173940;qualContr('01100001739400000062219').nrctremp := 62219;qualContr('01100001739400000062219').idquapro := 3;
    qualContr('01100000038400000062375').cdcooper := 11;qualContr('01100000038400000062375').nrdconta := 3840;qualContr('01100000038400000062375').nrctremp := 62375;qualContr('01100000038400000062375').idquapro := 3;
    qualContr('01100004075000000062489').cdcooper := 11;qualContr('01100004075000000062489').nrdconta := 407500;qualContr('01100004075000000062489').nrctremp := 62489;qualContr('01100004075000000062489').idquapro := 3;
    qualContr('01100003454150000062678').cdcooper := 11;qualContr('01100003454150000062678').nrdconta := 345415;qualContr('01100003454150000062678').nrctremp := 62678;qualContr('01100003454150000062678').idquapro := 3;
    qualContr('01100004098120000063893').cdcooper := 11;qualContr('01100004098120000063893').nrdconta := 409812;qualContr('01100004098120000063893').nrctremp := 63893;qualContr('01100004098120000063893').idquapro := 3;
    qualContr('01100000333830000063935').cdcooper := 11;qualContr('01100000333830000063935').nrdconta := 33383;qualContr('01100000333830000063935').nrctremp := 63935;qualContr('01100000333830000063935').idquapro := 3;
    qualContr('01100005330920000065549').cdcooper := 11;qualContr('01100005330920000065549').nrdconta := 533092;qualContr('01100005330920000065549').nrctremp := 65549;qualContr('01100005330920000065549').idquapro := 3;
    qualContr('01100002852260000065862').cdcooper := 11;qualContr('01100002852260000065862').nrdconta := 285226;qualContr('01100002852260000065862').nrctremp := 65862;qualContr('01100002852260000065862').idquapro := 3;
    qualContr('01100000967840000066186').cdcooper := 11;qualContr('01100000967840000066186').nrdconta := 96784;qualContr('01100000967840000066186').nrctremp := 66186;qualContr('01100000967840000066186').idquapro := 3;
    qualContr('01100003379600000066973').cdcooper := 11;qualContr('01100003379600000066973').nrdconta := 337960;qualContr('01100003379600000066973').nrctremp := 66973;qualContr('01100003379600000066973').idquapro := 3;
    qualContr('01100005431360000068652').cdcooper := 11;qualContr('01100005431360000068652').nrdconta := 543136;qualContr('01100005431360000068652').nrctremp := 68652;qualContr('01100005431360000068652').idquapro := 3;
    qualContr('01100003516870000068735').cdcooper := 11;qualContr('01100003516870000068735').nrdconta := 351687;qualContr('01100003516870000068735').nrctremp := 68735;qualContr('01100003516870000068735').idquapro := 3;
    qualContr('01100005011740000068794').cdcooper := 11;qualContr('01100005011740000068794').nrdconta := 501174;qualContr('01100005011740000068794').nrctremp := 68794;qualContr('01100005011740000068794').idquapro := 3;
    qualContr('01100000699810000068849').cdcooper := 11;qualContr('01100000699810000068849').nrdconta := 69981;qualContr('01100000699810000068849').nrctremp := 68849;qualContr('01100000699810000068849').idquapro := 3;
    qualContr('01100000271460000068996').cdcooper := 11;qualContr('01100000271460000068996').nrdconta := 27146;qualContr('01100000271460000068996').nrctremp := 68996;qualContr('01100000271460000068996').idquapro := 3;
    qualContr('01100002018800000069347').cdcooper := 11;qualContr('01100002018800000069347').nrdconta := 201880;qualContr('01100002018800000069347').nrctremp := 69347;qualContr('01100002018800000069347').idquapro := 4;
    qualContr('01100002452320000069380').cdcooper := 11;qualContr('01100002452320000069380').nrdconta := 245232;qualContr('01100002452320000069380').nrctremp := 69380;qualContr('01100002452320000069380').idquapro := 3;
    qualContr('01100005089340000069467').cdcooper := 11;qualContr('01100005089340000069467').nrdconta := 508934;qualContr('01100005089340000069467').nrctremp := 69467;qualContr('01100005089340000069467').idquapro := 3;
    qualContr('01100004972820000069575').cdcooper := 11;qualContr('01100004972820000069575').nrdconta := 497282;qualContr('01100004972820000069575').nrctremp := 69575;qualContr('01100004972820000069575').idquapro := 3;
    qualContr('01100001812180000069544').cdcooper := 11;qualContr('01100001812180000069544').nrdconta := 181218;qualContr('01100001812180000069544').nrctremp := 69544;qualContr('01100001812180000069544').idquapro := 3;
    qualContr('01100003447880000070050').cdcooper := 11;qualContr('01100003447880000070050').nrdconta := 344788;qualContr('01100003447880000070050').nrctremp := 70050;qualContr('01100003447880000070050').idquapro := 4;
    qualContr('01100003851400000070191').cdcooper := 11;qualContr('01100003851400000070191').nrdconta := 385140;qualContr('01100003851400000070191').nrctremp := 70191;qualContr('01100003851400000070191').idquapro := 4;
    qualContr('01100002101880000071042').cdcooper := 11;qualContr('01100002101880000071042').nrdconta := 210188;qualContr('01100002101880000071042').nrctremp := 71042;qualContr('01100002101880000071042').idquapro := 4;
    qualContr('01100005532710000071430').cdcooper := 11;qualContr('01100005532710000071430').nrdconta := 553271;qualContr('01100005532710000071430').nrctremp := 71430;qualContr('01100005532710000071430').idquapro := 4;
    qualContr('01100005086320000071561').cdcooper := 11;qualContr('01100005086320000071561').nrdconta := 508632;qualContr('01100005086320000071561').nrctremp := 71561;qualContr('01100005086320000071561').idquapro := 4;
    qualContr('01100003541120000071548').cdcooper := 11;qualContr('01100003541120000071548').nrdconta := 354112;qualContr('01100003541120000071548').nrctremp := 71548;qualContr('01100003541120000071548').idquapro := 3;
    qualContr('01100002302940000072686').cdcooper := 11;qualContr('01100002302940000072686').nrdconta := 230294;qualContr('01100002302940000072686').nrctremp := 72686;qualContr('01100002302940000072686').idquapro := 3;
    qualContr('01100005117650000072699').cdcooper := 11;qualContr('01100005117650000072699').nrdconta := 511765;qualContr('01100005117650000072699').nrctremp := 72699;qualContr('01100005117650000072699').idquapro := 3;
    qualContr('01100005920720000073782').cdcooper := 11;qualContr('01100005920720000073782').nrdconta := 592072;qualContr('01100005920720000073782').nrctremp := 73782;qualContr('01100005920720000073782').idquapro := 3;
    qualContr('01100000421610000074314').cdcooper := 11;qualContr('01100000421610000074314').nrdconta := 42161;qualContr('01100000421610000074314').nrctremp := 74314;qualContr('01100000421610000074314').idquapro := 3;
    qualContr('01100001800170000074554').cdcooper := 11;qualContr('01100001800170000074554').nrdconta := 180017;qualContr('01100001800170000074554').nrctremp := 74554;qualContr('01100001800170000074554').idquapro := 3;
    qualContr('01100005213370000075110').cdcooper := 11;qualContr('01100005213370000075110').nrdconta := 521337;qualContr('01100005213370000075110').nrctremp := 75110;qualContr('01100005213370000075110').idquapro := 3;
    qualContr('01100003741130000075197').cdcooper := 11;qualContr('01100003741130000075197').nrdconta := 374113;qualContr('01100003741130000075197').nrctremp := 75197;qualContr('01100003741130000075197').idquapro := 3;
    qualContr('01100001058800000075457').cdcooper := 11;qualContr('01100001058800000075457').nrdconta := 105880;qualContr('01100001058800000075457').nrctremp := 75457;qualContr('01100001058800000075457').idquapro := 3;
    qualContr('01100005474920000075354').cdcooper := 11;qualContr('01100005474920000075354').nrdconta := 547492;qualContr('01100005474920000075354').nrctremp := 75354;qualContr('01100005474920000075354').idquapro := 4;
    qualContr('01100002644400000075367').cdcooper := 11;qualContr('01100002644400000075367').nrdconta := 264440;qualContr('01100002644400000075367').nrctremp := 75367;qualContr('01100002644400000075367').idquapro := 3;
    qualContr('01100003389310000075717').cdcooper := 11;qualContr('01100003389310000075717').nrdconta := 338931;qualContr('01100003389310000075717').nrctremp := 75717;qualContr('01100003389310000075717').idquapro := 3;
    qualContr('01100004961620000076171').cdcooper := 11;qualContr('01100004961620000076171').nrdconta := 496162;qualContr('01100004961620000076171').nrctremp := 76171;qualContr('01100004961620000076171').idquapro := 3;
    qualContr('01100000548600000076140').cdcooper := 11;qualContr('01100000548600000076140').nrdconta := 54860;qualContr('01100000548600000076140').nrctremp := 76140;qualContr('01100000548600000076140').idquapro := 3;
    qualContr('01100003777750000076314').cdcooper := 11;qualContr('01100003777750000076314').nrdconta := 377775;qualContr('01100003777750000076314').nrctremp := 76314;qualContr('01100003777750000076314').idquapro := 3;
    qualContr('01100005495090000076594').cdcooper := 11;qualContr('01100005495090000076594').nrdconta := 549509;qualContr('01100005495090000076594').nrctremp := 76594;qualContr('01100005495090000076594').idquapro := 3;
    qualContr('01100003488300000076721').cdcooper := 11;qualContr('01100003488300000076721').nrdconta := 348830;qualContr('01100003488300000076721').nrctremp := 76721;qualContr('01100003488300000076721').idquapro := 3;
    qualContr('01100003860650000076833').cdcooper := 11;qualContr('01100003860650000076833').nrdconta := 386065;qualContr('01100003860650000076833').nrctremp := 76833;qualContr('01100003860650000076833').idquapro := 4;
    qualContr('01100003250740000076970').cdcooper := 11;qualContr('01100003250740000076970').nrdconta := 325074;qualContr('01100003250740000076970').nrctremp := 76970;qualContr('01100003250740000076970').idquapro := 4;
    qualContr('01100005142680000077153').cdcooper := 11;qualContr('01100005142680000077153').nrdconta := 514268;qualContr('01100005142680000077153').nrctremp := 77153;qualContr('01100005142680000077153').idquapro := 3;
    qualContr('01100000281180000077146').cdcooper := 11;qualContr('01100000281180000077146').nrdconta := 28118;qualContr('01100000281180000077146').nrctremp := 77146;qualContr('01100000281180000077146').idquapro := 3;
    qualContr('01100004498220000077099').cdcooper := 11;qualContr('01100004498220000077099').nrdconta := 449822;qualContr('01100004498220000077099').nrctremp := 77099;qualContr('01100004498220000077099').idquapro := 3;
    qualContr('01100003503110000077268').cdcooper := 11;qualContr('01100003503110000077268').nrdconta := 350311;qualContr('01100003503110000077268').nrctremp := 77268;qualContr('01100003503110000077268').idquapro := 3;
    qualContr('01100005505580000077491').cdcooper := 11;qualContr('01100005505580000077491').nrdconta := 550558;qualContr('01100005505580000077491').nrctremp := 77491;qualContr('01100005505580000077491').idquapro := 3;
    qualContr('01100001443040000077668').cdcooper := 11;qualContr('01100001443040000077668').nrdconta := 144304;qualContr('01100001443040000077668').nrctremp := 77668;qualContr('01100001443040000077668').idquapro := 3;
    qualContr('01100005048740000077617').cdcooper := 11;qualContr('01100005048740000077617').nrdconta := 504874;qualContr('01100005048740000077617').nrctremp := 77617;qualContr('01100005048740000077617').idquapro := 3;
    qualContr('01100003874950000077713').cdcooper := 11;qualContr('01100003874950000077713').nrdconta := 387495;qualContr('01100003874950000077713').nrctremp := 77713;qualContr('01100003874950000077713').idquapro := 3;
    qualContr('01100000742920000077683').cdcooper := 11;qualContr('01100000742920000077683').nrdconta := 74292;qualContr('01100000742920000077683').nrctremp := 77683;qualContr('01100000742920000077683').idquapro := 4;
    qualContr('01100004953280000077972').cdcooper := 11;qualContr('01100004953280000077972').nrdconta := 495328;qualContr('01100004953280000077972').nrctremp := 77972;qualContr('01100004953280000077972').idquapro := 4;
    qualContr('01100006137970000078117').cdcooper := 11;qualContr('01100006137970000078117').nrdconta := 613797;qualContr('01100006137970000078117').nrctremp := 78117;qualContr('01100006137970000078117').idquapro := 3;
    qualContr('01100000059590000078201').cdcooper := 11;qualContr('01100000059590000078201').nrdconta := 5959;qualContr('01100000059590000078201').nrctremp := 78201;qualContr('01100000059590000078201').idquapro := 4;
    qualContr('01100002851290000078761').cdcooper := 11;qualContr('01100002851290000078761').nrdconta := 285129;qualContr('01100002851290000078761').nrctremp := 78761;qualContr('01100002851290000078761').idquapro := 3;
    qualContr('01100003680910000078784').cdcooper := 11;qualContr('01100003680910000078784').nrdconta := 368091;qualContr('01100003680910000078784').nrctremp := 78784;qualContr('01100003680910000078784').idquapro := 4;
    qualContr('01100003680910000078787').cdcooper := 11;qualContr('01100003680910000078787').nrdconta := 368091;qualContr('01100003680910000078787').nrctremp := 78787;qualContr('01100003680910000078787').idquapro := 4;
    qualContr('01100005675150000078930').cdcooper := 11;qualContr('01100005675150000078930').nrdconta := 567515;qualContr('01100005675150000078930').nrctremp := 78930;qualContr('01100005675150000078930').idquapro := 3;
    qualContr('01100001417040000078964').cdcooper := 11;qualContr('01100001417040000078964').nrdconta := 141704;qualContr('01100001417040000078964').nrctremp := 78964;qualContr('01100001417040000078964').idquapro := 3;
    qualContr('01100005639510000080187').cdcooper := 11;qualContr('01100005639510000080187').nrdconta := 563951;qualContr('01100005639510000080187').nrctremp := 80187;qualContr('01100005639510000080187').idquapro := 4;
    qualContr('01100002861330000080499').cdcooper := 11;qualContr('01100002861330000080499').nrdconta := 286133;qualContr('01100002861330000080499').nrctremp := 80499;qualContr('01100002861330000080499').idquapro := 3;
    qualContr('01100003858910000080724').cdcooper := 11;qualContr('01100003858910000080724').nrdconta := 385891;qualContr('01100003858910000080724').nrctremp := 80724;qualContr('01100003858910000080724').idquapro := 3;
    qualContr('01100003602100000081262').cdcooper := 11;qualContr('01100003602100000081262').nrdconta := 360210;qualContr('01100003602100000081262').nrctremp := 81262;qualContr('01100003602100000081262').idquapro := 3;
    qualContr('01200000601430000013989').cdcooper := 12;qualContr('01200000601430000013989').nrdconta := 60143;qualContr('01200000601430000013989').nrctremp := 13989;qualContr('01200000601430000013989').idquapro := 3;
    qualContr('01200000181120000014925').cdcooper := 12;qualContr('01200000181120000014925').nrdconta := 18112;qualContr('01200000181120000014925').nrctremp := 14925;qualContr('01200000181120000014925').idquapro := 3;
    qualContr('01200001361400000018448').cdcooper := 12;qualContr('01200001361400000018448').nrdconta := 136140;qualContr('01200001361400000018448').nrctremp := 18448;qualContr('01200001361400000018448').idquapro := 4;
    qualContr('01200000568710000019192').cdcooper := 12;qualContr('01200000568710000019192').nrdconta := 56871;qualContr('01200000568710000019192').nrctremp := 19192;qualContr('01200000568710000019192').idquapro := 3;
    qualContr('01200000038750000019253').cdcooper := 12;qualContr('01200000038750000019253').nrdconta := 3875;qualContr('01200000038750000019253').nrctremp := 19253;qualContr('01200000038750000019253').idquapro := 3;
    qualContr('01200001409450000020796').cdcooper := 12;qualContr('01200001409450000020796').nrdconta := 140945;qualContr('01200001409450000020796').nrctremp := 20796;qualContr('01200001409450000020796').idquapro := 3;
    qualContr('01200000390200000021208').cdcooper := 12;qualContr('01200000390200000021208').nrdconta := 39020;qualContr('01200000390200000021208').nrctremp := 21208;qualContr('01200000390200000021208').idquapro := 3;
    qualContr('01300000548950000031783').cdcooper := 13;qualContr('01300000548950000031783').nrdconta := 54895;qualContr('01300000548950000031783').nrctremp := 31783;qualContr('01300000548950000031783').idquapro := 3;
    qualContr('01300002413500000034686').cdcooper := 13;qualContr('01300002413500000034686').nrdconta := 241350;qualContr('01300002413500000034686').nrctremp := 34686;qualContr('01300002413500000034686').idquapro := 3;
    qualContr('01300001672310000038091').cdcooper := 13;qualContr('01300001672310000038091').nrdconta := 167231;qualContr('01300001672310000038091').nrctremp := 38091;qualContr('01300001672310000038091').idquapro := 3;
    qualContr('01300002587330000038987').cdcooper := 13;qualContr('01300002587330000038987').nrdconta := 258733;qualContr('01300002587330000038987').nrctremp := 38987;qualContr('01300002587330000038987').idquapro := 3;
    qualContr('01300007088870000039396').cdcooper := 13;qualContr('01300007088870000039396').nrdconta := 708887;qualContr('01300007088870000039396').nrctremp := 39396;qualContr('01300007088870000039396').idquapro := 3;
    qualContr('01300002392910000040853').cdcooper := 13;qualContr('01300002392910000040853').nrdconta := 239291;qualContr('01300002392910000040853').nrctremp := 40853;qualContr('01300002392910000040853').idquapro := 3;
    qualContr('01300001806100000042596').cdcooper := 13;qualContr('01300001806100000042596').nrdconta := 180610;qualContr('01300001806100000042596').nrctremp := 42596;qualContr('01300001806100000042596').idquapro := 3;
    qualContr('01300002065040000043255').cdcooper := 13;qualContr('01300002065040000043255').nrdconta := 206504;qualContr('01300002065040000043255').nrctremp := 43255;qualContr('01300002065040000043255').idquapro := 3;
    qualContr('01300001240010000043442').cdcooper := 13;qualContr('01300001240010000043442').nrdconta := 124001;qualContr('01300001240010000043442').nrctremp := 43442;qualContr('01300001240010000043442').idquapro := 3;
    qualContr('01300002114000000044050').cdcooper := 13;qualContr('01300002114000000044050').nrdconta := 211400;qualContr('01300002114000000044050').nrctremp := 44050;qualContr('01300002114000000044050').idquapro := 3;
    qualContr('01300002295710000045446').cdcooper := 13;qualContr('01300002295710000045446').nrdconta := 229571;qualContr('01300002295710000045446').nrctremp := 45446;qualContr('01300002295710000045446').idquapro := 3;
    qualContr('01300002734730000045454').cdcooper := 13;qualContr('01300002734730000045454').nrdconta := 273473;qualContr('01300002734730000045454').nrctremp := 45454;qualContr('01300002734730000045454').idquapro := 3;
    qualContr('01300003160160000045423').cdcooper := 13;qualContr('01300003160160000045423').nrdconta := 316016;qualContr('01300003160160000045423').nrctremp := 45423;qualContr('01300003160160000045423').idquapro := 3;
    qualContr('01300000231750000046601').cdcooper := 13;qualContr('01300000231750000046601').nrdconta := 23175;qualContr('01300000231750000046601').nrctremp := 46601;qualContr('01300000231750000046601').idquapro := 3;
    qualContr('01300000331890000046737').cdcooper := 13;qualContr('01300000331890000046737').nrdconta := 33189;qualContr('01300000331890000046737').nrctremp := 46737;qualContr('01300000331890000046737').idquapro := 3;
    qualContr('01300000519500000047483').cdcooper := 13;qualContr('01300000519500000047483').nrdconta := 51950;qualContr('01300000519500000047483').nrctremp := 47483;qualContr('01300000519500000047483').idquapro := 3;
    qualContr('01300001655730000047639').cdcooper := 13;qualContr('01300001655730000047639').nrdconta := 165573;qualContr('01300001655730000047639').nrctremp := 47639;qualContr('01300001655730000047639').idquapro := 3;
    qualContr('01300001622800000047637').cdcooper := 13;qualContr('01300001622800000047637').nrdconta := 162280;qualContr('01300001622800000047637').nrctremp := 47637;qualContr('01300001622800000047637').idquapro := 3;
    qualContr('01300002760490000048561').cdcooper := 13;qualContr('01300002760490000048561').nrdconta := 276049;qualContr('01300002760490000048561').nrctremp := 48561;qualContr('01300002760490000048561').idquapro := 3;
    qualContr('01300002751150000048831').cdcooper := 13;qualContr('01300002751150000048831').nrdconta := 275115;qualContr('01300002751150000048831').nrctremp := 48831;qualContr('01300002751150000048831').idquapro := 3;
    qualContr('01300003351260000048960').cdcooper := 13;qualContr('01300003351260000048960').nrdconta := 335126;qualContr('01300003351260000048960').nrctremp := 48960;qualContr('01300003351260000048960').idquapro := 3;
    qualContr('01300000410500000049615').cdcooper := 13;qualContr('01300000410500000049615').nrdconta := 41050;qualContr('01300000410500000049615').nrctremp := 49615;qualContr('01300000410500000049615').idquapro := 3;
    qualContr('01300004097400000049738').cdcooper := 13;qualContr('01300004097400000049738').nrdconta := 409740;qualContr('01300004097400000049738').nrctremp := 49738;qualContr('01300004097400000049738').idquapro := 3;
    qualContr('01300003248760000050428').cdcooper := 13;qualContr('01300003248760000050428').nrdconta := 324876;qualContr('01300003248760000050428').nrctremp := 50428;qualContr('01300003248760000050428').idquapro := 3;
    qualContr('01300000571930000050892').cdcooper := 13;qualContr('01300000571930000050892').nrdconta := 57193;qualContr('01300000571930000050892').nrctremp := 50892;qualContr('01300000571930000050892').idquapro := 3;
    qualContr('01300003277000000051115').cdcooper := 13;qualContr('01300003277000000051115').nrdconta := 327700;qualContr('01300003277000000051115').nrctremp := 51115;qualContr('01300003277000000051115').idquapro := 3;
    qualContr('01300001590690000052136').cdcooper := 13;qualContr('01300001590690000052136').nrdconta := 159069;qualContr('01300001590690000052136').nrctremp := 52136;qualContr('01300001590690000052136').idquapro := 3;
    qualContr('01300002848660000053175').cdcooper := 13;qualContr('01300002848660000053175').nrdconta := 284866;qualContr('01300002848660000053175').nrctremp := 53175;qualContr('01300002848660000053175').idquapro := 3;
    qualContr('01300000574280000053879').cdcooper := 13;qualContr('01300000574280000053879').nrdconta := 57428;qualContr('01300000574280000053879').nrctremp := 53879;qualContr('01300000574280000053879').idquapro := 3;
    qualContr('01300007031500000053911').cdcooper := 13;qualContr('01300007031500000053911').nrdconta := 703150;qualContr('01300007031500000053911').nrctremp := 53911;qualContr('01300007031500000053911').idquapro := 3;
    qualContr('01300007309800000053900').cdcooper := 13;qualContr('01300007309800000053900').nrdconta := 730980;qualContr('01300007309800000053900').nrctremp := 53900;qualContr('01300007309800000053900').idquapro := 3;
    qualContr('01300001627010000054049').cdcooper := 13;qualContr('01300001627010000054049').nrdconta := 162701;qualContr('01300001627010000054049').nrctremp := 54049;qualContr('01300001627010000054049').idquapro := 3;
    qualContr('01300002383170000054867').cdcooper := 13;qualContr('01300002383170000054867').nrdconta := 238317;qualContr('01300002383170000054867').nrctremp := 54867;qualContr('01300002383170000054867').idquapro := 3;
    qualContr('01300002898090000056324').cdcooper := 13;qualContr('01300002898090000056324').nrdconta := 289809;qualContr('01300002898090000056324').nrctremp := 56324;qualContr('01300002898090000056324').idquapro := 3;
    qualContr('01300000705640000056371').cdcooper := 13;qualContr('01300000705640000056371').nrdconta := 70564;qualContr('01300000705640000056371').nrctremp := 56371;qualContr('01300000705640000056371').idquapro := 3;
    qualContr('01300002864000000056422').cdcooper := 13;qualContr('01300002864000000056422').nrdconta := 286400;qualContr('01300002864000000056422').nrctremp := 56422;qualContr('01300002864000000056422').idquapro := 3;
    qualContr('01300002149730000056987').cdcooper := 13;qualContr('01300002149730000056987').nrdconta := 214973;qualContr('01300002149730000056987').nrctremp := 56987;qualContr('01300002149730000056987').idquapro := 3;
    qualContr('01300002041100000057684').cdcooper := 13;qualContr('01300002041100000057684').nrdconta := 204110;qualContr('01300002041100000057684').nrctremp := 57684;qualContr('01300002041100000057684').idquapro := 3;
    qualContr('01300003334330000057692').cdcooper := 13;qualContr('01300003334330000057692').nrdconta := 333433;qualContr('01300003334330000057692').nrctremp := 57692;qualContr('01300003334330000057692').idquapro := 3;
    qualContr('01300002092440000057924').cdcooper := 13;qualContr('01300002092440000057924').nrdconta := 209244;qualContr('01300002092440000057924').nrctremp := 57924;qualContr('01300002092440000057924').idquapro := 3;
    qualContr('01300000682090000057922').cdcooper := 13;qualContr('01300000682090000057922').nrdconta := 68209;qualContr('01300000682090000057922').nrctremp := 57922;qualContr('01300000682090000057922').idquapro := 3;
    qualContr('01300003477100000058264').cdcooper := 13;qualContr('01300003477100000058264').nrdconta := 347710;qualContr('01300003477100000058264').nrctremp := 58264;qualContr('01300003477100000058264').idquapro := 3;
    qualContr('01300002360800000058234').cdcooper := 13;qualContr('01300002360800000058234').nrdconta := 236080;qualContr('01300002360800000058234').nrctremp := 58234;qualContr('01300002360800000058234').idquapro := 3;
    qualContr('01300003543170000058561').cdcooper := 13;qualContr('01300003543170000058561').nrdconta := 354317;qualContr('01300003543170000058561').nrctremp := 58561;qualContr('01300003543170000058561').idquapro := 3;
    qualContr('01300003209600000058662').cdcooper := 13;qualContr('01300003209600000058662').nrdconta := 320960;qualContr('01300003209600000058662').nrctremp := 58662;qualContr('01300003209600000058662').idquapro := 3;
    qualContr('01300002504300000058669').cdcooper := 13;qualContr('01300002504300000058669').nrdconta := 250430;qualContr('01300002504300000058669').nrctremp := 58669;qualContr('01300002504300000058669').idquapro := 3;
    qualContr('01300003338910000059186').cdcooper := 13;qualContr('01300003338910000059186').nrdconta := 333891;qualContr('01300003338910000059186').nrctremp := 59186;qualContr('01300003338910000059186').idquapro := 3;
    qualContr('01300001517850000059222').cdcooper := 13;qualContr('01300001517850000059222').nrdconta := 151785;qualContr('01300001517850000059222').nrctremp := 59222;qualContr('01300001517850000059222').idquapro := 3;
    qualContr('01300003633160000059307').cdcooper := 13;qualContr('01300003633160000059307').nrdconta := 363316;qualContr('01300003633160000059307').nrctremp := 59307;qualContr('01300003633160000059307').idquapro := 3;
    qualContr('01300001949720000059282').cdcooper := 13;qualContr('01300001949720000059282').nrdconta := 194972;qualContr('01300001949720000059282').nrctremp := 59282;qualContr('01300001949720000059282').idquapro := 3;
    qualContr('01300001992220000060178').cdcooper := 13;qualContr('01300001992220000060178').nrdconta := 199222;qualContr('01300001992220000060178').nrctremp := 60178;qualContr('01300001992220000060178').idquapro := 3;
    qualContr('01300000120090000060358').cdcooper := 13;qualContr('01300000120090000060358').nrdconta := 12009;qualContr('01300000120090000060358').nrctremp := 60358;qualContr('01300000120090000060358').idquapro := 3;
    qualContr('01300001529350000060495').cdcooper := 13;qualContr('01300001529350000060495').nrdconta := 152935;qualContr('01300001529350000060495').nrctremp := 60495;qualContr('01300001529350000060495').idquapro := 3;
    qualContr('01300003435280000060460').cdcooper := 13;qualContr('01300003435280000060460').nrdconta := 343528;qualContr('01300003435280000060460').nrctremp := 60460;qualContr('01300003435280000060460').idquapro := 3;
    qualContr('01300001610710000060479').cdcooper := 13;qualContr('01300001610710000060479').nrdconta := 161071;qualContr('01300001610710000060479').nrctremp := 60479;qualContr('01300001610710000060479').idquapro := 3;
    qualContr('01300001189900000060616').cdcooper := 13;qualContr('01300001189900000060616').nrdconta := 118990;qualContr('01300001189900000060616').nrctremp := 60616;qualContr('01300001189900000060616').idquapro := 3;
    qualContr('01300003029610000060833').cdcooper := 13;qualContr('01300003029610000060833').nrdconta := 302961;qualContr('01300003029610000060833').nrctremp := 60833;qualContr('01300003029610000060833').idquapro := 3;
    qualContr('01300002223640000060878').cdcooper := 13;qualContr('01300002223640000060878').nrdconta := 222364;qualContr('01300002223640000060878').nrctremp := 60878;qualContr('01300002223640000060878').idquapro := 3;
    qualContr('01300001669950000061075').cdcooper := 13;qualContr('01300001669950000061075').nrdconta := 166995;qualContr('01300001669950000061075').nrctremp := 61075;qualContr('01300001669950000061075').idquapro := 3;
    qualContr('01300002820810000061369').cdcooper := 13;qualContr('01300002820810000061369').nrdconta := 282081;qualContr('01300002820810000061369').nrctremp := 61369;qualContr('01300002820810000061369').idquapro := 3;
    qualContr('01300002238160000061432').cdcooper := 13;qualContr('01300002238160000061432').nrdconta := 223816;qualContr('01300002238160000061432').nrctremp := 61432;qualContr('01300002238160000061432').idquapro := 3;
    qualContr('01300003007130000061565').cdcooper := 13;qualContr('01300003007130000061565').nrdconta := 300713;qualContr('01300003007130000061565').nrctremp := 61565;qualContr('01300003007130000061565').idquapro := 3;
    qualContr('01300003190900000061647').cdcooper := 13;qualContr('01300003190900000061647').nrdconta := 319090;qualContr('01300003190900000061647').nrctremp := 61647;qualContr('01300003190900000061647').idquapro := 3;
    qualContr('01300003791230000061798').cdcooper := 13;qualContr('01300003791230000061798').nrdconta := 379123;qualContr('01300003791230000061798').nrctremp := 61798;qualContr('01300003791230000061798').idquapro := 3;
    qualContr('01300002609240000062373').cdcooper := 13;qualContr('01300002609240000062373').nrdconta := 260924;qualContr('01300002609240000062373').nrctremp := 62373;qualContr('01300002609240000062373').idquapro := 3;
    qualContr('01300001705770000063322').cdcooper := 13;qualContr('01300001705770000063322').nrdconta := 170577;qualContr('01300001705770000063322').nrctremp := 63322;qualContr('01300001705770000063322').idquapro := 3;
    qualContr('01300003942890000063884').cdcooper := 13;qualContr('01300003942890000063884').nrdconta := 394289;qualContr('01300003942890000063884').nrctremp := 63884;qualContr('01300003942890000063884').idquapro := 3;
    qualContr('01300003280220000064332').cdcooper := 13;qualContr('01300003280220000064332').nrdconta := 328022;qualContr('01300003280220000064332').nrctremp := 64332;qualContr('01300003280220000064332').idquapro := 3;
    qualContr('01300003757990000064333').cdcooper := 13;qualContr('01300003757990000064333').nrdconta := 375799;qualContr('01300003757990000064333').nrctremp := 64333;qualContr('01300003757990000064333').idquapro := 4;
    qualContr('01300001983900000064425').cdcooper := 13;qualContr('01300001983900000064425').nrdconta := 198390;qualContr('01300001983900000064425').nrctremp := 64425;qualContr('01300001983900000064425').idquapro := 3;
    qualContr('01300001341200000064674').cdcooper := 13;qualContr('01300001341200000064674').nrdconta := 134120;qualContr('01300001341200000064674').nrctremp := 64674;qualContr('01300001341200000064674').idquapro := 3;
    qualContr('01300002472000000064597').cdcooper := 13;qualContr('01300002472000000064597').nrdconta := 247200;qualContr('01300002472000000064597').nrctremp := 64597;qualContr('01300002472000000064597').idquapro := 3;
    qualContr('01300001322170000064697').cdcooper := 13;qualContr('01300001322170000064697').nrdconta := 132217;qualContr('01300001322170000064697').nrctremp := 64697;qualContr('01300001322170000064697').idquapro := 3;
    qualContr('01300001736900000064930').cdcooper := 13;qualContr('01300001736900000064930').nrdconta := 173690;qualContr('01300001736900000064930').nrctremp := 64930;qualContr('01300001736900000064930').idquapro := 3;
    qualContr('01300001484740000065036').cdcooper := 13;qualContr('01300001484740000065036').nrdconta := 148474;qualContr('01300001484740000065036').nrctremp := 65036;qualContr('01300001484740000065036').idquapro := 3;
    qualContr('01300001796630000065062').cdcooper := 13;qualContr('01300001796630000065062').nrdconta := 179663;qualContr('01300001796630000065062').nrctremp := 65062;qualContr('01300001796630000065062').idquapro := 3;
    qualContr('01300007059180000065181').cdcooper := 13;qualContr('01300007059180000065181').nrdconta := 705918;qualContr('01300007059180000065181').nrctremp := 65181;qualContr('01300007059180000065181').idquapro := 3;
    qualContr('01300000147020000065438').cdcooper := 13;qualContr('01300000147020000065438').nrdconta := 14702;qualContr('01300000147020000065438').nrctremp := 65438;qualContr('01300000147020000065438').idquapro := 3;
    qualContr('01300000376480000065509').cdcooper := 13;qualContr('01300000376480000065509').nrdconta := 37648;qualContr('01300000376480000065509').nrctremp := 65509;qualContr('01300000376480000065509').idquapro := 3;
    qualContr('01300000783280000065685').cdcooper := 13;qualContr('01300000783280000065685').nrdconta := 78328;qualContr('01300000783280000065685').nrctremp := 65685;qualContr('01300000783280000065685').idquapro := 3;
    qualContr('01300003031780000065809').cdcooper := 13;qualContr('01300003031780000065809').nrdconta := 303178;qualContr('01300003031780000065809').nrctremp := 65809;qualContr('01300003031780000065809').idquapro := 3;
    qualContr('01300003698880000066026').cdcooper := 13;qualContr('01300003698880000066026').nrdconta := 369888;qualContr('01300003698880000066026').nrctremp := 66026;qualContr('01300003698880000066026').idquapro := 3;
    qualContr('01300001227340000065994').cdcooper := 13;qualContr('01300001227340000065994').nrdconta := 122734;qualContr('01300001227340000065994').nrctremp := 65994;qualContr('01300001227340000065994').idquapro := 3;
    qualContr('01300003556150000066313').cdcooper := 13;qualContr('01300003556150000066313').nrdconta := 355615;qualContr('01300003556150000066313').nrctremp := 66313;qualContr('01300003556150000066313').idquapro := 4;
    qualContr('01300001420000000066859').cdcooper := 13;qualContr('01300001420000000066859').nrdconta := 142000;qualContr('01300001420000000066859').nrctremp := 66859;qualContr('01300001420000000066859').idquapro := 3;
    qualContr('01300003437570000067117').cdcooper := 13;qualContr('01300003437570000067117').nrdconta := 343757;qualContr('01300003437570000067117').nrctremp := 67117;qualContr('01300003437570000067117').idquapro := 3;
    qualContr('01300002163050000067089').cdcooper := 13;qualContr('01300002163050000067089').nrdconta := 216305;qualContr('01300002163050000067089').nrctremp := 67089;qualContr('01300002163050000067089').idquapro := 3;
    qualContr('01300002848900000067211').cdcooper := 13;qualContr('01300002848900000067211').nrdconta := 284890;qualContr('01300002848900000067211').nrctremp := 67211;qualContr('01300002848900000067211').idquapro := 3;
    qualContr('01300003369470000067594').cdcooper := 13;qualContr('01300003369470000067594').nrdconta := 336947;qualContr('01300003369470000067594').nrctremp := 67594;qualContr('01300003369470000067594').idquapro := 3;
    qualContr('01300000566850000068000').cdcooper := 13;qualContr('01300000566850000068000').nrdconta := 56685;qualContr('01300000566850000068000').nrctremp := 68000;qualContr('01300000566850000068000').idquapro := 3;
    qualContr('01300001714760000067973').cdcooper := 13;qualContr('01300001714760000067973').nrdconta := 171476;qualContr('01300001714760000067973').nrctremp := 67973;qualContr('01300001714760000067973').idquapro := 3;
    qualContr('01300003842830000068191').cdcooper := 13;qualContr('01300003842830000068191').nrdconta := 384283;qualContr('01300003842830000068191').nrctremp := 68191;qualContr('01300003842830000068191').idquapro := 3;
    qualContr('01300000576140000068381').cdcooper := 13;qualContr('01300000576140000068381').nrdconta := 57614;qualContr('01300000576140000068381').nrctremp := 68381;qualContr('01300000576140000068381').idquapro := 3;
    qualContr('01300003455630000068311').cdcooper := 13;qualContr('01300003455630000068311').nrdconta := 345563;qualContr('01300003455630000068311').nrctremp := 68311;qualContr('01300003455630000068311').idquapro := 3;
    qualContr('01300000684540000068283').cdcooper := 13;qualContr('01300000684540000068283').nrdconta := 68454;qualContr('01300000684540000068283').nrctremp := 68283;qualContr('01300000684540000068283').idquapro := 3;
    qualContr('01300000382020000068542').cdcooper := 13;qualContr('01300000382020000068542').nrdconta := 38202;qualContr('01300000382020000068542').nrctremp := 68542;qualContr('01300000382020000068542').idquapro := 3;
    qualContr('01300000576140000069104').cdcooper := 13;qualContr('01300000576140000069104').nrdconta := 57614;qualContr('01300000576140000069104').nrctremp := 69104;qualContr('01300000576140000069104').idquapro := 3;
    qualContr('01300003178880000068857').cdcooper := 13;qualContr('01300003178880000068857').nrdconta := 317888;qualContr('01300003178880000068857').nrctremp := 68857;qualContr('01300003178880000068857').idquapro := 3;
    qualContr('01300002518440000068434').cdcooper := 13;qualContr('01300002518440000068434').nrdconta := 251844;qualContr('01300002518440000068434').nrctremp := 68434;qualContr('01300002518440000068434').idquapro := 3;
    qualContr('01300003694110000070090').cdcooper := 13;qualContr('01300003694110000070090').nrdconta := 369411;qualContr('01300003694110000070090').nrctremp := 70090;qualContr('01300003694110000070090').idquapro := 3;
    qualContr('01300002553190000070170').cdcooper := 13;qualContr('01300002553190000070170').nrdconta := 255319;qualContr('01300002553190000070170').nrctremp := 70170;qualContr('01300002553190000070170').idquapro := 3;
    qualContr('01300003694110000070087').cdcooper := 13;qualContr('01300003694110000070087').nrdconta := 369411;qualContr('01300003694110000070087').nrctremp := 70087;qualContr('01300003694110000070087').idquapro := 3;
    qualContr('01400000617600000008503').cdcooper := 14;qualContr('01400000617600000008503').nrdconta := 61760;qualContr('01400000617600000008503').nrctremp := 8503;qualContr('01400000617600000008503').idquapro := 3;
    qualContr('01400000153000000008984').cdcooper := 14;qualContr('01400000153000000008984').nrdconta := 15300;qualContr('01400000153000000008984').nrctremp := 8984;qualContr('01400000153000000008984').idquapro := 3;
    qualContr('01400000180820000009120').cdcooper := 14;qualContr('01400000180820000009120').nrdconta := 18082;qualContr('01400000180820000009120').nrctremp := 9120;qualContr('01400000180820000009120').idquapro := 3;
    qualContr('01400000536940000009366').cdcooper := 14;qualContr('01400000536940000009366').nrdconta := 53694;qualContr('01400000536940000009366').nrctremp := 9366;qualContr('01400000536940000009366').idquapro := 3;
    qualContr('01400000476510000009687').cdcooper := 14;qualContr('01400000476510000009687').nrdconta := 47651;qualContr('01400000476510000009687').nrctremp := 9687;qualContr('01400000476510000009687').idquapro := 4;
    qualContr('01400000645480000009802').cdcooper := 14;qualContr('01400000645480000009802').nrdconta := 64548;qualContr('01400000645480000009802').nrctremp := 9802;qualContr('01400000645480000009802').idquapro := 3;
    qualContr('01400001066150000010538').cdcooper := 14;qualContr('01400001066150000010538').nrdconta := 106615;qualContr('01400001066150000010538').nrctremp := 10538;qualContr('01400001066150000010538').idquapro := 3;
    qualContr('01400000152450000010717').cdcooper := 14;qualContr('01400000152450000010717').nrdconta := 15245;qualContr('01400000152450000010717').nrctremp := 10717;qualContr('01400000152450000010717').idquapro := 4;
    qualContr('01400001013380000011192').cdcooper := 14;qualContr('01400001013380000011192').nrdconta := 101338;qualContr('01400001013380000011192').nrctremp := 11192;qualContr('01400001013380000011192').idquapro := 3;
    qualContr('01400000403550000011413').cdcooper := 14;qualContr('01400000403550000011413').nrdconta := 40355;qualContr('01400000403550000011413').nrctremp := 11413;qualContr('01400000403550000011413').idquapro := 3;
    qualContr('01400000664860000011744').cdcooper := 14;qualContr('01400000664860000011744').nrdconta := 66486;qualContr('01400000664860000011744').nrctremp := 11744;qualContr('01400000664860000011744').idquapro := 4;
    qualContr('01400000664860000011744').cdcooper := 14;qualContr('01400000664860000011744').nrdconta := 66486;qualContr('01400000664860000011744').nrctremp := 11744;qualContr('01400000664860000011744').idquapro := 4;
    qualContr('01400000664860000011744').cdcooper := 14;qualContr('01400000664860000011744').nrdconta := 66486;qualContr('01400000664860000011744').nrctremp := 11744;qualContr('01400000664860000011744').idquapro := 4;
    qualContr('01400000664860000011744').cdcooper := 14;qualContr('01400000664860000011744').nrdconta := 66486;qualContr('01400000664860000011744').nrctremp := 11744;qualContr('01400000664860000011744').idquapro := 4;
    qualContr('01400000363310000011759').cdcooper := 14;qualContr('01400000363310000011759').nrdconta := 36331;qualContr('01400000363310000011759').nrctremp := 11759;qualContr('01400000363310000011759').idquapro := 3;
    qualContr('01400000787270000011782').cdcooper := 14;qualContr('01400000787270000011782').nrdconta := 78727;qualContr('01400000787270000011782').nrctremp := 11782;qualContr('01400000787270000011782').idquapro := 3;
    qualContr('01400000425010000011904').cdcooper := 14;qualContr('01400000425010000011904').nrdconta := 42501;qualContr('01400000425010000011904').nrctremp := 11904;qualContr('01400000425010000011904').idquapro := 3;
    qualContr('01400001063720000011896').cdcooper := 14;qualContr('01400001063720000011896').nrdconta := 106372;qualContr('01400001063720000011896').nrctremp := 11896;qualContr('01400001063720000011896').idquapro := 3;
    qualContr('01400000502700000011966').cdcooper := 14;qualContr('01400000502700000011966').nrdconta := 50270;qualContr('01400000502700000011966').nrctremp := 11966;qualContr('01400000502700000011966').idquapro := 4;
    qualContr('01400000723890000012264').cdcooper := 14;qualContr('01400000723890000012264').nrdconta := 72389;qualContr('01400000723890000012264').nrctremp := 12264;qualContr('01400000723890000012264').idquapro := 3;
    qualContr('01400001009270000012314').cdcooper := 14;qualContr('01400001009270000012314').nrdconta := 100927;qualContr('01400001009270000012314').nrctremp := 12314;qualContr('01400001009270000012314').idquapro := 3;
    qualContr('01400001171100000012346').cdcooper := 14;qualContr('01400001171100000012346').nrdconta := 117110;qualContr('01400001171100000012346').nrctremp := 12346;qualContr('01400001171100000012346').idquapro := 3;
    qualContr('01400000741280000012367').cdcooper := 14;qualContr('01400000741280000012367').nrdconta := 74128;qualContr('01400000741280000012367').nrctremp := 12367;qualContr('01400000741280000012367').idquapro := 4;
    qualContr('01400000937930000012494').cdcooper := 14;qualContr('01400000937930000012494').nrdconta := 93793;qualContr('01400000937930000012494').nrctremp := 12494;qualContr('01400000937930000012494').idquapro := 3;
    qualContr('01400000655870000012506').cdcooper := 14;qualContr('01400000655870000012506').nrdconta := 65587;qualContr('01400000655870000012506').nrctremp := 12506;qualContr('01400000655870000012506').idquapro := 4;
    qualContr('01400000625530000012522').cdcooper := 14;qualContr('01400000625530000012522').nrdconta := 62553;qualContr('01400000625530000012522').nrctremp := 12522;qualContr('01400000625530000012522').idquapro := 4;
    qualContr('01400000322120000012613').cdcooper := 14;qualContr('01400000322120000012613').nrdconta := 32212;qualContr('01400000322120000012613').nrctremp := 12613;qualContr('01400000322120000012613').idquapro := 3;
    qualContr('01400000475540000012626').cdcooper := 14;qualContr('01400000475540000012626').nrdconta := 47554;qualContr('01400000475540000012626').nrctremp := 12626;qualContr('01400000475540000012626').idquapro := 3;
    qualContr('01400000852190000012814').cdcooper := 14;qualContr('01400000852190000012814').nrdconta := 85219;qualContr('01400000852190000012814').nrctremp := 12814;qualContr('01400000852190000012814').idquapro := 3;
    qualContr('01400000699730000012956').cdcooper := 14;qualContr('01400000699730000012956').nrdconta := 69973;qualContr('01400000699730000012956').nrctremp := 12956;qualContr('01400000699730000012956').idquapro := 3;
    qualContr('01400001142600000013203').cdcooper := 14;qualContr('01400001142600000013203').nrdconta := 114260;qualContr('01400001142600000013203').nrctremp := 13203;qualContr('01400001142600000013203').idquapro := 3;
    qualContr('01400000632900000013200').cdcooper := 14;qualContr('01400000632900000013200').nrdconta := 63290;qualContr('01400000632900000013200').nrctremp := 13200;qualContr('01400000632900000013200').idquapro := 3;
    qualContr('01400000862070000013479').cdcooper := 14;qualContr('01400000862070000013479').nrdconta := 86207;qualContr('01400000862070000013479').nrctremp := 13479;qualContr('01400000862070000013479').idquapro := 3;
    qualContr('01400000944040000013544').cdcooper := 14;qualContr('01400000944040000013544').nrdconta := 94404;qualContr('01400000944040000013544').nrctremp := 13544;qualContr('01400000944040000013544').idquapro := 3;
    qualContr('01400000338630000013706').cdcooper := 14;qualContr('01400000338630000013706').nrdconta := 33863;qualContr('01400000338630000013706').nrctremp := 13706;qualContr('01400000338630000013706').idquapro := 3;
    qualContr('01400000154150000013766').cdcooper := 14;qualContr('01400000154150000013766').nrdconta := 15415;qualContr('01400000154150000013766').nrctremp := 13766;qualContr('01400000154150000013766').idquapro := 3;
    qualContr('01400000915020000013760').cdcooper := 14;qualContr('01400000915020000013760').nrdconta := 91502;qualContr('01400000915020000013760').nrctremp := 13760;qualContr('01400000915020000013760').idquapro := 3;
    qualContr('01400000811160000013808').cdcooper := 14;qualContr('01400000811160000013808').nrdconta := 81116;qualContr('01400000811160000013808').nrctremp := 13808;qualContr('01400000811160000013808').idquapro := 3;
    qualContr('01400000521240000013804').cdcooper := 14;qualContr('01400000521240000013804').nrdconta := 52124;qualContr('01400000521240000013804').nrctremp := 13804;qualContr('01400000521240000013804').idquapro := 4;
    qualContr('01400000232300000013785').cdcooper := 14;qualContr('01400000232300000013785').nrdconta := 23230;qualContr('01400000232300000013785').nrctremp := 13785;qualContr('01400000232300000013785').idquapro := 3;
    qualContr('01400000276340000013784').cdcooper := 14;qualContr('01400000276340000013784').nrdconta := 27634;qualContr('01400000276340000013784').nrctremp := 13784;qualContr('01400000276340000013784').idquapro := 4;
    qualContr('01400001217110000013834').cdcooper := 14;qualContr('01400001217110000013834').nrdconta := 121711;qualContr('01400001217110000013834').nrctremp := 13834;qualContr('01400001217110000013834').idquapro := 3;
    qualContr('01400000653310000013847').cdcooper := 14;qualContr('01400000653310000013847').nrdconta := 65331;qualContr('01400000653310000013847').nrctremp := 13847;qualContr('01400000653310000013847').idquapro := 4;
    qualContr('01400001087070000013954').cdcooper := 14;qualContr('01400001087070000013954').nrdconta := 108707;qualContr('01400001087070000013954').nrctremp := 13954;qualContr('01400001087070000013954').idquapro := 3;
    qualContr('01400000617270000013970').cdcooper := 14;qualContr('01400000617270000013970').nrdconta := 61727;qualContr('01400000617270000013970').nrctremp := 13970;qualContr('01400000617270000013970').idquapro := 3;
    qualContr('01400000864870000014098').cdcooper := 14;qualContr('01400000864870000014098').nrdconta := 86487;qualContr('01400000864870000014098').nrctremp := 14098;qualContr('01400000864870000014098').idquapro := 3;
    qualContr('01400001157700000014121').cdcooper := 14;qualContr('01400001157700000014121').nrdconta := 115770;qualContr('01400001157700000014121').nrctremp := 14121;qualContr('01400001157700000014121').idquapro := 3;
    qualContr('01400000931490000014139').cdcooper := 14;qualContr('01400000931490000014139').nrdconta := 93149;qualContr('01400000931490000014139').nrctremp := 14139;qualContr('01400000931490000014139').idquapro := 3;
    qualContr('01400000495490000014162').cdcooper := 14;qualContr('01400000495490000014162').nrdconta := 49549;qualContr('01400000495490000014162').nrctremp := 14162;qualContr('01400000495490000014162').idquapro := 3;
    qualContr('01400001052520000014169').cdcooper := 14;qualContr('01400001052520000014169').nrdconta := 105252;qualContr('01400001052520000014169').nrctremp := 14169;qualContr('01400001052520000014169').idquapro := 3;
    qualContr('01400001265000000014178').cdcooper := 14;qualContr('01400001265000000014178').nrdconta := 126500;qualContr('01400001265000000014178').nrctremp := 14178;qualContr('01400001265000000014178').idquapro := 3;
    qualContr('01400001293210000014190').cdcooper := 14;qualContr('01400001293210000014190').nrdconta := 129321;qualContr('01400001293210000014190').nrctremp := 14190;qualContr('01400001293210000014190').idquapro := 4;
    qualContr('01400000701730000014200').cdcooper := 14;qualContr('01400000701730000014200').nrdconta := 70173;qualContr('01400000701730000014200').nrctremp := 14200;qualContr('01400000701730000014200').idquapro := 3;
    qualContr('01400000383850000014213').cdcooper := 14;qualContr('01400000383850000014213').nrdconta := 38385;qualContr('01400000383850000014213').nrctremp := 14213;qualContr('01400000383850000014213').idquapro := 3;
    qualContr('01400000658380000014262').cdcooper := 14;qualContr('01400000658380000014262').nrdconta := 65838;qualContr('01400000658380000014262').nrctremp := 14262;qualContr('01400000658380000014262').idquapro := 3;
    qualContr('01400001345380000014342').cdcooper := 14;qualContr('01400001345380000014342').nrdconta := 134538;qualContr('01400001345380000014342').nrctremp := 14342;qualContr('01400001345380000014342').idquapro := 4;
    qualContr('01400000490770000014388').cdcooper := 14;qualContr('01400000490770000014388').nrdconta := 49077;qualContr('01400000490770000014388').nrctremp := 14388;qualContr('01400000490770000014388').idquapro := 3;
    qualContr('01400001336390000014474').cdcooper := 14;qualContr('01400001336390000014474').nrdconta := 133639;qualContr('01400001336390000014474').nrctremp := 14474;qualContr('01400001336390000014474').idquapro := 3;
    qualContr('01400000566930000014506').cdcooper := 14;qualContr('01400000566930000014506').nrdconta := 56693;qualContr('01400000566930000014506').nrctremp := 14506;qualContr('01400000566930000014506').idquapro := 4;
    qualContr('01400001396530000014587').cdcooper := 14;qualContr('01400001396530000014587').nrdconta := 139653;qualContr('01400001396530000014587').nrctremp := 14587;qualContr('01400001396530000014587').idquapro := 3;
    qualContr('01400000111180000014584').cdcooper := 14;qualContr('01400000111180000014584').nrdconta := 11118;qualContr('01400000111180000014584').nrctremp := 14584;qualContr('01400000111180000014584').idquapro := 3;
    qualContr('01400000543720000014619').cdcooper := 14;qualContr('01400000543720000014619').nrdconta := 54372;qualContr('01400000543720000014619').nrctremp := 14619;qualContr('01400000543720000014619').idquapro := 3;
    qualContr('01400000572310000014646').cdcooper := 14;qualContr('01400000572310000014646').nrdconta := 57231;qualContr('01400000572310000014646').nrctremp := 14646;qualContr('01400000572310000014646').idquapro := 4;
    qualContr('01400000512410000014751').cdcooper := 14;qualContr('01400000512410000014751').nrdconta := 51241;qualContr('01400000512410000014751').nrctremp := 14751;qualContr('01400000512410000014751').idquapro := 4;
    qualContr('01400000780340000014767').cdcooper := 14;qualContr('01400000780340000014767').nrdconta := 78034;qualContr('01400000780340000014767').nrctremp := 14767;qualContr('01400000780340000014767').idquapro := 3;
    qualContr('01400000582460000014772').cdcooper := 14;qualContr('01400000582460000014772').nrdconta := 58246;qualContr('01400000582460000014772').nrctremp := 14772;qualContr('01400000582460000014772').idquapro := 3;
    qualContr('01400001179430000015038').cdcooper := 14;qualContr('01400001179430000015038').nrdconta := 117943;qualContr('01400001179430000015038').nrctremp := 15038;qualContr('01400001179430000015038').idquapro := 3;
    qualContr('01400000739970000015073').cdcooper := 14;qualContr('01400000739970000015073').nrdconta := 73997;qualContr('01400000739970000015073').nrctremp := 15073;qualContr('01400000739970000015073').idquapro := 3;
    qualContr('01400001092070000015170').cdcooper := 14;qualContr('01400001092070000015170').nrdconta := 109207;qualContr('01400001092070000015170').nrctremp := 15170;qualContr('01400001092070000015170').idquapro := 3;
    qualContr('01600038994200000075807').cdcooper := 16;qualContr('01600038994200000075807').nrdconta := 3899420;qualContr('01600038994200000075807').nrctremp := 75807;qualContr('01600038994200000075807').idquapro := 3;
    qualContr('01600003242050000076377').cdcooper := 16;qualContr('01600003242050000076377').nrdconta := 324205;qualContr('01600003242050000076377').nrctremp := 76377;qualContr('01600003242050000076377').idquapro := 3;
    qualContr('01600002705390000080032').cdcooper := 16;qualContr('01600002705390000080032').nrdconta := 270539;qualContr('01600002705390000080032').nrctremp := 80032;qualContr('01600002705390000080032').idquapro := 3;
    qualContr('01600022073030000083477').cdcooper := 16;qualContr('01600022073030000083477').nrdconta := 2207303;qualContr('01600022073030000083477').nrctremp := 83477;qualContr('01600022073030000083477').idquapro := 3;
    qualContr('01600002326370000093889').cdcooper := 16;qualContr('01600002326370000093889').nrdconta := 232637;qualContr('01600002326370000093889').nrctremp := 93889;qualContr('01600002326370000093889').idquapro := 3;
    qualContr('01600002689410000094116').cdcooper := 16;qualContr('01600002689410000094116').nrdconta := 268941;qualContr('01600002689410000094116').nrctremp := 94116;qualContr('01600002689410000094116').idquapro := 3;
    qualContr('01600000927890000094581').cdcooper := 16;qualContr('01600000927890000094581').nrdconta := 92789;qualContr('01600000927890000094581').nrctremp := 94581;qualContr('01600000927890000094581').idquapro := 3;
    qualContr('01600004361270000095151').cdcooper := 16;qualContr('01600004361270000095151').nrdconta := 436127;qualContr('01600004361270000095151').nrctremp := 95151;qualContr('01600004361270000095151').idquapro := 3;
    qualContr('01600001183890000095813').cdcooper := 16;qualContr('01600001183890000095813').nrdconta := 118389;qualContr('01600001183890000095813').nrctremp := 95813;qualContr('01600001183890000095813').idquapro := 3;
    qualContr('01600003757480000096014').cdcooper := 16;qualContr('01600003757480000096014').nrdconta := 375748;qualContr('01600003757480000096014').nrctremp := 96014;qualContr('01600003757480000096014').idquapro := 3;
    qualContr('01600036690330000095994').cdcooper := 16;qualContr('01600036690330000095994').nrdconta := 3669033;qualContr('01600036690330000095994').nrctremp := 95994;qualContr('01600036690330000095994').idquapro := 3;
    qualContr('01600065550390000096516').cdcooper := 16;qualContr('01600065550390000096516').nrdconta := 6555039;qualContr('01600065550390000096516').nrctremp := 96516;qualContr('01600065550390000096516').idquapro := 3;
    qualContr('01600021786640000097830').cdcooper := 16;qualContr('01600021786640000097830').nrdconta := 2178664;qualContr('01600021786640000097830').nrctremp := 97830;qualContr('01600021786640000097830').idquapro := 3;
    qualContr('01600029302180000098069').cdcooper := 16;qualContr('01600029302180000098069').nrdconta := 2930218;qualContr('01600029302180000098069').nrctremp := 98069;qualContr('01600029302180000098069').idquapro := 3;
    qualContr('01600002186420000098240').cdcooper := 16;qualContr('01600002186420000098240').nrdconta := 218642;qualContr('01600002186420000098240').nrctremp := 98240;qualContr('01600002186420000098240').idquapro := 3;
    qualContr('01600001089520000098687').cdcooper := 16;qualContr('01600001089520000098687').nrdconta := 108952;qualContr('01600001089520000098687').nrctremp := 98687;qualContr('01600001089520000098687').idquapro := 3;
    qualContr('01600062838700000099190').cdcooper := 16;qualContr('01600062838700000099190').nrdconta := 6283870;qualContr('01600062838700000099190').nrctremp := 99190;qualContr('01600062838700000099190').idquapro := 3;
    qualContr('01600000099110000106431').cdcooper := 16;qualContr('01600000099110000106431').nrdconta := 9911;qualContr('01600000099110000106431').nrctremp := 106431;qualContr('01600000099110000106431').idquapro := 3;
    qualContr('01600025577110000108548').cdcooper := 16;qualContr('01600025577110000108548').nrdconta := 2557711;qualContr('01600025577110000108548').nrctremp := 108548;qualContr('01600025577110000108548').idquapro := 3;
    qualContr('01600061502090000109638').cdcooper := 16;qualContr('01600061502090000109638').nrdconta := 6150209;qualContr('01600061502090000109638').nrctremp := 109638;qualContr('01600061502090000109638').idquapro := 3;
    qualContr('01600002128140000109703').cdcooper := 16;qualContr('01600002128140000109703').nrdconta := 212814;qualContr('01600002128140000109703').nrctremp := 109703;qualContr('01600002128140000109703').idquapro := 3;
    qualContr('01600001646580000110772').cdcooper := 16;qualContr('01600001646580000110772').nrdconta := 164658;qualContr('01600001646580000110772').nrctremp := 110772;qualContr('01600001646580000110772').idquapro := 3;
    qualContr('01600004155530000111545').cdcooper := 16;qualContr('01600004155530000111545').nrdconta := 415553;qualContr('01600004155530000111545').nrctremp := 111545;qualContr('01600004155530000111545').idquapro := 3;
    qualContr('01600000450470000112589').cdcooper := 16;qualContr('01600000450470000112589').nrdconta := 45047;qualContr('01600000450470000112589').nrctremp := 112589;qualContr('01600000450470000112589').idquapro := 3;
    qualContr('01600006135760000116207').cdcooper := 16;qualContr('01600006135760000116207').nrdconta := 613576;qualContr('01600006135760000116207').nrctremp := 116207;qualContr('01600006135760000116207').idquapro := 3;
    qualContr('01600004797560000117298').cdcooper := 16;qualContr('01600004797560000117298').nrdconta := 479756;qualContr('01600004797560000117298').nrctremp := 117298;qualContr('01600004797560000117298').idquapro := 3;
    qualContr('01600027355120000118238').cdcooper := 16;qualContr('01600027355120000118238').nrdconta := 2735512;qualContr('01600027355120000118238').nrctremp := 118238;qualContr('01600027355120000118238').idquapro := 3;
    qualContr('01600002405320000025094').cdcooper := 16;qualContr('01600002405320000025094').nrdconta := 240532;qualContr('01600002405320000025094').nrctremp := 25094;qualContr('01600002405320000025094').idquapro := 3;
    qualContr('01600006125100000119024').cdcooper := 16;qualContr('01600006125100000119024').nrdconta := 612510;qualContr('01600006125100000119024').nrctremp := 119024;qualContr('01600006125100000119024').idquapro := 3;
    qualContr('01600003670360000121779').cdcooper := 16;qualContr('01600003670360000121779').nrdconta := 367036;qualContr('01600003670360000121779').nrctremp := 121779;qualContr('01600003670360000121779').idquapro := 4;
    qualContr('01600001708440000122390').cdcooper := 16;qualContr('01600001708440000122390').nrdconta := 170844;qualContr('01600001708440000122390').nrctremp := 122390;qualContr('01600001708440000122390').idquapro := 3;
    qualContr('01600064329560000122605').cdcooper := 16;qualContr('01600064329560000122605').nrdconta := 6432956;qualContr('01600064329560000122605').nrctremp := 122605;qualContr('01600064329560000122605').idquapro := 3;
    qualContr('01600062830040000123256').cdcooper := 16;qualContr('01600062830040000123256').nrdconta := 6283004;qualContr('01600062830040000123256').nrctremp := 123256;qualContr('01600062830040000123256').idquapro := 3;
    qualContr('01600001083320000124552').cdcooper := 16;qualContr('01600001083320000124552').nrdconta := 108332;qualContr('01600001083320000124552').nrctremp := 124552;qualContr('01600001083320000124552').idquapro := 3;
    qualContr('01600037459960000125286').cdcooper := 16;qualContr('01600037459960000125286').nrdconta := 3745996;qualContr('01600037459960000125286').nrctremp := 125286;qualContr('01600037459960000125286').idquapro := 4;
    qualContr('01600004490830000125290').cdcooper := 16;qualContr('01600004490830000125290').nrdconta := 449083;qualContr('01600004490830000125290').nrctremp := 125290;qualContr('01600004490830000125290').idquapro := 3;
    qualContr('01600028411690000125455').cdcooper := 16;qualContr('01600028411690000125455').nrdconta := 2841169;qualContr('01600028411690000125455').nrctremp := 125455;qualContr('01600028411690000125455').idquapro := 3;
    qualContr('01600005278580000126000').cdcooper := 16;qualContr('01600005278580000126000').nrdconta := 527858;qualContr('01600005278580000126000').nrctremp := 126000;qualContr('01600005278580000126000').idquapro := 3;
    qualContr('01600061602470000128734').cdcooper := 16;qualContr('01600061602470000128734').nrdconta := 6160247;qualContr('01600061602470000128734').nrctremp := 128734;qualContr('01600061602470000128734').idquapro := 3;
    qualContr('01600004475100000130921').cdcooper := 16;qualContr('01600004475100000130921').nrdconta := 447510;qualContr('01600004475100000130921').nrctremp := 130921;qualContr('01600004475100000130921').idquapro := 3;
    qualContr('01600004692540000131120').cdcooper := 16;qualContr('01600004692540000131120').nrdconta := 469254;qualContr('01600004692540000131120').nrctremp := 131120;qualContr('01600004692540000131120').idquapro := 3;
    qualContr('01600026800410000131740').cdcooper := 16;qualContr('01600026800410000131740').nrdconta := 2680041;qualContr('01600026800410000131740').nrctremp := 131740;qualContr('01600026800410000131740').idquapro := 3;
    qualContr('01600002040210000132106').cdcooper := 16;qualContr('01600002040210000132106').nrdconta := 204021;qualContr('01600002040210000132106').nrctremp := 132106;qualContr('01600002040210000132106').idquapro := 3;
    qualContr('01600002023470000132745').cdcooper := 16;qualContr('01600002023470000132745').nrdconta := 202347;qualContr('01600002023470000132745').nrctremp := 132745;qualContr('01600002023470000132745').idquapro := 3;
    qualContr('01600002240650000133493').cdcooper := 16;qualContr('01600002240650000133493').nrdconta := 224065;qualContr('01600002240650000133493').nrctremp := 133493;qualContr('01600002240650000133493').idquapro := 3;
    qualContr('01600000242360000134515').cdcooper := 16;qualContr('01600000242360000134515').nrdconta := 24236;qualContr('01600000242360000134515').nrctremp := 134515;qualContr('01600000242360000134515').idquapro := 3;
    qualContr('01600004107990000135602').cdcooper := 16;qualContr('01600004107990000135602').nrdconta := 410799;qualContr('01600004107990000135602').nrctremp := 135602;qualContr('01600004107990000135602').idquapro := 3;
    qualContr('01600002807040000137253').cdcooper := 16;qualContr('01600002807040000137253').nrdconta := 280704;qualContr('01600002807040000137253').nrctremp := 137253;qualContr('01600002807040000137253').idquapro := 3;
    qualContr('01600003616400000137305').cdcooper := 16;qualContr('01600003616400000137305').nrdconta := 361640;qualContr('01600003616400000137305').nrctremp := 137305;qualContr('01600003616400000137305').idquapro := 3;
    qualContr('01600002909120000137455').cdcooper := 16;qualContr('01600002909120000137455').nrdconta := 290912;qualContr('01600002909120000137455').nrctremp := 137455;qualContr('01600002909120000137455').idquapro := 3;
    qualContr('01600002343380000138210').cdcooper := 16;qualContr('01600002343380000138210').nrdconta := 234338;qualContr('01600002343380000138210').nrctremp := 138210;qualContr('01600002343380000138210').idquapro := 3;
    qualContr('01600005081010000138223').cdcooper := 16;qualContr('01600005081010000138223').nrdconta := 508101;qualContr('01600005081010000138223').nrctremp := 138223;qualContr('01600005081010000138223').idquapro := 3;
    qualContr('01600019082350000138179').cdcooper := 16;qualContr('01600019082350000138179').nrdconta := 1908235;qualContr('01600019082350000138179').nrctremp := 138179;qualContr('01600019082350000138179').idquapro := 3;
    qualContr('01600001502660000138586').cdcooper := 16;qualContr('01600001502660000138586').nrdconta := 150266;qualContr('01600001502660000138586').nrctremp := 138586;qualContr('01600001502660000138586').idquapro := 3;
    qualContr('01600003153620000139223').cdcooper := 16;qualContr('01600003153620000139223').nrdconta := 315362;qualContr('01600003153620000139223').nrctremp := 139223;qualContr('01600003153620000139223').idquapro := 3;
    qualContr('01600003889040000139276').cdcooper := 16;qualContr('01600003889040000139276').nrdconta := 388904;qualContr('01600003889040000139276').nrctremp := 139276;qualContr('01600003889040000139276').idquapro := 3;
    qualContr('01600003046970000139424').cdcooper := 16;qualContr('01600003046970000139424').nrdconta := 304697;qualContr('01600003046970000139424').nrctremp := 139424;qualContr('01600003046970000139424').idquapro := 3;
    qualContr('01600003203740000140035').cdcooper := 16;qualContr('01600003203740000140035').nrdconta := 320374;qualContr('01600003203740000140035').nrctremp := 140035;qualContr('01600003203740000140035').idquapro := 3;
    qualContr('01600005229100000140100').cdcooper := 16;qualContr('01600005229100000140100').nrdconta := 522910;qualContr('01600005229100000140100').nrctremp := 140100;qualContr('01600005229100000140100').idquapro := 3;
    qualContr('01600001032920000140497').cdcooper := 16;qualContr('01600001032920000140497').nrdconta := 103292;qualContr('01600001032920000140497').nrctremp := 140497;qualContr('01600001032920000140497').idquapro := 3;
    qualContr('01600003086330000140631').cdcooper := 16;qualContr('01600003086330000140631').nrdconta := 308633;qualContr('01600003086330000140631').nrctremp := 140631;qualContr('01600003086330000140631').idquapro := 3;
    qualContr('01600006163380000141202').cdcooper := 16;qualContr('01600006163380000141202').nrdconta := 616338;qualContr('01600006163380000141202').nrctremp := 141202;qualContr('01600006163380000141202').idquapro := 3;
    qualContr('01600001288560000141280').cdcooper := 16;qualContr('01600001288560000141280').nrdconta := 128856;qualContr('01600001288560000141280').nrctremp := 141280;qualContr('01600001288560000141280').idquapro := 3;
    qualContr('01600001289610000141287').cdcooper := 16;qualContr('01600001289610000141287').nrdconta := 128961;qualContr('01600001289610000141287').nrctremp := 141287;qualContr('01600001289610000141287').idquapro := 3;
    qualContr('01600020365840000141739').cdcooper := 16;qualContr('01600020365840000141739').nrdconta := 2036584;qualContr('01600020365840000141739').nrctremp := 141739;qualContr('01600020365840000141739').idquapro := 3;
    qualContr('01600000959400000142365').cdcooper := 16;qualContr('01600000959400000142365').nrdconta := 95940;qualContr('01600000959400000142365').nrctremp := 142365;qualContr('01600000959400000142365').idquapro := 3;
    qualContr('01600002421360000142327').cdcooper := 16;qualContr('01600002421360000142327').nrdconta := 242136;qualContr('01600002421360000142327').nrctremp := 142327;qualContr('01600002421360000142327').idquapro := 3;
    qualContr('01600022935520000142784').cdcooper := 16;qualContr('01600022935520000142784').nrdconta := 2293552;qualContr('01600022935520000142784').nrctremp := 142784;qualContr('01600022935520000142784').idquapro := 3;
    qualContr('01600000280450000142702').cdcooper := 16;qualContr('01600000280450000142702').nrdconta := 28045;qualContr('01600000280450000142702').nrctremp := 142702;qualContr('01600000280450000142702').idquapro := 3;
    qualContr('01600065328880000142985').cdcooper := 16;qualContr('01600065328880000142985').nrdconta := 6532888;qualContr('01600065328880000142985').nrctremp := 142985;qualContr('01600065328880000142985').idquapro := 3;
    qualContr('01600000955910000143457').cdcooper := 16;qualContr('01600000955910000143457').nrdconta := 95591;qualContr('01600000955910000143457').nrctremp := 143457;qualContr('01600000955910000143457').idquapro := 3;
    qualContr('01600001752260000144451').cdcooper := 16;qualContr('01600001752260000144451').nrdconta := 175226;qualContr('01600001752260000144451').nrctremp := 144451;qualContr('01600001752260000144451').idquapro := 4;
    qualContr('01600063179440000145586').cdcooper := 16;qualContr('01600063179440000145586').nrdconta := 6317944;qualContr('01600063179440000145586').nrctremp := 145586;qualContr('01600063179440000145586').idquapro := 3;
    qualContr('01600002892210000149132').cdcooper := 16;qualContr('01600002892210000149132').nrdconta := 289221;qualContr('01600002892210000149132').nrctremp := 149132;qualContr('01600002892210000149132').idquapro := 3;
    qualContr('01600005048820000150154').cdcooper := 16;qualContr('01600005048820000150154').nrdconta := 504882;qualContr('01600005048820000150154').nrctremp := 150154;qualContr('01600005048820000150154').idquapro := 4;
    qualContr('01600005618780000151500').cdcooper := 16;qualContr('01600005618780000151500').nrdconta := 561878;qualContr('01600005618780000151500').nrctremp := 151500;qualContr('01600005618780000151500').idquapro := 3;
    qualContr('01600005985180000153114').cdcooper := 16;qualContr('01600005985180000153114').nrdconta := 598518;qualContr('01600005985180000153114').nrctremp := 153114;qualContr('01600005985180000153114').idquapro := 3;
    qualContr('01600001344220000153727').cdcooper := 16;qualContr('01600001344220000153727').nrdconta := 134422;qualContr('01600001344220000153727').nrctremp := 153727;qualContr('01600001344220000153727').idquapro := 3;
    qualContr('01600065340740000152614').cdcooper := 16;qualContr('01600065340740000152614').nrdconta := 6534074;qualContr('01600065340740000152614').nrctremp := 152614;qualContr('01600065340740000152614').idquapro := 3;
    qualContr('01600005868620000154475').cdcooper := 16;qualContr('01600005868620000154475').nrdconta := 586862;qualContr('01600005868620000154475').nrctremp := 154475;qualContr('01600005868620000154475').idquapro := 3;
    qualContr('01600005610610000157091').cdcooper := 16;qualContr('01600005610610000157091').nrdconta := 561061;qualContr('01600005610610000157091').nrctremp := 157091;qualContr('01600005610610000157091').idquapro := 3;
    qualContr('01600005234610000157853').cdcooper := 16;qualContr('01600005234610000157853').nrdconta := 523461;qualContr('01600005234610000157853').nrctremp := 157853;qualContr('01600005234610000157853').idquapro := 3;
    qualContr('01600005557890000157920').cdcooper := 16;qualContr('01600005557890000157920').nrdconta := 555789;qualContr('01600005557890000157920').nrctremp := 157920;qualContr('01600005557890000157920').idquapro := 3;
    qualContr('01600000609840000159191').cdcooper := 16;qualContr('01600000609840000159191').nrdconta := 60984;qualContr('01600000609840000159191').nrctremp := 159191;qualContr('01600000609840000159191').idquapro := 4;
    qualContr('01600005822710000159624').cdcooper := 16;qualContr('01600005822710000159624').nrdconta := 582271;qualContr('01600005822710000159624').nrctremp := 159624;qualContr('01600005822710000159624').idquapro := 4;
    qualContr('01600005451550000159886').cdcooper := 16;qualContr('01600005451550000159886').nrdconta := 545155;qualContr('01600005451550000159886').nrctremp := 159886;qualContr('01600005451550000159886').idquapro := 4;
    qualContr('01600005863820000160008').cdcooper := 16;qualContr('01600005863820000160008').nrdconta := 586382;qualContr('01600005863820000160008').nrctremp := 160008;qualContr('01600005863820000160008').idquapro := 3;
    qualContr('01600000836820000159777').cdcooper := 16;qualContr('01600000836820000159777').nrdconta := 83682;qualContr('01600000836820000159777').nrctremp := 159777;qualContr('01600000836820000159777').idquapro := 4;
    qualContr('01600005628150000160444').cdcooper := 16;qualContr('01600005628150000160444').nrdconta := 562815;qualContr('01600005628150000160444').nrctremp := 160444;qualContr('01600005628150000160444').idquapro := 3;
    qualContr('01600003111700000160632').cdcooper := 16;qualContr('01600003111700000160632').nrdconta := 311170;qualContr('01600003111700000160632').nrctremp := 160632;qualContr('01600003111700000160632').idquapro := 3;
    qualContr('01600000023720000161235').cdcooper := 16;qualContr('01600000023720000161235').nrdconta := 2372;qualContr('01600000023720000161235').nrctremp := 161235;qualContr('01600000023720000161235').idquapro := 3;
    qualContr('01600003431960000161941').cdcooper := 16;qualContr('01600003431960000161941').nrdconta := 343196;qualContr('01600003431960000161941').nrctremp := 161941;qualContr('01600003431960000161941').idquapro := 3;
    qualContr('01600002953450000161890').cdcooper := 16;qualContr('01600002953450000161890').nrdconta := 295345;qualContr('01600002953450000161890').nrctremp := 161890;qualContr('01600002953450000161890').idquapro := 3;
    qualContr('01600006148900000162198').cdcooper := 16;qualContr('01600006148900000162198').nrdconta := 614890;qualContr('01600006148900000162198').nrctremp := 162198;qualContr('01600006148900000162198').idquapro := 3;
    qualContr('01600001877040000162307').cdcooper := 16;qualContr('01600001877040000162307').nrdconta := 187704;qualContr('01600001877040000162307').nrctremp := 162307;qualContr('01600001877040000162307').idquapro := 3;
    qualContr('01600003646810000162647').cdcooper := 16;qualContr('01600003646810000162647').nrdconta := 364681;qualContr('01600003646810000162647').nrctremp := 162647;qualContr('01600003646810000162647').idquapro := 3;
    qualContr('01600002664500000162875').cdcooper := 16;qualContr('01600002664500000162875').nrdconta := 266450;qualContr('01600002664500000162875').nrctremp := 162875;qualContr('01600002664500000162875').idquapro := 3;
    qualContr('01600000212290000162896').cdcooper := 16;qualContr('01600000212290000162896').nrdconta := 21229;qualContr('01600000212290000162896').nrctremp := 162896;qualContr('01600000212290000162896').idquapro := 3;
    qualContr('01600005321930000163260').cdcooper := 16;qualContr('01600005321930000163260').nrdconta := 532193;qualContr('01600005321930000163260').nrctremp := 163260;qualContr('01600005321930000163260').idquapro := 3;
    qualContr('01600004286630000163307').cdcooper := 16;qualContr('01600004286630000163307').nrdconta := 428663;qualContr('01600004286630000163307').nrctremp := 163307;qualContr('01600004286630000163307').idquapro := 3;
    qualContr('01600001721200000163558').cdcooper := 16;qualContr('01600001721200000163558').nrdconta := 172120;qualContr('01600001721200000163558').nrctremp := 163558;qualContr('01600001721200000163558').idquapro := 3;
    qualContr('01600005735070000163763').cdcooper := 16;qualContr('01600005735070000163763').nrdconta := 573507;qualContr('01600005735070000163763').nrctremp := 163763;qualContr('01600005735070000163763').idquapro := 3;
    qualContr('01600005726670000164088').cdcooper := 16;qualContr('01600005726670000164088').nrdconta := 572667;qualContr('01600005726670000164088').nrctremp := 164088;qualContr('01600005726670000164088').idquapro := 3;
    qualContr('01600000275880000164067').cdcooper := 16;qualContr('01600000275880000164067').nrdconta := 27588;qualContr('01600000275880000164067').nrctremp := 164067;qualContr('01600000275880000164067').idquapro := 3;
    qualContr('01600028888580000164823').cdcooper := 16;qualContr('01600028888580000164823').nrdconta := 2888858;qualContr('01600028888580000164823').nrctremp := 164823;qualContr('01600028888580000164823').idquapro := 3;
    qualContr('01600006588800000165000').cdcooper := 16;qualContr('01600006588800000165000').nrdconta := 658880;qualContr('01600006588800000165000').nrctremp := 165000;qualContr('01600006588800000165000').idquapro := 3;
    qualContr('01600006091370000165044').cdcooper := 16;qualContr('01600006091370000165044').nrdconta := 609137;qualContr('01600006091370000165044').nrctremp := 165044;qualContr('01600006091370000165044').idquapro := 3;
    qualContr('01600003450830000165439').cdcooper := 16;qualContr('01600003450830000165439').nrdconta := 345083;qualContr('01600003450830000165439').nrctremp := 165439;qualContr('01600003450830000165439').idquapro := 3;
    qualContr('01600006047710000165498').cdcooper := 16;qualContr('01600006047710000165498').nrdconta := 604771;qualContr('01600006047710000165498').nrctremp := 165498;qualContr('01600006047710000165498').idquapro := 3;
    qualContr('01600003453690000165452').cdcooper := 16;qualContr('01600003453690000165452').nrdconta := 345369;qualContr('01600003453690000165452').nrctremp := 165452;qualContr('01600003453690000165452').idquapro := 3;
    qualContr('01600004964210000165608').cdcooper := 16;qualContr('01600004964210000165608').nrdconta := 496421;qualContr('01600004964210000165608').nrctremp := 165608;qualContr('01600004964210000165608').idquapro := 3;
    qualContr('01600020363390000165691').cdcooper := 16;qualContr('01600020363390000165691').nrdconta := 2036339;qualContr('01600020363390000165691').nrctremp := 165691;qualContr('01600020363390000165691').idquapro := 3;
    qualContr('01600005698360000165952').cdcooper := 16;qualContr('01600005698360000165952').nrdconta := 569836;qualContr('01600005698360000165952').nrctremp := 165952;qualContr('01600005698360000165952').idquapro := 3;
    qualContr('01600003391640000167060').cdcooper := 16;qualContr('01600003391640000167060').nrdconta := 339164;qualContr('01600003391640000167060').nrctremp := 167060;qualContr('01600003391640000167060').idquapro := 3;
    qualContr('01600066106840000167002').cdcooper := 16;qualContr('01600066106840000167002').nrdconta := 6610684;qualContr('01600066106840000167002').nrctremp := 167002;qualContr('01600066106840000167002').idquapro := 3;
    qualContr('01600005959000000167237').cdcooper := 16;qualContr('01600005959000000167237').nrdconta := 595900;qualContr('01600005959000000167237').nrctremp := 167237;qualContr('01600005959000000167237').idquapro := 3;
    qualContr('01600005782310000167263').cdcooper := 16;qualContr('01600005782310000167263').nrdconta := 578231;qualContr('01600005782310000167263').nrctremp := 167263;qualContr('01600005782310000167263').idquapro := 3;
    qualContr('01600005202920000167383').cdcooper := 16;qualContr('01600005202920000167383').nrdconta := 520292;qualContr('01600005202920000167383').nrctremp := 167383;qualContr('01600005202920000167383').idquapro := 3;
    qualContr('01600005725350000167533').cdcooper := 16;qualContr('01600005725350000167533').nrdconta := 572535;qualContr('01600005725350000167533').nrctremp := 167533;qualContr('01600005725350000167533').idquapro := 3;
    qualContr('01600005725350000167843').cdcooper := 16;qualContr('01600005725350000167843').nrdconta := 572535;qualContr('01600005725350000167843').nrctremp := 167843;qualContr('01600005725350000167843').idquapro := 3;
    qualContr('01600002500820000168370').cdcooper := 16;qualContr('01600002500820000168370').nrdconta := 250082;qualContr('01600002500820000168370').nrctremp := 168370;qualContr('01600002500820000168370').idquapro := 3;
    qualContr('01600005970900000168553').cdcooper := 16;qualContr('01600005970900000168553').nrdconta := 597090;qualContr('01600005970900000168553').nrctremp := 168553;qualContr('01600005970900000168553').idquapro := 3;
    qualContr('01600001336120000169404').cdcooper := 16;qualContr('01600001336120000169404').nrdconta := 133612;qualContr('01600001336120000169404').nrctremp := 169404;qualContr('01600001336120000169404').idquapro := 4;
    qualContr('01600003135130000171807').cdcooper := 16;qualContr('01600003135130000171807').nrdconta := 313513;qualContr('01600003135130000171807').nrctremp := 171807;qualContr('01600003135130000171807').idquapro := 3;
  END;

begin

  vr_incidente := 'INC0049770';

  vr_dsdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas';
  gene0001.pc_OScommand_Shell(pr_des_comando => 'mkdir ' || vr_dsdireto || '/' || vr_incidente
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);

  vr_dsdireto := vr_dsdireto || '/' || vr_incidente;
  vr_dirname := sistema.obternomedirectory(vr_dsdireto);

/*
  -- Usado em ambientes sem acesso para limpar pasta
  gene0001.pc_OScommand_Shell(pr_des_comando => 'rm -f ' || vr_dsdireto || '/*'
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
*/

  -- Inicializar o CLOB
  vr_texto_rollback := NULL;
  vr_des_log := NULL;
  dbms_lob.createtemporary(vr_des_log, TRUE);
  dbms_lob.open(vr_des_log, dbms_lob.lob_readwrite);

  vr_texto_erro := NULL;
  vr_des_erro := NULL;
  dbms_lob.createtemporary(vr_des_erro, TRUE);
  dbms_lob.open(vr_des_erro, dbms_lob.lob_readwrite);

  vr_texto_relatorio := NULL;
  vr_des_rel := NULL;
  dbms_lob.createtemporary(vr_des_rel, TRUE);
  dbms_lob.open(vr_des_rel, dbms_lob.lob_readwrite);

  pc_carrega_dados();

  pc_escreve_relatorio('cdcooper,nrdconta,nrctremp,de_idquapro,para_idquapro');

  vr_index := qualContr.FIRST;
  WHILE vr_index IS NOT null LOOP
    OPEN cr_crawepr(qualContr(vr_index).cdcooper
                   ,qualContr(vr_index).nrdconta
                   ,qualContr(vr_index).nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;
    CLOSE cr_crawepr;

    IF rw_crawepr.cdcooper IS NOT NULL THEN

      pc_escreve_relatorio(qualContr(vr_index).cdcooper      || ',' ||
                           qualContr(vr_index).nrdconta      || ',' ||
                           qualContr(vr_index).nrctremp      || ',' ||
                           NVL(rw_crawepr.idquapro, 0)       || ',' ||  -- DE
                           qualContr(vr_index).idquapro);               -- PARA

      pc_escreve_rollback('UPDATE crawepr SET idquapro = ' || qualContr(vr_index).idquapro || ' WHERE ' ||
                          'cdcooper = ' || qualContr(vr_index).cdcooper || ' AND ' ||
                          'nrdconta = ' || qualContr(vr_index).nrdconta || ' AND ' ||
                          'nrctremp = ' || qualContr(vr_index).nrctremp || ';');

    BEGIN
      UPDATE crawepr SET idquapro = qualContr(vr_index).idquapro  -- PARA
       WHERE cdcooper = qualContr(vr_index).cdcooper
         AND nrdconta = qualContr(vr_index).nrdconta
         AND nrctremp = qualContr(vr_index).nrctremp;
    EXCEPTION
      WHEN OTHERS THEN
        pc_escreve_erro('ERRO2,' ||
                        qualContr(vr_index).cdcooper || ',' ||
                        qualContr(vr_index).nrdconta || ',' ||
                        qualContr(vr_index).nrctremp || ',' ||
                        rw_crawepr.idquapro          || ',' ||  -- DE
                        qualContr(vr_index).idquapro);          -- PARA
    END;

    ELSE

      pc_escreve_erro('ERRO1,' ||
                      qualContr(vr_index).cdcooper || ',' ||
                      qualContr(vr_index).nrdconta || ',' ||
                      qualContr(vr_index).nrctremp || ',' ||
                      rw_crawepr.idquapro          || ',' ||  -- DE
                      qualContr(vr_index).idquapro);          -- PARA
    END IF;

    vr_index := qualContr.NEXT(vr_index);

  END LOOP;

  FOR row IN cr_operacoes_efetivadas_ativas LOOP
    qualificarOperacao(row.atrasoemadp, row.atrasoemadpcomlimite, vr_qualificacao);
    IF vr_qualificacao <> row.idquapro THEN

      pc_escreve_relatorio(row.cdcooper           || ',' ||
                           row.nrdconta           || ',' ||
                           row.nrctremp           || ',' ||
                           NVL(row.idquapro, 0)   || ',' ||  -- DE
                           vr_qualificacao);                 -- PARA

      pc_escreve_rollback('UPDATE crawepr SET idquapro = ' || row.idquapro || ' WHERE ' ||
                          'cdcooper = ' || row.cdcooper || ' AND ' ||
                          'nrdconta = ' || row.nrdconta || ' AND ' ||
                          'nrctremp = ' || row.nrctremp || ';');

      BEGIN
        UPDATE crawepr SET idquapro = vr_qualificacao  -- PARA
         WHERE cdcooper = row.cdcooper
           AND nrdconta = row.nrdconta
           AND nrctremp = row.nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          pc_escreve_erro('ERRO3,' ||
                          row.cdcooper || ',' ||
                          row.nrdconta || ',' ||
                          row.nrctremp || ',' ||
                          row.idquapro || ',' ||  -- DE
                          vr_qualificacao);       -- PARA
      END;

    END IF;
  END LOOP;

  -- FINAL
  pc_escreve_relatorio(' ',TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_rel, vr_dirname, 'QUALIFICACAO_DE_PARA_'||to_char(sysdate,'ddmmyyyy_hh24miss')|| '.txt', NLS_CHARSET_ID('UTF8'));

  dbms_lob.close(vr_des_rel);
  dbms_lob.freetemporary(vr_des_rel);

  pc_escreve_rollback(' ',TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_log, vr_dirname, 'QUALIFICACAO_ROLLBACK_'||to_char(sysdate,'ddmmyyyy_hh24miss')|| '.sql', NLS_CHARSET_ID('UTF8'));

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_log);
  dbms_lob.freetemporary(vr_des_log);

  pc_escreve_erro(' ',TRUE);
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_erro, vr_dirname, 'QUALIFICACAO_ERROS_'||to_char(sysdate,'ddmmyyyy_hh24miss')|| '.txt', NLS_CHARSET_ID('UTF8'));

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_erro);
  dbms_lob.freetemporary(vr_des_erro);

/*
  -- Permissão nos arquivos
  gene0001.pc_OScommand_Shell(pr_des_comando => 'chmod 777 ' || vr_dsdireto || '/*'
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
*/

  COMMIT;

END;
0
3
vr_nrcontrato
vr_qtdias_atraso
vr_dirname
