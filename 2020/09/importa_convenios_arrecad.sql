-- Created on 12/08/2020 by F0030474 
declare 
  -- Local variables here
  arq_csv CLOB := 'AGUA PREF CHAPECO SC;8261219;1219;2;0,59;0,59;0,30;4
ÁGUAS ARIQUEMES - MT;8261493;1493;2;0,48;0,30;0,30;4
ÁGUAS BARR GARÇA-MT;8261413;1413;2;0,48;0,30;0,30;4
AGUAS CAMPO VERDE MT;8260732;732;2;0,30;0,30;0,30;4
ÁGUAS DE BURITIS RO;8261446;1446;2;0,48;0,30;0,30;4
AGUAS DE CAMBORIU SC;8261473;1473;2;0,48;0,30;0,30;4
AGUAS DE ITAPEMA SC;8260910;910;2;0,48;0,30;0,30;4
ÁGUAS DE JUARA MT;8260536;536;2;0,72;0,72;0,00;4
AGUAS DE MATAO SP;8261387;1387;2;0,40;0,40;0,27;4
AGUAS DE SORRISO MT;8260527;527;2;0,30;0,30;0,30;4
ÁGUAS DE TERESINA PI;8261535;1535;2;0,48;0,30;0,30;4
AGUAS GUARIROBA MS;8260534;534;2;0,27;0,27;0,27;4
AGUAS JOINVILLE SC;8280961;961;2;1,01;0,40;0,40;4
AGUAS PARA MINAS-MG;8261442;1442;2;0,60;0,48;0,27;4
AGUAS PENHA SC;8261466;1466;2;0,48;0,30;0,30;4
ÁGUAS PIMEN BUENO-RO;8261474;1474;2;0,48;0,30;0,30;4
AGUAS PRIMAVERA MT;8260762;762;2;0,30;0,30;0,30;4
ÁGUAS ROLIM MOURA RO;8261491;1491;2;0,48;0,30;0,30;4
AGUAS S FRA SUL - SC;8261426;1426;2;0,48;0,30;0,30;4
AGUAS SINOP MT;8261422;1422;2;0,30;0,30;0,30;4
ALGAR TELECOM MG;8460464;464;4;0,42;0,42;0,21;4
AMAZONAS ENERGIA AM;8360047;47;3;0,48;0,48;0,48;4
AMAZONIA CELULAR;8460061;61;4;0,24;0,24;0,12;4
ATS - SANEAMENTO TO;8281341;1341;2;0,54;0,36;0,24;4
BRK AMBIENTAL ES;8260059;59;2;0,22;0,22;0,22;4
BRTELCEL-AC;8460149;149;4;0,25;0,18;0,18;3
BRTELCEL-DF;8460150;150;4;0,25;0,18;0,18;3
BRTELCEL-GO;8460151;151;4;0,25;0,18;0,18;3
BRTELCEL-MS;8460153;153;4;0,25;0,18;0,18;3
BRTELCEL-MT;8460152;152;4;0,25;0,18;0,18;3
BRTELCEL-PR;8460154;154;4;0,25;0,18;0,18;3
BRTELCEL-RO;8460156;156;4;0,25;0,18;0,18;3
BRTELCEL-RS;8460155;155;4;0,25;0,18;0,18;3
BRTELCEL-SC;8460157;157;4;0,25;0,18;0,18;3
CAB CUIABA MT;8261329;1329;2;0,60;0,60;0,18;4
CAERD RO;8260005;5;2;0,48;0,48;0,36;4
CAERN RN;8260006;6;2;0,56;0,56;0,56;4
CAERR RR;8260004;4;2;1,19;0,64;0,53;4
CAESB DF;8260008;8;2;0,65;0,65;0,37;3
CAGECE - CE;8260009;9;2;0,53;0,35;0,35;4
CAGEPA - PB;8260010;10;2;0,23;0,18;0,18;4
CASAL ALAGOAS AL;8260012;12;2;0,21;0,21;0,21;4
CASAL ARAPIRACA AL;8261351;1351;2;0,21;0,21;0,21;4
CASAL SANAMA AL;8261488;1488;2;0,21;0,21;0,21;5
CASAL SANEMA AL;8261475;1475;2;0,21;0,21;0,21;4
CASAN SC;8260013;13;2;0,23;0,23;0,23;3
CEA AMAPA AP;8360002;2;3;0,66;0,36;0,30;4
CEAL ELETROBRAS AL;8360003;3;3;0,30;0,30;0,30;4
CEB DISTRIBUIÇÃO DF;8360005;5;3;0,30;0,21;0,18;3
CEEE - RS;8360006;6;3;0,15;0,12;0,12;4
CEG - RJ;8360056;56;3;0,24;0,15;0,15;4
CEG RIO - RJ;8360100;100;3;0,24;0,15;0,15;4
CELESC DISTRIB - SC;8360162;162;3;0,44;0,23;0,23;4
CELG DISTRIBUIÇÃO GO;8360009;9;3;0,38;0,38;0,22;3
CELPA ENERGIA PA;8360010;10;3;0,30;0,16;0,16;5
CELPE PE;8360011;11;3;0,14;0,14;0,14;4
CEMAR - MA;8360013;13;3;0,30;0,16;0,16;5
CEMIG DISTRIB - MG;8360138;138;3;0,37;0,32;0,31;3
CEMIG MG;8360015;15;3;0,34;0,30;0,28;3
CEPISA PI;8360017;17;3;0,70;0,70;0,70;4
CEREJ - SC;8360082;82;3;0,54;0,54;0,42;4
CERGAL SC;8360078;78;3;0,54;0,42;0,36;4
CERON ELET RONDO-RO;8360020;20;3;0,60;0,48;0,30;4
CERTEL RS;8360179;179;3;0,90;0,72;0,48;4
CESAMA JUIZ FORA-MG;8260015;15;2;0,32;0,32;0,32;4
CESAN ES;8260016;16;2;0,37;0,24;0,24;3
CHESP CERES GO;8360023;23;3;0,48;0,42;0,33;4
CLARO BA / MG / SE;8480165;165;4;0,48;0,36;0,18;4
CLARO CO DDD 61 A 69;8480160;160;4;0,48;0,36;0,18;4
CLARO FIXO S.A.;8460071;71;4;0,48;0,36;0,18;3
CLARO FIXO SP;8460078;78;4;0,48;0,36;0,18;3
CLARO MÓVEL;8480162;162;4;0,48;0,36;0,18;4
CLARO NE DDD 81 A 89;8480221;221;4;0,48;0,36;0,18;4
CLARO NO DDD 91 A 99;8480297;297;4;0,48;0,36;0,18;4
CLARO PR / SC;8480163;163;4;0,48;0,36;0,18;4
CLARO RJ / ES;8480158;158;4;0,48;0,36;0,18;4
CLARO RS;8480161;161;4;0,48;0,36;0,18;4
CLARO SP DDD 12 A 19;8480159;159;4;0,48;0,36;0,18;4
CLARO TV;8460305;305;4;0,48;0,36;0,18;4
CODAU MG;8260017;17;2;0,83;0,83;0,21;4
CODEN NOVA ODESSA SP;8260319;319;2;0,53;0,47;0,33;4
COELBA BA;8360030;30;3;0,12;0,12;0,12;3
COELCE - CE;8360031;31;3;0,33;0,29;0,21;4
COHASB AM;8260915;915;2;0,90;0,90;0,00;4
COMPESA - PE;8260018;18;2;0,27;0,18;0,18;4
COMUSA NOVO HAMB RS;8261128;1128;2;0,76;0,69;0,30;4
COPANOR MG;8261116;1116;2;0,29;0,29;0,29;4
COPASA MG;8260019;19;2;0,26;0,26;0,20;3
COPEL - PR;8360111;111;3;0,54;0,32;0,28;3
COPEL TEL PR;8460106;106;4;0,62;0,62;0,62;4
CORSAN SAPIRANGA RS;8261100;1100;2;0,29;0,29;0,29;4
CORSAN VIL S ISAB-SC;8260798;798;2;0,29;0,29;0,29;4
COSERN RN;8360038;38;3;0,27;0,27;0,23;3
CPFL LESTE PAULIS-SP;8360039;39;3;0,40;0,40;0,21;4
CPFL MOCOCA-SP;8360026;26;3;0,40;0,40;0,21;4
CPFL PAULISTA - SP;8360040;40;3;0,36;0,18;0,18;3
CPFL PIRATININGA-SP;83690110;110;3;0,36;0,18;0,18;3
CPFL SANTA CRUZ - SP;8360052;52;3;0,40;0,40;0,21;4
CPFL SANTA CRUZ 2-SP;8360027;27;3;0,30;0,18;0,18;4
CPFL SUL PAULISTA-SP;8360055;55;3;0,40;0,40;0,21;4
CTBC CELULAR-MG;8460066;66;4;0,36;0,36;0,15;3
CTBC MULTIMIDIA-MG;8480284;284;4;0,36;0,36;0,18;4
CTBC TELECOM-MG;8460004;4;4;0,36;0,36;0,15;3
DAAE ARARAQUARA SP;8260024;24;2;0,67;0,67;0,50;4
DAAE RIO CLARO SP;8260026;26;2;0,56;0,56;0,56;4
DAE AMERICANA SP;8260027;27;2;0,54;0,54;0,54;3
DAE JOÃO MONLEVAD-MG;8260418;418;2;0,96;0,90;0,90;4
DAE SANTA BÁRBARA SP;8260033;33;2;0,57;0,53;0,39;4
DAE VG - MT;8260382;382;2;0,48;0,48;0,48;3
DAEMO OLIMPIA SP;8260039;39;2;0,54;0,48;0,30;4
DAEP PENÁPOLIS SP;8260704;704;2;0,53;0,42;0,33;4
DAEPA MG;8260349;349;2;0,66;0,66;0,66;4
DAERP SP;8260040;40;2;0,90;0,64;0,32;3
DAP ÁGUA PARECIS MT;8260632;632;2;0,35;0,35;0,35;4
DEAGUA SP;8260699;699;2;1,08;0,66;0,25;4
DEMAE CALD NOVAS-GO;8260311;311;2;0,72;0,60;0,36;4
DMAE PORTO ALEGRE-RS;8260043;43;2;0,00;0,00;0,00;4
DMAES PONTE NOVA MG;8260380;380;2;0,74;0,74;0,74;4
DME DISTR P CALAS-MG;8360041;41;3;0,45;0,45;0,00;4
EDP BANDEIRANTES SP;8360073;73;3;0,24;0,24;0,18;4
ELEKTRO SP;8360022;22;3;0,37;0,19;0,19;4
ELETROACRE AC;8360045;45;3;0,42;0,30;0,30;4
ELETROPAULO-SP;8360048;48;3;0,30;0,24;0,18;4
EMBASA BA;8260047;47;2;0,23;0,23;0,19;3
EMBASA BNDES BA;8261550;1550;2;0,23;0,23;0,19;4
EMBASA BNDESPAR-BA;8261551;1551;2;0,23;0,23;0,19;4
EMBASA FOZ JAGUAR-BA;8261207;1207;2;0,23;0,23;0,19;4
EMBRATEL;00067561;6;4;0,48;0,36;0,18;3
EMDAEP DRACENA SP;8260508;508;2;0,42;0,42;0,42;4
ENERG BORB - FIDC PB;8360147;147;3;0,31;0,31;0,31;4
ENERGISA BORBOREM PB;8360007;7;3;0,31;0,31;0,31;4
ENERGISA MATO GROSSO;8360159;159;3;0,39;0,39;0,18;4
ENERGISA MATO GROSSO;8360154;154;3;0,39;0,39;0,18;4
ENERGISA MATO GROSSO;8360014;14;3;0,39;0,39;0,18;4
ENERGISA MG;83600249;24;3;0,31;0,31;0,00;4
ENERGISA MG - FIDC;8360145;145;3;0,31;0,31;0,31;4
ENERGISA MT GROS SUL;8360199;199;3;0,30;0,16;0,16;4
ENERGISA MT GROS SUL;8360050;50;3;0,30;0,16;0,16;4
ENERGISA N.FRIB.FIDC;8360146;146;3;0,31;0,31;0,31;4
ENERGISA PB - FIDC;8360149;149;3;0,31;0,31;0,31;4
ENERGISA PB - SAELPA;8360054;54;3;0,31;0,31;0,31;4
ENERGISA SE;8360049;49;3;0,31;0,31;0,31;4
ENERGISA SE - FIDC;8360148;148;3;0,31;0,31;0,31;4
ENERGISA SUL SUDESTE;8360155;155;3;0,30;0,16;0,16;4
ENERGISA SUL SUDESTE;8360042;42;3;0,30;0,16;0,16;4
ENERGISA SUL SUDESTE;8360001;1;3;0,30;0,16;0,16;4
ENERGISA SUL SUDESTE;8360028;28;3;0,30;0,16;0,16;4
ENERGISA SUL SUDESTE;8360025;25;3;0,30;0,16;0,16;4
ENERGISA SUL SUDESTE;8360043;43;3;0,30;0,16;0,16;4
ENERGISA TOCANTINS;8360173;173;3;0,36;0,36;0,18;4
ENERGISA TOCANTINS;8360012;12;3;0,36;0,36;0,18;3
ENERGISA TOCANTINS;8360093;93;3;0,36;0,36;0,18;4
ESCELSA ES;8360051;51;3;0,20;0,17;0,17;3
FCT TIMBÓ SC;8570608;608;5;1,32;1,24;1,12;4
FMDDD DE TIMBÓ SC;8570607;607;5;1,32;1,24;1,12;4
FMMA DE TIMBO SC;8560563;563;5;1,32;1,24;1,12;4
FOZ DE LIMEIRA SA SP;8260124;124;2;0,30;0,30;0,30;4
FUMDEC DE TIMBO SC;8560562;562;5;1,32;1,24;1,12;4
FUMTRAN DE TIMBO SC;8560564;564;5;1,32;1,24;1,12;4
FUMTUR TIMBÓ SC;8570753;753;5;1,39;1,27;1,18;4
GN SAO PAULO SUL;8360116;116;3;0,24;0,15;0,15;4
HUGHES BRASIL LTDA;8460430;430;4;0,51;0,39;0,27;4
ISIMPLES MG;8490067;67;4;0,00;0,00;0,72;4
LIGHT RJ ELETRIC;8360053;53;3;0,27;0,27;0,18;3
LITORAL SANEAMENT SC;8261149;1149;2;0,60;0,60;0,60;4
MANAUS AMBIENTAL AM;8260477;477;2;0,48;0,30;0,30;4
NET SERV COMUNICAÇ;8460296;296;4;0,54;0,42;0,30;4
NEXTEL TELECOMUNIC;8480089;89;4;0,36;0,36;0,21;4
OI BRTEL CELULAR 14;8460313;313;4;0,25;0,18;0,18;4
OI BRTEL FIXO ACRE;8460011;11;4;0,25;0,18;0,18;3
OI BRTEL FIXO DF;8460014;14;4;0,25;0,18;0,18;3
OI CELULAR;8460113;113;4;0,25;0,18;0,18;3
OI FIXO RO;8460026;26;4;0,25;0,18;0,18;3
OI FIXO/BANDA LARGA;024756;24;4;0,24;0,18;0,18;3
OI S/A 0220;8460220;220;4;0,25;0,18;0,18;4
OI TV;8460369;369;4;0,24;0,18;0,18;4
PERSIS INTERNET ES;8460446;446;4;0,60;0,48;0,36;4
PROLAGOS RJ;8260370;370;2;0,36;0,12;0,18;3
QNET TELECOM - PR;8460423;423;4;0,72;0,66;0,60;5
RGE - RS;8360089;89;3;0,40;0,21;0,21;4
RGE SUL DISTRIB RS;8360086;86;3;0,40;0,21;0,21;4
RORAIMA ENERGIA RR;8360075;75;3;0,45;0,45;0,21;4
SAAE BANANAL ES;8260419;419;2;0,61;0,59;0,50;4
SAAE CAPIVARI SP;8260062;62;2;0,48;0,42;0,36;4
SAAE CHAPADA GUI MT;8260673;673;2;0,90;0,90;0,60;4
SAAE GARÇA SP;8270068;68;2;1,14;0,91;0,52;4
SAAE ITAPEMIRIM ES;8260333;333;2;0,47;0,47;0,60;4
SAAE LENÇS PAULIS-SP;8260077;77;2;0,42;0,42;0,42;4
SAAE LINHARES ES;8260079;79;2;0,81;0,81;0,49;4
SAAE LUCAS R VERD-MT;8260178;178;2;0,80;0,74;0,69;4
SAAE LUZ MG;8261300;1300;2;0,87;0,87;0,00;4
SAAE NOVA MUTUM MT;8260082;82;2;0,80;0,80;0,80;4
SAAE PASSOS MG;8260085;85;2;0,71;0,71;0,71;4
SAAE PORTO FELIZ SP;8260160;160;2;0,76;0,67;0,47;4
SAAE SÃO CARLOS SP;8260089;89;2;0,72;0,54;0,45;4
SAAE SOROCABA SP;8260091;91;2;0,30;0,30;0,21;4
SAAE VIÇOSA MG;8260094;94;2;1,02;0,54;0,41;4
SAAE VILHENA RO;8260297;297;2;0,83;0,83;0,83;4
SAAEB BEBEDOURO SP;8260292;292;2;1,44;0,52;0,68;4
SAAEC CERQUILHO SP;8260285;285;2;0,30;0,45;0,36;4
SAAEJ JABOTICABAL SP;8260075;75;2;0,48;0,48;0,48;4
SAAESP SÃO PEDRO SP;8260918;918;2;0,90;0,90;0,42;4
SAAET TAQUARITING SP;8260092;92;2;0,45;0,45;0,27;4
SABESP;8260097;97;2;0,53;0,37;0,18;4
SABESP GUARULHOS;8261626;1626;2;0,53;0,37;0,18;4
SAE PEDRA BRANCA SC;8261223;1223;2;0,66;0,48;0,36;4
SAE SANTA ADELIA SP;8260834;834;2;0,66;0,66;0,66;4
SAECIL SP;8270098;98;2;0,57;0,45;0,36;4
SAEMA ARARAS SP;8260099;99;2;0,48;0,36;0,36;4
SAEMAP SP;8260512;512;2;0,90;0,66;0,54;4
SAMAE ARARANGUÁ SC;8260533;533;2;0,63;0,63;0,54;4
SAMAE BLUMENAU SC;8261304;1304;2;0,66;0,89;0,40;4
SAMAE CAXIAS DO SUL;8260337;337;2;0,48;0,41;0,39;4
SAMAE GASPAR-SC;8260158;158;2;1,69;0,52;0,52;4
SAMAE JARAGUA SUL-SC;8260101;101;2;0,70;0,70;0,37;4
SAMAE PALH PREF-SC;8261098;1098;2;0,66;0,66;0,51;4
SAMAE PALHOÇA SC;8261295;1295;2;0,66;0,66;0,51;4
SAMAE POMERODE SC;8260159;159;2;0,86;0,86;0,86;4
SAMAE RIO NEGRI SC;8260153;153;2;1,02;1,02;0,79;4
SAMAE S.BENTO SUL SC;8260120;120;2;0,94;0,94;0,94;4
SAMAE TIMBÓ SC;8260816;816;2;1,32;1,24;1,12;4
SAMAR ARAÇATUBA SP;8261345;1345;2;0,57;0,48;0,48;5
SANASA SP;8260105;105;2;0,00;0,00;0,00;4
SANEAR ES;8260467;467;2;0,66;0,66;0,66;4
SANEAR MT;8260341;341;2;0,36;0,36;0,36;4
SANECAP - MT;8260768;768;2;0,80;0,40;0,00;4
SANEPAR PR;8260109;109;2;0,25;0,25;0,25;3
SANESSOL SP;8260622;622;2;0,42;0,30;0,30;4
SAS BARBACENA MG;8260483;483;2;1,13;0,66;0,82;4
SAV VIRADOURO SP;8271115;1115;2;0,36;0,36;0,36;4
SEMAE PIRACICABA SP;8260121;121;2;0,84;0,84;0,38;4
SEMAE RIO QUENTE GO;8260907;907;2;1,14;0,72;0,54;4
SEMAE S.J.R PRETO SP;8260304;304;2;0,46;0,36;0,27;4
SEMASA - SP;8260113;113;2;0,36;0,30;0,12;4
SEMASA LAGES SC;8260843;843;2;0,39;0,39;0,22;4
SERCOMTEL - PR;8460007;7;4;0,36;0,24;0,12;5
SIMAE SC;8260114;114;2;0,82;0,82;0,82;4
SISAM - SC;8260986;986;2;0,56;0,56;0,56;3
SKY;8460379;379;4;0,48;0,30;0,27;4
TELEFONICA SP;08461029;1029;4;0,45;0,36;0,18;3
TELEGOIAS FIXA GO;8460016;16;4;0,25;0,18;0,18;3
TELEMAT FIXA - MT;8460017;17;4;0,25;0,18;0,18;3
TELEMS FIXA MS;8460019;19;4;0,25;0,18;0,18;3
TELEPAR FIXA PR;8460020;20;4;0,25;0,18;0,18;3
TELERS FIXA RS;8460002;2;4;0,25;0,18;0,18;3
TELESC FIXA SC;8460027;27;4;0,25;0,18;0,18;3
TIM CELULAR - 0109;8460109;109;4;0,30;0,24;0,18;4
TUBARÃO SANEA - SC;8261330;1330;2;0,57;0,50;0,41;4
ULTRAGAZ;8360137;137;3;0,30;0,30;0,24;4
VALENET MG;8460469;469;4;0,51;0,40;0,32;4
VIVO - AC;8460053;53;4;0,45;0,36;0,18;3
VIVO - AM;08460073;73;4;0,45;0,36;0,18;3
VIVO - AP;8460076;76;4;0,45;0,36;0,18;4
VIVO - BA;8460041;41;4;0,45;0,36;0,18;3
VIVO - DF;8460047;47;4;0,45;0,36;0,18;3
VIVO - ES;00607561;60;4;0,45;0,36;0,18;3
VIVO - GO;8460044;44;4;0,45;0,36;0,18;3
VIVO - MA;8460074;74;4;0,45;0,36;0,18;4
VIVO - MS;8460049;49;4;0,45;0,36;0,18;3
VIVO - MT;8460055;55;4;0,45;0,36;0,18;3
VIVO - PA;08460072;72;4;0,45;0,36;0,18;3
VIVO - RJ;00487561;48;4;0,45;0,36;0,18;3
VIVO - RO;8460058;58;4;0,45;0,36;0,18;3
VIVO - RR;8460075;75;4;0,45;0,36;0,18;4
VIVO - RS;8460079;79;4;0,45;0,36;0,18;4
VIVO - SE;8460042;42;4;0,45;0,36;0,18;4
VIVO - SP;8460080;80;4;0,45;0,36;0,18;4
VIVO - TO;8460081;81;4;0,45;0,36;0,18;3
VIVO PARTICIPAÇÕES;8460064;64;4;0,24;0,24;0,12;3
VIVO PR_SC;8460069;69;4;0,45;0,36;0,18;3
VIVO-TELEFONICA;8460082;82;4;0,24;0,12;0,12;3
VOXBRAS ES;8460396;396;4;0,60;0,42;0,42;4
YAH TELECOM RJ;8460466;466;4;0,51;0,39;0,27;5
ZAP TELECOM MG;8460440;440;4;0,57;0,45;0,36;4';
	--Manipulação do texto do arquivo
	vr_linhascsv gene0002.typ_split;
	vr_linhacsv  gene0002.typ_split;
	
	vr_nmconven crapcon.nmextcon%TYPE;
	vr_cdempres tbconv_arrecadacao.cdempres%TYPE;
	vr_cdempcon crapcon.cdempcon%TYPE;
	vr_cdsegmto crapcon.cdsegmto%TYPE;
	vr_vltarcxa NUMBER(9,2);
	vr_vltarele NUMBER(9,2);
	vr_vltdebau NUMBER(9,2);
	vr_nrlayout INTEGER;
	vr_flgsicre INTEGER;
	vr_flgbancb INTEGER;
	vr_clob_conv_migra CLOB := '########################### CONVENIOS MIGRADOS SICREDI -> BANCOOB ###########################' || chr(10)|| chr(10);
	vr_clob_conv_inclb CLOB := '################################ CONVENIOS BANCOOB INCLUIDOS ################################' || chr(10)|| chr(10);
	vr_clob_conv_incla CLOB := '######################### CONVENIOS BANCOOB INCLUIDOS (ARR. AILOS) ##########################' || chr(10)|| chr(10);
	vr_clob_conv_sicca CLOB := '################################ CONVENIOS SICREDI CANCELADOS ###############################' || chr(10)|| chr(10);
	vr_clob_erros      CLOB := '########################################### ERROS ###########################################' || chr(10)|| chr(10);
	
	-- Satisfazer exigencias da interface
	vr_xmllog   VARCHAR2(4000);             --> XML com informações de LOG
	vr_cdcritic PLS_INTEGER;          --> Código da crítica
	vr_dscritic VARCHAR2(4000);             --> Descrição da crítica
	vr_retxml   XMLType;              --> Arquivo de retorno do XML
	vr_nmdcampo VARCHAR2(500);             --> Nome do campo com erro
	vr_des_erro VARCHAR2(4000);	
		
	CURSOR cr_crapcon (pr_cdempcon IN crapcon.cdempcon%TYPE
	                  ,pr_cdsegmto IN crapcon.cdsegmto%TYPE
										,pr_cdcooper IN crapcon.cdcooper%TYPE) IS
		SELECT con.tparrecd
		      ,con.nmrescon
					,con.nmextcon
					,con.cdhistor
					,con.flgaccec
		  FROM crapcon con
		 WHERE con.cdempcon = pr_cdempcon
		   AND con.cdsegmto = pr_cdsegmto
			 AND con.cdcooper = pr_cdcooper;
	rw_crapcon cr_crapcon%ROWTYPE;		
	
	CURSOR cr_crapscn IS		
    SELECT scn.cdempcon
		      ,scn.cdsegmto
					,scn.cdempres
					,scn.dsoparre
		  FROM crapscn scn
		 WHERE scn.dtencemp IS NULL
		   AND scn.cdempcon <> 0;
	rw_crapscn cr_crapscn%ROWTYPE;
		
  CURSOR cr_tbconv_arrecadacao(pr_cdempcon IN tbconv_arrecadacao.cdempcon%TYPE
                              ,pr_cdsegmto IN tbconv_arrecadacao.cdsegmto%TYPE) IS        
    SELECT tpdias_repasse
          ,nrdias_float
          ,nrdias_tolerancia
          ,dtencemp
          ,nrlayout
          ,vltarifa_caixa
          ,vltarifa_debaut
          ,vltarifa_internet
          ,vltarifa_taa
					,cdempres
					,cdempcon
					,cdsegmto
					,tparrecadacao
      FROM tbconv_arrecadacao conv
     WHERE conv.cdempcon = pr_cdempcon
       AND conv.cdsegmto = pr_cdsegmto;
  rw_tbconv_arrecadacao cr_tbconv_arrecadacao%ROWTYPE;
	
	CURSOR cr_tbconv_arrecadacao_t IS
	  SELECT arr.rowid
	    FROM tbconv_arrecadacao arr
		 WHERE arr.cdmodalidade IS NULL;	
	
	FUNCTION fn_quebra_string(pr_string   IN CLOB
                           ,pr_delimit  IN CHAR DEFAULT ',') RETURN gene0002.typ_split IS

    vr_vlret    gene0002.typ_split := gene0002.typ_split();
    vr_quebra   LONG DEFAULT pr_string || pr_delimit;
    vr_idx      NUMBER;

  BEGIN
	  -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => 'GENE0002.fn_quebra_string');
    --Se a string estiver nula retorna count = 0 no vetor
    IF nvl(pr_string,'#') = '#' THEN
      RETURN vr_vlret;
    END IF;

    LOOP
      -- Identifica ponto de quebra inicial
      vr_idx := instr(vr_quebra, pr_delimit);

      -- Clausula de saída para o loop
      exit WHEN nvl(vr_idx, 0) = 0;

      -- Acrescenta elemento para a coleção
      vr_vlret.EXTEND;
      -- Acresce mais um registro gravado no array com o bloco de quebra
      vr_vlret(vr_vlret.count) := trim(substr(vr_quebra, 1, vr_idx - 1));
      -- Atualiza a variável com a string integral eliminando o bloco quebrado
      vr_quebra := substr(vr_quebra, vr_idx + LENGTH(pr_delimit));
    END LOOP;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);

    -- Retorno do array com as substrings separadas em cada registro
    RETURN vr_vlret;
  END fn_quebra_string;
	
	PROCEDURE pc_libera_conven (pr_cdempres IN tbconv_arrecadacao.cdempres%TYPE
		                         ,pr_cdempcon IN crapcon.cdempcon%TYPE
														 ,pr_cdsegmto IN crapcon.cdsegmto%TYPE) IS
														 
		vr_exc_null EXCEPTION;
														 
		CURSOR cr_crapcop IS
			SELECT cop.cdcooper
				FROM crapcop cop
			 WHERE cop.flgativo = 1;
	     
		CURSOR cr_tbconv_liberacao(pr_cdcooper IN tbconv_liberacao.cdcooper%TYPE
															,pr_cdempres IN tbconv_liberacao.cdempres%TYPE) IS
			SELECT lib.idseqconvelib
				FROM tbconv_liberacao lib
			 WHERE lib.cdcooper = pr_cdcooper
				 AND lib.cdempres = pr_cdempres
				 AND lib.tparrecadacao = 2;
		rw_tbconv_liberacao cr_tbconv_liberacao%ROWTYPE;
	  
		CURSOR cr_tbgen_canal_entrada IS
			SELECT can.cdcanal
				FROM tbgen_canal_entrada can
			 WHERE can.cdcanal IN (2,3,4);
	     
		CURSOR cr_tbconv_canalcoop_liberado(pr_cdcanal IN tbconv_canalcoop_liberado.cdcanal%TYPE
																			 ,pr_idseqconvelib IN tbconv_canalcoop_liberado.idseqconvelib%TYPE) IS
			SELECT lib.flgliberado
						,lib.idsequencia
				FROM tbconv_canalcoop_liberado lib
			 WHERE lib.cdcanal = pr_cdcanal
				 AND lib.idseqconvelib = pr_idseqconvelib;
		rw_tbconv_canalcoop_liberado cr_tbconv_canalcoop_liberado%ROWTYPE;
																 
		BEGIN
			FOR rw_crapcop IN cr_crapcop LOOP
				OPEN cr_tbconv_liberacao(pr_cdcooper => rw_crapcop.cdcooper
																,pr_cdempres => pr_cdempres);
				FETCH cr_tbconv_liberacao INTO rw_tbconv_liberacao;
                
				IF cr_tbconv_liberacao%NOTFOUND THEN
					--INSERIR tbconv_liberacao   
					BEGIN            
						INSERT INTO tbconv_liberacao
							(idseqconvelib,
							 tparrecadacao,
							 cdcooper,
							 cdempres,
							 cdconven,
							 flgautdb)
						VALUES
							(tbconv_liberacao_seq.nextval,
							 2,
							 rw_crapcop.cdcooper,
							 pr_cdempres,
							 0,
							 0)
						RETURNING tbconv_liberacao.idseqconvelib INTO rw_tbconv_liberacao.idseqconvelib;
					EXCEPTION
						WHEN OTHERS THEN
							vr_clob_erros := vr_clob_erros || to_clob('Erro ao atualizar liberacao de convenio Bancoob -> cdempcon: ' || pr_cdempcon || 
																																 ', cdsegmto: ' || pr_cdsegmto ||
																																 ', cdempres: ' || pr_cdempres ||
																																 ', cdcooper: ' || rw_crapcop.cdcooper ||
                                                                 ', dscritic: ' || SQLERRM || chr(10));
							RAISE vr_exc_null;
					END;        
				END IF;
				CLOSE cr_tbconv_liberacao;
                
				FOR rw_tbgen_canal_entrada IN cr_tbgen_canal_entrada LOOP
					OPEN cr_tbconv_canalcoop_liberado(pr_cdcanal => rw_tbgen_canal_entrada.cdcanal
																					 ,pr_idseqconvelib => rw_tbconv_liberacao.idseqconvelib);
					FETCH cr_tbconv_canalcoop_liberado INTO rw_tbconv_canalcoop_liberado;
                  
					-- Inserir registro
					IF cr_tbconv_canalcoop_liberado%NOTFOUND THEN
						BEGIN
								INSERT INTO tbconv_canalcoop_liberado
									(idsequencia,
									 idseqconvelib,
									 cdsegmto,
									 cdempcon,
									 cdcanal,
									 flgliberado)
								VALUES
									(tbconv_canalcoop_liberado_seq.nextval,
									 rw_tbconv_liberacao.idseqconvelib,
									 pr_cdsegmto,
									 pr_cdempcon,
									 rw_tbgen_canal_entrada.cdcanal,
									 1);
							EXCEPTION
								WHEN OTHERS THEN
									vr_clob_erros := vr_clob_erros || to_clob('Erro ao inserir canal de liberacao de convenio Bancoob -> cdempcon: ' || pr_cdempcon || 
																									 ', cdsegmto: ' || pr_cdsegmto ||
																									 ', cdempres: ' || pr_cdempres ||
																									 ', cdcooper: ' || rw_crapcop.cdcooper ||
                                                   ', dscritic: ' || SQLERRM || chr(10));
                  RAISE vr_exc_null;
						END;              
					END IF;
					CLOSE cr_tbconv_canalcoop_liberado;
					IF rw_tbconv_canalcoop_liberado.flgliberado = 0 THEN
						BEGIN
							UPDATE tbconv_canalcoop_liberado
								 SET flgliberado = 1
							 WHERE idsequencia = rw_tbconv_canalcoop_liberado.idsequencia; 
							EXCEPTION
								WHEN OTHERS THEN
									vr_clob_erros := vr_clob_erros || to_clob('Erro ao atualizar canal de liberacao de convenio Bancoob -> cdempcon: ' || pr_cdempcon || 
																									 ', cdsegmto: ' || pr_cdsegmto ||
																									 ', cdempres: ' || pr_cdempres ||
																									 ', cdcooper: ' || rw_crapcop.cdcooper ||
                                                   ', dscritic: ' || SQLERRM|| chr(10));
                  RAISE vr_exc_null;
						END;                          
					END IF;
				END LOOP;
			END LOOP; 
	EXCEPTION
		WHEN vr_exc_null THEN
			NULL;
	END pc_libera_conven;
	
