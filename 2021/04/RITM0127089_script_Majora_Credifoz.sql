declare
  --
  vr_nrregistro number := 0;
  vr_existe_ass number;
  vr_existe_lim number;
  vr_nrdrowid   rowid;
  vr_dsmensagem varchar2(500);
  vr_nmarq_rollback VARCHAR2(100);
  vr_nmarq_log      VARCHAR2(100);
  vr_dsdireto     VARCHAR2(150);
  vr_des_erro VARCHAR2(1000);
  vr_dscritic VARCHAR2(1000);
  vr_handle utl_file.file_type;
  vr_handle_log utl_file.file_type;
  vr_exc_erro EXCEPTION;
  
  vr_insitlim NUMBER(5);
  vr_flmajora NUMBER(1);
  vr_tpctrlim NUMBER(1);
  ----
BEGIN
  BEGIN
  
-- Banco individual
        --  vr_nmarq_rollback := '/progress/t0031664/micros/cpd/bacas/RITM0127089_ROLLBACK_Majora.sql';
        --  vr_nmarq_log      := '/progress/t0031664/micros/cpd/bacas/LOG_RITM0127089_Majora.txt';

-- Banco Test      
-- \\pkgtest\micros---  /microstst/cecred/Elton/
        --  vr_nmarq_rollback := '/microstst/cecred/Elton/RITM0127089_ROLLBACK_Majora.sql';
        --  vr_nmarq_log      := '/microstst/cecred/Elton/LOG_RITM0127089_Majora.txt';
 

-- caminho para produção:
          vr_dsdireto       := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/';
          vr_nmarq_rollback := vr_dsdireto||'RITM0127089_ROLLBACK_Majora.sql';
          vr_nmarq_log      := vr_dsdireto||'LOG_RITM0127089_Majora.txt';

          /* Abrir o arquivo de rollback */
          gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback
                                  ,pr_tipabert => 'W'           --> Modo de abertura (R,W,A)
                                  ,pr_utlfileh => vr_handle     --> Handle do arquivo aberto
                                  ,pr_des_erro => vr_des_erro);
          if vr_des_erro is not null then
            vr_dsmensagem := 'Erro ao abrir arquivo de rollback: ' || vr_des_erro;
            RAISE vr_exc_erro;
          end if;
          --
          /* Abrir o arquivo de LOG */
          gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_log
                                  ,pr_tipabert => 'W'                --> Modo de abertura (R,W,A)
                                  ,pr_utlfileh => vr_handle_log     --> Handle do arquivo aberto
                                  ,pr_des_erro => vr_des_erro);
          if vr_des_erro is not null then
            vr_dsmensagem := 'Erro ao abrir arquivo de LOG: ' || vr_des_erro;
            RAISE vr_exc_erro;
          end if;
          
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                        ,pr_des_text => 'Linha;Coop;Conta;Contrato;Mensagem');
                                        
