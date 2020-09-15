PL/SQL Developer Test script 3.0
431
declare
  arq_csv CLOB := '8261219;1219;2;2;0;4
8261493;1493;2;2;10;4
8261413;1413;2;2;0;4
8260732;732;2;2;10;4
8261446;1446;2;2;10;4
8261473;1473;2;2;0;4
8260910;910;2;2;0;4
8261387;1387;2;2;10;4
8260527;527;2;2;10;4
8261535;1535;2;2;10;4
8260534;534;2;2;0;4
8280961;961;2;2;0;4
8261442;1442;2;2;0;4
8261466;1466;2;2;0;4
8261474;1474;2;2;11;4
8260762;762;2;2;10;4
8261491;1491;2;2;10;4
8261426;1426;2;2;10;4
8261422;1422;2;2;10;4
8460464;464;4;2;12;4
8360047;47;3;2;0;4
8460061;61;4;2;0;4
8360019;19;3;2;11;4
8281341;1341;2;2;8;4
8260059;59;2;2;0;4
8261379;1379;2;2;0;4
8460149;149;4;2;0;3
8460150;150;4;2;0;3
8460151;151;4;2;0;3
8460153;153;4;2;0;3
8460152;152;4;2;0;3
8460154;154;4;2;0;3
8460156;156;4;2;0;3
8460155;155;4;2;0;3
8460157;157;4;2;0;3
8261329;1329;2;2;0;4
8260005;5;2;2;8;4
8260004;4;2;2;8;4
8260008;8;2;2;0;3
8260009;9;2;2;0;4
8260010;10;2;2;9;4
8260012;12;2;2;0;4
8261351;1351;2;2;0;4
8261475;1475;2;2;0;4
8260013;13;2;2;8;3
8360002;2;3;2;0;4
8360003;3;3;2;0;4
8360005;5;3;2;11;3
8360006;6;3;2;13;4
8360056;56;3;2;11;4
8360100;100;3;2;11;4
8360162;162;3;2;0;4
8360009;9;3;2;0;3
8360010;10;3;2;12;5
8360011;11;3;2;12;4
8360013;13;3;2;12;5
8360138;138;3;2;12;3
8360017;17;3;2;14;4
8360078;78;3;2;0;4
8360020;20;3;2;0;4
8360179;179;3;2;10;4
8260015;15;2;2;0;4
8260016;16;2;2;8;3
8360023;23;3;2;9;4
8460071;71;4;2;10;3
8480162;162;4;2;0;4
8460305;305;4;2;0;4
8260017;17;2;2;0;4
8260319;319;2;2;0;4
8360030;30;3;2;0;3
8360031;31;3;2;11;4
8260018;18;2;2;0;4
8261128;1128;2;2;0;4
8261116;1116;2;2;25;4
8260019;19;2;2;25;3
8360111;111;3;2;13;3
8460106;106;4;2;10;4
8261100;1100;2;2;11;4
8260798;798;2;2;11;4
8360038;38;3;2;0;3
8360040;40;3;2;25;3
83690110;110;3;2;25;3
8360052;52;3;2;12;4
8480284;284;4;2;0;4
8460004;4;4;2;12;3
8260024;24;2;2;8;4
8260027;27;2;2;0;3
8260418;418;2;2;0;4
8260039;39;2;2;8;4
8260704;704;2;2;15;4
8260349;349;2;2;7;4
8260040;40;2;2;15;3
8260632;632;2;2;0;4
8260699;699;2;2;10;4
8260311;311;2;2;0;4
8260043;43;2;2;8;4
8260380;380;2;2;0;4
8360041;41;3;2;0;4
8360073;73;3;2;0;4
8360022;22;3;2;13;4
8360045;45;3;2;11;4
8360048;48;3;2;0;4
8260047;47;2;2;0;3
8261550;1550;2;2;0;4
8261551;1551;2;2;0;4
8261207;1207;2;2;0;4
67561;6;4;2;14;3
8260508;508;2;2;0;4
8360007;7;3;2;0;4
8360014;14;3;2;11;4
8360050;50;3;2;11;4
8360146;146;3;2;0;4
8360054;54;3;2;0;4
8360049;49;3;2;0;4
8360155;155;3;2;0;4
8360001;1;3;2;11;4
8360012;12;3;2;10;3
8360051;51;3;2;12;3
8260124;124;2;2;7;4
8360116;116;3;2;11;4
8460430;430;4;2;0;4
8490067;67;4;2;0;4
8360053;53;3;2;0;3
8261149;1149;2;2;0;4
8260477;477;2;2;8;4
8460296;296;4;2;0;4
8480089;89;4;2;25;4
8460313;313;4;2;0;4
8460014;14;4;2;0;3
8460113;113;4;2;0;3
8460026;26;4;2;0;3
24756;24;4;2;0;3
8460369;369;4;2;0;4
8460446;446;4;2;10;4
8260370;370;2;2;0;3
8460423;423;4;2;0;5
8360086;86;3;2;12;4
8260419;419;2;2;0;4
8260062;62;2;2;14;4
8260673;673;2;2;0;4
8270068;68;2;2;0;4
8260333;333;2;2;7;4
8260077;77;2;2;8;4
8260079;79;2;2;0;4
8260178;178;2;2;8;4
8261300;1300;2;2;0;4
8260082;82;2;2;0;4
8260085;85;2;2;0;4
8260160;160;2;2;10;4
8260089;89;2;2;0;4
8260091;91;2;2;0;4
8260094;94;2;2;10;4
8260297;297;2;2;0;4
8260292;292;2;2;15;4
8260285;285;2;2;0;4
8260075;75;2;2;0;4
8260918;918;2;2;15;4
8260092;92;2;2;0;4
8260097;97;2;2;0;4
8261626;1626;2;2;7;4
8260834;834;2;2;14;4
8260099;99;2;2;13;4
8260512;512;2;2;15;4
8260533;533;2;2;0;4
8261304;1304;2;2;0;4
8260119;119;2;2;0;4
8260337;337;2;2;10;4
8260158;158;2;2;0;4
8260101;101;2;2;0;4
8261098;1098;2;2;0;4
8261295;1295;2;2;0;4
8260159;159;2;2;0;4
8260153;153;2;2;0;4
8260120;120;2;2;0;4
8260816;816;2;2;10;4
8261345;1345;2;2;12;5
8260106;106;2;2;0;3
8260467;467;2;2;6;4
8260341;341;2;2;8;4
8260107;107;2;2;0;3
8260768;768;2;2;0;4
8260109;109;2;2;0;3
8260622;622;2;2;0;4
8260110;110;2;2;0;4
8260483;483;2;2;0;4
8271115;1115;2;2;0;4
8260121;121;2;2;0;4
8260907;907;2;2;9;4
8260113;113;2;2;0;4
8260843;843;2;2;10;4
8460007;7;4;2;0;5
8260114;114;2;2;8;4
8260986;986;2;2;0;3
8461029;1029;4;2;0;3
8460016;16;4;2;0;3
8460017;17;4;2;0;3
8460019;19;4;2;0;3
8460020;20;4;2;0;3
8460002;2;4;2;0;3
8460027;27;4;2;0;3
8460109;109;4;2;20;4
8261330;1330;2;2;6;4
8360137;137;3;2;0;4
8460469;469;4;2;7;4
8460053;53;4;2;0;3
8460073;73;4;2;0;3
8460076;76;4;2;0;4
8460041;41;4;2;0;3
8460047;47;4;2;0;3
607561;60;4;2;0;3
8460044;44;4;2;0;3
8460074;74;4;2;0;4
8460049;49;4;2;0;3
8460055;55;4;2;0;3
8460072;72;4;2;0;3
487561;48;4;2;0;3
8460058;58;4;2;0;3
8460075;75;4;2;0;4
8460079;79;4;2;0;4
8460042;42;4;2;0;4
8460080;80;4;2;0;4
8460081;81;4;2;0;3
8460064;64;4;2;11;3
8460069;69;4;2;0;3
8460082;82;4;2;0;3
8460466;466;4;2;12;5';

  vr_arquivo      UTL_FILE.file_type;
  vr_dserro       varchar2(1000);
  vr_texto        varchar2(1000);
  vr_linhascsv    gene0002.typ_split;
  vr_linhacsv     gene0002.typ_split;
  --
  vr_rowid        rowid;
  vr_cdempres     tbconv_arrecadacao.cdempres%type;
  vr_cdempcon     tbconv_arrecadacao.cdempcon%type; 
  vr_cdsegmto     tbconv_arrecadacao.cdsegmto%type;
  vr_cdmodalidade tbconv_arrecadacao.cdmodalidade%type;
  vr_qttamanho_optante     tbconv_arrecadacao.qttamanho_optante%type; 
  vr_nrlayout_debaut       tbconv_arrecadacao.nrlayout_debaut%type;
  vr_vltarifa_debaut       tbconv_arrecadacao.vltarifa_debaut%type;
  
  --
  vr_linha        number(6) := 0;
  vr_delimitador  varchar2(1) := ';';
  vr_dtcancel     tbconv_arrecadacao.dtencemp%type;
  --
  vr_dsmotivo     varchar2(1000);
  vr_sqlerrm      varchar2(1000);
  --
  wexiste         number(1);
  wexiste_conv    number(1);
  wcommit         number(5) := 5000;
  --
  err_convenio    exception;
  
     CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
           where cop.flgativo = 1
     ORDER BY cop.cdcooper;
  rw_cr_crapcop   cr_crapcop%ROWTYPE;

     CURSOR cr_crapcop2 IS
    SELECT cop.cdcooper
      FROM crapcop cop
           where cop.flgativo = 1
         and cop.cdcooper <> 3
     ORDER BY cop.cdcooper;
  rw_cr_crapcop2   cr_crapcop2%ROWTYPE;
  
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

 
begin
  vr_linhascsv := fn_quebra_string(arq_csv,CHR(10));
  FOR i IN 1 .. vr_linhascsv.COUNT
  LOOP
    vr_linhacsv := fn_quebra_string(vr_linhascsv(i), ';');
    vr_cdempres := vr_linhacsv(1); --tbconv_arrecadacao.cdempres
    vr_cdempcon := to_number(vr_linhacsv(2)); --tbconv_arrecadacao.cdempcon
    vr_cdsegmto := to_number(vr_linhacsv(3)); --tbconv_arrecadacao.cdsegmto
    vr_cdmodalidade := to_number(vr_linhacsv(4)); --tbconv_arrecadacao.cdmodalidade
    vr_qttamanho_optante := to_number(vr_linhacsv(5)); --tbconv_arrecadacao.qttamanho_optante
    vr_nrlayout_debaut := to_number(vr_linhacsv(6)); --tbconv_arrecadacao.nrlayout_debaut


      
      dbms_output.put_line('importando: -> '||vr_cdempcon||' '||vr_cdsegmto);  
      
      begin

        UPDATE tbconv_arrecadacao SET tbconv_arrecadacao.cdmodalidade = vr_cdmodalidade,
                    tbconv_arrecadacao.qttamanho_optante = vr_qttamanho_optante,
                    tbconv_arrecadacao.nrlayout_debaut = vr_nrlayout_debaut
              WHERE tbconv_arrecadacao.cdempcon = vr_cdempcon
                AND tbconv_arrecadacao.cdsegmto = vr_cdsegmto
          AND tbconv_arrecadacao.tparrecadacao = 2;
   
        EXCEPTION
            WHEN others THEN
          dbms_output.put_line('Nao foi possivel incluir convenio (tbconv_arrecadacao): '||vr_cdempres||'->'||SQLERRM);
                RAISE;
      end;

    END LOOP;

     dbms_output.put_line('importando: -> 52 2');
    
     INSERT INTO tbconv_arrecadacao
             (cdempres ,tparrecadacao,cdempcon,cdsegmto,tpdias_repasse,nrdias_float,nrdias_tolerancia,dtencemp,nrlayout,vltarifa_caixa,vltarifa_debaut,vltarifa_internet ,vltarifa_taa ,nrlayout_debaut ,qttamanho_optante,cdmodalidade)
      VALUES (8260052,2,52,2 ,'U',0 ,0 ,'',0,0,'0,51',0,0,4,7,2);

      FOR rw_cr_crapcop IN cr_crapcop LOOP


             INSERT INTO crapcon(cdempcon,cdsegmto,nmrescon,nmextcon,cdhistor,nrdolote,tparrecd,flgaccec,flgacsic,flgacbcb,cdcooper) VALUES
                                (52,2,'SAAE ARACRUZ', 'SAAE ARACRUZ - ES',2515,15000, 2,0,0,1,rw_cr_crapcop.cdcooper);

      END LOOP;


      dbms_output.put_line('importando: -> 1223 2');  
      begin

        UPDATE tbconv_arrecadacao SET tbconv_arrecadacao.tparrecadacao = 2,
                                    tbconv_arrecadacao.vltarifa_debaut = '0,42',
                    tbconv_arrecadacao.cdmodalidade = 2,
                    tbconv_arrecadacao.qttamanho_optante = 0,
                    tbconv_arrecadacao.nrlayout_debaut = 4,
                    tbconv_arrecadacao.vltarifa_caixa = 0,
                    tbconv_arrecadacao.vltarifa_internet = 0,
                    tbconv_arrecadacao.vltarifa_taa = 0,
                    tbconv_arrecadacao.nrdias_tolerancia = 0
              WHERE tbconv_arrecadacao.cdempcon = 1223
                AND tbconv_arrecadacao.cdsegmto = 2;
   
        EXCEPTION
            WHEN others THEN
          dbms_output.put_line('Nao foi possivel incluir convenio (tbconv_arrecadacao): '||1223||'->'||SQLERRM);
                RAISE;
      end;

      begin
        UPDATE crapcon SET crapcon.tparrecd = 2,
                       crapcon.cdhistor = 2515,
                 crapcon.flgacbcb = 1, 
               crapcon.flgaccec = 0,
               crapcon.flgacsic = 0
                   WHERE crapcon.cdempcon = 1223
                   AND crapcon.cdsegmto = 2;
        EXCEPTION
            WHEN others THEN
          dbms_output.put_line('Nao foi possivel incluir convenio (crapcon): '||1223||'->'||SQLERRM);
                RAISE;
      end;



      dbms_output.put_line('importando: -> 75 3');
      
      begin

        UPDATE tbconv_arrecadacao SET tbconv_arrecadacao.tparrecadacao = 2,
                                    tbconv_arrecadacao.vltarifa_debaut = '0,25',
                    tbconv_arrecadacao.cdmodalidade = 2,
                    tbconv_arrecadacao.qttamanho_optante = 0,
                    tbconv_arrecadacao.nrlayout_debaut = 4,
                    tbconv_arrecadacao.vltarifa_caixa = 0,
                    tbconv_arrecadacao.vltarifa_internet = 0,
                    tbconv_arrecadacao.vltarifa_taa = 0,
                    tbconv_arrecadacao.nrdias_tolerancia = 0
              WHERE tbconv_arrecadacao.cdempcon = 75
                AND tbconv_arrecadacao.cdsegmto = 3;
   
        EXCEPTION
            WHEN others THEN
          dbms_output.put_line('Nao foi possivel incluir convenio (tbconv_arrecadacao): '||75||'->'||SQLERRM);
                RAISE;
      end;

     
      FOR rw_cr_crapcop2 IN cr_crapcop2 LOOP

             INSERT INTO crapcon(cdempcon,cdsegmto,nmrescon,nmextcon,cdhistor,nrdolote,tparrecd,flgaccec,flgacsic,flgacbcb,cdcooper,flginter) VALUES
                                (75,3,'RORAIMA ENERGIA', 'RORAIMA ENERGIA RR',2515,15000, 2,0,0,1,rw_cr_crapcop2.cdcooper,1);

      END LOOP; 

                             
    commit;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro geral no script -> ' ||SQLERRM);               
end;
0
0
