declare
  --
  vr_nrregistro number := 0;
  vr_existe_ass number;
  vr_existe_lim number;
  vr_nrdrowid   rowid;
  vr_dsmensagem varchar2(500);
  vr_nmarq_rollback VARCHAR2(100);
  vr_nmarq_log      VARCHAR2(100);
  vr_des_erro VARCHAR2(1000);
  vr_dscritic VARCHAR2(1000);
  vr_handle utl_file.file_type;
  vr_handle_log utl_file.file_type;
  vr_exc_erro EXCEPTION;
  
  vr_insitlim NUMBER(5);
  vr_cddlinha_contrato NUMBER(10);
  vr_dsdireto varchar2(300);
  ----
BEGIN
  BEGIN

-- caminho para produção:
          vr_dsdireto       := SISTEMA.obternomedirectory(GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/');
          vr_nmarq_rollback := vr_dsdireto||'RITM0123000_ROLLBACK.sql';
          vr_nmarq_log      := vr_dsdireto||'LOG_RITM0123000.txt';

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
              ,cnt.cddlinha_atual
              ,cnt.cddlinha_nova
        from
        (
SELECT 05 cdcooper, 0120952 nrdconta,  00259197 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0144959 nrdconta,  00000270 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0216968 nrdconta,  00101658 nrctrlim, 13  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0184314 nrdconta,  00002576 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0138339 nrdconta,  04077190 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0147028 nrdconta,  00424487 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0114650 nrdconta,  00105297 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0207551 nrdconta,  00002590 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0164720 nrdconta,  00002729 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0089940 nrdconta,  00323395 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0161705 nrdconta,  00003158 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0174742 nrdconta,  00006718 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0179590 nrdconta,  00100576 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0151068 nrdconta,  00001154 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0120855 nrdconta,  00259200 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0173320 nrdconta,  00008143 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0234834 nrdconta,  00000662 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0154512 nrdconta,  00000364 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0151882 nrdconta,  00001166 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0115975 nrdconta,  00259131 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0177490 nrdconta,  00000428 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0034126 nrdconta,  00016978 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0164607 nrdconta,  00002728 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0124397 nrdconta,  00380763 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0102270 nrdconta,  00342671 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0124206 nrdconta,  00000057 nrctrlim, 13  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0146684 nrdconta,  00000312 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0086398 nrdconta,  00103338 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0263524 nrdconta,  00000894 nrctrlim, 13  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0208680 nrdconta,  00101086 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0159956 nrdconta,  00000430 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0157880 nrdconta,  00002639 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0189448 nrdconta,  00002461 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0098884 nrdconta,  00000827 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0046906 nrdconta,  00044076 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0142670 nrdconta,  00424448 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0179418 nrdconta,  00004307 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0140562 nrdconta,  00000145 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0191884 nrdconta,  00006709 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0172650 nrdconta,  00001693 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0139688 nrdconta,  00416514 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0127515 nrdconta,  00380871 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0181390 nrdconta,  00000145 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0158011 nrdconta,  00002082 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0149195 nrdconta,  00149195 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0132659 nrdconta,  00380696 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0149136 nrdconta,  00104797 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0113220 nrdconta,  00013618 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0109444 nrdconta,  00365450 nrctrlim, 11  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0151483 nrdconta,  00001161 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0123633 nrdconta,  00380646 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0130060 nrdconta,  00000815 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0120081 nrdconta,  00100936 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0143430 nrdconta,  00000228 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0176613 nrdconta,  00003315 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0081264 nrdconta,  00103303 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0249394 nrdconta,  00104412 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0051357 nrdconta,  00044009 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0075523 nrdconta,  00104402 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0147150 nrdconta,  00000323 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0104515 nrdconta,  00000171 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0253260 nrdconta,  00102881 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0132322 nrdconta,  00000056 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0146870 nrdconta,  00000315 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0146390 nrdconta,  00002539 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0160997 nrdconta,  00003149 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0237965 nrdconta,  00105370 nrctrlim, 13  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0146749 nrdconta,  00000083 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0216925 nrdconta,  00101295 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0145173 nrdconta,  00101566 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0163090 nrdconta,  00002149 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0066826 nrdconta,  00044055 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0081345 nrdconta,  00000283 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0209589 nrdconta,  00101110 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0251062 nrdconta,  00102751 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0112160 nrdconta,  00007053 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0263630 nrdconta,  00103808 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0176028 nrdconta,  00007074 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0150436 nrdconta,  00000509 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0169650 nrdconta,  00000691 nrctrlim, 13  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0172383 nrdconta,  00005742 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0178357 nrdconta,  00008231 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0181137 nrdconta,  00008223 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0159344 nrdconta,  00000426 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0158968 nrdconta,  00000425 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0254819 nrdconta,  00104794 nrctrlim, 13  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0188468 nrdconta,  00002427 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0130397 nrdconta,  00342632 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0137235 nrdconta,  00003551 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0159476 nrdconta,  00000428 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0135151 nrdconta,  00338583 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0090476 nrdconta,  00352057 nrctrlim, 11  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0100846 nrdconta,  00336063 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0126527 nrdconta,  00043829 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0114790 nrdconta,  00259114 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0239909 nrdconta,  00003033 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144444 nrdconta,  00000057 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0140023 nrdconta,  00416517 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0186074 nrdconta,  00000712 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0118400 nrdconta,  00380645 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0113760 nrdconta,  00001772 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0201006 nrdconta,  00104230 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0221708 nrdconta,  00007478 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0106771 nrdconta,  00336052 nrctrlim, 07  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0199940 nrdconta,  00100814 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0157929 nrdconta,  00003214 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0106267 nrdconta,  00336029 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0048569 nrdconta,  00000638 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0043990 nrdconta,  00102481 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0127418 nrdconta,  00100237 nrctrlim, 07  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0208914 nrdconta,  00101011 nrctrlim, 11  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0110949 nrdconta,  00259699 nrctrlim, 07  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0158194 nrdconta,  00001793 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0180289 nrdconta,  00003359 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0110760 nrdconta,  00000148 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0254169 nrdconta,  00103479 nrctrlim, 13  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0191671 nrdconta,  00004292 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0225070 nrdconta,  00101664 nrctrlim, 13  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0149900 nrdconta,  00001716 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0131830 nrdconta,  00342641 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0148776 nrdconta,  00000351 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0119156 nrdconta,  00307529 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0121053 nrdconta,  00105290 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0180360 nrdconta,  00008217 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0167614 nrdconta,  00005724 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0174521 nrdconta,  00101038 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0126322 nrdconta,  00101823 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0128015 nrdconta,  00000012 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0146226 nrdconta,  00001317 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0132551 nrdconta,  00365968 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0150525 nrdconta,  00001152 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0186627 nrdconta,  00100097 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0214060 nrdconta,  00101384 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0142980 nrdconta,  00001420 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0147109 nrdconta,  00001315 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0238635 nrdconta,  00102610 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0145467 nrdconta,  00000859 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0210285 nrdconta,  00101049 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0215473 nrdconta,  00101246 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0139548 nrdconta,  00000667 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0139459 nrdconta,  00380570 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0154016 nrdconta,  00000288 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0140538 nrdconta,  00103462 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0140414 nrdconta,  00002683 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0212199 nrdconta,  00101146 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144363 nrdconta,  00000279 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0154989 nrdconta,  00000291 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0168432 nrdconta,  00007023 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0201502 nrdconta,  00002356 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0184080 nrdconta,  00101104 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144495 nrdconta,  00000058 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0143421 nrdconta,  00000028 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0155128 nrdconta,  00001372 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0145793 nrdconta,  00000335 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0150690 nrdconta,  00000377 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0246670 nrdconta,  00000787 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0152145 nrdconta,  00100847 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0157996 nrdconta,  00104428 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0262269 nrdconta,  00104280 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0196207 nrdconta,  00007284 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0173746 nrdconta,  00007136 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0150851 nrdconta,  00001468 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0151459 nrdconta,  00001328 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0165735 nrdconta,  00004321 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0180190 nrdconta,  00000399 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0162752 nrdconta,  00100722 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0158291 nrdconta,  00429206 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0242349 nrdconta,  00000656 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0234133 nrdconta,  00101939 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0158828 nrdconta,  00002556 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0165590 nrdconta,  00005913 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0172774 nrdconta,  00105288 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0168050 nrdconta,  00002566 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0177105 nrdconta,  00000123 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0171972 nrdconta,  00101220 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0248029 nrdconta,  00000715 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0210226 nrdconta,  00101168 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0173860 nrdconta,  00007149 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0184195 nrdconta,  00100154 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0197890 nrdconta,  00002471 nrctrlim, 11  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0180475 nrdconta,  00003361 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0201189 nrdconta,  00100730 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0198943 nrdconta,  00100590 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0184004 nrdconta,  00101045 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0198560 nrdconta,  00000590 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0189880 nrdconta,  00100303 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0212989 nrdconta,  00101211 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0188816 nrdconta,  00010407 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0218138 nrdconta,  00101310 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0184420 nrdconta,  00008247 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0218600 nrdconta,  00000641 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0247332 nrdconta,  00102472 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0196886 nrdconta,  00100538 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0200085 nrdconta,  00000695 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0192872 nrdconta,  00000670 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0206792 nrdconta,  00100932 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0207020 nrdconta,  00104965 nrctrlim, 14  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0204986 nrdconta,  00009002 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0206105 nrdconta,  00010137 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0207101 nrdconta,  00101736 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0205346 nrdconta,  00100927 nrctrlim, 11  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0238627 nrdconta,  00103088 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0234630 nrdconta,  00002599 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0235920 nrdconta,  00102805 nrctrlim, 13  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0243175 nrdconta,  00102300 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0242250 nrdconta,  00010646 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0241016 nrdconta,  00102213 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0256218 nrdconta,  00103000 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0076104 nrdconta,  00000734 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0082660 nrdconta,  00043884 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0114740 nrdconta,  00372738 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0160750 nrdconta,  00002634 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0123609 nrdconta,  00307509 nrctrlim, 12  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144703 nrdconta,  00424466 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0165972 nrdconta,  00000795 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0159620 nrdconta,  00001910 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0114197 nrdconta,  00342693 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0057568 nrdconta,  00000622 nrctrlim, 07  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0252395 nrdconta,  00000814 nrctrlim, 13  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0256269 nrdconta,  00104273 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0142395 nrdconta,  00000449 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0068101 nrdconta,  00259330 nrctrlim, 02  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0069124 nrdconta,  00104791 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0252964 nrdconta,  00102878 nrctrlim, 09  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0132519 nrdconta,  00001511 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0193038 nrdconta,  00100440 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0148083 nrdconta,  00001113 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144355 nrdconta,  00001147 nrctrlim, 10  cddlinha_atual, 14  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0149748 nrdconta,  00001734 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0145025 nrdconta,  00000271 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0220949 nrdconta,  00006695 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144789 nrdconta,  00424463 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0139696 nrdconta,  00405564 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0227269 nrdconta,  00105186 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0029971 nrdconta,  00334405 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0023140 nrdconta,  00004308 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0102539 nrdconta,  00352116 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0138118 nrdconta,  00401046 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0165328 nrdconta,  00002162 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0107204 nrdconta,  00366096 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0210137 nrdconta,  00005654 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0096210 nrdconta,  00338138 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0043273 nrdconta,  00000634 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0024457 nrdconta,  00105511 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0149225 nrdconta,  00001122 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0107328 nrdconta,  00000873 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0026786 nrdconta,  00402591 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0048410 nrdconta,  00352194 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0025453 nrdconta,  00323464 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0160555 nrdconta,  00000440 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0200760 nrdconta,  00010126 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0185280 nrdconta,  00003120 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0114928 nrdconta,  00259119 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0073377 nrdconta,  00000896 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0091162 nrdconta,  00363110 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0091219 nrdconta,  00380918 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0051322 nrdconta,  00400962 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0151475 nrdconta,  00001160 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0033448 nrdconta,  00001787 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144657 nrdconta,  00424433 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0062782 nrdconta,  00402589 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0172910 nrdconta,  00001695 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0216810 nrdconta,  00010632 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0225720 nrdconta,  00104901 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0263605 nrdconta,  00103803 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0095222 nrdconta,  00103976 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0061441 nrdconta,  00001308 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0162000 nrdconta,  00102668 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0135194 nrdconta,  00380540 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0224596 nrdconta,  00010604 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0040266 nrdconta,  00259393 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0117196 nrdconta,  00391931 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0145831 nrdconta,  00007392 nrctrlim, 03  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0126144 nrdconta,  00338507 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0127795 nrdconta,  00380999 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0180971 nrdconta,  00004303 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0003140 nrdconta,  00334448 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0087572 nrdconta,  00389894 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0196460 nrdconta,  00004415 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0088536 nrdconta,  00001496 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0126055 nrdconta,  00101682 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0120650 nrdconta,  00391985 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0058157 nrdconta,  00336034 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0084719 nrdconta,  00336032 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0193844 nrdconta,  00100429 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0008028 nrdconta,  00323490 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0098914 nrdconta,  00365825 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0032883 nrdconta,  00010331 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0141313 nrdconta,  00405647 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0167487 nrdconta,  00103196 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0103292 nrdconta,  00103613 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0207730 nrdconta,  00007340 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0098744 nrdconta,  00001027 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0142727 nrdconta,  00000743 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0045543 nrdconta,  00105503 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0117765 nrdconta,  00102149 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0046035 nrdconta,  00323313 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0204412 nrdconta,  00006741 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0070882 nrdconta,  00380616 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0133000 nrdconta,  00380682 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0204250 nrdconta,  00004444 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0081418 nrdconta,  00103169 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0064840 nrdconta,  00001582 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0114677 nrdconta,  00102675 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0189413 nrdconta,  00004338 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0148245 nrdconta,  00000056 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0074195 nrdconta,  00105049 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0080330 nrdconta,  00002478 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0074560 nrdconta,  00338536 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0072389 nrdconta,  00380666 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0109380 nrdconta,  00001799 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0009857 nrdconta,  00307632 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0153494 nrdconta,  00001365 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0092495 nrdconta,  00000676 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0180653 nrdconta,  00002316 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144479 nrdconta,  00101076 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0107468 nrdconta,  00001291 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0109240 nrdconta,  00102656 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0143960 nrdconta,  00001425 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0238112 nrdconta,  00008342 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0087297 nrdconta,  00336083 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0006858 nrdconta,  00391905 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0178802 nrdconta,  00007199 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0029157 nrdconta,  00102586 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0200328 nrdconta,  00006642 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0137308 nrdconta,  00338514 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0132101 nrdconta,  00101369 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0016225 nrdconta,  00379147 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0234389 nrdconta,  00101946 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0114545 nrdconta,  00380612 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0199729 nrdconta,  00010125 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0133949 nrdconta,  00365986 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0149799 nrdconta,  00001812 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0010464 nrdconta,  00000131 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0183865 nrdconta,  00002232 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0006408 nrdconta,  00102681 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0208299 nrdconta,  00005651 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0044989 nrdconta,  00389811 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144037 nrdconta,  00416530 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0126314 nrdconta,  00006772 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0189570 nrdconta,  00000172 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0161438 nrdconta,  00000464 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0164437 nrdconta,  00002694 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0174181 nrdconta,  00100447 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0135488 nrdconta,  00380978 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0141712 nrdconta,  00104600 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0257729 nrdconta,  00104994 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0132640 nrdconta,  00338576 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0050563 nrdconta,  00044188 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0101591 nrdconta,  00352042 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0162248 nrdconta,  00001646 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0241520 nrdconta,  00102245 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0002186 nrdconta,  00102550 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0045560 nrdconta,  00104201 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0119016 nrdconta,  00006744 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0188107 nrdconta,  00104997 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0052833 nrdconta,  00102441 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0076112 nrdconta,  00103726 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0159980 nrdconta,  00000459 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0109126 nrdconta,  00365493 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0110728 nrdconta,  00001218 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0100617 nrdconta,  00336095 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0127264 nrdconta,  00100356 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0122815 nrdconta,  00401009 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0156825 nrdconta,  00000667 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0116300 nrdconta,  00338416 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0193895 nrdconta,  00007302 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0148610 nrdconta,  00001261 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0182290 nrdconta,  00002327 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0013803 nrdconta,  00389850 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0136255 nrdconta,  00380991 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0083984 nrdconta,  00002654 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0085901 nrdconta,  00000878 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0162418 nrdconta,  00006742 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0171778 nrdconta,  00007123 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0141534 nrdconta,  00005914 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0134945 nrdconta,  00402599 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0115339 nrdconta,  00003588 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0137197 nrdconta,  00000862 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0021610 nrdconta,  00366035 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0108286 nrdconta,  00336051 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0175153 nrdconta,  00008203 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0057576 nrdconta,  00003062 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0108944 nrdconta,  00391919 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0158496 nrdconta,  00003527 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0173045 nrdconta,  00002205 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0007242 nrdconta,  00402517 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0146277 nrdconta,  00000079 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0081884 nrdconta,  00401031 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0076201 nrdconta,  00336088 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0119083 nrdconta,  00259162 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0116475 nrdconta,  00000955 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0018910 nrdconta,  00391990 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0146579 nrdconta,  00000702 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0168556 nrdconta,  00007025 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0140325 nrdconta,  00416315 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0161527 nrdconta,  00001833 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0119725 nrdconta,  00400967 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0194557 nrdconta,  00004299 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0002313 nrdconta,  00389888 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0158712 nrdconta,  00002604 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0123862 nrdconta,  00334452 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0135836 nrdconta,  00402576 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0144061 nrdconta,  00001426 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0083240 nrdconta,  00365847 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0155993 nrdconta,  00001527 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0129453 nrdconta,  00400963 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0023426 nrdconta,  00002151 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0132276 nrdconta,  00365964 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0142050 nrdconta,  00416336 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0024430 nrdconta,  00043743 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0023396 nrdconta,  00101268 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0031445 nrdconta,  00307686 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0126659 nrdconta,  00338534 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0131199 nrdconta,  00007100 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0248789 nrdconta,  00102590 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0022926 nrdconta,  00307628 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0209538 nrdconta,  00101089 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0151327 nrdconta,  00000865 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0157171 nrdconta,  00002067 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0019860 nrdconta,  00003566 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0102750 nrdconta,  00380674 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0162183 nrdconta,  00102688 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0149144 nrdconta,  00001046 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0029165 nrdconta,  00389849 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0079839 nrdconta,  00334567 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0100528 nrdconta,  00002448 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0164593 nrdconta,  00003182 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0131687 nrdconta,  00342639 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0155780 nrdconta,  00003098 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0104744 nrdconta,  00336031 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0188271 nrdconta,  00007206 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0225860 nrdconta,  00003086 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0118036 nrdconta,  00102689 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0130753 nrdconta,  00365957 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0087050 nrdconta,  00002420 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0024082 nrdconta,  00259360 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0024821 nrdconta,  00104521 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0165522 nrdconta,  00102100 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0126454 nrdconta,  00400968 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0146811 nrdconta,  00102692 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0266841 nrdconta,  00104844 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0151980 nrdconta,  00001171 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0031798 nrdconta,  00405628 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0093645 nrdconta,  00001463 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0141500 nrdconta,  00405582 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0079693 nrdconta,  00007205 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0114871 nrdconta,  00000864 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0202053 nrdconta,  00100761 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0237744 nrdconta,  00011701 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0044148 nrdconta,  00389869 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0069442 nrdconta,  00365835 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0073865 nrdconta,  00043880 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0240230 nrdconta,  00102161 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0114030 nrdconta,  00380818 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0051764 nrdconta,  00010465 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0083348 nrdconta,  00002285 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0125318 nrdconta,  00402561 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0234958 nrdconta,  00102978 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0133841 nrdconta,  00043858 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0112771 nrdconta,  00259698 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0136298 nrdconta,  00402568 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0194581 nrdconta,  00103069 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0137839 nrdconta,  00407720 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0253332 nrdconta,  00102886 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0168700 nrdconta,  00002194 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0042757 nrdconta,  00102552 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0018880 nrdconta,  00044155 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0262196 nrdconta,  00105229 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0081876 nrdconta,  00352151 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0084875 nrdconta,  00003526 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0115630 nrdconta,  00389816 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0219401 nrdconta,  00008341 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0219789 nrdconta,  00004271 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0092550 nrdconta,  00013634 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0139033 nrdconta,  00416508 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0096750 nrdconta,  00391907 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0176400 nrdconta,  00104281 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0031500 nrdconta,  00104293 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0138312 nrdconta,  00013686 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0161780 nrdconta,  00002138 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0166995 nrdconta,  00000486 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0170208 nrdconta,  00100872 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0076813 nrdconta,  00105306 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0042390 nrdconta,  00352192 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0152439 nrdconta,  00000787 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0167282 nrdconta,  00003590 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0041009 nrdconta,  00001219 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0075434 nrdconta,  00104354 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0038202 nrdconta,  00338433 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0139505 nrdconta,  00416305 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0126250 nrdconta,  00010419 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0021563 nrdconta,  00002480 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0249866 nrdconta,  00102778 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0153117 nrdconta,  00001181 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0023914 nrdconta,  00102731 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0019500 nrdconta,  00338412 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0195901 nrdconta,  00007276 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0203998 nrdconta,  00010135 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0031070 nrdconta,  00389872 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0133892 nrdconta,  00004322 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0240036 nrdconta,  00102404 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0115800 nrdconta,  00379177 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0227722 nrdconta,  00101723 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0116130 nrdconta,  00103238 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0242314 nrdconta,  00010647 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0137090 nrdconta,  00000967 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0221643 nrdconta,  00104317 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0246719 nrdconta,  00102451 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0068209 nrdconta,  00405615 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0099201 nrdconta,  00338495 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0079502 nrdconta,  00338589 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0074888 nrdconta,  00259377 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0081566 nrdconta,  00000910 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0084425 nrdconta,  00000843 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0177377 nrdconta,  00004195 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0036200 nrdconta,  00342668 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0037818 nrdconta,  00001052 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0156817 nrdconta,  00100313 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0162310 nrdconta,  00104735 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0118060 nrdconta,  00391938 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0203629 nrdconta,  00002489 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0040827 nrdconta,  00391918 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0168661 nrdconta,  00002657 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0074993 nrdconta,  00102798 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0098680 nrdconta,  00101188 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0029190 nrdconta,  00001053 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0138282 nrdconta,  00405606 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0112518 nrdconta,  00338501 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0067792 nrdconta,  00102463 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0179221 nrdconta,  00000436 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0207764 nrdconta,  00002358 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0044245 nrdconta,  00004458 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0111708 nrdconta,  00013640 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0089397 nrdconta,  00043899 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0110434 nrdconta,  00401022 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0141917 nrdconta,  00102410 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0118583 nrdconta,  00391942 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0127710 nrdconta,  00000059 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0075469 nrdconta,  00352027 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0075140 nrdconta,  00102783 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0081019 nrdconta,  00380720 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0080322 nrdconta,  00104455 nrctrlim, 16  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0197793 nrdconta,  00007299 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0096776 nrdconta,  00338441 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0085286 nrdconta,  00402572 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0085928 nrdconta,  00000909 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0198714 nrdconta,  00007312 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0103500 nrdconta,  00044146 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0150673 nrdconta,  00000785 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0116378 nrdconta,  00003065 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0093920 nrdconta,  00010210 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0077909 nrdconta,  00002469 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0031844 nrdconta,  00259340 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0137170 nrdconta,  00001407 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0150681 nrdconta,  00103917 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0036226 nrdconta,  00102319 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0168009 nrdconta,  00007015 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0103446 nrdconta,  00001439 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0125547 nrdconta,  00365931 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0101869 nrdconta,  00372751 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0181129 nrdconta,  00002451 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0066818 nrdconta,  00102709 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0060178 nrdconta,  00389846 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0202215 nrdconta,  00010140 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0137553 nrdconta,  00411803 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0123749 nrdconta,  00103189 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0173398 nrdconta,  00007130 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0027570 nrdconta,  00102571 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0202339 nrdconta,  00010141 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0037141 nrdconta,  00102507 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0131326 nrdconta,  00000738 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0036757 nrdconta,  00259336 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0101524 nrdconta,  00352043 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0161420 nrdconta,  00000462 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144762 nrdconta,  00424462 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0113506 nrdconta,  00307688 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0141976 nrdconta,  00100740 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0249831 nrdconta,  00102666 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0177350 nrdconta,  00104054 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0209988 nrdconta,  00101344 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0061255 nrdconta,  00001792 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0181471 nrdconta,  00001914 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0091790 nrdconta,  00338107 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0080535 nrdconta,  00336014 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0045608 nrdconta,  00101778 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0147745 nrdconta,  00001105 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0095419 nrdconta,  00342699 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0158364 nrdconta,  00005511 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0087076 nrdconta,  00001637 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0162930 nrdconta,  00003163 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0087386 nrdconta,  00336065 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0062480 nrdconta,  00102792 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0084590 nrdconta,  00102573 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0075000 nrdconta,  00365895 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0048402 nrdconta,  00044132 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144509 nrdconta,  00000265 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0080691 nrdconta,  00102674 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0223760 nrdconta,  00102515 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0184870 nrdconta,  00008273 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0147494 nrdconta,  00001298 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0140287 nrdconta,  00401068 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0168211 nrdconta,  00004124 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0078298 nrdconta,  00001887 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0059501 nrdconta,  00003562 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0097535 nrdconta,  00102578 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0083542 nrdconta,  00005655 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0128007 nrdconta,  00342616 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0253820 nrdconta,  00104564 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0052108 nrdconta,  00001269 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0236080 nrdconta,  00010328 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0132608 nrdconta,  00105078 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0115231 nrdconta,  00389803 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0039152 nrdconta,  00043712 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0211176 nrdconta,  00007353 nrctrlim, 03  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0075493 nrdconta,  00013654 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0045837 nrdconta,  00001705 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0129020 nrdconta,  00001249 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0256870 nrdconta,  00104802 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0231819 nrdconta,  00007342 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0111309 nrdconta,  00259697 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0124478 nrdconta,  00401037 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0040304 nrdconta,  00103451 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0122424 nrdconta,  00389861 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0222186 nrdconta,  00004478 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0138819 nrdconta,  00401055 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0108170 nrdconta,  00103452 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0070700 nrdconta,  00365828 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0211915 nrdconta,  00101131 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0185000 nrdconta,  00002269 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0256382 nrdconta,  00104743 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0137146 nrdconta,  00411797 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0176036 nrdconta,  00101991 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0131318 nrdconta,  00342637 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0032867 nrdconta,  00259388 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0193780 nrdconta,  00004295 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0131180 nrdconta,  00001382 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0067423 nrdconta,  00001676 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0090247 nrdconta,  00000603 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0140686 nrdconta,  00001760 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0151297 nrdconta,  00000510 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0139750 nrdconta,  00401064 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0217484 nrdconta,  00006753 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0067814 nrdconta,  00323418 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0107271 nrdconta,  00365423 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0176362 nrdconta,  00003313 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0064530 nrdconta,  00391917 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0141623 nrdconta,  00101056 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0176974 nrdconta,  00007176 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0076929 nrdconta,  00402544 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0093092 nrdconta,  00389824 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0114200 nrdconta,  00342694 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0158151 nrdconta,  00000415 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0195561 nrdconta,  00007271 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0113131 nrdconta,  00307687 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0149152 nrdconta,  00001774 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0224162 nrdconta,  00104318 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0218731 nrdconta,  00007403 nrctrlim, 03  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0241113 nrdconta,  00104777 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0125334 nrdconta,  00402562 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0084352 nrdconta,  00000737 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0175293 nrdconta,  00104234 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0074446 nrdconta,  00307665 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0087220 nrdconta,  00334509 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0167975 nrdconta,  00002650 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0229725 nrdconta,  00101770 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0161918 nrdconta,  00002118 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0253197 nrdconta,  00102876 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0198765 nrdconta,  00007316 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0132411 nrdconta,  00365965 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0133272 nrdconta,  00365981 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0089028 nrdconta,  00009580 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0157430 nrdconta,  00003522 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0069540 nrdconta,  00000518 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0189812 nrdconta,  00007231 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0247790 nrdconta,  00102499 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0168017 nrdconta,  00008103 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0185388 nrdconta,  00002454 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0067334 nrdconta,  00259683 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0095133 nrdconta,  00391995 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0099066 nrdconta,  00338488 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0208817 nrdconta,  00105206 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0136549 nrdconta,  00407705 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0045152 nrdconta,  00044037 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0079979 nrdconta,  00380772 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0223476 nrdconta,  00101744 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0171956 nrdconta,  00003066 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0059633 nrdconta,  00259025 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0141828 nrdconta,  00365794 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0121657 nrdconta,  00389829 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0106364 nrdconta,  00005667 nrctrlim, 03  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0102130 nrdconta,  00338522 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0136239 nrdconta,  00103493 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0143278 nrdconta,  00001412 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0048720 nrdconta,  00338525 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0108243 nrdconta,  00352052 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0113379 nrdconta,  00389896 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0121142 nrdconta,  00389827 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0084662 nrdconta,  00342676 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0119415 nrdconta,  00391960 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0178632 nrdconta,  00007193 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0123145 nrdconta,  00405584 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0046264 nrdconta,  00102517 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0169064 nrdconta,  00003261 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0157686 nrdconta,  00003523 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0182532 nrdconta,  00004215 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0160075 nrdconta,  00000433 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0145319 nrdconta,  00001435 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0041548 nrdconta,  00389854 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0082295 nrdconta,  00100997 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0102741 nrdconta,  00365496 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0214523 nrdconta,  00007378 nrctrlim, 03  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0084697 nrdconta,  00389843 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0104205 nrdconta,  00001873 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0153214 nrdconta,  00001186 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0126756 nrdconta,  00102456 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0159603 nrdconta,  00102712 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0106437 nrdconta,  00000900 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0247316 nrdconta,  00102469 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0114847 nrdconta,  00000907 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0041130 nrdconta,  00103176 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0079618 nrdconta,  00002458 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0195898 nrdconta,  00007274 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0201170 nrdconta,  00100728 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0131547 nrdconta,  00365959 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0194123 nrdconta,  00007264 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0102920 nrdconta,  00102086 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0080314 nrdconta,  00400902 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0160288 nrdconta,  00002126 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0069620 nrdconta,  00005923 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0176370 nrdconta,  00005762 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0134899 nrdconta,  00103281 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0043729 nrdconta,  00102760 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0111724 nrdconta,  00380957 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0147460 nrdconta,  00000091 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0102016 nrdconta,  00105108 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0190101 nrdconta,  00004342 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0084646 nrdconta,  00003508 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0089168 nrdconta,  00102776 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0149047 nrdconta,  00000506 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0114634 nrdconta,  00000954 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0162604 nrdconta,  00003161 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0148806 nrdconta,  00002552 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0106577 nrdconta,  00102717 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0086657 nrdconta,  00379171 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0143855 nrdconta,  00000050 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0162159 nrdconta,  00000468 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0038261 nrdconta,  00352046 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0042889 nrdconta,  00258961 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0182281 nrdconta,  00001896 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0120561 nrdconta,  00389825 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0100960 nrdconta,  00366055 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0152811 nrdconta,  00001174 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0185302 nrdconta,  00002272 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0162990 nrdconta,  00002147 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0224650 nrdconta,  00003084 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0134953 nrdconta,  00380782 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0160105 nrdconta,  00005303 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0080047 nrdconta,  00003068 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0246085 nrdconta,  00102413 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0233757 nrdconta,  00101967 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0042676 nrdconta,  00259344 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0054224 nrdconta,  00307639 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0044644 nrdconta,  00338532 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0185990 nrdconta,  00100143 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0238775 nrdconta,  00102079 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0162981 nrdconta,  00002253 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0157767 nrdconta,  00102718 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0210102 nrdconta,  00008920 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0211249 nrdconta,  00007354 nrctrlim, 03  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0066575 nrdconta,  00103506 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0194956 nrdconta,  00104952 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0214213 nrdconta,  00105358 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0045489 nrdconta,  00402528 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0088552 nrdconta,  00365473 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0227498 nrdconta,  00105123 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0163414 nrdconta,  00002512 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0162035 nrdconta,  00003230 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0134244 nrdconta,  00380965 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0207772 nrdconta,  00002359 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0226971 nrdconta,  00101900 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0135500 nrdconta,  00380542 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0123811 nrdconta,  00334451 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0177083 nrdconta,  00000122 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0123137 nrdconta,  00391976 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0103942 nrdconta,  00001907 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0186317 nrdconta,  00002245 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0074691 nrdconta,  00338109 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0133264 nrdconta,  00365979 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0133256 nrdconta,  00001000 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0071129 nrdconta,  00338330 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0197254 nrdconta,  00006725 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0139629 nrdconta,  00416307 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0169994 nrdconta,  00003558 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0243116 nrdconta,  00010845 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0140929 nrdconta,  00424411 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0044440 nrdconta,  00002665 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0048160 nrdconta,  00104480 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0161101 nrdconta,  00002112 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0221384 nrdconta,  00104716 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0210110 nrdconta,  00006667 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0190829 nrdconta,  00103821 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0120588 nrdconta,  00001018 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0109770 nrdconta,  00000925 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0056626 nrdconta,  00365816 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0156094 nrdconta,  00103942 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0053856 nrdconta,  00003567 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0201200 nrdconta,  00010138 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0107034 nrdconta,  00365471 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0073164 nrdconta,  00102759 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0160644 nrdconta,  00003541 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0059838 nrdconta,  00103515 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0126039 nrdconta,  00010178 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0242896 nrdconta,  00104099 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0152463 nrdconta,  00002002 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0160008 nrdconta,  00000460 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0231746 nrdconta,  00102093 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0079332 nrdconta,  00402571 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0171093 nrdconta,  00003269 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0135941 nrdconta,  00402577 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0100420 nrdconta,  00104479 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0077623 nrdconta,  00400988 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0142212 nrdconta,  00424912 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0204692 nrdconta,  00002367 nrctrlim, 03  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0162140 nrdconta,  00001836 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0159190 nrdconta,  00101952 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0067490 nrdconta,  00104841 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0205150 nrdconta,  00006724 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0166421 nrdconta,  00003197 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0067679 nrdconta,  00103151 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0208523 nrdconta,  00004453 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0059129 nrdconta,  00002612 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0222062 nrdconta,  00101394 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144142 nrdconta,  00000255 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0157090 nrdconta,  00003207 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0249696 nrdconta,  00102659 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0118338 nrdconta,  00336027 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0087670 nrdconta,  00334461 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0116670 nrdconta,  00402579 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0123170 nrdconta,  00334457 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0096563 nrdconta,  00405609 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0135607 nrdconta,  00105146 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0238805 nrdconta,  00102127 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0120103 nrdconta,  00104206 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0091430 nrdconta,  00001231 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0219002 nrdconta,  00103477 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0155802 nrdconta,  00000869 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0061204 nrdconta,  00102875 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0214590 nrdconta,  00007379 nrctrlim, 03  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0184691 nrdconta,  00002264 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0210064 nrdconta,  00007348 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0077925 nrdconta,  00002680 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0072338 nrdconta,  00307678 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0087351 nrdconta,  00400927 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0077291 nrdconta,  00400960 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0065811 nrdconta,  00003502 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0208337 nrdconta,  00104747 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0094650 nrdconta,  00401028 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0105031 nrdconta,  00411791 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0176940 nrdconta,  00007426 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0147907 nrdconta,  00001107 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0093513 nrdconta,  00001722 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0063630 nrdconta,  00102745 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0084760 nrdconta,  00103986 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0242110 nrdconta,  00104739 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0114766 nrdconta,  00307698 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0183725 nrdconta,  00102763 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0096741 nrdconta,  00342687 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0181692 nrdconta,  00003118 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0080195 nrdconta,  00002408 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0159468 nrdconta,  00000427 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0225428 nrdconta,  00101675 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0159530 nrdconta,  00001474 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0151947 nrdconta,  00001243 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0219479 nrdconta,  00006799 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0071498 nrdconta,  00001855 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0197106 nrdconta,  00006719 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0126799 nrdconta,  00010480 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0162515 nrdconta,  00003564 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0217395 nrdconta,  00006602 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0138150 nrdconta,  00000934 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0064823 nrdconta,  00365795 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0238643 nrdconta,  00102392 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0076767 nrdconta,  00380706 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0165425 nrdconta,  00007174 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0211923 nrdconta,  00007364 nrctrlim, 03  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0158666 nrdconta,  00001798 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0080853 nrdconta,  00000892 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0161110 nrdconta,  00002133 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0113620 nrdconta,  00002453 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0158577 nrdconta,  00002706 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0056669 nrdconta,  00001029 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0251623 nrdconta,  00102781 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0177130 nrdconta,  00000941 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0071250 nrdconta,  00405577 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0122440 nrdconta,  00389862 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0160393 nrdconta,  00005001 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0072478 nrdconta,  00102858 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0080349 nrdconta,  00380528 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0123412 nrdconta,  00005739 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0092185 nrdconta,  00044066 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0106615 nrdconta,  00000961 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144630 nrdconta,  00000259 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0149535 nrdconta,  00001732 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0257958 nrdconta,  00103293 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0136395 nrdconta,  00013660 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0121002 nrdconta,  00000754 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0217263 nrdconta,  00007400 nrctrlim, 03  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0102890 nrdconta,  00102733 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0249351 nrdconta,  00102633 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0146072 nrdconta,  00424436 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0138142 nrdconta,  00103699 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0094951 nrdconta,  00405570 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0097896 nrdconta,  00366083 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0141372 nrdconta,  00405649 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0124966 nrdconta,  00401038 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0075566 nrdconta,  00001248 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0128848 nrdconta,  00338554 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0252948 nrdconta,  00102862 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0111503 nrdconta,  00002411 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0172642 nrdconta,  00007040 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0134201 nrdconta,  00380964 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0192368 nrdconta,  00004351 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0081035 nrdconta,  00001682 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0171654 nrdconta,  00000930 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0173355 nrdconta,  00005616 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0195669 nrdconta,  00004382 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0095168 nrdconta,  00001065 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0266361 nrdconta,  00104189 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0111350 nrdconta,  00102736 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0160636 nrdconta,  00003569 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0193500 nrdconta,  00007261 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0251542 nrdconta,  00102775 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0166960 nrdconta,  00000484 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0199486 nrdconta,  00104194 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0254851 nrdconta,  00102954 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0160180 nrdconta,  00002630 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0238490 nrdconta,  00010182 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0134783 nrdconta,  00380775 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0199095 nrdconta,  00002490 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0248150 nrdconta,  00102561 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0159891 nrdconta,  00000429 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0235725 nrdconta,  00102783 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0188980 nrdconta,  00002460 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0195782 nrdconta,  00007275 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0134651 nrdconta,  00105417 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0179035 nrdconta,  00100201 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0127833 nrdconta,  00000665 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0146528 nrdconta,  00002124 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0261890 nrdconta,  00103474 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0114456 nrdconta,  00259108 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144347 nrdconta,  00002525 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0099449 nrdconta,  00338155 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0260517 nrdconta,  00103280 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0113727 nrdconta,  00307690 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0211834 nrdconta,  00105111 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0003735 nrdconta,  00352068 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0004898 nrdconta,  00338323 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0090450 nrdconta,  00000045 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0203610 nrdconta,  00100801 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144592 nrdconta,  00424432 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0012076 nrdconta,  00005642 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0066028 nrdconta,  00000681 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0083380 nrdconta,  00000974 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0136760 nrdconta,  00003401 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0142387 nrdconta,  00424446 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0201286 nrdconta,  00004435 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0199257 nrdconta,  00007325 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0203769 nrdconta,  00010821 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0052027 nrdconta,  00044012 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0224065 nrdconta,  00102966 nrctrlim, 16  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0002453 nrdconta,  00000179 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0182753 nrdconta,  00002332 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0040622 nrdconta,  00259301 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0112690 nrdconta,  00101347 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0150860 nrdconta,  00001127 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0135224 nrdconta,  00307533 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0143154 nrdconta,  00101334 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0165174 nrdconta,  00003235 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0136140 nrdconta,  00380988 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0010634 nrdconta,  00391982 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0238660 nrdconta,  00104228 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0194670 nrdconta,  00004373 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0225100 nrdconta,  00002499 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0086401 nrdconta,  00338452 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0113530 nrdconta,  00000879 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0119547 nrdconta,  00391957 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0121835 nrdconta,  00105405 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0024880 nrdconta,  00405571 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0084239 nrdconta,  00044015 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0197858 nrdconta,  00004423 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0266353 nrdconta,  00104187 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0116009 nrdconta,  00338409 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0007978 nrdconta,  00001064 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0074233 nrdconta,  00366081 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0076198 nrdconta,  00001606 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0036870 nrdconta,  00044001 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0081795 nrdconta,  00365845 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0126594 nrdconta,  00338510 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0030244 nrdconta,  00334463 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0250244 nrdconta,  00102700 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0121762 nrdconta,  00334456 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0151424 nrdconta,  00102768 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0221180 nrdconta,  00010467 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0178144 nrdconta,  00000944 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0172731 nrdconta,  00103990 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0131792 nrdconta,  00380797 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0219312 nrdconta,  00104985 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0004103 nrdconta,  00391965 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144304 nrdconta,  00002547 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0004090 nrdconta,  00323474 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0057487 nrdconta,  00380712 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0161934 nrdconta,  00000893 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0067539 nrdconta,  00334449 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0043826 nrdconta,  00000774 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0061239 nrdconta,  00000601 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0001589 nrdconta,  00104169 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0203645 nrdconta,  00002364 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0194182 nrdconta,  00100442 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0129534 nrdconta,  00001021 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0068721 nrdconta,  00352028 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0005266 nrdconta,  00102769 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0106453 nrdconta,  00424926 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0061514 nrdconta,  00366046 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0005541 nrdconta,  00044199 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0096822 nrdconta,  00338444 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0000205 nrdconta,  00001073 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0143812 nrdconta,  00000036 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0237663 nrdconta,  00102037 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0058173 nrdconta,  00323376 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0123404 nrdconta,  00102838 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0037478 nrdconta,  00102538 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0132497 nrdconta,  00380936 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0256072 nrdconta,  00102992 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0155357 nrdconta,  00001820 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0123064 nrdconta,  00001017 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0071013 nrdconta,  00334544 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0070386 nrdconta,  00402560 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0122360 nrdconta,  00001025 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0143774 nrdconta,  00000073 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0174785 nrdconta,  00007157 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0138207 nrdconta,  00000890 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0097349 nrdconta,  00000669 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0125911 nrdconta,  00402582 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0144770 nrdconta,  00416536 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0134589 nrdconta,  00001602 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0085960 nrdconta,  00401001 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0142808 nrdconta,  00005008 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0009148 nrdconta,  00002199 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0150045 nrdconta,  00001149 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0100676 nrdconta,  00352118 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0029769 nrdconta,  00003547 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0132578 nrdconta,  00001072 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0041793 nrdconta,  00017395 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0224677 nrdconta,  00007431 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0267988 nrdconta,  00104252 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0108111 nrdconta,  00366013 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0052043 nrdconta,  00102873 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0144177 nrdconta,  00000256 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0031992 nrdconta,  00101123 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0179922 nrdconta,  00008213 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0043800 nrdconta,  00352033 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0087980 nrdconta,  00104449 nrctrlim, 16  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0146382 nrdconta,  00002574 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0128090 nrdconta,  00104268 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0093963 nrdconta,  00338445 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0129810 nrdconta,  00043882 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0093297 nrdconta,  00000848 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0161160 nrdconta,  00002211 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0075019 nrdconta,  00342609 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0026476 nrdconta,  00338361 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0103136 nrdconta,  00103060 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0246409 nrdconta,  00102442 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0134465 nrdconta,  00334420 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0065609 nrdconta,  00323241 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0253375 nrdconta,  00103266 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0155209 nrdconta,  00002043 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all 
SELECT 05 cdcooper, 0199311 nrdconta,  00102647 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0125245 nrdconta,  00338503 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0145084 nrdconta,  00005661 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0100323 nrdconta,  00402514 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0146633 nrdconta,  00001288 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0084794 nrdconta,  00402541 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0207675 nrdconta,  00007338 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0195537 nrdconta,  00004380 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0145610 nrdconta,  00000609 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0206997 nrdconta,  00007092 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0016411 nrdconta,  00379032 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0236012 nrdconta,  00010660 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0036110 nrdconta,  00105211 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0235067 nrdconta,  00101960 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0056260 nrdconta,  00100076 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0134740 nrdconta,  00000824 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0033928 nrdconta,  00105398 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0160423 nrdconta,  00103996 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0111996 nrdconta,  00380603 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0118982 nrdconta,  00391950 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0127183 nrdconta,  00380867 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0176001 nrdconta,  00008208 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0160245 nrdconta,  00103285 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0206008 nrdconta,  00002395 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0092460 nrdconta,  00043811 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0115100 nrdconta,  00342692 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0247553 nrdconta,  00104982 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0234613 nrdconta,  00102098 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0118214 nrdconta,  00391939 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0189596 nrdconta,  00002462 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0092762 nrdconta,  00005903 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0189006 nrdconta,  00010366 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0138010 nrdconta,  00005777 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0003417 nrdconta,  00102771 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0032778 nrdconta,  00334416 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0189324 nrdconta,  00102981 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0041777 nrdconta,  00003525 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0157376 nrdconta,  00002073 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0189855 nrdconta,  00000186 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0082325 nrdconta,  00323216 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0122483 nrdconta,  00389863 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0074462 nrdconta,  00013650 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0003263 nrdconta,  00043803 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0026840 nrdconta,  00258976 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0204129 nrdconta,  00004385 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0081094 nrdconta,  00334599 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0006343 nrdconta,  00259386 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0179442 nrdconta,  00008235 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0129119 nrdconta,  00103482 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0158984 nrdconta,  00003143 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0084581 nrdconta,  00389832 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0171069 nrdconta,  00003271 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0138290 nrdconta,  00405607 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0111791 nrdconta,  00259680 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0137855 nrdconta,  00105124 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0069337 nrdconta,  00323209 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0096180 nrdconta,  00000004 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0138703 nrdconta,  00401056 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0160849 nrdconta,  00002113 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0026646 nrdconta,  00000029 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0061778 nrdconta,  00352097 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0032166 nrdconta,  00391936 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0177393 nrdconta,  00000943 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0085715 nrdconta,  00365447 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0004405 nrdconta,  00102791 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0231959 nrdconta,  00007359 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0116165 nrdconta,  00338414 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0142174 nrdconta,  00424426 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0233056 nrdconta,  00010812 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0241156 nrdconta,  00102224 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0105945 nrdconta,  00000696 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0095958 nrdconta,  00365755 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0145394 nrdconta,  00002549 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0252620 nrdconta,  00102828 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0086819 nrdconta,  00334450 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0138355 nrdconta,  00101427 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0108448 nrdconta,  00105624 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0126012 nrdconta,  00000957 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0243094 nrdconta,  00105126 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0128627 nrdconta,  00043833 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0112445 nrdconta,  00001020 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0157570 nrdconta,  00002075 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0141690 nrdconta,  00424422 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0016136 nrdconta,  00006793 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0118702 nrdconta,  00391948 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0191558 nrdconta,  00007244 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0080152 nrdconta,  00259102 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0080446 nrdconta,  00000801 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0158941 nrdconta,  00000424 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0130443 nrdconta,  00400956 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0107930 nrdconta,  00380571 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0012386 nrdconta,  00103859 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0067954 nrdconta,  00102548 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0095397 nrdconta,  00389844 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0052485 nrdconta,  00334414 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0164640 nrdconta,  00003183 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0004847 nrdconta,  00000100 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0042714 nrdconta,  00389897 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0040584 nrdconta,  00000502 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0081043 nrdconta,  00000825 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0034371 nrdconta,  00334465 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0215481 nrdconta,  00007382 nrctrlim, 03  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0089958 nrdconta,  00003078 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0163520 nrdconta,  00002154 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0107026 nrdconta,  00000866 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0124125 nrdconta,  00334454 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0205702 nrdconta,  00002388 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0063614 nrdconta,  00001302 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0044040 nrdconta,  00102570 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0098833 nrdconta,  00336044 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0212687 nrdconta,  00006691 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0174769 nrdconta,  00007154 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0033618 nrdconta,  00001011 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0128511 nrdconta,  00001229 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0126632 nrdconta,  00102743 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0150320 nrdconta,  00103306 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0185272 nrdconta,  00102335 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0212997 nrdconta,  00009014 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0003921 nrdconta,  00402510 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0121614 nrdconta,  00391971 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0007919 nrdconta,  00000044 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0004170 nrdconta,  00103058 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0085936 nrdconta,  00334537 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0004570 nrdconta,  00338538 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0136484 nrdconta,  00013663 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0120758 nrdconta,  00391967 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0176044 nrdconta,  00104537 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0131563 nrdconta,  00001010 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0109754 nrdconta,  00004209 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0131040 nrdconta,  00380939 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0207438 nrdconta,  00101017 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0250775 nrdconta,  00102726 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0118206 nrdconta,  00380644 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0200034 nrdconta,  00100673 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0156671 nrdconta,  00102749 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0018457 nrdconta,  00389890 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0148032 nrdconta,  00001112 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0009636 nrdconta,  00001055 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0010111 nrdconta,  00389817 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0060585 nrdconta,  00102728 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0052523 nrdconta,  00000191 nrctrlim, 05  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0134350 nrdconta,  00365990 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0128562 nrdconta,  00338544 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0156876 nrdconta,  00008271 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0104086 nrdconta,  00010631 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0199699 nrdconta,  00100658 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0092398 nrdconta,  00005662 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0232190 nrdconta,  00101968 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0123617 nrdconta,  00400977 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0062294 nrdconta,  00102740 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0087874 nrdconta,  00104304 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0003913 nrdconta,  00307692 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0219142 nrdconta,  00010475 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0028746 nrdconta,  00338543 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0139300 nrdconta,  00405624 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0103047 nrdconta,  00001669 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0002550 nrdconta,  00389884 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0072427 nrdconta,  00416335 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0107875 nrdconta,  00003530 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0025356 nrdconta,  00307649 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0179779 nrdconta,  00002404 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0231436 nrdconta,  00101832 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144185 nrdconta,  00000837 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0123692 nrdconta,  00000963 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0095290 nrdconta,  00307626 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0156655 nrdconta,  00102625 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0096784 nrdconta,  00338440 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0147451 nrdconta,  00000716 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0201472 nrdconta,  00004437 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0122530 nrdconta,  00389875 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0040541 nrdconta,  00001264 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0041017 nrdconta,  00003572 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0225142 nrdconta,  00004484 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0239100 nrdconta,  00105157 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0151866 nrdconta,  00001165 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0170933 nrdconta,  00007121 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0190020 nrdconta,  00000188 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0254118 nrdconta,  00105081 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0047120 nrdconta,  00405553 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0164879 nrdconta,  00004115 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0164895 nrdconta,  00004114 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0135143 nrdconta,  00338582 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0129674 nrdconta,  00342624 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0000825 nrdconta,  00402536 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0002160 nrdconta,  00001247 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0209198 nrdconta,  00004454 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0166243 nrdconta,  00102219 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0111635 nrdconta,  00424450 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0252131 nrdconta,  00103002 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0195359 nrdconta,  00004377 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0181765 nrdconta,  00005779 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0161691 nrdconta,  00004159 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0244600 nrdconta,  00102353 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0121991 nrdconta,  00389833 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0183202 nrdconta,  00002340 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0126896 nrdconta,  00007301 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0074098 nrdconta,  00001067 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0126381 nrdconta,  00338509 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0224910 nrdconta,  00101556 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0000736 nrdconta,  00001003 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0040894 nrdconta,  00391994 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0156191 nrdconta,  00000516 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0119873 nrdconta,  00002068 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0112453 nrdconta,  00380944 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0095273 nrdconta,  00391992 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0032840 nrdconta,  00391906 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0221910 nrdconta,  00101927 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0100854 nrdconta,  00000872 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0203351 nrdconta,  00002361 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0138770 nrdconta,  00380795 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0057282 nrdconta,  00391915 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0157074 nrdconta,  00102658 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0023752 nrdconta,  00003501 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0112402 nrdconta,  00000761 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0107409 nrdconta,  00365416 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0096938 nrdconta,  00336071 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0044652 nrdconta,  00379036 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0167703 nrdconta,  00002192 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0257915 nrdconta,  00103076 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0212792 nrdconta,  00007373 nrctrlim, 03  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0181226 nrdconta,  00002412 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0176885 nrdconta,  00004540 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0143650 nrdconta,  00000232 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0090336 nrdconta,  00103464 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0130168 nrdconta,  00043876 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0093572 nrdconta,  00001766 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0075922 nrdconta,  00336075 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0050261 nrdconta,  00000833 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0106690 nrdconta,  00000916 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0223212 nrdconta,  00101442 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0120782 nrdconta,  00389891 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0119776 nrdconta,  00380846 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0059889 nrdconta,  00005931 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0167185 nrdconta,  00000518 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0181994 nrdconta,  00102063 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0175110 nrdconta,  00102987 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0153028 nrdconta,  00000798 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0110795 nrdconta,  00010443 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0174980 nrdconta,  00004245 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0139165 nrdconta,  00401058 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0142409 nrdconta,  00100738 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0107425 nrdconta,  00389886 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0057002 nrdconta,  00402522 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0044164 nrdconta,  00102556 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0017094 nrdconta,  00259677 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0149870 nrdconta,  00001740 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0104752 nrdconta,  00000519 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0121975 nrdconta,  00103140 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0020664 nrdconta,  00005505 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0014206 nrdconta,  00044109 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0061530 nrdconta,  00044019 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0136956 nrdconta,  00013669 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0216429 nrdconta,  00004493 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0172804 nrdconta,  00102754 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0168955 nrdconta,  00005716 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0080063 nrdconta,  00103388 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0147001 nrdconta,  00424483 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0193704 nrdconta,  00004358 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0021288 nrdconta,  00102704 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0152609 nrdconta,  00000287 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0122718 nrdconta,  00389876 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0114049 nrdconta,  00342690 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0191779 nrdconta,  00100355 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0146838 nrdconta,  00000313 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0100382 nrdconta,  00391927 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0253596 nrdconta,  00105144 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0266221 nrdconta,  00104698 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0140279 nrdconta,  00102655 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0185477 nrdconta,  00008249 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0028738 nrdconta,  00102725 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0186007 nrdconta,  00009097 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0150126 nrdconta,  00001747 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0103373 nrdconta,  00365805 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0103020 nrdconta,  00336055 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0088579 nrdconta,  00104540 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0104353 nrdconta,  00365732 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0088560 nrdconta,  00336077 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0084786 nrdconta,  00402590 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0117994 nrdconta,  00000897 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0152838 nrdconta,  00000867 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0212636 nrdconta,  00005663 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0047090 nrdconta,  00402533 nrctrlim, 01  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0115444 nrdconta,  00001209 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0212180 nrdconta,  00007366 nrctrlim, 03  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0146650 nrdconta,  00001313 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0146641 nrdconta,  00001289 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0008214 nrdconta,  00336009 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0130486 nrdconta,  00001295 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0005339 nrdconta,  00400999 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0115908 nrdconta,  00000820 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0120073 nrdconta,  00389822 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0231568 nrdconta,  00101842 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0147508 nrdconta,  00102657 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0144940 nrdconta,  00001406 nrctrlim, 08  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0237752 nrdconta,  00104946 nrctrlim, 15  cddlinha_atual, 16  cddlinha_nova from dual union all
SELECT 05 cdcooper, 0026239 nrdconta,  00101788 nrctrlim, 07  cddlinha_atual, 16  cddlinha_nova from dual
        ) cnt
                       )
          loop
            --
            vr_dsmensagem := null;
            vr_nrregistro := vr_nrregistro + 1;

            --
            begin
              --
              select 1 into vr_existe_ass
              from crapass ass
              where ass.nrdconta = r_cnt.nrdconta
                and ass.cdcooper = r_cnt.cdcooper;
              --
            exception
              when others then
                vr_existe_ass := 0;
                vr_dsmensagem := 'Cooperado nao existe';
            end;
            --
            vr_existe_lim := 0;
            vr_insitlim := 0;
            vr_cddlinha_contrato := NULL;
            if vr_existe_ass = 1 then
              --
              begin
                --
                select 1, lim.insitlim, lim.cddlinha into vr_existe_lim, vr_insitlim, vr_cddlinha_contrato
                from craplim lim
                where lim.nrctrlim = r_cnt.nrctrlim
                  and lim.nrdconta = r_cnt.nrdconta
                  and lim.cdcooper = r_cnt.cdcooper
                  and lim.tpctrlim = 1;
                --
              exception
                when others then
                  vr_existe_lim := 0;
                  vr_dsmensagem := 'Contrato nao encontrado';
              end;
              --
              if vr_existe_lim = 1 AND vr_insitlim = 2 THEN  -- 2-contrato ativo
                --
                begin
                  --
                  update craplim lim
                  set lim.cddlinha = r_cnt.cddlinha_nova
                  where lim.nrctrlim = r_cnt.nrctrlim
                    and lim.nrdconta = r_cnt.nrdconta
                    and lim.cdcooper = r_cnt.cdcooper
                    and lim.tpctrlim =1;
                    
                  update crawlim lim
                  set lim.cddlinha = r_cnt.cddlinha_nova
                  where lim.nrctrlim = r_cnt.nrctrlim
                    and lim.nrdconta = r_cnt.nrdconta
                    and lim.cdcooper = r_cnt.cdcooper
                    and lim.tpctrlim =1;

                  --
                exception
                  when others then
                    vr_dsmensagem := 'Erro na atualizacao:'||sqlerrm;
                end;
                --
                if vr_dsmensagem is null then
                  --
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                ,pr_des_text => 'UPDATE craplim lim '    ||
                                                                '   SET lim.cddlinha = ' || r_cnt.cddlinha_atual ||
                                                                ' WHERE lim.cdcooper = ' || r_cnt.cdcooper       ||
                                                                '   AND lim.nrdconta = ' || r_cnt.nrdconta       ||
                                                                '   AND lim.nrctrlim = ' || r_cnt.nrctrlim       ||
                                                                '   AND lim.tpctrlim = 1 ' ||
                                                                ';');

                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                ,pr_des_text => 'UPDATE crawlim lim '    ||
                                                                '   SET lim.cddlinha = ' || r_cnt.cddlinha_atual ||
                                                                ' WHERE lim.cdcooper = ' || r_cnt.cdcooper       ||
                                                                '   AND lim.nrdconta = ' || r_cnt.nrdconta       ||
                                                                '   AND lim.nrctrlim = ' || r_cnt.nrctrlim       ||
                                                                '   AND lim.tpctrlim = 1 ' ||
                                                                ';');
                                     
                  GENE0001.pc_gera_log(pr_cdcooper => r_cnt.cdcooper
                                      ,pr_cdoperad => '1'
                                      ,pr_dscritic => ' '
                                      ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                                      ,pr_dstransa => 'Troca de linha de credito (RITM0123000)'
                                      ,pr_dttransa => TRUNC(SYSDATE)
                                      ,pr_flgtrans => 1
                                      ,pr_hrtransa => gene0002.fn_busca_time
                                      ,pr_idseqttl => 1
                                      ,pr_nmdatela => 'Script'
                                      ,pr_nrdconta => r_cnt.nrdconta
                                      ,pr_nrdrowid => vr_nrdrowid);
                  --
                  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                            pr_nmdcampo => 'Linha de credito',
                                            pr_dsdadant => r_cnt.cddlinha_atual,
                                            pr_dsdadatu => r_cnt.cddlinha_nova);
                  --
                  --vr_dsmensagem := 'Atualizado';
                  --
                end if;
                --
              ELSIF vr_existe_lim = 1 AND vr_insitlim <> 2 THEN
                vr_dsmensagem := 'Contrato não é ativo.';
              end if;
              --

            end if;

            IF vr_cddlinha_contrato   <>      r_cnt.cddlinha_atual AND vr_dsmensagem is NULL THEN
               vr_dsmensagem := ' Linha atual diferente! Atual arquivo: '||r_cnt.cddlinha_atual||' Atual contrato: '||vr_cddlinha_contrato||'. O contrato foi atualizado para nova linha.'; 
            END IF;
               
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
          --dbms_output.put_line('vr_nrregistro:'||vr_nrregistro);
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