begin
  	
  -- Atualizar código de convenios especificos que seguem um formato diferenciado
  BEGIN
    UPDATE tbconv_arrecadacao arr
       SET arr.cdempres = '00067561'
     WHERE arr.cdempres = '67561'; -- EMBRATEL

    UPDATE tbconv_arrecadacao arr
       SET arr.cdempres = '00487561'
     WHERE arr.cdempres = '487561'; -- VIVO - RJ
     
    UPDATE tbconv_arrecadacao arr
       SET arr.cdempres = '00607561'
     WHERE arr.cdempres = '607561'; -- VIVO - ES
     
    UPDATE tbconv_arrecadacao arr
       SET arr.cdempres = '024756'
     WHERE arr.cdempres = '24756'; -- TELEMAR-RJ
     
    UPDATE tbconv_arrecadacao arr
       SET arr.cdempres = '08460072'
     WHERE arr.cdempres = '8460072'; -- VIVO - PA
     
    UPDATE tbconv_arrecadacao arr
       SET arr.cdempres = '08460073'
     WHERE arr.cdempres = '8460073'; -- VIVO - AM
     
    UPDATE tbconv_arrecadacao arr
       SET arr.cdempres = '08461029'
     WHERE arr.cdempres = '8461029'; -- TELEFONICA SP
  END;
	
	vr_linhascsv := fn_quebra_string(arq_csv, CHR(10));
	FOR i IN 1 .. vr_linhascsv.COUNT
	LOOP
		vr_linhacsv := fn_quebra_string(vr_linhascsv(i), ';');
		vr_nmconven := vr_linhacsv(1);
		vr_cdempres := vr_linhacsv(2);
		vr_cdempcon := to_number(vr_linhacsv(3));
		vr_cdsegmto := to_number(vr_linhacsv(4));
		vr_vltarcxa := to_number(vr_linhacsv(5));
		vr_vltarele := to_number(vr_linhacsv(6));
		vr_vltdebau := to_number(vr_linhacsv(7));
		vr_nrlayout := to_number(vr_linhacsv(8));
		vr_flgsicre := 0;
		vr_flgbancb := 0;
		-- Criar xml da tela para satisfazer interface
	  vr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="WINDOWS-1252"?><Root><Dados></Dados><params><nmprogra>TELA_CONVEN</nmprogra><nmeacao>GRAVAR_DADOS_CONVEN_PARC</nmeacao><cdcooper>3</cdcooper><cdagenci>0</cdagenci><nrdcaixa>0</nrdcaixa><idorigem>5</idorigem><cdoperad>1</cdoperad><filesphp>/var/www/ayllos/telas/conven/manter_rotina.php</filesphp></params><Permissao><nmdatela>CONVEN</nmdatela><nmrotina/><cddopcao>I</cddopcao><idsistem>1</idsistem><inproces>1</inproces><cdagecxa>0</cdagecxa><nrdcaixa>0</nrdcaixa><cdopecxa>1</cdopecxa><idorigem>5</idorigem></Permissao></Root>');              --> Arquivo de retorno do XML		
		IF (vr_cdempcon = 64  AND vr_cdsegmto = 5) OR
			 (vr_cdempcon = 385 AND vr_cdsegmto = 5) OR
			 (vr_cdempcon = 153 AND vr_cdsegmto = 5) OR
			 (vr_cdempcon = 154 AND vr_cdsegmto = 5) OR
			 (vr_cdempcon = 328 AND vr_cdsegmto = 5) OR
			 (vr_cdempcon = 270 AND vr_cdsegmto = 5) THEN
			-- Não migraremos tributos neste momento
      CONTINUE;
    END IF;
		
		OPEN cr_tbconv_arrecadacao(pr_cdempcon => vr_cdempcon
          										,pr_cdsegmto => vr_cdsegmto);
		FETCH cr_tbconv_arrecadacao INTO rw_tbconv_arrecadacao;
		
		-- Já existe convenio bancoob cadastrado
		IF cr_tbconv_arrecadacao%FOUND THEN
			vr_flgbancb:= 1;
		END IF;
		CLOSE cr_tbconv_arrecadacao;
				
    OPEN cr_crapcon (pr_cdempcon => vr_cdempcon
                    ,pr_cdsegmto => vr_cdsegmto
										,pr_cdcooper => 3);
    FETCH cr_crapcon INTO rw_crapcon;
    
    -- Verificar agente arrecadador
    IF cr_crapcon%FOUND THEN
	    CLOSE cr_crapcon;
			-- Convênio já cadastrado e arrecadando no Bancoob
			IF rw_crapcon.tparrecd = 2 AND vr_flgbancb = 1 THEN
        BEGIN
					UPDATE tbconv_arrecadacao arr
					   SET arr.cdmodalidade = 1
					 WHERE arr.cdempres = rw_tbconv_arrecadacao.cdempres
					   AND arr.tparrecadacao = rw_tbconv_arrecadacao.tparrecadacao;
        EXCEPTION
				  WHEN OTHERS THEN
						vr_clob_erros := vr_clob_erros || to_clob('Erro ao atualizar convenio Bancoob -> cdempcon: ' || vr_cdempcon || 
																						 ', cdsegmto: ' || vr_cdsegmto ||
																						 ', cdempres: ' || rw_tbconv_arrecadacao.cdempres ||
																						 ', dscritic: ' || SQLERRM|| chr(10));
        END;				
				CONTINUE;
			ELSIF rw_crapcon.tparrecd = 3 THEN
        -- Convênio cadastrado e arrecadando na Ailos, mas sem cadsatro no Bancoob
        IF vr_flgbancb = 0 THEN
					vr_clob_conv_incla := vr_clob_conv_incla || to_clob(
															 'Convênio: ' || vr_nmconven || CHR(10) ||
															 'Cod. Empresa: ' || vr_cdempres || CHR(10) ||
															 'Cod. Febaban: ' || vr_cdempcon || CHR(10) ||
															 'Cod. Segmto: ' || vr_cdsegmto || CHR(10) ||
															 '------------------------------------------' || CHR(10));						
					-- Cadastrar novo convênio no Bancoob
					tela_conven.pc_grava_conv_parceiros(pr_cddopcao           => 'I',
																						  pr_tparrecd           => 2,
																						  pr_cdconven           => vr_cdempres,
																						  pr_nmfantasia         => rw_crapcon.nmrescon,
																						  pr_rzsocial           => rw_crapcon.nmextcon,
																						  pr_cdhistor           => rw_crapcon.cdhistor,
																						  pr_codfebraban        => vr_cdempcon,
																						  pr_cdsegmento         => vr_cdsegmto,
																						  pr_vltarint           => vr_vltarele,
																						  pr_vltartaa           => vr_vltarele,
																						  pr_vltarcxa           => vr_vltarcxa,
																						  pr_vltardeb           => vr_vltdebau,
																						  pr_vltarcor           => 0,
																						  pr_vltararq           => 0,
																						  pr_nrrenorm           => 0,
																						  pr_nrtolera           => 99,
																						  pr_dsdianor           => 'U',
																						  pr_dtcancel           => null,
																						  pr_layout_arrecadacao => vr_nrlayout,
																						  pr_flgaccec           => rw_crapcon.flgaccec,
																						  pr_flgacsic           => 0,
																						  pr_flgacbcb           => 1,
																						  pr_forma_arrecadacao  => rw_crapcon.tparrecd, --> Ailos
																						  pr_nrlayout_debaut    => 0,
																						  pr_tam_optante        => 0,
																						  pr_cdmodalidade       => 1,
																						  pr_dsdsigla           => ' ',
																						  pr_nrseqint           => 1,
																						  pr_nrseqatu           => 1,
																						  pr_xmllog             => vr_xmllog,
																						  pr_cdcritic           => vr_cdcritic,
																						  pr_dscritic           => vr_dscritic,
																						  pr_retxml             => vr_retxml,
																						  pr_nmdcampo           => vr_nmdcampo,
																						  pr_des_erro           => vr_des_erro);           
	                                        
					IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
						vr_clob_erros := vr_clob_erros || to_clob('Erro ao inserir convenio Bancoob -> cdempcon: ' || vr_cdempcon || 
																																	 ', cdsegmto: ' || vr_cdsegmto ||
																																	 ', cdempres: ' || vr_cdempres  ||
                                                                   ', dscritic: ' || vr_dscritic|| chr(10));
						CONTINUE;
					END IF; 
					
					pc_libera_conven (pr_cdempres => vr_cdempres        
					                 ,pr_cdempcon => vr_cdempcon
													 ,pr_cdsegmto => vr_cdsegmto);
        END IF;
			-- Sicredi
			ELSE
				-- Se existe cadastro no Bancoob, só precisamos alterar convênio para arrecadar no Bancoob
				IF vr_flgbancb = 1 THEN
          vr_clob_conv_migra := vr_clob_conv_migra || to_clob(
                               'Convênio: ' || vr_nmconven || CHR(10) ||
                               'Cod. Empresa: ' || vr_cdempres || CHR(10) ||
                               'Cod. Febaban: ' || vr_cdempcon || CHR(10) ||
                               'Cod. Segmto: ' || vr_cdsegmto || CHR(10) ||
                               '------------------------------------------' || CHR(10));
	        tela_conven.pc_grava_conv_parceiros(pr_cddopcao           => 'A',
                                             pr_tparrecd           => 2,
                                             pr_cdconven           => vr_cdempres,
                                             pr_nmfantasia         => substr(vr_nmconven,1,15),
                                             pr_rzsocial           => vr_nmconven,
                                             pr_cdhistor           => 2515,
                                             pr_codfebraban        => vr_cdempcon,
                                             pr_cdsegmento         => vr_cdsegmto,
                                             pr_vltarint           => rw_tbconv_arrecadacao.vltarifa_internet,
                                             pr_vltartaa           => rw_tbconv_arrecadacao.vltarifa_taa,
                                             pr_vltarcxa           => rw_tbconv_arrecadacao.vltarifa_caixa,
                                             pr_vltardeb           => rw_tbconv_arrecadacao.vltarifa_debaut,
                                             pr_vltarcor           => 0,
                                             pr_vltararq           => 0,
                                             pr_nrrenorm           => rw_tbconv_arrecadacao.nrdias_float,
                                             pr_nrtolera           => rw_tbconv_arrecadacao.nrdias_tolerancia,
                                             pr_dsdianor           => rw_tbconv_arrecadacao.tpdias_repasse,
                                             pr_dtcancel           => NULL,
                                             pr_layout_arrecadacao => rw_tbconv_arrecadacao.nrlayout,
                                             pr_flgaccec           => rw_crapcon.flgaccec,
                                             pr_flgacsic           => 0,
                                             pr_flgacbcb           => 1,
                                             pr_forma_arrecadacao  => 2,
                                             pr_nrlayout_debaut    => 0,
                                             pr_tam_optante        => 0,
                                             pr_cdmodalidade       => 1,
                                             pr_dsdsigla           => ' ',
                                             pr_nrseqint           => 1,
                                             pr_nrseqatu           => 1,
                                             pr_xmllog             => vr_xmllog,
                                             pr_cdcritic           => vr_cdcritic,
                                             pr_dscritic           => vr_dscritic,
                                             pr_retxml             => vr_retxml,
                                             pr_nmdcampo           => vr_nmdcampo,
                                             pr_des_erro           => vr_des_erro);
																				
					IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
						vr_clob_erros := vr_clob_erros || to_clob('Erro ao atualizar convenio Bancoob -> cdempcon: ' || vr_cdempcon || 
																																		 ', cdsegmto: ' || vr_cdsegmto ||
																																		 ', cdempres: ' || vr_cdempres ||
                                                                     ', dscritic: ' || vr_dscritic|| chr(10));
						CONTINUE;
					END IF;
          pc_libera_conven (pr_cdempres => vr_cdempres
                           ,pr_cdempcon => vr_cdempcon
                           ,pr_cdsegmto => vr_cdempres);					
						
				ELSE
          vr_clob_conv_inclb := vr_clob_conv_inclb || to_clob(
                               'Convênio: ' || vr_nmconven || CHR(10) ||
                               'Cod. Empresa: ' || vr_cdempres || CHR(10) ||
                               'Cod. Febaban: ' || vr_cdempcon || CHR(10) ||
                               'Cod. Segmto: ' || vr_cdsegmto || CHR(10) ||
                               '------------------------------------------' || CHR(10));
					-- Cadastrar novo convênio no Bancoob
          tela_conven.pc_grava_conv_parceiros(pr_cddopcao           => 'I',
                                              pr_tparrecd           => 2,
                                              pr_cdconven           => vr_cdempres,
                                              pr_nmfantasia         => substr(vr_nmconven,1,15),
                                              pr_rzsocial           => vr_nmconven,
                                              pr_cdhistor           => 2515,
                                              pr_codfebraban        => vr_cdempcon,
                                              pr_cdsegmento         => vr_cdsegmto,
                                              pr_vltarint           => vr_vltarele,
                                              pr_vltartaa           => vr_vltarele,
                                              pr_vltarcxa           => vr_vltarcxa,
                                              pr_vltardeb           => vr_vltdebau,
                                              pr_vltarcor           => 0,
                                              pr_vltararq           => 0,
                                              pr_nrrenorm           => 0,
                                              pr_nrtolera           => 99,
                                              pr_dsdianor           => 'U',
                                              pr_dtcancel           => null,
                                              pr_layout_arrecadacao => vr_nrlayout,
                                              pr_flgaccec           => rw_crapcon.flgaccec,
                                              pr_flgacsic           => 0,
                                              pr_flgacbcb           => 1,
                                              pr_forma_arrecadacao  => 2, --> Bancoob
                                              pr_nrlayout_debaut    => 0,
                                              pr_tam_optante        => 0,
                                              pr_cdmodalidade       => 1,
                                              pr_dsdsigla           => ' ',
                                              pr_nrseqint           => 1,
                                              pr_nrseqatu           => 1,
                                              pr_xmllog             => vr_xmllog,
                                              pr_cdcritic           => vr_cdcritic,
                                              pr_dscritic           => vr_dscritic,
                                              pr_retxml             => vr_retxml,
                                              pr_nmdcampo           => vr_nmdcampo,
                                              pr_des_erro           => vr_des_erro);         
                                        
					IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
						vr_clob_erros := vr_clob_erros || to_clob('Erro ao inserir convenio Bancoob -> cdempcon: ' || vr_cdempcon || 
																																	 ', cdsegmto: ' || vr_cdsegmto ||
																																	 ', cdempres: ' || vr_cdempres ||
                                                                   ', dscritic: ' || vr_dscritic|| chr(10));
					  CONTINUE;
					END IF;
          pc_libera_conven (pr_cdempres => vr_cdempres        
                           ,pr_cdempcon => vr_cdempcon
                           ,pr_cdsegmto => vr_cdsegmto);						
						
				END IF;
			END IF;
		ELSE
	    CLOSE cr_crapcon;
			vr_clob_conv_inclb := vr_clob_conv_inclb || to_clob(
													 'Convênio: ' || vr_nmconven || CHR(10) ||
													 'Cod. Empresa: ' || vr_cdempres || CHR(10) ||
													 'Cod. Febaban: ' || vr_cdempcon || CHR(10) ||
													 'Cod. Segmto: ' || vr_cdsegmto || CHR(10) ||
													 '------------------------------------------' || CHR(10));
			-- Cadastrar novo convênio no Bancoob
			tela_conven.pc_grava_conv_parceiros(pr_cddopcao           => 'I',
																					pr_tparrecd           => 2,
																					pr_cdconven           => vr_cdempres,
																					pr_nmfantasia         => substr(vr_nmconven,1,15),
																					pr_rzsocial           => vr_nmconven,
																					pr_cdhistor           => 2515,
																					pr_codfebraban        => vr_cdempcon,
																					pr_cdsegmento         => vr_cdsegmto,
																					pr_vltarint           => vr_vltarele,
																					pr_vltartaa           => vr_vltarele,
																					pr_vltarcxa           => vr_vltarcxa,
																					pr_vltardeb           => vr_vltdebau,
																					pr_vltarcor           => 0,
																					pr_vltararq           => 0,
																					pr_nrrenorm           => 0,
																					pr_nrtolera           => 99,
																					pr_dsdianor           => 'U',
																					pr_dtcancel           => null,
																					pr_layout_arrecadacao => vr_nrlayout,
																					pr_flgaccec           => 0,
																					pr_flgacsic           => 0,
																					pr_flgacbcb           => 1,
																					pr_forma_arrecadacao  => 2, --> Bancoob
																					pr_nrlayout_debaut    => 0,
																					pr_tam_optante        => 0,
																					pr_cdmodalidade       => 1,
																					pr_dsdsigla           => ' ',
																					pr_nrseqint           => 1,
																					pr_nrseqatu           => 1,
																					pr_xmllog             => vr_xmllog,
																					pr_cdcritic           => vr_cdcritic,
																					pr_dscritic           => vr_dscritic,
																					pr_retxml             => vr_retxml,
																					pr_nmdcampo           => vr_nmdcampo,
																					pr_des_erro           => vr_des_erro);         
                                        
			IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				vr_clob_erros := vr_clob_erros || to_clob('Erro ao inserir convenio Bancoob -> cdempcon: ' || vr_cdempcon || 
																															 ', cdsegmto: ' || vr_cdsegmto ||
																															 ', cdempres: ' || vr_cdempres ||
                                                               ', dscritic: ' || vr_dscritic|| chr(10));
			  CONTINUE;
			END IF;
			pc_libera_conven (pr_cdempres => vr_cdempres        
											 ,pr_cdempcon => vr_cdempcon
											 ,pr_cdsegmto => vr_cdsegmto);
    END IF;
	END LOOP;
	
	-- Percorrer todos os convênios sicredi
	FOR rw_crapscn IN cr_crapscn LOOP
		
	  -- Não migraremos tributos neste momento
		IF rw_crapscn.cdempres IN('147','149','609','K0','A0','D0','C06') THEN
			CONTINUE;
		END IF;
		
		IF rw_crapscn.dsoparre = 'E' THEN
			-- Desprezar convenios de D.A.
			CONTINUE;
		END IF;
	
	  OPEN cr_crapcon	(pr_cdempcon => rw_crapscn.cdempcon
                    ,pr_cdsegmto => rw_crapscn.cdsegmto
										,pr_cdcooper => 3);
		FETCH cr_crapcon INTO rw_crapcon;
		
		IF cr_crapcon%NOTFOUND THEN
			CLOSE cr_crapcon;
			CONTINUE;
		END IF;
		CLOSE cr_crapcon;
		-- Criar xml da tela para satisfazer interface
	  vr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="WINDOWS-1252"?><Root><Dados></Dados><params><nmprogra>TELA_CONVEN</nmprogra><nmeacao>GRAVAR_DADOS_CONVEN_PARC</nmeacao><cdcooper>3</cdcooper><cdagenci>0</cdagenci><nrdcaixa>0</nrdcaixa><idorigem>5</idorigem><cdoperad>1</cdoperad><filesphp>/var/www/ayllos/telas/conven/manter_rotina.php</filesphp></params><Permissao><nmdatela>CONVEN</nmdatela><nmrotina/><cddopcao>I</cddopcao><idsistem>1</idsistem><inproces>1</inproces><cdagecxa>0</cdagecxa><nrdcaixa>0</nrdcaixa><cdopecxa>1</cdopecxa><idorigem>5</idorigem></Permissao></Root>');              --> Arquivo de retorno do XML		    
		
		BEGIN		
      vr_clob_conv_sicca := vr_clob_conv_sicca || to_clob(
                           'Convênio: ' || rw_crapcon.nmrescon || CHR(10) ||
                           'Cod. Empresa: ' || rw_crapscn.cdempres || CHR(10) ||
                           'Cod. Febaban: ' || rw_crapscn.cdempcon || CHR(10) ||
                           'Cod. Segmto: ' || rw_crapscn.cdsegmto || CHR(10) ||
                           '------------------------------------------' || CHR(10));
      UPDATE crapscn
         SET dtencemp = trunc(SYSDATE)
       WHERE crapscn.cdempres = rw_crapscn.cdempres;
				 
			UPDATE crapcon
			   SET flgacsic = 0
			 WHERE crapcon.cdempcon = rw_crapscn.cdempcon
			   AND crapcon.cdsegmto = rw_crapscn.cdsegmto;
    EXCEPTION
			WHEN OTHERS THEN
	      vr_clob_erros := vr_clob_erros || to_clob('Erro ao cancelar convenio Sicredi -> cdempcon: ' || rw_crapscn.cdempcon || 
																				          ', cdsegmto: ' || rw_crapscn.cdsegmto ||
																				          ', cdempres: ' || rw_crapscn.cdempres ||
                                                  ', dscritic: ' || SQLERRM|| chr(10));	
				CONTINUE;			 
		END;
		
		-- Este convenio de DARF vamos apenas cancelar
		IF rw_crapscn.cdempres = '608' THEN
			CONTINUE;
		END IF;
		
		-- Se já arrecada pelo Bancoob ou Ailos
    IF rw_crapcon.tparrecd = 2 OR rw_crapcon.tparrecd = 3 THEN
			CONTINUE;	
		END IF;
					
		OPEN cr_tbconv_arrecadacao(pr_cdempcon => rw_crapscn.cdempcon
		                          ,pr_cdsegmto => rw_crapscn.cdsegmto);
		FETCH cr_tbconv_arrecadacao INTO rw_tbconv_arrecadacao;
		
		IF cr_tbconv_arrecadacao%FOUND THEN
			CLOSE cr_tbconv_arrecadacao;
			vr_clob_conv_migra := vr_clob_conv_migra || to_clob(
													 'Convênio: ' || rw_crapcon.nmrescon || CHR(10) ||
													 'Cod. Empresa: ' || rw_tbconv_arrecadacao.cdempres || CHR(10) ||
													 'Cod. Febaban: ' || rw_tbconv_arrecadacao.cdempcon || CHR(10) ||
													 'Cod. Segmto: ' || rw_tbconv_arrecadacao.cdsegmto || CHR(10) ||
													 '------------------------------------------' || CHR(10));
													 
			tela_conven.pc_grava_conv_parceiros(pr_cddopcao           => 'A',
																					 pr_tparrecd           => 2,
																					 pr_cdconven           => rw_tbconv_arrecadacao.cdempres,
																					 pr_nmfantasia         => substr(vr_nmconven,1,15),
																					 pr_rzsocial           => vr_nmconven,
																					 pr_cdhistor           => 2515,
																					 pr_codfebraban        => rw_tbconv_arrecadacao.cdempcon,
																					 pr_cdsegmento         => rw_tbconv_arrecadacao.cdsegmto,
																					 pr_vltarint           => rw_tbconv_arrecadacao.vltarifa_internet,
																					 pr_vltartaa           => rw_tbconv_arrecadacao.vltarifa_taa,
																					 pr_vltarcxa           => rw_tbconv_arrecadacao.vltarifa_caixa,
																					 pr_vltardeb           => rw_tbconv_arrecadacao.vltarifa_debaut,
																					 pr_vltarcor           => 0,
																					 pr_vltararq           => 0,
																					 pr_nrrenorm           => rw_tbconv_arrecadacao.nrdias_float,
																					 pr_nrtolera           => rw_tbconv_arrecadacao.nrdias_tolerancia,
																					 pr_dsdianor           => rw_tbconv_arrecadacao.tpdias_repasse,
																					 pr_dtcancel           => NULL,
																					 pr_layout_arrecadacao => rw_tbconv_arrecadacao.nrlayout,
																					 pr_flgaccec           => rw_crapcon.flgaccec,
																					 pr_flgacsic           => 0,
																					 pr_flgacbcb           => 1,
																					 pr_forma_arrecadacao  => 2,
																					 pr_nrlayout_debaut    => 0,
																					 pr_tam_optante        => 0,
																					 pr_cdmodalidade       => 1,
																					 pr_dsdsigla           => ' ',
																					 pr_nrseqint           => 1,
																					 pr_nrseqatu           => 1,
																					 pr_xmllog             => vr_xmllog,
																					 pr_cdcritic           => vr_cdcritic,
																					 pr_dscritic           => vr_dscritic,
																					 pr_retxml             => vr_retxml,
																					 pr_nmdcampo           => vr_nmdcampo,
																					 pr_des_erro           => vr_des_erro);
																	
			IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				vr_clob_erros := vr_clob_erros || to_clob('Erro ao atualizar convenio Bancoob -> cdempcon: ' || rw_tbconv_arrecadacao.cdempcon || 
																																 ', cdsegmto: ' || rw_tbconv_arrecadacao.cdsegmto ||
																																 ', cdempres: ' || rw_tbconv_arrecadacao.cdempres ||
																																 ', dscritic: ' || vr_dscritic|| chr(10));
				CONTINUE;
			END IF;
			
			pc_libera_conven (pr_cdempres => rw_tbconv_arrecadacao.cdempres        
											 ,pr_cdempcon => rw_tbconv_arrecadacao.cdempcon
											 ,pr_cdsegmto => rw_tbconv_arrecadacao.cdsegmto);
					
		ELSE
			CLOSE cr_tbconv_arrecadacao;											
			BEGIN
      UPDATE crapcon
         SET flginter = 0
       WHERE crapcon.cdempcon = rw_crapscn.cdempcon
         AND crapcon.cdsegmto = rw_crapscn.cdsegmto;				
			EXCEPTION
      WHEN OTHERS THEN
        vr_clob_erros := vr_clob_erros || to_clob('Erro ao cancelar convenio Sicredi -> cdempcon: ' || rw_crapscn.cdempcon || 
                                                  ', cdsegmto: ' || rw_crapscn.cdsegmto ||
                                                  ', cdempres: ' || rw_crapscn.cdempres ||
                                                  ', dscritic: ' || SQLERRM|| chr(10)); 
        CONTINUE;      				
			END;
		END IF;
	END LOOP;
	
	FOR rw_conv IN cr_tbconv_arrecadacao_t LOOP
		BEGIN
			UPDATE tbconv_arrecadacao arr
				 SET arr.cdmodalidade = 1
			 WHERE arr.rowid = rw_conv.rowid;
		EXCEPTION
			WHEN OTHERS THEN
				vr_clob_erros := vr_clob_erros || to_clob('Erro ao atualizar convenio Bancoob -> cdempcon: ' || vr_cdempcon || 
																				 ', cdsegmto: ' || vr_cdsegmto ||
																				 ', cdempres: ' || rw_tbconv_arrecadacao.cdempres ||
																				 ', dscritic: ' || SQLERRM|| chr(10));
		END;		
	END LOOP;

	gene0002.pc_clob_para_arquivo(pr_clob     => vr_clob_conv_migra || vr_clob_conv_inclb || vr_clob_conv_incla || vr_clob_conv_sicca || vr_clob_erros,
                               pr_caminho  => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
															                                         ,pr_cdcooper => 0
																																			 ,pr_cdacesso => 'ROOT_MICROS') || 'cecred/reinert',
                               pr_arquivo  => 'rel_migra_conv.txt',
                               pr_des_erro => vr_dscritic);

COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		dbms_output.put_line('Erro geral no script -> ' ||SQLERRM);								
end;
