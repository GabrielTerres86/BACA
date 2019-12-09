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
  ----
BEGIN
  BEGIN
    
          vr_nmarq_rollback := '/micros/cecred/ramon/RITM0043743/RDM0033019_ROLLBACK.sql';
          vr_nmarq_log      := '/micros/cecred/ramon/RITM0043743/LOG_RITM0043743.txt';
            
          /* Abrir o arquivo de rollback */
          gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback
                                  ,pr_tipabert => 'W'                --> Modo de abertura (R,W,A)
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
			SELECT 5 cdcooper, 205 nrdconta, 1073 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 825 nrdconta, 402536 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 922 nrdconta, 259396 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 1830 nrdconta, 323492 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 1953 nrdconta, 334475 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 2313 nrdconta, 389888 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 3190 nrdconta, 102502 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 3700 nrdconta, 259374 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 3921 nrdconta, 402510 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 4006 nrdconta, 405552 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 7145 nrdconta, 102775 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 7676 nrdconta, 258993 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 7978 nrdconta, 1064 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 8745 nrdconta, 102581 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 9423 nrdconta, 307677 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 9636 nrdconta, 338656 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 9857 nrdconta, 307632 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 10111 nrdconta, 389817 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 10910 nrdconta, 323433 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 12491 nrdconta, 389880 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 13323 nrdconta, 102559 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 15342 nrdconta, 102505 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 18228 nrdconta, 259400 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 18910 nrdconta, 391990 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 19500 nrdconta, 338412 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 19860 nrdconta, 3566 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 21652 nrdconta, 102528 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 21750 nrdconta, 259378 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 21997 nrdconta, 100368 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 22144 nrdconta, 258975 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 22926 nrdconta, 307628 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 23043 nrdconta, 102828 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 23302 nrdconta, 44118 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 23310 nrdconta, 102842 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 23752 nrdconta, 3501 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 25054 nrdconta, 323420 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 26387 nrdconta, 102759 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 26840 nrdconta, 258976 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 27391 nrdconta, 102810 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 27421 nrdconta, 402531 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 29165 nrdconta, 389849 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 29769 nrdconta, 3547 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 29939 nrdconta, 323494 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 29971 nrdconta, 334405 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 29980 nrdconta, 334462 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 30252 nrdconta, 44112 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 30775 nrdconta, 102789 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 31801 nrdconta, 336020 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 32166 nrdconta, 391936 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 32522 nrdconta, 323435 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 33065 nrdconta, 334402 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 33588 nrdconta, 102529 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 35386 nrdconta, 102841 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 35874 nrdconta, 307647 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 36285 nrdconta, 402563 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 36749 nrdconta, 102501 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 37141 nrdconta, 102507 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 40134 nrdconta, 102503 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 40266 nrdconta, 259393 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 40681 nrdconta, 102599 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 40894 nrdconta, 391994 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 41009 nrdconta, 1219 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 41017 nrdconta, 3572 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 42676 nrdconta, 259344 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 43885 nrdconta, 334403 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 44148 nrdconta, 389869 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 44164 nrdconta, 102556 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 44644 nrdconta, 338532 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 45489 nrdconta, 402528 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 45730 nrdconta, 102576 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 46957 nrdconta, 103136 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 47007 nrdconta, 402508 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 47120 nrdconta, 405553 nrctrlim, 3 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 48062 nrdconta, 323437 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 48402 nrdconta, 44132 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 50458 nrdconta, 338502 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 53856 nrdconta, 3567 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 54224 nrdconta, 307639 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 54615 nrdconta, 1212 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 54631 nrdconta, 102795 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 54976 nrdconta, 323445 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 57002 nrdconta, 402522 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 59439 nrdconta, 365866 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 59501 nrdconta, 3562 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 60127 nrdconta, 307652 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 60780 nrdconta, 307660 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 60933 nrdconta, 323447 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 62499 nrdconta, 307606 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 65811 nrdconta, 3502 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 68950 nrdconta, 3579 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 69620 nrdconta, 5923 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 70190 nrdconta, 5927 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 70386 nrdconta, 402560 nrctrlim, 3 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 71250 nrdconta, 405577 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 72338 nrdconta, 307678 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 73768 nrdconta, 336028 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 74098 nrdconta, 1067 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 74209 nrdconta, 338553 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 75140 nrdconta, 102783 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 78379 nrdconta, 3512 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 78387 nrdconta, 389847 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 79057 nrdconta, 391973 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 79332 nrdconta, 402571 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 79502 nrdconta, 338589 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 84646 nrdconta, 3508 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 84697 nrdconta, 389843 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 84786 nrdconta, 402590 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 86819 nrdconta, 334450 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 87572 nrdconta, 389894 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 87670 nrdconta, 334461 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 92762 nrdconta, 5903 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 93092 nrdconta, 389824 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 95133 nrdconta, 391995 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 95273 nrdconta, 391992 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 100382 nrdconta, 391927 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 104744 nrdconta, 336031 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 104752 nrdconta, 519 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 110728 nrdconta, 1218 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 112143 nrdconta, 1262 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 112283 nrdconta, 389808 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 114472 nrdconta, 402507 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 114766 nrdconta, 307698 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 115339 nrdconta, 3588 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 115401 nrdconta, 389810 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 115444 nrdconta, 1209 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 116670 nrdconta, 402579 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 119415 nrdconta, 391960 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 120073 nrdconta, 389822 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 121142 nrdconta, 389827 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 121657 nrdconta, 389829 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 121860 nrdconta, 5968 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 122440 nrdconta, 389862 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 123781 nrdconta, 400950 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 123811 nrdconta, 334451 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 125245 nrdconta, 338503 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 126659 nrdconta, 338534 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 127973 nrdconta, 338539 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 128210 nrdconta, 1258 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 128511 nrdconta, 1229 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 128562 nrdconta, 338544 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 128759 nrdconta, 3533 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 129020 nrdconta, 1249 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 130400 nrdconta, 338556 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 130486 nrdconta, 1295 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 5541 nrdconta, 44199 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 5649 nrdconta, 323410 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 5843 nrdconta, 323388 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 7226 nrdconta, 365918 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 12807 nrdconta, 43739 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 21156 nrdconta, 102647 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 22802 nrdconta, 259621 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 24430 nrdconta, 43743 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 26476 nrdconta, 338361 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 29998 nrdconta, 44017 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 30392 nrdconta, 13653 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 30430 nrdconta, 352174 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 33782 nrdconta, 648 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 36145 nrdconta, 352017 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 36838 nrdconta, 323413 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 36935 nrdconta, 259597 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 37052 nrdconta, 372701 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 39152 nrdconta, 43712 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 39160 nrdconta, 323329 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 41556 nrdconta, 366084 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 41661 nrdconta, 379010 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 43044 nrdconta, 352030 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 43273 nrdconta, 634 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 43761 nrdconta, 365917 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 43800 nrdconta, 352033 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 43826 nrdconta, 774 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 44440 nrdconta, 2665 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 44652 nrdconta, 379036 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 45829 nrdconta, 307503 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 47597 nrdconta, 336001 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 48615 nrdconta, 43894 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 50806 nrdconta, 334470 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 52825 nrdconta, 338668 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 53430 nrdconta, 352035 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 55484 nrdconta, 334471 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 55840 nrdconta, 102894 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 56260 nrdconta, 100076 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 56596 nrdconta, 323374 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 57509 nrdconta, 338371 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 57568 nrdconta, 352020 nrctrlim, 11 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 58173 nrdconta, 323376 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 58696 nrdconta, 44126 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 59803 nrdconta, 366033 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 59811 nrdconta, 2638 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 61204 nrdconta, 102875 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 61239 nrdconta, 601 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 63614 nrdconta, 1302 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 68721 nrdconta, 352028 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 68853 nrdconta, 366085 nrctrlim, 11 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 71331 nrdconta, 2658 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 73598 nrdconta, 323238 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 73695 nrdconta, 2672 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 73865 nrdconta, 43880 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 74233 nrdconta, 366081 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 77887 nrdconta, 416320 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 77925 nrdconta, 2680 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 80152 nrdconta, 259102 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 80276 nrdconta, 259115 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 81876 nrdconta, 352151 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 82040 nrdconta, 13658 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 82600 nrdconta, 638 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 82805 nrdconta, 352044 nrctrlim, 2 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 83720 nrdconta, 366047 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 83984 nrdconta, 2654 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 84280 nrdconta, 617 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 84352 nrdconta, 737 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 92584 nrdconta, 352128 nrctrlim, 2 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 93912 nrdconta, 2625 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 97349 nrdconta, 669 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 101109 nrdconta, 1307 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 101869 nrdconta, 372751 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 105945 nrdconta, 696 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 108111 nrdconta, 366013 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 114383 nrdconta, 640 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 114782 nrdconta, 259117 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 118842 nrdconta, 365984 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 125547 nrdconta, 365931 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 125636 nrdconta, 651 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 126519 nrdconta, 649 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 127418 nrdconta, 100237 nrctrlim, 10 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 128007 nrdconta, 342616 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 128627 nrdconta, 43833 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 131105 nrdconta, 365958 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 131318 nrdconta, 342637 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 131326 nrdconta, 738 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 2011 nrdconta, 323459 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 5339 nrdconta, 400999 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 6912 nrdconta, 102824 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 7587 nrdconta, 365451 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 21563 nrdconta, 2480 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 39039 nrdconta, 365817 nrctrlim, 3 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 50261 nrdconta, 833 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 56936 nrdconta, 323217 nrctrlim, 2 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 65781 nrdconta, 334550 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 70882 nrdconta, 380616 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 71013 nrdconta, 334544 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 71609 nrdconta, 1428 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 73377 nrdconta, 896 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 76180 nrdconta, 942 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 76201 nrdconta, 336088 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 79960 nrdconta, 380598 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 79979 nrdconta, 380772 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 80195 nrdconta, 2408 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 80330 nrdconta, 2478 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 80853 nrdconta, 892 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 80870 nrdconta, 380673 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 80934 nrdconta, 336076 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 80969 nrdconta, 338446 nrctrlim, 2 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 81035 nrdconta, 1682 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 81477 nrdconta, 854 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 83380 nrdconta, 974 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 85650 nrdconta, 1709 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 85928 nrdconta, 909 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 86401 nrdconta, 338452 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 87076 nrdconta, 1637 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 87165 nrdconta, 365856 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 88358 nrdconta, 365858 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 88480 nrdconta, 1706 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 88560 nrdconta, 336077 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 93513 nrdconta, 1722 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 93572 nrdconta, 1766 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 96938 nrdconta, 336071 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 98833 nrdconta, 336044 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 99066 nrdconta, 338488 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 99201 nrdconta, 338495 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 100528 nrdconta, 2448 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 100617 nrdconta, 336095 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 100749 nrdconta, 922 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 100811 nrdconta, 2409 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 100854 nrdconta, 872 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 102814 nrdconta, 1493 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 102857 nrdconta, 2449 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 103020 nrdconta, 336055 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 103373 nrdconta, 365805 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 107409 nrdconta, 365416 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 111503 nrdconta, 2411 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 113530 nrdconta, 879 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 113590 nrdconta, 1491 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 113620 nrdconta, 2453 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 114634 nrdconta, 954 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 116785 nrdconta, 2466 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 117200 nrdconta, 380627 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 118206 nrdconta, 380644 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 121410 nrdconta, 996 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 123617 nrdconta, 400977 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 126250 nrdconta, 10419 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 130222 nrdconta, 380671 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 130443 nrdconta, 400956 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 131334 nrdconta, 814 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 3778 nrdconta, 1900 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 4898 nrdconta, 338323 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 5150 nrdconta, 102738 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 7188 nrdconta, 379105 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 8060 nrdconta, 259079 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 9881 nrdconta, 307669 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 12610 nrdconta, 102720 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 13137 nrdconta, 338302 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 15032 nrdconta, 380942 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 16225 nrdconta, 379147 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 16322 nrdconta, 259033 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 23914 nrdconta, 102731 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 28738 nrdconta, 102725 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 36617 nrdconta, 338305 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 51144 nrdconta, 365777 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 71498 nrdconta, 1855 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 78298 nrdconta, 1887 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 86657 nrdconta, 379171 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 91162 nrdconta, 363110 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 91219 nrdconta, 380918 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 91278 nrdconta, 365746 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 94650 nrdconta, 401028 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 95923 nrdconta, 67 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 100250 nrdconta, 379107 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 103942 nrdconta, 1907 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 104205 nrdconta, 1873 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 105031 nrdconta, 411791 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 110841 nrdconta, 380840 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 113085 nrdconta, 1824 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 121541 nrdconta, 380857 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 122815 nrdconta, 401009 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 124966 nrdconta, 401038 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 130192 nrdconta, 401057 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 131040 nrdconta, 380939 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 146498 nrdconta, 1893 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 3301 nrdconta, 323309 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 6564 nrdconta, 102837 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 23655 nrdconta, 259121 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 25020 nrdconta, 100138 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 28703 nrdconta, 43706 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 36870 nrdconta, 44001 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 38210 nrdconta, 319 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 70920 nrdconta, 323270 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 75310 nrdconta, 13627 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 98132 nrdconta, 352034 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 100323 nrdconta, 402514 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 114618 nrdconta, 360 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 125466 nrdconta, 289 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 36552 nrdconta, 323453 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 99554 nrdconta, 424454 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 111724 nrdconta, 380957 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 112453 nrdconta, 380944 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 361 nrdconta, 352072 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 2240 nrdconta, 323471 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 21687 nrdconta, 7101 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 23426 nrdconta, 2151 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 25453 nrdconta, 323464 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 53120 nrdconta, 2161 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 56170 nrdconta, 44026 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 75493 nrdconta, 13654 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 77291 nrdconta, 400960 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 79693 nrdconta, 7205 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 83348 nrdconta, 2285 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 93700 nrdconta, 365468 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 97543 nrdconta, 352076 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 106771 nrdconta, 336052 nrctrlim, 2 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 110671 nrdconta, 100364 nrctrlim, 2 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 110949 nrdconta, 259699 nrctrlim, 10 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 111309 nrdconta, 259697 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 114545 nrdconta, 380612 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 122971 nrdconta, 2136 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 126896 nrdconta, 7301 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 3263 nrdconta, 43803 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 33960 nrdconta, 323323 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 45152 nrdconta, 44037 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 62928 nrdconta, 102546 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 109754 nrdconta, 4209 nrctrlim, 8 cddlinha_atual, 7 cddlinha_nova from dual union all 
			SELECT 5 cdcooper, 125717 nrdconta, 402583 nrctrlim, 1 cddlinha_atual, 7 cddlinha_nova from dual 
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
            if vr_existe_ass = 1 then
              --
              begin
                --
                select 1 into vr_existe_lim
                from craplim lim
                where lim.nrctrlim = r_cnt.nrctrlim
                  and lim.nrdconta = r_cnt.nrdconta
                  and lim.cdcooper = r_cnt.cdcooper;
                --
              exception
                when others then
                  vr_existe_lim := 0;
                  vr_dsmensagem := 'Contrato nao existe';
              end;
              --
              if vr_existe_lim = 1 then
                --
                begin
                  --
                  update craplim lim
                  set lim.cddlinha = r_cnt.cddlinha_nova
                  where lim.nrctrlim = r_cnt.nrctrlim
                    and lim.nrdconta = r_cnt.nrdconta
                    and lim.cdcooper = r_cnt.cdcooper;
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
                                                                ';');
                                     
                  GENE0001.pc_gera_log(pr_cdcooper => r_cnt.cdcooper
                                      ,pr_cdoperad => '1'
                                      ,pr_dscritic => ' '
                                      ,pr_dsorigem => gene0001.vr_vet_des_origens(5)
                                      ,pr_dstransa => 'Troca de linha de credito (RITM0027927)'
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
                  vr_dsmensagem := 'Atualizado';
                  --
                end if;
                --
              end if;
              --
            end if;
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                          ,pr_des_text => vr_nrregistro || ';' || r_cnt.cdcooper || ';' || r_cnt.nrdconta ||
                                                          ';' || r_cnt.nrctrlim || ';' || vr_dsmensagem);
            
/*            dbms_output.put_line(vr_nrregistro
                          ||';'||r_cnt.cdcooper
                          ||';'||r_cnt.nrdconta
                          ||';'||r_cnt.nrctrlim
                          ||';'||vr_dsmensagem); */
            --
          end loop;
          --
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                        ,pr_des_text => 'vr_nrregistro: ' || vr_nrregistro);
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
/