--          dbms_output.put_line('Linha;Coop;Conta;Contrato;Mensagem');
          --
          for r_cnt in (
        select cnt.cdcooper
              ,cnt.nrdconta
              ,cnt.nrctrlim
        from
        (
SELECT 11 cdcooper, 0435430 nrdconta,  00026617 nrctrlim from dual union all 
SELECT 11 cdcooper, 0505846 nrdconta,  00038731 nrctrlim from dual union all 
SELECT 11 cdcooper, 0543829 nrdconta,  00047704 nrctrlim from dual union all 
SELECT 11 cdcooper, 0418064 nrdconta,  00031979 nrctrlim from dual union all 
SELECT 11 cdcooper, 0488887 nrdconta,  00038233 nrctrlim from dual union all 
SELECT 11 cdcooper, 0498149 nrdconta,  00107815 nrctrlim from dual union all 
SELECT 11 cdcooper, 0425540 nrdconta,  00103984 nrctrlim from dual union all 
SELECT 11 cdcooper, 0447790 nrdconta,  00035559 nrctrlim from dual union all 
SELECT 11 cdcooper, 0380890 nrdconta,  00325090 nrctrlim from dual union all 
SELECT 11 cdcooper, 0380105 nrdconta,  00025794 nrctrlim from dual union all 
SELECT 11 cdcooper, 0395676 nrdconta,  00028466 nrctrlim from dual union all 
SELECT 11 cdcooper, 0486299 nrdconta,  00034548 nrctrlim from dual union all 
SELECT 11 cdcooper, 0498734 nrdconta,  00039668 nrctrlim from dual union all 
SELECT 11 cdcooper, 0498157 nrdconta,  00002005 nrctrlim from dual union all 
SELECT 11 cdcooper, 0386332 nrdconta,  00025567 nrctrlim from dual union all 
SELECT 11 cdcooper, 0527734 nrdconta,  00039160 nrctrlim from dual union all 
SELECT 11 cdcooper, 0434582 nrdconta,  00035214 nrctrlim from dual union all 
SELECT 11 cdcooper, 0525464 nrdconta,  00035735 nrctrlim from dual union all 
SELECT 11 cdcooper, 0516554 nrdconta,  00111777 nrctrlim from dual union all 
SELECT 11 cdcooper, 0385670 nrdconta,  00027784 nrctrlim from dual union all 
SELECT 11 cdcooper, 0410306 nrdconta,  00028139 nrctrlim from dual union all 
SELECT 11 cdcooper, 0481424 nrdconta,  00037380 nrctrlim from dual union all 
SELECT 11 cdcooper, 0436194 nrdconta,  00001104 nrctrlim from dual union all 
SELECT 11 cdcooper, 0531103 nrdconta,  00043800 nrctrlim from dual union all 
SELECT 11 cdcooper, 0542547 nrdconta,  00044825 nrctrlim from dual union all 
SELECT 11 cdcooper, 0394254 nrdconta,  00115412 nrctrlim from dual union all 
SELECT 11 cdcooper, 0440248 nrdconta,  00035266 nrctrlim from dual union all 
SELECT 11 cdcooper, 0523461 nrdconta,  00045209 nrctrlim from dual union all 
SELECT 11 cdcooper, 0468371 nrdconta,  00048127 nrctrlim from dual union all 
SELECT 11 cdcooper, 0506168 nrdconta,  00041926 nrctrlim from dual union all 
SELECT 11 cdcooper, 0478504 nrdconta,  00027580 nrctrlim from dual union all 
SELECT 11 cdcooper, 0456055 nrdconta,  00036503 nrctrlim from dual union all 
SELECT 11 cdcooper, 0481394 nrdconta,  00100718 nrctrlim from dual union all 
SELECT 11 cdcooper, 0554618 nrdconta,  00049893 nrctrlim from dual union all 
SELECT 11 cdcooper, 0414816 nrdconta,  00028209 nrctrlim from dual union all 
SELECT 11 cdcooper, 0407160 nrdconta,  00034493 nrctrlim from dual union all 
SELECT 11 cdcooper, 0670081 nrdconta,  00113962 nrctrlim from dual union all 
SELECT 11 cdcooper, 0471410 nrdconta,  00036407 nrctrlim from dual union all 
SELECT 11 cdcooper, 0399884 nrdconta,  00041485 nrctrlim from dual union all 
SELECT 11 cdcooper, 0445630 nrdconta,  00034026 nrctrlim from dual union all 
SELECT 11 cdcooper, 0490636 nrdconta,  00107911 nrctrlim from dual union all 
SELECT 11 cdcooper, 0420425 nrdconta,  00110068 nrctrlim from dual union all 
SELECT 11 cdcooper, 0428353 nrdconta,  00035330 nrctrlim from dual union all 
SELECT 11 cdcooper, 0463710 nrdconta,  00035924 nrctrlim from dual union all 
SELECT 11 cdcooper, 0388114 nrdconta,  00027394 nrctrlim from dual union all 
SELECT 11 cdcooper, 0526452 nrdconta,  00115717 nrctrlim from dual union all 
SELECT 11 cdcooper, 0692956 nrdconta,  00112221 nrctrlim from dual union all 
SELECT 11 cdcooper, 0416924 nrdconta,  00029469 nrctrlim from dual union all 
SELECT 11 cdcooper, 0463159 nrdconta,  00036580 nrctrlim from dual union all
SELECT 11 cdcooper, 0534927 nrdconta,  00045061 nrctrlim from dual union all
SELECT 11 cdcooper, 0483605 nrdconta,  00038202 nrctrlim from dual union all
SELECT 11 cdcooper, 0469513 nrdconta,  00108478 nrctrlim from dual union all
SELECT 11 cdcooper, 0469700 nrdconta,  00030742 nrctrlim from dual union all
SELECT 11 cdcooper, 0522910 nrdconta,  00040840 nrctrlim from dual union all
SELECT 11 cdcooper, 0505315 nrdconta,  00044939 nrctrlim from dual union all
SELECT 11 cdcooper, 0412112 nrdconta,  00033408 nrctrlim from dual union all
SELECT 11 cdcooper, 0653284 nrdconta,  00114079 nrctrlim from dual union all
SELECT 11 cdcooper, 0459429 nrdconta,  00038887 nrctrlim from dual union all
SELECT 11 cdcooper, 0390763 nrdconta,  00001590 nrctrlim from dual union all
SELECT 11 cdcooper, 0496979 nrdconta,  00038416 nrctrlim from dual union all
SELECT 11 cdcooper, 0417858 nrdconta,  00111409 nrctrlim from dual union all
SELECT 11 cdcooper, 0431982 nrdconta,  00033386 nrctrlim from dual union all
SELECT 11 cdcooper, 0544710 nrdconta,  00040535 nrctrlim from dual union all
SELECT 11 cdcooper, 0426210 nrdconta,  00105936 nrctrlim from dual union all
SELECT 11 cdcooper, 0501450 nrdconta,  00038742 nrctrlim from dual union all
SELECT 11 cdcooper, 0460940 nrdconta,  00035071 nrctrlim from dual union all
SELECT 11 cdcooper, 0546640 nrdconta,  00101985 nrctrlim from dual union all
SELECT 11 cdcooper, 0520187 nrdconta,  00045293 nrctrlim from dual union all
SELECT 11 cdcooper, 0499889 nrdconta,  00036187 nrctrlim from dual union all
SELECT 11 cdcooper, 0521981 nrdconta,  00002662 nrctrlim from dual union all
SELECT 11 cdcooper, 0531170 nrdconta,  00043887 nrctrlim from dual union all
SELECT 11 cdcooper, 0556289 nrdconta,  00104559 nrctrlim from dual union all
SELECT 11 cdcooper, 0524360 nrdconta,  00101016 nrctrlim from dual union all
SELECT 11 cdcooper, 0404586 nrdconta,  00028867 nrctrlim from dual union all
SELECT 11 cdcooper, 0504149 nrdconta,  00038676 nrctrlim from dual union all
SELECT 11 cdcooper, 0541958 nrdconta,  00101608 nrctrlim from dual union all
SELECT 11 cdcooper, 0523895 nrdconta,  00039144 nrctrlim from dual union all
SELECT 11 cdcooper, 0554200 nrdconta,  00040567 nrctrlim from dual union all
SELECT 11 cdcooper, 0444073 nrdconta,  00034811 nrctrlim from dual union all
SELECT 11 cdcooper, 0386138 nrdconta,  00027779 nrctrlim from dual union all
SELECT 11 cdcooper, 0457027 nrdconta,  00046129 nrctrlim from dual union all
SELECT 11 cdcooper, 0434027 nrdconta,  00033665 nrctrlim from dual union all
SELECT 11 cdcooper, 0537055 nrdconta,  00047289 nrctrlim from dual union all
SELECT 11 cdcooper, 0548235 nrdconta,  00042793 nrctrlim from dual union all
SELECT 11 cdcooper, 0537551 nrdconta,  00001877 nrctrlim from dual union all
SELECT 11 cdcooper, 0642703 nrdconta,  00114868 nrctrlim from dual union all
SELECT 11 cdcooper, 0416045 nrdconta,  00040564 nrctrlim from dual union all
SELECT 11 cdcooper, 0468940 nrdconta,  00001733 nrctrlim from dual union all
SELECT 11 cdcooper, 0489646 nrdconta,  00101203 nrctrlim from dual union all
SELECT 11 cdcooper, 0482374 nrdconta,  00105578 nrctrlim from dual union all
SELECT 11 cdcooper, 0545317 nrdconta,  00042617 nrctrlim from dual union all
SELECT 11 cdcooper, 0455040 nrdconta,  00036045 nrctrlim from dual union all
SELECT 11 cdcooper, 0408433 nrdconta,  00038569 nrctrlim from dual union all
SELECT 11 cdcooper, 0407879 nrdconta,  00033145 nrctrlim from dual union all
SELECT 11 cdcooper, 0506460 nrdconta,  00108745 nrctrlim from dual union all
SELECT 11 cdcooper, 0473014 nrdconta,  00040879 nrctrlim from dual union all
SELECT 11 cdcooper, 0540013 nrdconta,  00044820 nrctrlim from dual union all
SELECT 11 cdcooper, 0462934 nrdconta,  00114836 nrctrlim from dual union all
SELECT 11 cdcooper, 0432105 nrdconta,  00032920 nrctrlim from dual union all
SELECT 11 cdcooper, 0387975 nrdconta,  00029768 nrctrlim from dual union all
SELECT 11 cdcooper, 0407607 nrdconta,  00033312 nrctrlim from dual union all
SELECT 11 cdcooper, 0513806 nrdconta,  00041999 nrctrlim from dual union all
SELECT 11 cdcooper, 0477796 nrdconta,  00034588 nrctrlim from dual union all
SELECT 11 cdcooper, 0402338 nrdconta,  00107360 nrctrlim from dual union all
SELECT 11 cdcooper, 0490610 nrdconta,  00106378 nrctrlim from dual union all
SELECT 11 cdcooper, 0445584 nrdconta,  00031895 nrctrlim from dual union all
SELECT 11 cdcooper, 0403040 nrdconta,  00030527 nrctrlim from dual union all
SELECT 11 cdcooper, 0397881 nrdconta,  00028263 nrctrlim from dual union all
SELECT 11 cdcooper, 0432920 nrdconta,  00113903 nrctrlim from dual union all
SELECT 11 cdcooper, 0464716 nrdconta,  00035679 nrctrlim from dual union all
SELECT 11 cdcooper, 0423190 nrdconta,  00103068 nrctrlim from dual union all
SELECT 11 cdcooper, 0476650 nrdconta,  00043461 nrctrlim from dual union all
SELECT 11 cdcooper, 0651435 nrdconta,  00108598 nrctrlim from dual union all
SELECT 11 cdcooper, 0525642 nrdconta,  00102437 nrctrlim from dual union all
SELECT 11 cdcooper, 0561150 nrdconta,  00047653 nrctrlim from dual union all
SELECT 11 cdcooper, 0411450 nrdconta,  00001148 nrctrlim from dual union all
SELECT 11 cdcooper, 0456918 nrdconta,  00036543 nrctrlim from dual union all
SELECT 11 cdcooper, 0560979 nrdconta,  00047615 nrctrlim from dual union all
SELECT 11 cdcooper, 0521396 nrdconta,  00103825 nrctrlim from dual union all
SELECT 11 cdcooper, 0537691 nrdconta,  00045052 nrctrlim from dual union all
SELECT 11 cdcooper, 0560839 nrdconta,  00045936 nrctrlim from dual union all
SELECT 11 cdcooper, 0444634 nrdconta,  00034824 nrctrlim from dual union all
SELECT 11 cdcooper, 0422193 nrdconta,  00022820 nrctrlim from dual union all
SELECT 11 cdcooper, 0510920 nrdconta,  00042261 nrctrlim from dual union all
SELECT 11 cdcooper, 0622222 nrdconta,  00111721 nrctrlim from dual union all
SELECT 11 cdcooper, 0415120 nrdconta,  00031520 nrctrlim from dual union all
SELECT 11 cdcooper, 0487350 nrdconta,  00112648 nrctrlim from dual union all
SELECT 11 cdcooper, 0449407 nrdconta,  00035140 nrctrlim from dual union all
SELECT 11 cdcooper, 0427470 nrdconta,  00031987 nrctrlim from dual union all
SELECT 11 cdcooper, 0556530 nrdconta,  00042158 nrctrlim from dual union all
SELECT 11 cdcooper, 0500364 nrdconta,  00046234 nrctrlim from dual union all
SELECT 11 cdcooper, 0561568 nrdconta,  00042154 nrctrlim from dual union all
SELECT 11 cdcooper, 0466581 nrdconta,  00034982 nrctrlim from dual union all
SELECT 11 cdcooper, 0520527 nrdconta,  00042686 nrctrlim from dual union all
SELECT 11 cdcooper, 0445681 nrdconta,  00037723 nrctrlim from dual union all
SELECT 11 cdcooper, 0394610 nrdconta,  00050222 nrctrlim from dual union all
SELECT 11 cdcooper, 0402508 nrdconta,  00102459 nrctrlim from dual union all
SELECT 11 cdcooper, 0477842 nrdconta,  00030884 nrctrlim from dual union all
SELECT 11 cdcooper, 0549037 nrdconta,  00047404 nrctrlim from dual union all
SELECT 11 cdcooper, 0457515 nrdconta,  00036532 nrctrlim from dual union all
SELECT 11 cdcooper, 0516236 nrdconta,  00111143 nrctrlim from dual union all
SELECT 11 cdcooper, 0542989 nrdconta,  00047172 nrctrlim from dual union all
SELECT 11 cdcooper, 0384852 nrdconta,  00001583 nrctrlim from dual union all
SELECT 11 cdcooper, 0457884 nrdconta,  00030665 nrctrlim from dual union all
SELECT 11 cdcooper, 0560073 nrdconta,  00106219 nrctrlim from dual union all
SELECT 11 cdcooper, 0502804 nrdconta,  00105639 nrctrlim from dual union all
SELECT 11 cdcooper, 0520314 nrdconta,  00044742 nrctrlim from dual union all
SELECT 11 cdcooper, 0551759 nrdconta,  00111715 nrctrlim from dual union all
SELECT 11 cdcooper, 0514390 nrdconta,  00002167 nrctrlim from dual union all
SELECT 11 cdcooper, 0534862 nrdconta,  00109493 nrctrlim from dual union all
SELECT 11 cdcooper, 0477923 nrdconta,  00033955 nrctrlim from dual union all
SELECT 11 cdcooper, 0621064 nrdconta,  00107355 nrctrlim from dual union all
SELECT 11 cdcooper, 0623822 nrdconta,  00108358 nrctrlim from dual union all
SELECT 11 cdcooper, 0549614 nrdconta,  00046310 nrctrlim from dual union all
SELECT 11 cdcooper, 0447315 nrdconta,  00103535 nrctrlim from dual union all
SELECT 11 cdcooper, 0503240 nrdconta,  00038671 nrctrlim from dual union all
SELECT 11 cdcooper, 0503150 nrdconta,  00114503 nrctrlim from dual union all
SELECT 11 cdcooper, 0390267 nrdconta,  00029660 nrctrlim from dual union all
SELECT 11 cdcooper, 0512150 nrdconta,  00112943 nrctrlim from dual union all
SELECT 11 cdcooper, 0521884 nrdconta,  00002148 nrctrlim from dual union all
SELECT 11 cdcooper, 0498602 nrdconta,  00039508 nrctrlim from dual union all
SELECT 11 cdcooper, 0386189 nrdconta,  00110405 nrctrlim from dual union all
SELECT 11 cdcooper, 0380873 nrdconta,  00106667 nrctrlim from dual union all
SELECT 11 cdcooper, 0405507 nrdconta,  00036855 nrctrlim from dual union all
SELECT 11 cdcooper, 0533807 nrdconta,  00040888 nrctrlim from dual union all
SELECT 11 cdcooper, 0449059 nrdconta,  00112407 nrctrlim from dual union all
SELECT 11 cdcooper, 0543128 nrdconta,  00043484 nrctrlim from dual union all
SELECT 11 cdcooper, 0507806 nrdconta,  00117341 nrctrlim from dual union all
SELECT 11 cdcooper, 0372480 nrdconta,  00025183 nrctrlim from dual union all
SELECT 11 cdcooper, 0452769 nrdconta,  00050292 nrctrlim from dual union all
SELECT 11 cdcooper, 0439517 nrdconta,  00032096 nrctrlim from dual union all
SELECT 11 cdcooper, 0396761 nrdconta,  00038694 nrctrlim from dual union all
SELECT 11 cdcooper, 0480762 nrdconta,  00035285 nrctrlim from dual union all
SELECT 11 cdcooper, 0538680 nrdconta,  00045915 nrctrlim from dual union all
SELECT 11 cdcooper, 0383201 nrdconta,  00043341 nrctrlim from dual union all
SELECT 11 cdcooper, 0538612 nrdconta,  00045086 nrctrlim from dual union all
SELECT 11 cdcooper, 0417610 nrdconta,  00035820 nrctrlim from dual union all
SELECT 11 cdcooper, 0535281 nrdconta,  00047265 nrctrlim from dual union all
SELECT 11 cdcooper, 0409065 nrdconta,  00033504 nrctrlim from dual union all
SELECT 11 cdcooper, 0394599 nrdconta,  00044596 nrctrlim from dual union all
SELECT 11 cdcooper, 0380300 nrdconta,  00026017 nrctrlim from dual union all
SELECT 11 cdcooper, 0457108 nrdconta,  00034938 nrctrlim from dual union all
SELECT 11 cdcooper, 0419346 nrdconta,  00115549 nrctrlim from dual union all
SELECT 11 cdcooper, 0480100 nrdconta,  00106830 nrctrlim from dual union all
SELECT 11 cdcooper, 0521272 nrdconta,  00044753 nrctrlim from dual union all
SELECT 11 cdcooper, 0399264 nrdconta,  00029507 nrctrlim from dual union all
SELECT 11 cdcooper, 0622370 nrdconta,  00113274 nrctrlim from dual union all
SELECT 11 cdcooper, 0438804 nrdconta,  00112195 nrctrlim from dual union all
SELECT 11 cdcooper, 0417211 nrdconta,  00039088 nrctrlim from dual union all
SELECT 11 cdcooper, 0446653 nrdconta,  00045045 nrctrlim from dual union all
SELECT 11 cdcooper, 0531537 nrdconta,  00045321 nrctrlim from dual union all
SELECT 11 cdcooper, 0447803 nrdconta,  00038834 nrctrlim from dual union all
SELECT 11 cdcooper, 0464562 nrdconta,  00046968 nrctrlim from dual union all
SELECT 11 cdcooper, 0389021 nrdconta,  00025595 nrctrlim from dual union all
SELECT 11 cdcooper, 0464511 nrdconta,  00036587 nrctrlim from dual union all
SELECT 11 cdcooper, 0388955 nrdconta,  00037370 nrctrlim from dual union all
SELECT 11 cdcooper, 0536768 nrdconta,  00047019 nrctrlim from dual union all
SELECT 11 cdcooper, 0520322 nrdconta,  00042682 nrctrlim from dual union all
SELECT 11 cdcooper, 0528110 nrdconta,  00100160 nrctrlim from dual union all
SELECT 11 cdcooper, 0411973 nrdconta,  00033406 nrctrlim from dual union all
SELECT 11 cdcooper, 0381462 nrdconta,  00114730 nrctrlim from dual union all
SELECT 11 cdcooper, 0644544 nrdconta,  00110952 nrctrlim from dual union all
SELECT 11 cdcooper, 0485470 nrdconta,  00037179 nrctrlim from dual union all
SELECT 11 cdcooper, 0467162 nrdconta,  00101868 nrctrlim from dual union all
SELECT 11 cdcooper, 0476447 nrdconta,  00036818 nrctrlim from dual union all
SELECT 11 cdcooper, 0440485 nrdconta,  00105338 nrctrlim from dual union all
SELECT 11 cdcooper, 0547816 nrdconta,  00110882 nrctrlim from dual union all
SELECT 11 cdcooper, 0497207 nrdconta,  00039021 nrctrlim from dual union all
SELECT 11 cdcooper, 0506494 nrdconta,  00117755 nrctrlim from dual union all
SELECT 11 cdcooper, 0459356 nrdconta,  00038717 nrctrlim from dual union all
SELECT 11 cdcooper, 0501425 nrdconta,  00104465 nrctrlim from dual union all
SELECT 11 cdcooper, 0390585 nrdconta,  00037133 nrctrlim from dual union all
SELECT 11 cdcooper, 0421782 nrdconta,  00101487 nrctrlim from dual union all
SELECT 11 cdcooper, 0535273 nrdconta,  00050010 nrctrlim from dual union all
SELECT 11 cdcooper, 0473073 nrdconta,  00101205 nrctrlim from dual union all
SELECT 11 cdcooper, 0392014 nrdconta,  00029683 nrctrlim from dual union all
SELECT 11 cdcooper, 0383112 nrdconta,  00019835 nrctrlim from dual union all
SELECT 11 cdcooper, 0501000 nrdconta,  00107401 nrctrlim from dual union all
SELECT 11 cdcooper, 0528048 nrdconta,  00040887 nrctrlim from dual union all
SELECT 11 cdcooper, 0528790 nrdconta,  00044266 nrctrlim from dual union all
SELECT 11 cdcooper, 0521094 nrdconta,  00105348 nrctrlim from dual union all
SELECT 11 cdcooper, 0648418 nrdconta,  00112277 nrctrlim from dual union all
SELECT 11 cdcooper, 0389528 nrdconta,  00112938 nrctrlim from dual union all
SELECT 11 cdcooper, 0401617 nrdconta,  00035862 nrctrlim from dual union all
SELECT 11 cdcooper, 0443034 nrdconta,  00034392 nrctrlim from dual union all
SELECT 11 cdcooper, 0520888 nrdconta,  00039136 nrctrlim from dual union all
SELECT 11 cdcooper, 0424862 nrdconta,  00043820 nrctrlim from dual union all
SELECT 11 cdcooper, 0493813 nrdconta,  00034187 nrctrlim from dual union all
SELECT 11 cdcooper, 0473855 nrdconta,  00107425 nrctrlim from dual union all
SELECT 11 cdcooper, 0545600 nrdconta,  00047174 nrctrlim from dual union all
SELECT 11 cdcooper, 0478440 nrdconta,  00037778 nrctrlim from dual union all
SELECT 11 cdcooper, 0468100 nrdconta,  00102641 nrctrlim from dual union all
SELECT 11 cdcooper, 0510971 nrdconta,  00044451 nrctrlim from dual union all
SELECT 11 cdcooper, 0475203 nrdconta,  00114118 nrctrlim from dual union all
SELECT 11 cdcooper, 0506885 nrdconta,  00002411 nrctrlim from dual union all
SELECT 11 cdcooper, 0414379 nrdconta,  00032709 nrctrlim from dual union all
SELECT 11 cdcooper, 0533491 nrdconta,  00045314 nrctrlim from dual union all
SELECT 11 cdcooper, 0530433 nrdconta,  00039175 nrctrlim from dual union all
SELECT 11 cdcooper, 0461741 nrdconta,  00049505 nrctrlim from dual union all
SELECT 11 cdcooper, 0498203 nrdconta,  00041189 nrctrlim from dual union all
SELECT 11 cdcooper, 0414034 nrdconta,  00031178 nrctrlim from dual union all
SELECT 11 cdcooper, 0630853 nrdconta,  00115929 nrctrlim from dual union all
SELECT 11 cdcooper, 0455318 nrdconta,  00001684 nrctrlim from dual union all
SELECT 11 cdcooper, 0533939 nrdconta,  00100848 nrctrlim from dual union all
SELECT 11 cdcooper, 0475840 nrdconta,  00049451 nrctrlim from dual union all
SELECT 11 cdcooper, 0486981 nrdconta,  00034157 nrctrlim from dual union all
SELECT 11 cdcooper, 0528455 nrdconta,  00110420 nrctrlim from dual union all
SELECT 11 cdcooper, 0544264 nrdconta,  00040045 nrctrlim from dual union all
SELECT 11 cdcooper, 0471666 nrdconta,  00030859 nrctrlim from dual union all
SELECT 11 cdcooper, 0527483 nrdconta,  00045410 nrctrlim from dual union all
SELECT 11 cdcooper, 0390348 nrdconta,  00038052 nrctrlim from dual union all
SELECT 11 cdcooper, 0405159 nrdconta,  00039096 nrctrlim from dual union all
SELECT 11 cdcooper, 0516252 nrdconta,  00041909 nrctrlim from dual union all
SELECT 11 cdcooper, 0383848 nrdconta,  00040764 nrctrlim from dual union all
SELECT 11 cdcooper, 0430803 nrdconta,  00104395 nrctrlim from dual union all
SELECT 11 cdcooper, 0485845 nrdconta,  00038260 nrctrlim from dual union all
SELECT 11 cdcooper, 0487970 nrdconta,  00033997 nrctrlim from dual union all
SELECT 11 cdcooper, 0692158 nrdconta,  00113455 nrctrlim from dual union all
SELECT 11 cdcooper, 0529931 nrdconta,  00045419 nrctrlim from dual union all
SELECT 11 cdcooper, 0491993 nrdconta,  00041978 nrctrlim from dual union all
SELECT 11 cdcooper, 0493040 nrdconta,  00039989 nrctrlim from dual union all
SELECT 11 cdcooper, 0530751 nrdconta,  00107858 nrctrlim from dual union all
SELECT 11 cdcooper, 0627941 nrdconta,  00040993 nrctrlim from dual union all
SELECT 11 cdcooper, 0435244 nrdconta,  00111103 nrctrlim from dual union all
SELECT 11 cdcooper, 0490113 nrdconta,  00038760 nrctrlim from dual union all
SELECT 11 cdcooper, 0429732 nrdconta,  00104503 nrctrlim from dual union all
SELECT 11 cdcooper, 0379956 nrdconta,  00113380 nrctrlim from dual union all
SELECT 11 cdcooper, 0487848 nrdconta,  00037221 nrctrlim from dual union all
SELECT 11 cdcooper, 0463680 nrdconta,  00111411 nrctrlim from dual union all
SELECT 11 cdcooper, 0438766 nrdconta,  00031779 nrctrlim from dual union all
SELECT 11 cdcooper, 0445690 nrdconta,  00040303 nrctrlim from dual union all
SELECT 11 cdcooper, 0504580 nrdconta,  00041942 nrctrlim from dual union all
SELECT 11 cdcooper, 0494445 nrdconta,  00049486 nrctrlim from dual union all
SELECT 11 cdcooper, 0393088 nrdconta,  00103108 nrctrlim from dual union all
SELECT 11 cdcooper, 0510963 nrdconta,  00040362 nrctrlim from dual union all
SELECT 11 cdcooper, 0404080 nrdconta,  00043831 nrctrlim from dual union all
SELECT 11 cdcooper, 0541613 nrdconta,  00045911 nrctrlim from dual union all
SELECT 11 cdcooper, 0414646 nrdconta,  00048165 nrctrlim from dual union all
SELECT 11 cdcooper, 0486671 nrdconta,  00037399 nrctrlim from dual union all
SELECT 11 cdcooper, 0521191 nrdconta,  00045912 nrctrlim from dual union all
SELECT 11 cdcooper, 0525049 nrdconta,  00045281 nrctrlim from dual union all
SELECT 11 cdcooper, 0493228 nrdconta,  00105070 nrctrlim from dual union all
SELECT 11 cdcooper, 0668389 nrdconta,  00113416 nrctrlim from dual union all
SELECT 11 cdcooper, 0543420 nrdconta,  00044643 nrctrlim from dual union all
SELECT 11 cdcooper, 0536431 nrdconta,  00043845 nrctrlim from dual union all
SELECT 11 cdcooper, 0407577 nrdconta,  00050280 nrctrlim from dual union all
SELECT 11 cdcooper, 0511897 nrdconta,  00047914 nrctrlim from dual union all
SELECT 11 cdcooper, 0417661 nrdconta,  00106895 nrctrlim from dual union all
SELECT 11 cdcooper, 0395803 nrdconta,  00028206 nrctrlim from dual union all
SELECT 11 cdcooper, 0535060 nrdconta,  00100962 nrctrlim from dual union all
SELECT 11 cdcooper, 0684546 nrdconta,  00113320 nrctrlim from dual union all
SELECT 11 cdcooper, 0554383 nrdconta,  00112467 nrctrlim from dual union all
SELECT 11 cdcooper, 0530891 nrdconta,  00039178 nrctrlim from dual union all
SELECT 11 cdcooper, 0553042 nrdconta,  00050294 nrctrlim from dual union all
SELECT 11 cdcooper, 0436089 nrdconta,  00045165 nrctrlim from dual union all
SELECT 11 cdcooper, 0550540 nrdconta,  00109229 nrctrlim from dual union all
SELECT 11 cdcooper, 0487791 nrdconta,  00038229 nrctrlim from dual union all
SELECT 11 cdcooper, 0405108 nrdconta,  00026108 nrctrlim from dual union all
SELECT 11 cdcooper, 0504025 nrdconta,  00039310 nrctrlim from dual union all
SELECT 11 cdcooper, 0535192 nrdconta,  00038583 nrctrlim from dual union all
SELECT 11 cdcooper, 0423483 nrdconta,  00111639 nrctrlim from dual union all
SELECT 11 cdcooper, 0487872 nrdconta,  00046990 nrctrlim from dual union all
SELECT 11 cdcooper, 0648957 nrdconta,  00114029 nrctrlim from dual union all
SELECT 11 cdcooper, 0387185 nrdconta,  00025579 nrctrlim from dual union all
SELECT 11 cdcooper, 0440191 nrdconta,  00114718 nrctrlim from dual union all
SELECT 11 cdcooper, 0544272 nrdconta,  00049839 nrctrlim from dual union all
SELECT 11 cdcooper, 0484989 nrdconta,  00041973 nrctrlim from dual union all
SELECT 11 cdcooper, 0558788 nrdconta,  00043884 nrctrlim from dual union all
SELECT 11 cdcooper, 0528838 nrdconta,  00047243 nrctrlim from dual union all
SELECT 11 cdcooper, 0453323 nrdconta,  00034834 nrctrlim from dual union all
SELECT 11 cdcooper, 0478431 nrdconta,  00037463 nrctrlim from dual union all
SELECT 11 cdcooper, 0517763 nrdconta,  00043910 nrctrlim from dual union all
SELECT 11 cdcooper, 0543535 nrdconta,  00050253 nrctrlim from dual union all
SELECT 11 cdcooper, 0485330 nrdconta,  00038111 nrctrlim from dual union all
SELECT 11 cdcooper, 0523640 nrdconta,  00046388 nrctrlim from dual union all
SELECT 11 cdcooper, 0396028 nrdconta,  00103150 nrctrlim from dual union all
SELECT 11 cdcooper, 0399272 nrdconta,  00032712 nrctrlim from dual union all
SELECT 11 cdcooper, 0477524 nrdconta,  00037885 nrctrlim from dual union all
SELECT 11 cdcooper, 0431362 nrdconta,  00106173 nrctrlim from dual union all
SELECT 11 cdcooper, 0522384 nrdconta,  00039142 nrctrlim from dual union all
SELECT 11 cdcooper, 0438316 nrdconta,  00001437 nrctrlim from dual union all
SELECT 11 cdcooper, 0466832 nrdconta,  00034486 nrctrlim from dual union all
SELECT 11 cdcooper, 0548685 nrdconta,  00109061 nrctrlim from dual union all
SELECT 11 cdcooper, 0521051 nrdconta,  00042220 nrctrlim from dual union all
SELECT 11 cdcooper, 0525456 nrdconta,  00045170 nrctrlim from dual union all
SELECT 11 cdcooper, 0560413 nrdconta,  00112532 nrctrlim from dual union all
SELECT 11 cdcooper, 0406872 nrdconta,  00105565 nrctrlim from dual union all
SELECT 11 cdcooper, 0560910 nrdconta,  00103055 nrctrlim from dual union all
SELECT 11 cdcooper, 0501530 nrdconta,  00105447 nrctrlim from dual union all
SELECT 11 cdcooper, 0439282 nrdconta,  00036332 nrctrlim from dual union all
SELECT 11 cdcooper, 0472433 nrdconta,  00036425 nrctrlim from dual union all
SELECT 11 cdcooper, 0509701 nrdconta,  00041040 nrctrlim from dual union all
SELECT 11 cdcooper, 0488186 nrdconta,  00038149 nrctrlim from dual union all
SELECT 11 cdcooper, 0402788 nrdconta,  00030526 nrctrlim from dual union all
SELECT 11 cdcooper, 0375810 nrdconta,  00025705 nrctrlim from dual union all
SELECT 11 cdcooper, 0484393 nrdconta,  00036232 nrctrlim from dual union all
SELECT 11 cdcooper, 0389714 nrdconta,  00100119 nrctrlim from dual union all
SELECT 11 cdcooper, 0525928 nrdconta,  00101439 nrctrlim from dual union all
SELECT 11 cdcooper, 0536385 nrdconta,  00116296 nrctrlim from dual union all
SELECT 11 cdcooper, 0452084 nrdconta,  00033818 nrctrlim from dual union all
SELECT 11 cdcooper, 0518301 nrdconta,  00045216 nrctrlim from dual union all
SELECT 11 cdcooper, 0501441 nrdconta,  00039479 nrctrlim from dual union all
SELECT 11 cdcooper, 0413402 nrdconta,  00031861 nrctrlim from dual union all
SELECT 11 cdcooper, 0394289 nrdconta,  00044549 nrctrlim from dual union all
SELECT 11 cdcooper, 0433918 nrdconta,  00035310 nrctrlim from dual union all
SELECT 11 cdcooper, 0440639 nrdconta,  00034376 nrctrlim from dual union all
SELECT 11 cdcooper, 0495662 nrdconta,  00110105 nrctrlim from dual union all
SELECT 11 cdcooper, 0437522 nrdconta,  00038279 nrctrlim from dual union all
SELECT 11 cdcooper, 0405205 nrdconta,  00030552 nrctrlim from dual union all
SELECT 11 cdcooper, 0386731 nrdconta,  00029808 nrctrlim from dual union all
SELECT 11 cdcooper, 0428132 nrdconta,  00031683 nrctrlim from dual union all
SELECT 11 cdcooper, 0506478 nrdconta,  00040020 nrctrlim from dual union all
SELECT 11 cdcooper, 0534480 nrdconta,  00050023 nrctrlim from dual union all
SELECT 11 cdcooper, 0491640 nrdconta,  00034177 nrctrlim from dual union all
SELECT 11 cdcooper, 0437948 nrdconta,  00036772 nrctrlim from dual union all
SELECT 11 cdcooper, 0441430 nrdconta,  00101552 nrctrlim from dual union all
SELECT 11 cdcooper, 0510114 nrdconta,  00040354 nrctrlim from dual union all
SELECT 11 cdcooper, 0447137 nrdconta,  00100893 nrctrlim from dual union all
SELECT 11 cdcooper, 0615668 nrdconta,  00110238 nrctrlim from dual union all
SELECT 11 cdcooper, 0386898 nrdconta,  00027760 nrctrlim from dual union all
SELECT 11 cdcooper, 0530611 nrdconta,  00044578 nrctrlim from dual union all
SELECT 11 cdcooper, 0561550 nrdconta,  00047761 nrctrlim from dual union all
SELECT 11 cdcooper, 0477761 nrdconta,  00027574 nrctrlim from dual union all
SELECT 11 cdcooper, 0409260 nrdconta,  00050097 nrctrlim from dual union all
SELECT 11 cdcooper, 0474711 nrdconta,  00049479 nrctrlim from dual union all
SELECT 11 cdcooper, 0432067 nrdconta,  00107320 nrctrlim from dual union all
SELECT 11 cdcooper, 0435899 nrdconta,  00109768 nrctrlim from dual union all
SELECT 11 cdcooper, 0540153 nrdconta,  00042473 nrctrlim from dual union all
SELECT 11 cdcooper, 0536490 nrdconta,  00111497 nrctrlim from dual union all
SELECT 11 cdcooper, 0526614 nrdconta,  00045172 nrctrlim from dual union all
SELECT 11 cdcooper, 0401722 nrdconta,  00028258 nrctrlim from dual union all
SELECT 11 cdcooper, 0403938 nrdconta,  00030009 nrctrlim from dual union all 
SELECT 11 cdcooper, 0505331 nrdconta,  00037278 nrctrlim from dual union all 
SELECT 11 cdcooper, 0527793 nrdconta,  00043770 nrctrlim from dual union all 
SELECT 11 cdcooper, 0619914 nrdconta,  00047443 nrctrlim from dual union all 
SELECT 11 cdcooper, 0458660 nrdconta,  00045043 nrctrlim from dual union all 
SELECT 11 cdcooper, 0409170 nrdconta,  00025089 nrctrlim from dual union all 
SELECT 11 cdcooper, 0558508 nrdconta,  00106311 nrctrlim from dual union all 
SELECT 11 cdcooper, 0554545 nrdconta,  00102916 nrctrlim from dual union all 
SELECT 11 cdcooper, 0435350 nrdconta,  00029466 nrctrlim from dual union all 
SELECT 11 cdcooper, 0504874 nrdconta,  00116376 nrctrlim from dual union all 
SELECT 11 cdcooper, 0526762 nrdconta,  00047241 nrctrlim from dual union all 
SELECT 11 cdcooper, 0493031 nrdconta,  00038823 nrctrlim from dual union all 
SELECT 11 cdcooper, 0412813 nrdconta,  00041026 nrctrlim from dual union all 
SELECT 11 cdcooper, 0430935 nrdconta,  00033636 nrctrlim from dual union all 
SELECT 11 cdcooper, 0387592 nrdconta,  00039621 nrctrlim from dual union all 
SELECT 11 cdcooper, 0451606 nrdconta,  00035659 nrctrlim from dual union all 
SELECT 11 cdcooper, 0451436 nrdconta,  00035656 nrctrlim from dual union all 
SELECT 11 cdcooper, 0501484 nrdconta,  00039920 nrctrlim from dual union all 
SELECT 11 cdcooper, 0441481 nrdconta,  00116688 nrctrlim from dual union all 
SELECT 11 cdcooper, 0645931 nrdconta,  00113813 nrctrlim from dual union all 
SELECT 11 cdcooper, 0382213 nrdconta,  00026356 nrctrlim from dual union all 
SELECT 11 cdcooper, 0501077 nrdconta,  00038350 nrctrlim from dual union all 
SELECT 11 cdcooper, 0653535 nrdconta,  00113496 nrctrlim from dual union all 
SELECT 11 cdcooper, 0411752 nrdconta,  00002024 nrctrlim from dual union all 
SELECT 11 cdcooper, 0472999 nrdconta,  00112713 nrctrlim from dual union all 
SELECT 11 cdcooper, 0561002 nrdconta,  00103291 nrctrlim from dual union all 
SELECT 11 cdcooper, 0450138 nrdconta,  00117519 nrctrlim from dual union all 
SELECT 11 cdcooper, 0389234 nrdconta,  00029722 nrctrlim from dual union all 
SELECT 11 cdcooper, 0384496 nrdconta,  00114126 nrctrlim from dual union all 
SELECT 11 cdcooper, 0500003 nrdconta,  00039270 nrctrlim from dual union all 
SELECT 11 cdcooper, 0499242 nrdconta,  00101968 nrctrlim from dual union all 
SELECT 11 cdcooper, 0462519 nrdconta,  00001085 nrctrlim from dual union all 
SELECT 11 cdcooper, 0552852 nrdconta,  00049857 nrctrlim from dual union all 
SELECT 11 cdcooper, 0530328 nrdconta,  00100388 nrctrlim from dual union all 
SELECT 11 cdcooper, 0381128 nrdconta,  00022769 nrctrlim from dual union all 
SELECT 11 cdcooper, 0526860 nrdconta,  00107445 nrctrlim from dual union all 
SELECT 11 cdcooper, 0550604 nrdconta,  00045931 nrctrlim from dual union all 
SELECT 11 cdcooper, 0528196 nrdconta,  00047103 nrctrlim from dual union all 
SELECT 11 cdcooper, 0482382 nrdconta,  00038055 nrctrlim from dual union all 
SELECT 11 cdcooper, 0396990 nrdconta,  00040859 nrctrlim from dual union all 
SELECT 11 cdcooper, 0457132 nrdconta,  00367702 nrctrlim from dual union all 
SELECT 11 cdcooper, 0657948 nrdconta,  00113862 nrctrlim from dual union all 
SELECT 11 cdcooper, 0548146 nrdconta,  00044678 nrctrlim from dual union all 
SELECT 11 cdcooper, 0490970 nrdconta,  00039446 nrctrlim from dual union all 
SELECT 11 cdcooper, 0551821 nrdconta,  00110608 nrctrlim from dual union all 
SELECT 11 cdcooper, 0477486 nrdconta,  00044241 nrctrlim from dual union all 
SELECT 11 cdcooper, 0512303 nrdconta,  00039555 nrctrlim from dual union all 
SELECT 11 cdcooper, 0453366 nrdconta,  00035173 nrctrlim from dual union all 
SELECT 11 cdcooper, 0405671 nrdconta,  00110129 nrctrlim from dual union all
SELECT 11 cdcooper, 0499285 nrdconta,  00114124 nrctrlim from dual union all
SELECT 11 cdcooper, 0542857 nrdconta,  00106243 nrctrlim from dual union all
SELECT 11 cdcooper, 0555711 nrdconta,  00047510 nrctrlim from dual union all
SELECT 11 cdcooper, 0439991 nrdconta,  00001980 nrctrlim from dual union all
SELECT 11 cdcooper, 0523550 nrdconta,  00104305 nrctrlim from dual union all
SELECT 11 cdcooper, 0561444 nrdconta,  00040539 nrctrlim from dual union all
SELECT 11 cdcooper, 0515752 nrdconta,  00045269 nrctrlim from dual
        ) cnt
                       )
          loop
            --
            vr_dsmensagem := null;
            vr_nrregistro := vr_nrregistro + 1;

            --
            begin
              --
              select 1, ass.flmajora into vr_existe_ass, vr_flmajora
              from crapass ass
              where ass.nrdconta = r_cnt.nrdconta
                and ass.cdcooper = r_cnt.cdcooper;
              --
            exception
              when others then
                vr_existe_ass := 0;
                vr_dsmensagem := 'Cooperado nao existe';
            end;
            
            IF vr_flmajora = 1 THEN
                vr_existe_ass := 0;
                vr_dsmensagem := 'Majoração já habilitada!';            
            END IF;
            --
            vr_existe_lim := 0;
            vr_insitlim := 0;
            if vr_existe_ass = 1  then
              --
              begin
                --
                select 1, lim.insitlim, lim.tpctrlim into vr_existe_lim, vr_insitlim, vr_tpctrlim
                from craplim lim
                where lim.nrctrlim = r_cnt.nrctrlim
                  and lim.nrdconta = r_cnt.nrdconta
                  and lim.cdcooper = r_cnt.cdcooper;
                --  and lim.tpctrlim = 1;
                --
              exception
                when others then
                  vr_existe_lim := 0;
                  vr_dsmensagem := 'Contrato nao encontrado';
              end;
              --
              IF vr_tpctrlim <> 1 THEN
                  vr_existe_ass := 0;
                  vr_dsmensagem := 'Contrato nao encontrado, mas existe com o tipo Contrato: '||vr_tpctrlim;            
              END IF;              
              
              if vr_existe_lim = 1 AND vr_insitlim = 2 THEN  -- 2-contrato ativo
                --
                begin
                  --
                  UPDATE crapass a
                  SET a.flmajora  = 1-- Majoração automática habilitada
                  WHERE a.nrdconta = r_cnt.nrdconta
                  AND a.cdcooper = r_cnt.cdcooper;
                  --
                exception
                  when others then
                    vr_dsmensagem := 'Erro na atualizacao:'||sqlerrm;
                end;
                --
                if vr_dsmensagem is null then
                  --
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                ,pr_des_text => 'UPDATE crapass a '    ||
                                                                '   SET a.flmajora = 0 '||
                                                                ' WHERE a.cdcooper = ' || r_cnt.cdcooper       ||
                                                                '   AND a.nrdconta = ' || r_cnt.nrdconta       ||
                                                                ';');

                                     
                  GENE0001.pc_gera_log(pr_cdcooper => r_cnt.cdcooper
                                      ,pr_cdoperad => '1'
                                      ,pr_dscritic => ' '
                                      ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                                      ,pr_dstransa => 'Habilitar Majoração em massa (RITM0127089)'
                                      ,pr_dttransa => TRUNC(SYSDATE)
                                      ,pr_flgtrans => 1
                                      ,pr_hrtransa => gene0002.fn_busca_time
                                      ,pr_idseqttl => 1
                                      ,pr_nmdatela => 'Script'
                                      ,pr_nrdconta => r_cnt.nrdconta
                                      ,pr_nrdrowid => vr_nrdrowid);
                  --
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                            pr_nmdcampo => 'crapass.flmajora',
                                            pr_dsdadant => '0',
                                            pr_dsdadatu => '1');
                  --
                end if;
                --
              ELSIF vr_existe_lim = 1 AND vr_insitlim <> 2 THEN
                vr_dsmensagem := 'Contrato não é ativo.';
              END IF;
              --

            end if;
               
            IF vr_dsmensagem IS NOT NULL THEN
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                            ,pr_des_text => vr_nrregistro || ';' || r_cnt.cdcooper || ';' || r_cnt.nrdconta ||
                                                            ';' || r_cnt.nrctrlim || ';' || vr_dsmensagem);
            END IF;
            --
          end loop;
          --
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                        ,pr_des_text => 'Total de registros tratados no processo: ' || vr_nrregistro);
          --
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                ,pr_des_text => 'COMMIT;');
                                                
          COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      --dbms_output.put_line('Erro: ' || vr_dsmensagem || ' SQLERRM: ' || SQLERRM);
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                    ,pr_des_text => 'Erro: ' || vr_dsmensagem || ' SQLERRM: ' || SQLERRM);
      
      ROLLBACK;
  END;
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
end;
