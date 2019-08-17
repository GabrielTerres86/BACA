DECLARE
  
  TYPE typ_rcportab IS RECORD (NumCtrlPart  VARCHAR2(20)
                              ,NUPortddPCS  NUMBER(21)
                              ,idsituacao   NUMBER(1)
                              ,dsdominio    VARCHAR2(30)
                              ,cdmotivo     VARCHAR2(10)
                              ,dtretorno    DATE
                              ,nmarquivo    VARCHAR2(100));
  TYPE typ_tbportab IS TABLE OF typ_rcportab INDEX BY BINARY_INTEGER;
  
  vr_tbportab        typ_tbportab;
  vr_dsmotivoreprv   CONSTANT VARCHAR2(30) := 'MOTVREPRVCPORTDDCTSALR';

BEGIN


  -- ADICIONAR OS REGISTROS A SEREM CORRIGIDOS
  -- 201903110000085572533 - APROVADA - APCS104_05463212_20190322_00009
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '00100000809409800001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572533;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 3;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := NULL;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := NULL;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190322','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190322_00009';
  
  -- 201903110000085572534 - APROVADA - APCS104_05463212_20190320_00042
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '01200000012427300002';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572534;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 3;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := NULL;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := NULL;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190320','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190320_00042';

  -- 201903110000085572535 - REPROVADA - MOTIVO 1 - APCS104_05463212_20190311_00045
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '00100001033159000001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572535;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 4;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := vr_dsmotivoreprv;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := 1;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190311','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190311_00045';

  -- 201903110000085572536 - APROVADA - APCS104_05463212_20190322_00058
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '00100001033172700001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572536; 
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 3;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := NULL;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := NULL;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190322','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190322_00058';

  -- 201903110000085572537 - REPROVADA - MOTIVO 2 - APCS104_05463212_20190311_00045
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '00100000214299600001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572537;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 4;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := vr_dsmotivoreprv;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := 2;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190311','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190311_00045';

  -- 201903110000085572538 - APROVADA - APCS104_05463212_20190322_00044
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '00100001020410500001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572538;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 3;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := NULL;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := NULL;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190322','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190322_00044';

  -- 201903110000085572539 - REPROVADA - MOTIVO 1 - APCS104_05463212_20190311_00045
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '00100001029411200001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572539;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 4;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := vr_dsmotivoreprv;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := 1;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190311','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190311_00045';

  -- 201903110000085572540 - APROVADA - APCS104_05463212_20190322_00009
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '00100000303196900001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572540;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 3;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := NULL;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := NULL;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190322','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190322_00009';

  -- 201903110000085572541 - REPROVADA - MOTIVO 3 - APCS104_05463212_20190311_00033
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '00100000231502500001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572541;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 4;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := vr_dsmotivoreprv;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := 3;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190311','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190311_00033';
  
  -- 201903110000085572542 - APROVADA - APCS104_05463212_20190322_00058
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '00900000016035000001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572542;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 3;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := NULL;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := NULL;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190322','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190322_00058';

  -- 201903110000085572543 - REPROVADA - MOTIVO 6 - APCS104_05463212_20190321_00049
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '01100000040531000001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572543;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 4;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := vr_dsmotivoreprv;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := 6;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190321','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190321_00049';

  -- 201903110000085572544 - APROVADA - APCS104_05463212_20190319_00060
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '00100000768145300001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572544;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 3;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := NULL;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := NULL;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190319','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190319_00060';

  -- 201903110000085572545 - APROVADA - APCS104_05463212_20190322_00045
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '00100000850165300001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572545;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 3;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := NULL;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := NULL;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190322','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190322_00045';

  -- 201903110000085572546 - APROVADA - APCS104_05463212_20190320_00047
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '00100000094930200001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572546;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 3;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := NULL;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := NULL;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190320','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190320_00047';

  -- 201903110000085572547 - REPROVADA - MOTIVO 3 - APCS104_05463212_20190311_00045
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '00100000896048800001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572547;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 4;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := vr_dsmotivoreprv;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := 3;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190311','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190311_00045';

  -- 201903110000085572548 - APROVADA - APCS104_05463212_20190322_00058
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '01100000050274000001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572548;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 3;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := NULL;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := NULL;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190322','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190322_00058';

  -- 201903110000085572549 - APROVADA - APCS104_05463212_20190319_00060
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '00100001033156500001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572549;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 3;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := NULL;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := NULL;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190319','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190319_00060';

  -- 201903110000085572550 - REPROVADA - MOTIVO 2 - APCS104_05463212_20190311_00032
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '01300000029654600001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572550;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 4;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := vr_dsmotivoreprv;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := 2;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190311','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190311_00032';

  -- 201903110000085572551 - APROVADA - APCS104_05463212_20190322_00058
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '00100000945341500001';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572551;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 3;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := NULL;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := NULL;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190322','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190322_00058';

  -- 201903110000085572552 - REPROVADA - MOTIVO 6 - APCS104_05463212_20190322_00011
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '01000000012226200002';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572552;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 4;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := vr_dsmotivoreprv;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := 6;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190322','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190322_00011';

  -- 201903110000085572553 - APROVADA - APCS104_05463212_20190315_00041
  vr_tbportab(vr_tbportab.count()+1).NumCtrlPart := '00100000151704000002';
  vr_tbportab(vr_tbportab.count()  ).NUPortddPCS :=  201903110000085572553;
  vr_tbportab(vr_tbportab.count()  ).idsituacao  := 3;
  vr_tbportab(vr_tbportab.count()  ).dsdominio   := NULL;
  vr_tbportab(vr_tbportab.count()  ).cdmotivo    := NULL;
  vr_tbportab(vr_tbportab.count()  ).dtretorno   := to_date('20190315','yyyymmdd');
  vr_tbportab(vr_tbportab.count()  ).nmarquivo   := 'APCS104_05463212_20190315_00041';


  -- Percorrer os registros
  FOR ind IN vr_tbportab.FIRST..vr_tbportab.LAST LOOP
    
    -- Atualizar os dados 
    UPDATE tbcc_portabilidade_envia t
       SET t.nrnu_portabilidade = vr_tbportab(ind).NUPortddPCS
         , t.idsituacao         = vr_tbportab(ind).idsituacao
         , t.dsdominio_motivo   = vr_tbportab(ind).dsdominio 
         , t.cdmotivo           = vr_tbportab(ind).cdmotivo  
         , t.dtretorno          = vr_tbportab(ind).dtretorno 
         , t.nmarquivo_retorno  = vr_tbportab(ind).nmarquivo 
     WHERE lpad(t.cdcooper,3,'0')||LPAD(t.nrdconta,12,'0')||LPAD(t.nrsolicitacao,5,'0') = vr_tbportab(ind).NumCtrlPart;
    
  END LOOP;


  -- Atualizar a portabilidade que foi rejeitada
  UPDATE tbcc_portabilidade_envia t
         SET t.nrnu_portabilidade = NULL
           , t.idsituacao         = 8 -- Rejeitada (dominio: SIT_PORTAB_SALARIO_ENVIA)
           , t.dtretorno          = to_date('11/03/2019','dd/mm/yyyy')
           , t.nmarquivo_retorno  = 'APCS101_05463212_20190311_00498_RET'
           , t.dsdominio_motivo   = 'ERRO_PCPS_CIP' -- Dominio dos erros da CIP
           , t.cdmotivo           = 'EGENPCPS' -- ERRO PADRÃO, SERÁ TRATADO CAMPO A CAMPO NA TABELA FILHA
       WHERE t.cdcooper      = 16
         AND t.nrdconta      = 3745732
         AND t.nrsolicitacao = 1;

  -- Inserir o erro apurado
  INSERT INTO tbcc_portabilidade_env_erros
                 (cdcooper
                 ,nrdconta
                 ,nrsolicitacao
                 ,dsdominio_motivo
                 ,cdmotivo)
          VALUES (16 -- cdcooper
                 ,3745732 -- nrdconta
                 ,1 -- nrsolicitacao
                 ,'ERRO_PCPS_CIP' -- dsdominio_motivo
                 ,'EPCS0014' ); -- cdmotivo

  -- Commitar os dados trasacionados
  COMMIT;

END;

