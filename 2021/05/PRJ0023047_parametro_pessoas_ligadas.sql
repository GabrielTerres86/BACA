BEGIN
  --
  delete crapprm
  where NMSISTEM = 'CRED'
    and CDACESSO = 'PESSOA_LIGADA_DIRETORIA';
  delete crapprm
  where NMSISTEM = 'CRED'
    and CDACESSO = 'PESSOA_LIGADA_CNSLH_ADM';
  delete crapprm
  where NMSISTEM = 'CRED'
    and CDACESSO = 'PESSOA_LIGADA_CNSLH_FSCL';
  --
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 1, 'PESSOA_LIGADA_DIRETORIA', 'Indica os CPFs de pessoas ligadas - Diretoria', ',47777303953,48954659934,55781241949,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 1, 'PESSOA_LIGADA_CNSLH_ADM', 'Indica os CPFs de pessoas ligadas - Conselho de Administracao', ',00484245953,02759338908,09310045949,18170374987,68606753904,88669734915,89176294900,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 1, 'PESSOA_LIGADA_CNSLH_FSCL', 'Indica os CPFs de pessoas ligadas - Conselho Fiscal', ',01457538911,04804487956,21624046991,27068862004,57849757904,84580879953,');
  --
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 2, 'PESSOA_LIGADA_DIRETORIA', 'Indica os CPFs de pessoas ligadas - Diretoria', ',04744599931,76595315904,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 2, 'PESSOA_LIGADA_CNSLH_ADM', 'Indica os CPFs de pessoas ligadas - Conselho de Administracao', ',02019876949,35179767920,52450929991,79640303968,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 2, 'PESSOA_LIGADA_CNSLH_FSCL', 'Indica os CPFs de pessoas ligadas - Conselho Fiscal', ',00456419942,41848950934,50039016900,68682344904,70071020934,80313477949,');
  --
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 5, 'PESSOA_LIGADA_DIRETORIA', 'Indica os CPFs de pessoas ligadas - Diretoria', ',03028531976,04357500974,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 5, 'PESSOA_LIGADA_CNSLH_ADM', 'Indica os CPFs de pessoas ligadas - Conselho de Administracao', ',00492878935,02429298937,02650137983,04811351975,07101524931,33187541100,49832883920,71713476991,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 5, 'PESSOA_LIGADA_CNSLH_FSCL', 'Indica os CPFs de pessoas ligadas - Conselho Fiscal', ',03474201921,04801263992,55124984953,74809342972,77627806968,95110429987,');
  --
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 6, 'PESSOA_LIGADA_DIRETORIA', 'Indica os CPFs de pessoas ligadas - Diretoria', ',67410596953,69121664900,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 6, 'PESSOA_LIGADA_CNSLH_ADM', 'Indica os CPFs de pessoas ligadas - Conselho de Administracao', ',41739507991,54094275991,59171332987,76940985972,80642446920,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 6, 'PESSOA_LIGADA_CNSLH_FSCL', 'Indica os CPFs de pessoas ligadas - Conselho Fiscal', ',00667603999,52121011900,81696965934,88767019900,');
  --
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 7, 'PESSOA_LIGADA_DIRETORIA', 'Indica os CPFs de pessoas ligadas - Diretoria', ',02498047948,02844604943,64935973072,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 7, 'PESSOA_LIGADA_CNSLH_ADM', 'Indica os CPFs de pessoas ligadas - Conselho de Administracao', ',00388679905,02992710997,06314188903,08400673999,37766023920,37837796934,37888722920,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 7, 'PESSOA_LIGADA_CNSLH_FSCL', 'Indica os CPFs de pessoas ligadas - Conselho Fiscal', ',01799964957,19453302872,23443332900,34452770959,46597468015,62911848772,');
  --
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 8, 'PESSOA_LIGADA_DIRETORIA', 'Indica os CPFs de pessoas ligadas - Diretoria', ',02222355940,15470571904,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 8, 'PESSOA_LIGADA_CNSLH_ADM', 'Indica os CPFs de pessoas ligadas - Conselho de Administracao', ',00339525908,02998912915,05712165953,19474660972,24591688968,33365040668,34336265968,34461493920,37838490987,59486570949,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 8, 'PESSOA_LIGADA_CNSLH_FSCL', 'Indica os CPFs de pessoas ligadas - Conselho Fiscal', ',25756923934,28916344972,34219021949,38531860920,41789334934,55774547949,');
  --
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 9, 'PESSOA_LIGADA_DIRETORIA', 'Indica os CPFs de pessoas ligadas - Diretoria', ',00908373988,03857044969,74979698034,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 9, 'PESSOA_LIGADA_CNSLH_ADM', 'Indica os CPFs de pessoas ligadas - Conselho de Administracao', ',00649279972,00882085085,04693095982,06748481953,09339892968,21926689968,25568949972,38617528915,75123037934,76700208904,83320954920,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 9, 'PESSOA_LIGADA_CNSLH_FSCL', 'Indica os CPFs de pessoas ligadas - Conselho Fiscal', ',30488516900,41743849915,46053115991,63972115920,93938098015,');
  --
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 10, 'PESSOA_LIGADA_DIRETORIA', 'Indica os CPFs de pessoas ligadas - Diretoria', ',00927510910,78080959072,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 10, 'PESSOA_LIGADA_CNSLH_ADM', 'Indica os CPFs de pessoas ligadas - Conselho de Administracao', ',02165124921,19926430082,34523243972,58178740915,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 10, 'PESSOA_LIGADA_CNSLH_FSCL', 'Indica os CPFs de pessoas ligadas - Conselho Fiscal', ',01996179969,05433185915,50604236972,58404260915,73723320953,');
  --
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 11, 'PESSOA_LIGADA_DIRETORIA', 'Indica os CPFs de pessoas ligadas - Diretoria', ',04594408966,05114955950,90770641920,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 11, 'PESSOA_LIGADA_CNSLH_ADM', 'Indica os CPFs de pessoas ligadas - Conselho de Administracao', ',05660431909,24675857949,39828522934,69258376900,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 11, 'PESSOA_LIGADA_CNSLH_FSCL', 'Indica os CPFs de pessoas ligadas - Conselho Fiscal', ',01457550962,05389059646,24118184915,27261441015,80640974953,93154356991,');
  --
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 12, 'PESSOA_LIGADA_DIRETORIA', 'Indica os CPFs de pessoas ligadas - Diretoria', ',00927569990,72162643987,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 12, 'PESSOA_LIGADA_CNSLH_ADM', 'Indica os CPFs de pessoas ligadas - Conselho de Administracao', ',01946958913,19432461904,58823514991,90483103934,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 12, 'PESSOA_LIGADA_CNSLH_FSCL', 'Indica os CPFs de pessoas ligadas - Conselho Fiscal', ',01817845993,03684397989,09376578830,53229304934,58267638920,59950960959,');
  --
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 13, 'PESSOA_LIGADA_DIRETORIA', 'Indica os CPFs de pessoas ligadas - Diretoria', ',00621637955,04767567904,56603916991,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 13, 'PESSOA_LIGADA_CNSLH_ADM', 'Indica os CPFs de pessoas ligadas - Conselho de Administracao', ',01844823997,02795736772,29307260915,38080516987,39982602934,45248931991,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 13, 'PESSOA_LIGADA_CNSLH_FSCL', 'Indica os CPFs de pessoas ligadas - Conselho Fiscal', ',00548094950,03819816909,29423783953,31059473968,33268649068,86030132920,');
  --
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 14, 'PESSOA_LIGADA_DIRETORIA', 'Indica os CPFs de pessoas ligadas - Diretoria', ',56967527053,88080277915,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 14, 'PESSOA_LIGADA_CNSLH_ADM', 'Indica os CPFs de pessoas ligadas - Conselho de Administracao', ',17712637920,25668900991,60298227991,70880670991,80641075987,83101330904,88086828972,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 14, 'PESSOA_LIGADA_CNSLH_FSCL', 'Indica os CPFs de pessoas ligadas - Conselho Fiscal', ',37036122900,37039318920,54618525991,61994413972,74482637904,88080536953,');
  --
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 16, 'PESSOA_LIGADA_DIRETORIA', 'Indica os CPFs de pessoas ligadas - Diretoria', ',03693828970,04026495914,98853872934,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 16, 'PESSOA_LIGADA_CNSLH_ADM', 'Indica os CPFs de pessoas ligadas - Conselho de Administracao', ',00943489954,07185171997,31028551991,69309426934,81190417987,');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 16, 'PESSOA_LIGADA_CNSLH_FSCL', 'Indica os CPFs de pessoas ligadas - Conselho Fiscal', ',00607319909,03281320988,50183516915,68288581900,68382316972,75103990920,');
  --
  COMMIT;
  --
END;
