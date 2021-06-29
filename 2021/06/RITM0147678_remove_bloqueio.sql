DECLARE

  vr_nrregistro     NUMBER := 0;
  vr_existe_ass     NUMBER;
  vr_nrdrowid       ROWID;
  vr_dsmensagem     VARCHAR2(500);
  vr_nmarq_rollback VARCHAR2(100);
  vr_nmarq_log      VARCHAR2(100);
  vr_des_erro       VARCHAR2(1000);
  vr_dscritic       VARCHAR2(1000);
  vr_handle         utl_file.file_type;
  vr_handle_log     utl_file.file_type;
  vr_exc_erro EXCEPTION;
  vr_dsdireto VARCHAR2(300);
  
  vr_datavigencia  VARCHAR2(100);



  CURSOR cr_param (pr_cdcooper  IN crapcop.cdcooper%TYPE,
                    pr_cpfcnpj   IN tbcc_hist_param_pessoa_prod.nrcpfcnpj_base%TYPE,
                    pr_tppessoa  IN tbcc_hist_param_pessoa_prod.tppessoa%TYPE) IS
  SELECT * FROM 
    tbcc_param_pessoa_produto a
   WHERE a.cdcooper = pr_cdcooper
   AND a.tppessoa = pr_tppessoa
   AND a.nrcpfcnpj_base = pr_cpfcnpj
   AND a.cdproduto = 25
;

   rw_param cr_param%ROWTYPE;      


  CURSOR his_param (pr_cdcooper  IN crapcop.cdcooper%TYPE,
                    pr_cpfcnpj   IN tbcc_hist_param_pessoa_prod.nrcpfcnpj_base%TYPE,
                    pr_tppessoa  IN tbcc_hist_param_pessoa_prod.tppessoa%TYPE) IS
  SELECT * FROM 
    tbcc_hist_param_pessoa_prod a
   WHERE a.cdcooper = pr_cdcooper
   AND a.tppessoa = pr_tppessoa
   AND a.nrcpfcnpj_base = pr_cpfcnpj
   AND a.cdproduto = 25
   AND a.dtoperac = (SELECT MAX(b.dtoperac) FROM tbcc_hist_param_pessoa_prod b
       WHERE a.cdcooper = b.cdcooper
       AND a.tppessoa = b.tppessoa
       AND a.nrcpfcnpj_base = b.nrcpfcnpj_base
       AND a.cdproduto = 25   );

   rw_his_param his_param%ROWTYPE;      

BEGIN
  BEGIN

  -- caminho para produção:
     vr_dsdireto       := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/daniel/';
     vr_nmarq_rollback := vr_dsdireto||'RITM0147678_ROLLBACK.sql';
     vr_nmarq_log      := vr_dsdireto||'RITM0147678_LOG.txt';
  
    -- Abrir o arquivo de rollback
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback,
                             pr_tipabert => 'W',
                             pr_utlfileh => vr_handle,
                             pr_des_erro => vr_des_erro);
    IF vr_des_erro IS NOT NULL THEN
      vr_dsmensagem := 'Erro ao abrir arquivo de rollback: ' || vr_des_erro;
      RAISE vr_exc_erro;
    END IF;
  
    -- Abrir o arquivo de LOG
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_log,
                             pr_tipabert => 'W',
                             pr_utlfileh => vr_handle_log,
                             pr_des_erro => vr_des_erro);
    IF vr_des_erro IS NOT NULL THEN
      vr_dsmensagem := 'Erro ao abrir arquivo de LOG: ' || vr_des_erro;
      RAISE vr_exc_erro;
    END IF;
  
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                   pr_des_text => 'Linha;Coop;Conta;CPF/CNPJ;Mensagem');
  
    FOR r_cnt IN (SELECT 2 cdcooper
                        ,cnt.nrdconta
                        ,cnt.inpessoa
                        ,cnt.nrcpfcnpj_base
                    FROM (SELECT 716804     nrdconta
                                ,1          inpessoa
                                ,2363516990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 647870      nrdconta
                                ,1           inpessoa
                                ,11676847960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 395900      nrdconta
                                ,1           inpessoa
                                ,69770832987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 616435      nrdconta
                                ,1           inpessoa
                                ,12003979913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 456853     nrdconta
                                ,1          inpessoa
                                ,4761673966 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 569232   nrdconta
                                ,2        inpessoa
                                ,84717925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 169471    nrdconta
                                ,1         inpessoa
                                ,348370946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 156850     nrdconta
                                ,1          inpessoa
                                ,2500977960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 796760     nrdconta
                                ,1          inpessoa
                                ,8966512909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 659339      nrdconta
                                ,1           inpessoa
                                ,46878971934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 707155     nrdconta
                                ,1          inpessoa
                                ,8292688986 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 664049   nrdconta
                                ,2        inpessoa
                                ,30433634 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 718165      nrdconta
                                ,1           inpessoa
                                ,10686473965 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 711497      nrdconta
                                ,1           inpessoa
                                ,10339113995 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 342483      nrdconta
                                ,1           inpessoa
                                ,11121694900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 675156      nrdconta
                                ,1           inpessoa
                                ,11151808946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 548022     nrdconta
                                ,1          inpessoa
                                ,5528069947 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735183     nrdconta
                                ,1          inpessoa
                                ,9235495954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 852821     nrdconta
                                ,1          inpessoa
                                ,9933281992 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 317020      nrdconta
                                ,1           inpessoa
                                ,67432751900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 591173   nrdconta
                                ,2        inpessoa
                                ,28353037 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 615790      nrdconta
                                ,1           inpessoa
                                ,32679892801 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 640786      nrdconta
                                ,1           inpessoa
                                ,13775744908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 653039      nrdconta
                                ,1           inpessoa
                                ,10806813962 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 518794     nrdconta
                                ,1          inpessoa
                                ,5681431916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 979040      nrdconta
                                ,1           inpessoa
                                ,50818651920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 505200    nrdconta
                                ,1         inpessoa
                                ,954529901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 399272     nrdconta
                                ,1          inpessoa
                                ,8787028905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 667188   nrdconta
                                ,2        inpessoa
                                ,19959214 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 756946    nrdconta
                                ,1         inpessoa
                                ,709714980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 623210     nrdconta
                                ,1          inpessoa
                                ,4072670936 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 589551     nrdconta
                                ,1          inpessoa
                                ,6477869900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 608505     nrdconta
                                ,1          inpessoa
                                ,5458837924 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 708887   nrdconta
                                ,2        inpessoa
                                ,23190221 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 605603   nrdconta
                                ,2        inpessoa
                                ,25299861 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 531472     nrdconta
                                ,1          inpessoa
                                ,3082976956 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 477699    nrdconta
                                ,1         inpessoa
                                ,478363931 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 608130   nrdconta
                                ,2        inpessoa
                                ,20033552 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 310131     nrdconta
                                ,1          inpessoa
                                ,3838851919 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 567868      nrdconta
                                ,1           inpessoa
                                ,79205682934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 580279     nrdconta
                                ,1          inpessoa
                                ,7750001913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 627488   nrdconta
                                ,2        inpessoa
                                ,24126660 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 440280      nrdconta
                                ,1           inpessoa
                                ,89064178968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 726265     nrdconta
                                ,1          inpessoa
                                ,7114661908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 731340   nrdconta
                                ,2        inpessoa
                                ,82096884 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755788     nrdconta
                                ,1          inpessoa
                                ,6459306958 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 644676   nrdconta
                                ,2        inpessoa
                                ,22774795 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 659231      nrdconta
                                ,1           inpessoa
                                ,12468728971 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 822302   nrdconta
                                ,2        inpessoa
                                ,29256503 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 761478      nrdconta
                                ,1           inpessoa
                                ,38888173153 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 624780     nrdconta
                                ,1          inpessoa
                                ,5564637909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 699136      nrdconta
                                ,1           inpessoa
                                ,68404514968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 689378     nrdconta
                                ,1          inpessoa
                                ,7169063921 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 700789      nrdconta
                                ,1           inpessoa
                                ,26221719860 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 675431     nrdconta
                                ,1          inpessoa
                                ,7926166936 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755311   nrdconta
                                ,2        inpessoa
                                ,18275798 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 478911     nrdconta
                                ,1          inpessoa
                                ,5121009933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 216968      nrdconta
                                ,1           inpessoa
                                ,72054239968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 217549   nrdconta
                                ,2        inpessoa
                                ,24192129 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 635030   nrdconta
                                ,2        inpessoa
                                ,26324753 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 429341     nrdconta
                                ,1          inpessoa
                                ,2641055910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 844039   nrdconta
                                ,2        inpessoa
                                ,10950175 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 860182     nrdconta
                                ,1          inpessoa
                                ,3758149908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 582840      nrdconta
                                ,1           inpessoa
                                ,86403320963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 872490     nrdconta
                                ,1          inpessoa
                                ,9601083944 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764418   nrdconta
                                ,2        inpessoa
                                ,13155183 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 739715   nrdconta
                                ,2        inpessoa
                                ,33847622 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 625876     nrdconta
                                ,1          inpessoa
                                ,7907393990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 486850      nrdconta
                                ,1           inpessoa
                                ,10171014936 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 268402      nrdconta
                                ,1           inpessoa
                                ,93639040910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 818186     nrdconta
                                ,1          inpessoa
                                ,3907329902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 920584      nrdconta
                                ,1           inpessoa
                                ,86666010949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 472212    nrdconta
                                ,1         inpessoa
                                ,960211950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 625728     nrdconta
                                ,1          inpessoa
                                ,5139492911 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 468134      nrdconta
                                ,1           inpessoa
                                ,38314150991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 549517   nrdconta
                                ,2        inpessoa
                                ,21496025 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 509612   nrdconta
                                ,2        inpessoa
                                ,23289412 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 632872      nrdconta
                                ,1           inpessoa
                                ,64647773949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 746193      nrdconta
                                ,1           inpessoa
                                ,10460440950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 522058   nrdconta
                                ,2        inpessoa
                                ,22866539 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 605646   nrdconta
                                ,2        inpessoa
                                ,28012580 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735140      nrdconta
                                ,1           inpessoa
                                ,58623663934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 759236     nrdconta
                                ,1          inpessoa
                                ,9181913940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 504483      nrdconta
                                ,1           inpessoa
                                ,97071315949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 749923     nrdconta
                                ,1          inpessoa
                                ,1696795940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 787230     nrdconta
                                ,1          inpessoa
                                ,2082394999 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 239259   nrdconta
                                ,2        inpessoa
                                ,24451776 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 733768     nrdconta
                                ,1          inpessoa
                                ,1686199970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 432024      nrdconta
                                ,1           inpessoa
                                ,68384742987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 705152     nrdconta
                                ,1          inpessoa
                                ,4853745955 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765767     nrdconta
                                ,1          inpessoa
                                ,6817404932 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 757420     nrdconta
                                ,1          inpessoa
                                ,2768400033 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 694843   nrdconta
                                ,2        inpessoa
                                ,23706688 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 663506   nrdconta
                                ,2        inpessoa
                                ,31910361 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 715670   nrdconta
                                ,2        inpessoa
                                ,30895987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 750034     nrdconta
                                ,1          inpessoa
                                ,6537490901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 611131      nrdconta
                                ,1           inpessoa
                                ,10267521910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 657964     nrdconta
                                ,1          inpessoa
                                ,9460248985 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 736651     nrdconta
                                ,1          inpessoa
                                ,4780993202 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 753122      nrdconta
                                ,1           inpessoa
                                ,77571851220 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 207446      nrdconta
                                ,1           inpessoa
                                ,65809041949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 837105     nrdconta
                                ,1          inpessoa
                                ,6115172993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 467871      nrdconta
                                ,1           inpessoa
                                ,26905035068 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 554367      nrdconta
                                ,1           inpessoa
                                ,58492550953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 792870     nrdconta
                                ,1          inpessoa
                                ,1720600953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 551953   nrdconta
                                ,2        inpessoa
                                ,16628181 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 318000   nrdconta
                                ,2        inpessoa
                                ,14209010 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 355917      nrdconta
                                ,1           inpessoa
                                ,58498141915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 615765     nrdconta
                                ,1          inpessoa
                                ,7286636944 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 442020     nrdconta
                                ,1          inpessoa
                                ,9036109906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755753      nrdconta
                                ,1           inpessoa
                                ,29725993810 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 780120     nrdconta
                                ,1          inpessoa
                                ,3969836859 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764612     nrdconta
                                ,1          inpessoa
                                ,8778269946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 154407      nrdconta
                                ,1           inpessoa
                                ,95635459900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 733725     nrdconta
                                ,1          inpessoa
                                ,9569941995 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754773      nrdconta
                                ,1           inpessoa
                                ,56452586904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 633593   nrdconta
                                ,2        inpessoa
                                ,30069779 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742503   nrdconta
                                ,2        inpessoa
                                ,33852593 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 812897     nrdconta
                                ,1          inpessoa
                                ,7961806954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 519006     nrdconta
                                ,1          inpessoa
                                ,9157191930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 618330     nrdconta
                                ,1          inpessoa
                                ,8230391963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 441538     nrdconta
                                ,1          inpessoa
                                ,8400964969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 588830      nrdconta
                                ,1           inpessoa
                                ,61360708987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 703648   nrdconta
                                ,2        inpessoa
                                ,20405565 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 758205     nrdconta
                                ,1          inpessoa
                                ,8148737908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 891282     nrdconta
                                ,1          inpessoa
                                ,2101680998 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 445983   nrdconta
                                ,2        inpessoa
                                ,16697352 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 238635     nrdconta
                                ,1          inpessoa
                                ,9736129918 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 468657      nrdconta
                                ,1           inpessoa
                                ,60965754987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 565377   nrdconta
                                ,2        inpessoa
                                ,75893057 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 522376      nrdconta
                                ,1           inpessoa
                                ,67415083920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 477320   nrdconta
                                ,2        inpessoa
                                ,17732640 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 759511     nrdconta
                                ,1          inpessoa
                                ,3677144930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 637327   nrdconta
                                ,2        inpessoa
                                ,27759962 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735914     nrdconta
                                ,1          inpessoa
                                ,6592373938 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 906280     nrdconta
                                ,1          inpessoa
                                ,2024882927 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764710   nrdconta
                                ,2        inpessoa
                                ,27034235 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 529370   nrdconta
                                ,2        inpessoa
                                ,20651269 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 488259      nrdconta
                                ,1           inpessoa
                                ,63115697953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 709360   nrdconta
                                ,2        inpessoa
                                ,33070007 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 206474      nrdconta
                                ,1           inpessoa
                                ,59821159087 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 738573      nrdconta
                                ,1           inpessoa
                                ,10806000945 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 594741     nrdconta
                                ,1          inpessoa
                                ,9890634961 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 716405   nrdconta
                                ,2        inpessoa
                                ,18312583 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 683353      nrdconta
                                ,1           inpessoa
                                ,94842620900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 606120  nrdconta
                                ,2       inpessoa
                                ,7074464 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 686492   nrdconta
                                ,2        inpessoa
                                ,13112241 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 580805  nrdconta
                                ,2       inpessoa
                                ,5853893 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 611395     nrdconta
                                ,1          inpessoa
                                ,1987106903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 663883     nrdconta
                                ,1          inpessoa
                                ,4620700932 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 314900  nrdconta
                                ,2       inpessoa
                                ,3258473 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 724505   nrdconta
                                ,2        inpessoa
                                ,33436076 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 542636      nrdconta
                                ,1           inpessoa
                                ,76980219987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 683965     nrdconta
                                ,1          inpessoa
                                ,4025444984 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 715158      nrdconta
                                ,1           inpessoa
                                ,62380281904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 609285     nrdconta
                                ,1          inpessoa
                                ,7061800976 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 547980     nrdconta
                                ,1          inpessoa
                                ,3477441923 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 739758      nrdconta
                                ,1           inpessoa
                                ,80463592972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 228583     nrdconta
                                ,1          inpessoa
                                ,6687201905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 427527     nrdconta
                                ,1          inpessoa
                                ,6855706908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 201170      nrdconta
                                ,1           inpessoa
                                ,68466641904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 531677     nrdconta
                                ,1          inpessoa
                                ,2946140954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 835536     nrdconta
                                ,1          inpessoa
                                ,6711754913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 630810  nrdconta
                                ,2       inpessoa
                                ,1593148 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 710229     nrdconta
                                ,1          inpessoa
                                ,6026614982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 872148     nrdconta
                                ,1          inpessoa
                                ,4793120954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 407046      nrdconta
                                ,1           inpessoa
                                ,14764008904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 674443   nrdconta
                                ,2        inpessoa
                                ,32420787 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 705608   nrdconta
                                ,2        inpessoa
                                ,21223149 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 513636     nrdconta
                                ,1          inpessoa
                                ,5607363988 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 761672     nrdconta
                                ,1          inpessoa
                                ,9122957910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 381373     nrdconta
                                ,1          inpessoa
                                ,2989691901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 824437      nrdconta
                                ,1           inpessoa
                                ,39965503915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 696072     nrdconta
                                ,1          inpessoa
                                ,5150149900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 829030   nrdconta
                                ,2        inpessoa
                                ,32701116 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754323      nrdconta
                                ,1           inpessoa
                                ,82179913915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 380202     nrdconta
                                ,1          inpessoa
                                ,4626288928 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 633690      nrdconta
                                ,1           inpessoa
                                ,75088096968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 547000   nrdconta
                                ,2        inpessoa
                                ,11771156 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 950912   nrdconta
                                ,2        inpessoa
                                ,33465375 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 664880     nrdconta
                                ,1          inpessoa
                                ,7575531920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 192929      nrdconta
                                ,1           inpessoa
                                ,45250952968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 670081   nrdconta
                                ,2        inpessoa
                                ,27414426 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 719587     nrdconta
                                ,1          inpessoa
                                ,8663540930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 625914      nrdconta
                                ,1           inpessoa
                                ,89103122972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 769452     nrdconta
                                ,1          inpessoa
                                ,7106841935 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 702641     nrdconta
                                ,1          inpessoa
                                ,4914979977 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 753335     nrdconta
                                ,1          inpessoa
                                ,1740948254 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732273   nrdconta
                                ,2        inpessoa
                                ,33848570 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764400     nrdconta
                                ,1          inpessoa
                                ,6921900908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 790940   nrdconta
                                ,2        inpessoa
                                ,12486110 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 460745      nrdconta
                                ,1           inpessoa
                                ,19379471904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754919      nrdconta
                                ,1           inpessoa
                                ,12201190917 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 509817     nrdconta
                                ,1          inpessoa
                                ,5491856908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 647969     nrdconta
                                ,1          inpessoa
                                ,5289193936 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 710415      nrdconta
                                ,1           inpessoa
                                ,49989758972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 587311      nrdconta
                                ,1           inpessoa
                                ,63116359920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 449652     nrdconta
                                ,1          inpessoa
                                ,7186333931 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 445100   nrdconta
                                ,2        inpessoa
                                ,15988810 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 314560      nrdconta
                                ,1           inpessoa
                                ,62742922920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 576735    nrdconta
                                ,1         inpessoa
                                ,337725926 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742830   nrdconta
                                ,2        inpessoa
                                ,20773736 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 443930     nrdconta
                                ,1          inpessoa
                                ,4589161966 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 623601      nrdconta
                                ,1           inpessoa
                                ,38101530959 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 403474  nrdconta
                                ,2       inpessoa
                                ,7327162 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 802859   nrdconta
                                ,2        inpessoa
                                ,27747399 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 489891     nrdconta
                                ,1          inpessoa
                                ,8250955900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 746401     nrdconta
                                ,1          inpessoa
                                ,9608434939 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 550647    nrdconta
                                ,1         inpessoa
                                ,636146006 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 600261     nrdconta
                                ,1          inpessoa
                                ,9563465962 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 637580     nrdconta
                                ,1          inpessoa
                                ,5461764967 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 659320   nrdconta
                                ,2        inpessoa
                                ,29640743 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 509493   nrdconta
                                ,2        inpessoa
                                ,27299038 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 834556      nrdconta
                                ,1           inpessoa
                                ,86643274915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 628514      nrdconta
                                ,1           inpessoa
                                ,76821889953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 456152     nrdconta
                                ,1          inpessoa
                                ,8142605945 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 675148      nrdconta
                                ,1           inpessoa
                                ,75113368920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 228389      nrdconta
                                ,1           inpessoa
                                ,71595007920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 568805   nrdconta
                                ,2        inpessoa
                                ,78984747 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 201480      nrdconta
                                ,1           inpessoa
                                ,44575050997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742635     nrdconta
                                ,1          inpessoa
                                ,9239119957 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 633461   nrdconta
                                ,2        inpessoa
                                ,18121850 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 721980     nrdconta
                                ,1          inpessoa
                                ,3872448919 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 528897   nrdconta
                                ,2        inpessoa
                                ,26122646 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 586234     nrdconta
                                ,1          inpessoa
                                ,8129587998 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 190233      nrdconta
                                ,1           inpessoa
                                ,25824104972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 726435     nrdconta
                                ,1          inpessoa
                                ,4785463945 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 220728      nrdconta
                                ,1           inpessoa
                                ,35110562920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 666025   nrdconta
                                ,2        inpessoa
                                ,10140818 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 788066     nrdconta
                                ,1          inpessoa
                                ,3733827902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 492710   nrdconta
                                ,2        inpessoa
                                ,26348170 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 557471     nrdconta
                                ,1          inpessoa
                                ,3170587978 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 382078     nrdconta
                                ,1          inpessoa
                                ,5202099908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 467120      nrdconta
                                ,1           inpessoa
                                ,48310786972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 821160     nrdconta
                                ,1          inpessoa
                                ,7926747904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 746495      nrdconta
                                ,1           inpessoa
                                ,10202727408 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 446300     nrdconta
                                ,1          inpessoa
                                ,4437099982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 315451      nrdconta
                                ,1           inpessoa
                                ,98902792900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 460486      nrdconta
                                ,1           inpessoa
                                ,50818686987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 829510   nrdconta
                                ,2        inpessoa
                                ,35398362 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 406821     nrdconta
                                ,1          inpessoa
                                ,8702301903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 407216      nrdconta
                                ,1           inpessoa
                                ,79793312904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 587397     nrdconta
                                ,1          inpessoa
                                ,1864036907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 169617     nrdconta
                                ,1          inpessoa
                                ,3578636908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 781835      nrdconta
                                ,1           inpessoa
                                ,10285366904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 339172     nrdconta
                                ,1          inpessoa
                                ,7928046946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 216780     nrdconta
                                ,1          inpessoa
                                ,9056729926 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 302228      nrdconta
                                ,1           inpessoa
                                ,59502460987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 567671   nrdconta
                                ,2        inpessoa
                                ,18752670 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 752509      nrdconta
                                ,1           inpessoa
                                ,13957540984 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 450847     nrdconta
                                ,1          inpessoa
                                ,6701233902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 772127      nrdconta
                                ,1           inpessoa
                                ,61289639949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 589926      nrdconta
                                ,1           inpessoa
                                ,23175213839 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 689220      nrdconta
                                ,1           inpessoa
                                ,68417446915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 667170   nrdconta
                                ,1        inpessoa
                                ,43734995 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 653640      nrdconta
                                ,1           inpessoa
                                ,56118503915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755648      nrdconta
                                ,1           inpessoa
                                ,68378246949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 695831     nrdconta
                                ,1          inpessoa
                                ,7106841935 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 932019      nrdconta
                                ,1           inpessoa
                                ,95141677915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 335223   nrdconta
                                ,2        inpessoa
                                ,17889190 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 737984      nrdconta
                                ,1           inpessoa
                                ,15014325912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 757187     nrdconta
                                ,1          inpessoa
                                ,4588527916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 638889   nrdconta
                                ,2        inpessoa
                                ,30096096 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 530719   nrdconta
                                ,2        inpessoa
                                ,75272013 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 392170     nrdconta
                                ,1          inpessoa
                                ,5775758994 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 403466    nrdconta
                                ,1         inpessoa
                                ,453120954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 536296      nrdconta
                                ,1           inpessoa
                                ,76524710010 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 425982     nrdconta
                                ,1          inpessoa
                                ,4448719936 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 746070      nrdconta
                                ,1           inpessoa
                                ,92047548934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 730408     nrdconta
                                ,1          inpessoa
                                ,2554626200 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 504688     nrdconta
                                ,1          inpessoa
                                ,4206847940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 157929  nrdconta
                                ,2       inpessoa
                                ,7067367 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 770965     nrdconta
                                ,1          inpessoa
                                ,8112429944 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742996     nrdconta
                                ,1          inpessoa
                                ,6162483932 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 239178  nrdconta
                                ,2       inpessoa
                                ,7188803 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 761290     nrdconta
                                ,1          inpessoa
                                ,8417871900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732680    nrdconta
                                ,1         inpessoa
                                ,455330913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 373400      nrdconta
                                ,1           inpessoa
                                ,92059007968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 912409     nrdconta
                                ,1          inpessoa
                                ,5747831569 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 386812     nrdconta
                                ,1          inpessoa
                                ,4588848984 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 723177     nrdconta
                                ,1          inpessoa
                                ,5475978948 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 783382     nrdconta
                                ,1          inpessoa
                                ,3137666902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 595640     nrdconta
                                ,1          inpessoa
                                ,7410600942 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 670286     nrdconta
                                ,1          inpessoa
                                ,9741306997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 205451      nrdconta
                                ,1           inpessoa
                                ,55460739934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 731129   nrdconta
                                ,2        inpessoa
                                ,33175451 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 706566      nrdconta
                                ,1           inpessoa
                                ,74812025915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 650668      nrdconta
                                ,1           inpessoa
                                ,90234650915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 746444     nrdconta
                                ,1          inpessoa
                                ,4058431946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 737275     nrdconta
                                ,1          inpessoa
                                ,9981641944 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 795720      nrdconta
                                ,1           inpessoa
                                ,14210220957 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 881066   nrdconta
                                ,2        inpessoa
                                ,29741351 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 560006   nrdconta
                                ,2        inpessoa
                                ,19401224 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 700150    nrdconta
                                ,1         inpessoa
                                ,386975990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 693510   nrdconta
                                ,2        inpessoa
                                ,31953932 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 695114     nrdconta
                                ,1          inpessoa
                                ,3926723912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 339423      nrdconta
                                ,1           inpessoa
                                ,62267060906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 584304   nrdconta
                                ,2        inpessoa
                                ,80664535 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 734039      nrdconta
                                ,1           inpessoa
                                ,24477397968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 734985    nrdconta
                                ,1         inpessoa
                                ,602463912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 517097     nrdconta
                                ,1          inpessoa
                                ,6134080985 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 518930     nrdconta
                                ,1          inpessoa
                                ,1706088914 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 759015      nrdconta
                                ,1           inpessoa
                                ,50970232934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 493007   nrdconta
                                ,2        inpessoa
                                ,24192129 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 535818      nrdconta
                                ,1           inpessoa
                                ,82138613968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 810541      nrdconta
                                ,1           inpessoa
                                ,10559900970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 376531      nrdconta
                                ,1           inpessoa
                                ,29344760900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 586358     nrdconta
                                ,1          inpessoa
                                ,9547781979 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 710806      nrdconta
                                ,1           inpessoa
                                ,89112237949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754943      nrdconta
                                ,1           inpessoa
                                ,14113819980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 788872      nrdconta
                                ,1           inpessoa
                                ,10751958964 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 680478      nrdconta
                                ,1           inpessoa
                                ,90215010906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 316857      nrdconta
                                ,1           inpessoa
                                ,89064178968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 229709  nrdconta
                                ,2       inpessoa
                                ,1285635 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 633852   nrdconta
                                ,2        inpessoa
                                ,26842281 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 762113    nrdconta
                                ,1         inpessoa
                                ,572444990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725277     nrdconta
                                ,1          inpessoa
                                ,2771016206 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 673650      nrdconta
                                ,1           inpessoa
                                ,11030521956 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 251496      nrdconta
                                ,1           inpessoa
                                ,78243157972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 630993   nrdconta
                                ,2        inpessoa
                                ,29938802 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 540102     nrdconta
                                ,1          inpessoa
                                ,8692105996 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 234788  nrdconta
                                ,2       inpessoa
                                ,9532834 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 611964     nrdconta
                                ,1          inpessoa
                                ,2758116979 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 515086     nrdconta
                                ,1          inpessoa
                                ,4282495901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 843202     nrdconta
                                ,1          inpessoa
                                ,2628785935 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 851329      nrdconta
                                ,1           inpessoa
                                ,69479771934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 464643     nrdconta
                                ,1          inpessoa
                                ,5373114910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 810240     nrdconta
                                ,1          inpessoa
                                ,4441180985 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 689769   nrdconta
                                ,2        inpessoa
                                ,32815919 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 791709  nrdconta
                                ,2       inpessoa
                                ,7771794 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755842   nrdconta
                                ,2        inpessoa
                                ,34009078 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 518603      nrdconta
                                ,1           inpessoa
                                ,96952431934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 842303   nrdconta
                                ,2        inpessoa
                                ,27565388 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 339830   nrdconta
                                ,2        inpessoa
                                ,20737187 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 677060 nrdconta
                                ,2      inpessoa
                                ,107316 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 332402      nrdconta
                                ,1           inpessoa
                                ,67647049968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 704954      nrdconta
                                ,1           inpessoa
                                ,94804800930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 702366      nrdconta
                                ,1           inpessoa
                                ,68653042920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 186775      nrdconta
                                ,1           inpessoa
                                ,82159238953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 488747     nrdconta
                                ,1          inpessoa
                                ,7261139998 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 812668     nrdconta
                                ,1          inpessoa
                                ,3719575918 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 589543     nrdconta
                                ,1          inpessoa
                                ,6459257990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 489514     nrdconta
                                ,1          inpessoa
                                ,9256154986 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 733709   nrdconta
                                ,2        inpessoa
                                ,27183096 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 304522      nrdconta
                                ,1           inpessoa
                                ,94807060910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 682012   nrdconta
                                ,2        inpessoa
                                ,17713676 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 767751      nrdconta
                                ,1           inpessoa
                                ,11091773998 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 488984      nrdconta
                                ,1           inpessoa
                                ,56019769100 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 458252     nrdconta
                                ,1          inpessoa
                                ,8282699985 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 370096      nrdconta
                                ,1           inpessoa
                                ,75007053953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735035      nrdconta
                                ,1           inpessoa
                                ,35139110920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 836966   nrdconta
                                ,2        inpessoa
                                ,31529262 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 218103     nrdconta
                                ,1          inpessoa
                                ,4172686966 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765597     nrdconta
                                ,1          inpessoa
                                ,9502926994 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 462535   nrdconta
                                ,2        inpessoa
                                ,79370391 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 643793      nrdconta
                                ,1           inpessoa
                                ,68392397991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 612480     nrdconta
                                ,1          inpessoa
                                ,7254234980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 611263      nrdconta
                                ,1           inpessoa
                                ,11235944905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 728756      nrdconta
                                ,1           inpessoa
                                ,72276940972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 638382      nrdconta
                                ,1           inpessoa
                                ,11060729954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 794546     nrdconta
                                ,1          inpessoa
                                ,2508049999 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 529583   nrdconta
                                ,2        inpessoa
                                ,25989908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 239208      nrdconta
                                ,1           inpessoa
                                ,10310040922 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 950882      nrdconta
                                ,1           inpessoa
                                ,40626517850 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 606022     nrdconta
                                ,1          inpessoa
                                ,4456854928 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 659711     nrdconta
                                ,1          inpessoa
                                ,5247251954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 489743  nrdconta
                                ,2       inpessoa
                                ,6221020 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 633020   nrdconta
                                ,2        inpessoa
                                ,30488927 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 812072     nrdconta
                                ,1          inpessoa
                                ,4603821956 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732303      nrdconta
                                ,1           inpessoa
                                ,10127431950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 702013      nrdconta
                                ,1           inpessoa
                                ,67801994868 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 462454     nrdconta
                                ,1          inpessoa
                                ,9149883950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 689572      nrdconta
                                ,1           inpessoa
                                ,68437315972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 339997      nrdconta
                                ,1           inpessoa
                                ,10268038961 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 858897      nrdconta
                                ,1           inpessoa
                                ,12571905988 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 385298     nrdconta
                                ,1          inpessoa
                                ,8142885964 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 529770   nrdconta
                                ,2        inpessoa
                                ,27053562 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 605085      nrdconta
                                ,1           inpessoa
                                ,10378558927 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 630870     nrdconta
                                ,1          inpessoa
                                ,3739952962 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 589403      nrdconta
                                ,1           inpessoa
                                ,56833130906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 269190      nrdconta
                                ,1           inpessoa
                                ,38266865949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 301710      nrdconta
                                ,1           inpessoa
                                ,65835158904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764094     nrdconta
                                ,1          inpessoa
                                ,6378807906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 548685     nrdconta
                                ,1          inpessoa
                                ,7689608949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 679844      nrdconta
                                ,1           inpessoa
                                ,82170398953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 680940     nrdconta
                                ,1          inpessoa
                                ,7309308905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 492469     nrdconta
                                ,1          inpessoa
                                ,7659595938 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 610437     nrdconta
                                ,1          inpessoa
                                ,7522699924 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 756547      nrdconta
                                ,1           inpessoa
                                ,90214420949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 681865     nrdconta
                                ,1          inpessoa
                                ,3560462908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 719544     nrdconta
                                ,1          inpessoa
                                ,9897514902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 952494   nrdconta
                                ,2        inpessoa
                                ,38153015 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 269026     nrdconta
                                ,1          inpessoa
                                ,2938408900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 400009      nrdconta
                                ,1           inpessoa
                                ,31131620925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 739138      nrdconta
                                ,1           inpessoa
                                ,85124699191 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 590460     nrdconta
                                ,1          inpessoa
                                ,6475402907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 731633     nrdconta
                                ,1          inpessoa
                                ,2653882957 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 304433    nrdconta
                                ,1         inpessoa
                                ,542160951 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 651044      nrdconta
                                ,1           inpessoa
                                ,68124635900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 582549     nrdconta
                                ,1          inpessoa
                                ,7379243900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 485861      nrdconta
                                ,1           inpessoa
                                ,85481858991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 530484     nrdconta
                                ,1          inpessoa
                                ,1526556979 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 736473      nrdconta
                                ,1           inpessoa
                                ,70095163247 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 293067      nrdconta
                                ,1           inpessoa
                                ,85127990997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 703630      nrdconta
                                ,1           inpessoa
                                ,14870027852 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 468355    nrdconta
                                ,1         inpessoa
                                ,579487989 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 759007   nrdconta
                                ,2        inpessoa
                                ,26604233 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 695904      nrdconta
                                ,1           inpessoa
                                ,16724213819 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 290300     nrdconta
                                ,1          inpessoa
                                ,1040741916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 751243     nrdconta
                                ,1          inpessoa
                                ,7445994904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 605123     nrdconta
                                ,1          inpessoa
                                ,9441686980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 403202     nrdconta
                                ,1          inpessoa
                                ,1028400918 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 380172     nrdconta
                                ,1          inpessoa
                                ,2972200985 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 358967  nrdconta
                                ,2       inpessoa
                                ,3430156 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765350      nrdconta
                                ,1           inpessoa
                                ,10179359983 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 516430   nrdconta
                                ,2        inpessoa
                                ,16742805 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 514080     nrdconta
                                ,1          inpessoa
                                ,8013689956 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735884      nrdconta
                                ,1           inpessoa
                                ,89089812920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 853631     nrdconta
                                ,1          inpessoa
                                ,6468421969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 723681      nrdconta
                                ,1           inpessoa
                                ,10912181966 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 661120      nrdconta
                                ,1           inpessoa
                                ,63086719915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 825220    nrdconta
                                ,1         inpessoa
                                ,377184950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 645346      nrdconta
                                ,1           inpessoa
                                ,43451519968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 728187     nrdconta
                                ,1          inpessoa
                                ,8823173930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 574341   nrdconta
                                ,2        inpessoa
                                ,17450541 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 503924      nrdconta
                                ,1           inpessoa
                                ,59238046034 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 630900   nrdconta
                                ,2        inpessoa
                                ,10896773 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 356646      nrdconta
                                ,1           inpessoa
                                ,31197035915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 658529      nrdconta
                                ,1           inpessoa
                                ,22116338204 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 688215   nrdconta
                                ,2        inpessoa
                                ,32842638 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 881562      nrdconta
                                ,1           inpessoa
                                ,58497536991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 832650   nrdconta
                                ,2        inpessoa
                                ,13092349 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743143     nrdconta
                                ,1          inpessoa
                                ,7951219975 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 670200    nrdconta
                                ,1         inpessoa
                                ,490492916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 565024     nrdconta
                                ,1          inpessoa
                                ,5602567950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 662151   nrdconta
                                ,2        inpessoa
                                ,19157824 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 847747     nrdconta
                                ,1          inpessoa
                                ,7046301921 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 472719     nrdconta
                                ,1          inpessoa
                                ,4712383925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 562980   nrdconta
                                ,2        inpessoa
                                ,21278949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 316547      nrdconta
                                ,1           inpessoa
                                ,56659148949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 201901     nrdconta
                                ,1          inpessoa
                                ,5262570917 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 670146     nrdconta
                                ,1          inpessoa
                                ,4126232931 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 311936      nrdconta
                                ,1           inpessoa
                                ,62308149949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 129534    nrdconta
                                ,1         inpessoa
                                ,612993914 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 629413     nrdconta
                                ,1          inpessoa
                                ,7745597994 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 797820   nrdconta
                                ,2        inpessoa
                                ,32189065 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 703010     nrdconta
                                ,1          inpessoa
                                ,3756763927 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 738468   nrdconta
                                ,2        inpessoa
                                ,27605825 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 400319     nrdconta
                                ,1          inpessoa
                                ,8415117990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 492450     nrdconta
                                ,1          inpessoa
                                ,4770249985 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 507830     nrdconta
                                ,1          inpessoa
                                ,6942171905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 781320   nrdconta
                                ,2        inpessoa
                                ,35374112 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 215228     nrdconta
                                ,1          inpessoa
                                ,6743589969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 748269    nrdconta
                                ,1         inpessoa
                                ,363336974 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 613657  nrdconta
                                ,2       inpessoa
                                ,3286482 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 734551   nrdconta
                                ,2        inpessoa
                                ,24777311 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 593583     nrdconta
                                ,1          inpessoa
                                ,3900396914 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 738948      nrdconta
                                ,1           inpessoa
                                ,66436958991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 730335   nrdconta
                                ,2        inpessoa
                                ,31925010 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 602876     nrdconta
                                ,1          inpessoa
                                ,7246298908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 628522     nrdconta
                                ,1          inpessoa
                                ,8986033909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754544      nrdconta
                                ,1           inpessoa
                                ,65252900906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 741418      nrdconta
                                ,1           inpessoa
                                ,47565020915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 726087      nrdconta
                                ,1           inpessoa
                                ,10000996955 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 192082      nrdconta
                                ,1           inpessoa
                                ,65675169920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 746207      nrdconta
                                ,1           inpessoa
                                ,31267157968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 471496     nrdconta
                                ,1          inpessoa
                                ,6062693986 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 767883     nrdconta
                                ,1          inpessoa
                                ,4499688981 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 799823      nrdconta
                                ,1           inpessoa
                                ,82145946934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 666602   nrdconta
                                ,2        inpessoa
                                ,28869399 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 546437   nrdconta
                                ,2        inpessoa
                                ,20932496 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 693952     nrdconta
                                ,1          inpessoa
                                ,8785855910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 682209   nrdconta
                                ,2        inpessoa
                                ,32131147 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 767948      nrdconta
                                ,1           inpessoa
                                ,11047752980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 501301      nrdconta
                                ,1           inpessoa
                                ,71978844972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 748099   nrdconta
                                ,2        inpessoa
                                ,22865457 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 495255   nrdconta
                                ,2        inpessoa
                                ,26523518 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 686662      nrdconta
                                ,1           inpessoa
                                ,66576822987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 796808      nrdconta
                                ,1           inpessoa
                                ,45255832820 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 612626   nrdconta
                                ,2        inpessoa
                                ,28106578 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 522287     nrdconta
                                ,1          inpessoa
                                ,2508422975 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 830526   nrdconta
                                ,2        inpessoa
                                ,36765940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 385867      nrdconta
                                ,1           inpessoa
                                ,66026741968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725943      nrdconta
                                ,1           inpessoa
                                ,65514289915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 640093     nrdconta
                                ,1          inpessoa
                                ,8364920995 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 734411     nrdconta
                                ,1          inpessoa
                                ,4488473962 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 643319     nrdconta
                                ,1          inpessoa
                                ,7398469900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 673056    nrdconta
                                ,1         inpessoa
                                ,497114151 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725757      nrdconta
                                ,1           inpessoa
                                ,55719678972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 443654      nrdconta
                                ,1           inpessoa
                                ,90723287953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 626406      nrdconta
                                ,1           inpessoa
                                ,25930234817 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 534480     nrdconta
                                ,1          inpessoa
                                ,8663834926 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 507997     nrdconta
                                ,1          inpessoa
                                ,6882327955 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 463515      nrdconta
                                ,1           inpessoa
                                ,79187765934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 268500     nrdconta
                                ,1          inpessoa
                                ,4570559956 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 726931      nrdconta
                                ,1           inpessoa
                                ,10720653983 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 770680  nrdconta
                                ,2       inpessoa
                                ,7743292 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 358932     nrdconta
                                ,1          inpessoa
                                ,4386247939 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 504793   nrdconta
                                ,2        inpessoa
                                ,17424207 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 296848      nrdconta
                                ,1           inpessoa
                                ,89738004004 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 723142      nrdconta
                                ,1           inpessoa
                                ,10240261917 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 609587     nrdconta
                                ,1          inpessoa
                                ,8145276985 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 202363      nrdconta
                                ,1           inpessoa
                                ,64140318953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 339482   nrdconta
                                ,2        inpessoa
                                ,24336465 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 557170  nrdconta
                                ,2       inpessoa
                                ,7566632 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 648612      nrdconta
                                ,1           inpessoa
                                ,13706255960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 674583   nrdconta
                                ,2        inpessoa
                                ,28577329 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725412   nrdconta
                                ,2        inpessoa
                                ,33830825 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 530778      nrdconta
                                ,1           inpessoa
                                ,74551612987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 660655   nrdconta
                                ,2        inpessoa
                                ,28086009 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 550558      nrdconta
                                ,1           inpessoa
                                ,37985230963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 631060   nrdconta
                                ,2        inpessoa
                                ,30261822 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 314021      nrdconta
                                ,1           inpessoa
                                ,92061869904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 798223   nrdconta
                                ,2        inpessoa
                                ,17655458 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 793094  nrdconta
                                ,2       inpessoa
                                ,7156963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 432741  nrdconta
                                ,2       inpessoa
                                ,1820172 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 550370      nrdconta
                                ,1           inpessoa
                                ,19357427953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 473170   nrdconta
                                ,2        inpessoa
                                ,20589022 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 440957      nrdconta
                                ,1           inpessoa
                                ,75285703972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 581801   nrdconta
                                ,2        inpessoa
                                ,12015678 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 675016   nrdconta
                                ,2        inpessoa
                                ,31606036 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 506958   nrdconta
                                ,2        inpessoa
                                ,20292374 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 507903      nrdconta
                                ,1           inpessoa
                                ,94743878500 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765880   nrdconta
                                ,2        inpessoa
                                ,34966255 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 156760      nrdconta
                                ,1           inpessoa
                                ,98913166968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 673382 nrdconta
                                ,2      inpessoa
                                ,946903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 686026   nrdconta
                                ,2        inpessoa
                                ,24894175 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 339962     nrdconta
                                ,1          inpessoa
                                ,7959224935 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 734888     nrdconta
                                ,1          inpessoa
                                ,2056150158 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725200      nrdconta
                                ,1           inpessoa
                                ,42007500906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 489093     nrdconta
                                ,1          inpessoa
                                ,4065184916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 280984      nrdconta
                                ,1           inpessoa
                                ,11534005960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 406260      nrdconta
                                ,1           inpessoa
                                ,44230630930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 508365     nrdconta
                                ,1          inpessoa
                                ,3796483933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 639508     nrdconta
                                ,1          inpessoa
                                ,7584771980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 753912      nrdconta
                                ,1           inpessoa
                                ,11101411902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 820067   nrdconta
                                ,2        inpessoa
                                ,36641706 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 458996     nrdconta
                                ,1          inpessoa
                                ,1966931956 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 775657   nrdconta
                                ,2        inpessoa
                                ,24830363 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 302376     nrdconta
                                ,1          inpessoa
                                ,6303980970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 831328   nrdconta
                                ,2        inpessoa
                                ,14859936 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 901172      nrdconta
                                ,1           inpessoa
                                ,80085309958 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 692646   nrdconta
                                ,2        inpessoa
                                ,17064479 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 160407   nrdconta
                                ,2        inpessoa
                                ,23267679 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 387002    nrdconta
                                ,1         inpessoa
                                ,432218904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 766267     nrdconta
                                ,1          inpessoa
                                ,1639037942 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 443590     nrdconta
                                ,1          inpessoa
                                ,3681562903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 598895     nrdconta
                                ,1          inpessoa
                                ,7278396913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 674290     nrdconta
                                ,1          inpessoa
                                ,7715664928 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 251763     nrdconta
                                ,1          inpessoa
                                ,2621255957 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 385719   nrdconta
                                ,2        inpessoa
                                ,10354831 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 679046     nrdconta
                                ,1          inpessoa
                                ,6314209919 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 700916      nrdconta
                                ,1           inpessoa
                                ,93638965953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 871974   nrdconta
                                ,2        inpessoa
                                ,35086581 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 668168     nrdconta
                                ,1          inpessoa
                                ,4622793911 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 791865   nrdconta
                                ,2        inpessoa
                                ,31179874 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 515949   nrdconta
                                ,2        inpessoa
                                ,20231419 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 843849     nrdconta
                                ,1          inpessoa
                                ,5840219924 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 861847      nrdconta
                                ,1           inpessoa
                                ,11301572969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 621501     nrdconta
                                ,1          inpessoa
                                ,3471591923 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 487759   nrdconta
                                ,2        inpessoa
                                ,22529253 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 641316   nrdconta
                                ,2        inpessoa
                                ,30743507 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 498572   nrdconta
                                ,2        inpessoa
                                ,10978282 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 706329   nrdconta
                                ,2        inpessoa
                                ,21058109 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 752517   nrdconta
                                ,2        inpessoa
                                ,34385942 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 824330  nrdconta
                                ,2       inpessoa
                                ,2064150 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 587028     nrdconta
                                ,1          inpessoa
                                ,6509337967 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735256     nrdconta
                                ,1          inpessoa
                                ,9387215938 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 491985     nrdconta
                                ,1          inpessoa
                                ,8781323921 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 909734     nrdconta
                                ,1          inpessoa
                                ,8958836946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 332470     nrdconta
                                ,1          inpessoa
                                ,5305137900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 472751      nrdconta
                                ,1           inpessoa
                                ,79150713949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 468843     nrdconta
                                ,1          inpessoa
                                ,7123006941 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 756938     nrdconta
                                ,1          inpessoa
                                ,8673801958 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 763454   nrdconta
                                ,2        inpessoa
                                ,34773229 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 426156    nrdconta
                                ,1         inpessoa
                                ,888690916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 711586     nrdconta
                                ,1          inpessoa
                                ,6382554146 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 739316   nrdconta
                                ,2        inpessoa
                                ,26562979 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 547530   nrdconta
                                ,2        inpessoa
                                ,16857805 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 342327      nrdconta
                                ,1           inpessoa
                                ,98796550953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 447021     nrdconta
                                ,1          inpessoa
                                ,5351825970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 768588     nrdconta
                                ,1          inpessoa
                                ,9714531950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 954187     nrdconta
                                ,1          inpessoa
                                ,9221946967 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 559563     nrdconta
                                ,1          inpessoa
                                ,9458487900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 510823     nrdconta
                                ,1          inpessoa
                                ,9148705993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 517720     nrdconta
                                ,1          inpessoa
                                ,5204468951 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 634468     nrdconta
                                ,1          inpessoa
                                ,9558534943 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 649201      nrdconta
                                ,1           inpessoa
                                ,42201578915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 200760      nrdconta
                                ,1           inpessoa
                                ,96959533953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 619124   nrdconta
                                ,2        inpessoa
                                ,28948704 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 465810      nrdconta
                                ,1           inpessoa
                                ,85127990997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 721433     nrdconta
                                ,1          inpessoa
                                ,6221433959 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 818909      nrdconta
                                ,1           inpessoa
                                ,76706974900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 616796     nrdconta
                                ,1          inpessoa
                                ,3164720939 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 519685      nrdconta
                                ,1           inpessoa
                                ,35099550991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 441619     nrdconta
                                ,1          inpessoa
                                ,8859706912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 639192     nrdconta
                                ,1          inpessoa
                                ,4349187928 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 319198     nrdconta
                                ,1          inpessoa
                                ,6112189925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 666343     nrdconta
                                ,1          inpessoa
                                ,5961525902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 395056     nrdconta
                                ,1          inpessoa
                                ,8617806982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 497258     nrdconta
                                ,1          inpessoa
                                ,5278359943 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743909  nrdconta
                                ,2       inpessoa
                                ,9477840 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 700738   nrdconta
                                ,2        inpessoa
                                ,11724492 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 419273      nrdconta
                                ,1           inpessoa
                                ,75545250930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 724947    nrdconta
                                ,1         inpessoa
                                ,715667084 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 615307   nrdconta
                                ,2        inpessoa
                                ,29492835 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 766062   nrdconta
                                ,2        inpessoa
                                ,12567786 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732400     nrdconta
                                ,1          inpessoa
                                ,6890370902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 713910      nrdconta
                                ,1           inpessoa
                                ,11493017918 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 716278   nrdconta
                                ,2        inpessoa
                                ,33268222 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 521353     nrdconta
                                ,1          inpessoa
                                ,8508141971 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 371165     nrdconta
                                ,1          inpessoa
                                ,9095824918 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 763322      nrdconta
                                ,1           inpessoa
                                ,22929419881 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 665614     nrdconta
                                ,1          inpessoa
                                ,3028268906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 520241    nrdconta
                                ,1         inpessoa
                                ,769889964 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 761966    nrdconta
                                ,1         inpessoa
                                ,498069982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 218570   nrdconta
                                ,2        inpessoa
                                ,11682057 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 597066   nrdconta
                                ,2        inpessoa
                                ,17236865 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 595829   nrdconta
                                ,2        inpessoa
                                ,24770311 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 759775     nrdconta
                                ,1          inpessoa
                                ,8928080983 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 876160   nrdconta
                                ,2        inpessoa
                                ,18487804 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 736430      nrdconta
                                ,1           inpessoa
                                ,12503313906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754285     nrdconta
                                ,1          inpessoa
                                ,2648401946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 763721   nrdconta
                                ,2        inpessoa
                                ,23375535 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 381276    nrdconta
                                ,1         inpessoa
                                ,816872902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 486515   nrdconta
                                ,2        inpessoa
                                ,19307306 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 664391     nrdconta
                                ,1          inpessoa
                                ,4538068993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 502715   nrdconta
                                ,2        inpessoa
                                ,26553779 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 709549   nrdconta
                                ,2        inpessoa
                                ,33364422 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 464740   nrdconta
                                ,2        inpessoa
                                ,16491488 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 820776   nrdconta
                                ,2        inpessoa
                                ,80705858 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 719773     nrdconta
                                ,1          inpessoa
                                ,8243559973 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 832723   nrdconta
                                ,2        inpessoa
                                ,24654829 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 729051   nrdconta
                                ,2        inpessoa
                                ,33774643 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 658987     nrdconta
                                ,1          inpessoa
                                ,8609953998 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 760447     nrdconta
                                ,1          inpessoa
                                ,2832155936 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764248     nrdconta
                                ,1          inpessoa
                                ,1648511007 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 301787      nrdconta
                                ,1           inpessoa
                                ,48681270982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 493244    nrdconta
                                ,1         inpessoa
                                ,632234903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 595683      nrdconta
                                ,1           inpessoa
                                ,11460774914 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 651370   nrdconta
                                ,2        inpessoa
                                ,29464622 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 504408     nrdconta
                                ,1          inpessoa
                                ,7093318940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 763462     nrdconta
                                ,1          inpessoa
                                ,6824875970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 727555     nrdconta
                                ,1          inpessoa
                                ,2131095309 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 529753      nrdconta
                                ,1           inpessoa
                                ,72855550025 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 734403      nrdconta
                                ,1           inpessoa
                                ,10058156909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 645079      nrdconta
                                ,1           inpessoa
                                ,11236042905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 671800   nrdconta
                                ,2        inpessoa
                                ,29768434 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 614645      nrdconta
                                ,1           inpessoa
                                ,41841085987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 263664  nrdconta
                                ,2       inpessoa
                                ,4062243 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743771   nrdconta
                                ,2        inpessoa
                                ,33871844 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 821950   nrdconta
                                ,2        inpessoa
                                ,32934391 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 591670   nrdconta
                                ,2        inpessoa
                                ,28093232 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 507318     nrdconta
                                ,1          inpessoa
                                ,4132723976 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 489131      nrdconta
                                ,1           inpessoa
                                ,89112237949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 739103   nrdconta
                                ,2        inpessoa
                                ,23624070 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 825646   nrdconta
                                ,2        inpessoa
                                ,33226892 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 756741     nrdconta
                                ,1          inpessoa
                                ,5651764984 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 810681   nrdconta
                                ,2        inpessoa
                                ,28596786 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 218499  nrdconta
                                ,2       inpessoa
                                ,8190512 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 679321     nrdconta
                                ,1          inpessoa
                                ,5884684959 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 763730     nrdconta
                                ,1          inpessoa
                                ,7085293993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 578509      nrdconta
                                ,1           inpessoa
                                ,79185118915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 449881      nrdconta
                                ,1           inpessoa
                                ,65805089904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 479292      nrdconta
                                ,1           inpessoa
                                ,40837807972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 319228      nrdconta
                                ,1           inpessoa
                                ,85121371934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 532231     nrdconta
                                ,1          inpessoa
                                ,3476080943 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 559490      nrdconta
                                ,1           inpessoa
                                ,97076112949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 712582     nrdconta
                                ,1          inpessoa
                                ,5665844845 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 705403      nrdconta
                                ,1           inpessoa
                                ,40167933949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 715123     nrdconta
                                ,1          inpessoa
                                ,3893973931 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 706787   nrdconta
                                ,2        inpessoa
                                ,77908879 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 593575     nrdconta
                                ,1          inpessoa
                                ,5908055921 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 780189      nrdconta
                                ,1           inpessoa
                                ,48660205987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 426040   nrdconta
                                ,2        inpessoa
                                ,25230929 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 712469   nrdconta
                                ,2        inpessoa
                                ,32057664 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 297879      nrdconta
                                ,1           inpessoa
                                ,67342205915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 626686   nrdconta
                                ,2        inpessoa
                                ,22801247 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 664430   nrdconta
                                ,2        inpessoa
                                ,16986172 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 729230     nrdconta
                                ,1          inpessoa
                                ,1007527994 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 611670   nrdconta
                                ,2        inpessoa
                                ,27979134 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 737631     nrdconta
                                ,1          inpessoa
                                ,6693667902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 517950     nrdconta
                                ,1          inpessoa
                                ,8368204950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743461   nrdconta
                                ,2        inpessoa
                                ,33434577 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 700622     nrdconta
                                ,1          inpessoa
                                ,4807943910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 900435     nrdconta
                                ,1          inpessoa
                                ,6984516943 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 750204      nrdconta
                                ,1           inpessoa
                                ,12875542966 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 682446      nrdconta
                                ,1           inpessoa
                                ,82102562972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754927    nrdconta
                                ,1         inpessoa
                                ,605254958 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 785121      nrdconta
                                ,1           inpessoa
                                ,10368473902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 800635      nrdconta
                                ,1           inpessoa
                                ,97030040910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 485977     nrdconta
                                ,1          inpessoa
                                ,4527118943 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 657166      nrdconta
                                ,1           inpessoa
                                ,78265029934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755656     nrdconta
                                ,1          inpessoa
                                ,6269175909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 616311     nrdconta
                                ,1          inpessoa
                                ,6757884984 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 604003     nrdconta
                                ,1          inpessoa
                                ,2717869573 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725528     nrdconta
                                ,1          inpessoa
                                ,7310456963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 596094      nrdconta
                                ,1           inpessoa
                                ,68392397991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 319481     nrdconta
                                ,1          inpessoa
                                ,4727524996 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 726036   nrdconta
                                ,2        inpessoa
                                ,27597257 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 713007   nrdconta
                                ,2        inpessoa
                                ,27464950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 626503   nrdconta
                                ,2        inpessoa
                                ,24370855 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 825417   nrdconta
                                ,2        inpessoa
                                ,15162885 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 831670   nrdconta
                                ,2        inpessoa
                                ,10888123 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 705942     nrdconta
                                ,1          inpessoa
                                ,9361680994 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 693979     nrdconta
                                ,1          inpessoa
                                ,8885276911 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 590576     nrdconta
                                ,1          inpessoa
                                ,1834727995 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 679216   nrdconta
                                ,2        inpessoa
                                ,21485244 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 643050     nrdconta
                                ,1          inpessoa
                                ,6138827929 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 748986      nrdconta
                                ,1           inpessoa
                                ,14810687929 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 767417      nrdconta
                                ,1           inpessoa
                                ,64386490906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 650129     nrdconta
                                ,1          inpessoa
                                ,3872230964 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 646806     nrdconta
                                ,1          inpessoa
                                ,9579924910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 617008     nrdconta
                                ,1          inpessoa
                                ,9484463908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 502685     nrdconta
                                ,1          inpessoa
                                ,5096347966 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 721948      nrdconta
                                ,1           inpessoa
                                ,79139930904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 505684   nrdconta
                                ,2        inpessoa
                                ,24307699 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 383554  nrdconta
                                ,2       inpessoa
                                ,7725482 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 759805      nrdconta
                                ,1           inpessoa
                                ,10420415980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 615668   nrdconta
                                ,2        inpessoa
                                ,29534356 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 699918      nrdconta
                                ,1           inpessoa
                                ,15262984738 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 699330      nrdconta
                                ,1           inpessoa
                                ,69401268991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 589420      nrdconta
                                ,1           inpessoa
                                ,96376988920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 641405     nrdconta
                                ,1          inpessoa
                                ,8728362900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735906     nrdconta
                                ,1          inpessoa
                                ,1745704060 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 738417   nrdconta
                                ,2        inpessoa
                                ,10841912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 461849    nrdconta
                                ,1         inpessoa
                                ,403727901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 728152     nrdconta
                                ,1          inpessoa
                                ,6747988990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 307114   nrdconta
                                ,2        inpessoa
                                ,79018842 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 771759      nrdconta
                                ,1           inpessoa
                                ,86674170925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 826200     nrdconta
                                ,1          inpessoa
                                ,3703768975 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 826537      nrdconta
                                ,1           inpessoa
                                ,10189035935 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 591998   nrdconta
                                ,2        inpessoa
                                ,21313778 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 609668     nrdconta
                                ,1          inpessoa
                                ,6615754975 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 727261      nrdconta
                                ,1           inpessoa
                                ,11299345948 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 705810     nrdconta
                                ,1          inpessoa
                                ,8587161946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 625558   nrdconta
                                ,2        inpessoa
                                ,30289498 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 218642     nrdconta
                                ,1          inpessoa
                                ,4884412931 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 493201     nrdconta
                                ,1          inpessoa
                                ,5927372929 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 746347      nrdconta
                                ,1           inpessoa
                                ,35030201874 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 3050        nrdconta
                                ,1           inpessoa
                                ,29133718920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 576697      nrdconta
                                ,1           inpessoa
                                ,10501794980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 740446   nrdconta
                                ,2        inpessoa
                                ,21207453 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 738018   nrdconta
                                ,2        inpessoa
                                ,17770913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 467995     nrdconta
                                ,1          inpessoa
                                ,6102835964 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 748366    nrdconta
                                ,1         inpessoa
                                ,911648933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765619     nrdconta
                                ,1          inpessoa
                                ,6321532967 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 694185     nrdconta
                                ,1          inpessoa
                                ,6999527946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 298468     nrdconta
                                ,1          inpessoa
                                ,7470553940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 342114      nrdconta
                                ,1           inpessoa
                                ,81692587900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 641138     nrdconta
                                ,1          inpessoa
                                ,6956725924 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 479420      nrdconta
                                ,1           inpessoa
                                ,48329762068 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732842     nrdconta
                                ,1          inpessoa
                                ,5925637909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 660043   nrdconta
                                ,2        inpessoa
                                ,21439469 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 429600   nrdconta
                                ,2        inpessoa
                                ,26076274 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 726184     nrdconta
                                ,1          inpessoa
                                ,7180458902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 516511     nrdconta
                                ,1          inpessoa
                                ,7421969926 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 202916      nrdconta
                                ,1           inpessoa
                                ,69340595904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 727881   nrdconta
                                ,2        inpessoa
                                ,28846059 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 639540     nrdconta
                                ,1          inpessoa
                                ,9942979980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 379468   nrdconta
                                ,2        inpessoa
                                ,14110479 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 818259     nrdconta
                                ,1          inpessoa
                                ,9976573910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754862      nrdconta
                                ,1           inpessoa
                                ,11719231982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 235210     nrdconta
                                ,1          inpessoa
                                ,9798136977 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 623830   nrdconta
                                ,2        inpessoa
                                ,20402264 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 30767       nrdconta
                                ,1           inpessoa
                                ,62359355953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 646296      nrdconta
                                ,1           inpessoa
                                ,79012787904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 549436      nrdconta
                                ,1           inpessoa
                                ,94835527968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 313831      nrdconta
                                ,1           inpessoa
                                ,82144818991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 226696      nrdconta
                                ,1           inpessoa
                                ,89064402949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 652814      nrdconta
                                ,1           inpessoa
                                ,11109895984 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754170     nrdconta
                                ,1          inpessoa
                                ,3897836920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 382850     nrdconta
                                ,1          inpessoa
                                ,5710571954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 588172   nrdconta
                                ,2        inpessoa
                                ,27213810 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 573949   nrdconta
                                ,2        inpessoa
                                ,18647400 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 549622      nrdconta
                                ,1           inpessoa
                                ,37971557949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 227110      nrdconta
                                ,1           inpessoa
                                ,86744739972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 730955     nrdconta
                                ,1          inpessoa
                                ,7124280460 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 756300      nrdconta
                                ,1           inpessoa
                                ,72069260968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 399159      nrdconta
                                ,1           inpessoa
                                ,68515057972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 404349     nrdconta
                                ,1          inpessoa
                                ,1040741916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 290670      nrdconta
                                ,1           inpessoa
                                ,66025834920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 722375   nrdconta
                                ,2        inpessoa
                                ,31330059 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 445029     nrdconta
                                ,1          inpessoa
                                ,2512888975 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 194344     nrdconta
                                ,1          inpessoa
                                ,7781501942 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 383562      nrdconta
                                ,1           inpessoa
                                ,50039016900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 887838   nrdconta
                                ,2        inpessoa
                                ,37367594 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 507725  nrdconta
                                ,2       inpessoa
                                ,5775908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 685615     nrdconta
                                ,1          inpessoa
                                ,3864024935 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 473472     nrdconta
                                ,1          inpessoa
                                ,4527118943 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 472018     nrdconta
                                ,1          inpessoa
                                ,2621780873 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 740780   nrdconta
                                ,2        inpessoa
                                ,18755244 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 701815  nrdconta
                                ,2       inpessoa
                                ,7819215 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 694223  nrdconta
                                ,2       inpessoa
                                ,8020861 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 661228     nrdconta
                                ,1          inpessoa
                                ,9098327907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 834335   nrdconta
                                ,2        inpessoa
                                ,22521685 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 738816      nrdconta
                                ,1           inpessoa
                                ,67080995949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 987719     nrdconta
                                ,1          inpessoa
                                ,9559535960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 832960     nrdconta
                                ,1          inpessoa
                                ,1659522960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 389749      nrdconta
                                ,1           inpessoa
                                ,44433433004 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 239461     nrdconta
                                ,1          inpessoa
                                ,9684364989 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 586692   nrdconta
                                ,2        inpessoa
                                ,26086601 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 690970      nrdconta
                                ,1           inpessoa
                                ,11454668938 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725021  nrdconta
                                ,2       inpessoa
                                ,8307391 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 466484     nrdconta
                                ,1          inpessoa
                                ,5815060909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 965243      nrdconta
                                ,1           inpessoa
                                ,42183515899 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 750905    nrdconta
                                ,1         inpessoa
                                ,609354990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 492426      nrdconta
                                ,1           inpessoa
                                ,10607567902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 640280   nrdconta
                                ,2        inpessoa
                                ,29496723 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 31267       nrdconta
                                ,1           inpessoa
                                ,98678299991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 556173     nrdconta
                                ,1          inpessoa
                                ,4189633984 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 389390      nrdconta
                                ,1           inpessoa
                                ,80897991915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 787892     nrdconta
                                ,1          inpessoa
                                ,9069639904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 664871     nrdconta
                                ,1          inpessoa
                                ,2270459989 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 957984    nrdconta
                                ,1         inpessoa
                                ,794008925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 574562   nrdconta
                                ,2        inpessoa
                                ,21063944 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 697435     nrdconta
                                ,1          inpessoa
                                ,2996492960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 427535      nrdconta
                                ,1           inpessoa
                                ,69486263949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 645214      nrdconta
                                ,1           inpessoa
                                ,11731348916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 356212      nrdconta
                                ,1           inpessoa
                                ,90245555900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 745030      nrdconta
                                ,1           inpessoa
                                ,99550040372 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743682   nrdconta
                                ,2        inpessoa
                                ,34314809 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 477621     nrdconta
                                ,1          inpessoa
                                ,4935358963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 736880     nrdconta
                                ,1          inpessoa
                                ,5767390908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 549452     nrdconta
                                ,1          inpessoa
                                ,6637798983 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 528510      nrdconta
                                ,1           inpessoa
                                ,82143757972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 698806   nrdconta
                                ,2        inpessoa
                                ,30941571 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 239011      nrdconta
                                ,1           inpessoa
                                ,63732220982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 723959      nrdconta
                                ,1           inpessoa
                                ,36103980860 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 848433   nrdconta
                                ,2        inpessoa
                                ,27545074 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 463604     nrdconta
                                ,1          inpessoa
                                ,4077330947 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 462853     nrdconta
                                ,1          inpessoa
                                ,6001355940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 693120     nrdconta
                                ,1          inpessoa
                                ,2102027937 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 647047     nrdconta
                                ,1          inpessoa
                                ,3020097959 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 713163   nrdconta
                                ,2        inpessoa
                                ,28734384 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 787582   nrdconta
                                ,2        inpessoa
                                ,35411314 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 566276   nrdconta
                                ,2        inpessoa
                                ,15488730 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 788147   nrdconta
                                ,2        inpessoa
                                ,27406430 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 313262   nrdconta
                                ,2        inpessoa
                                ,11656924 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 628212   nrdconta
                                ,2        inpessoa
                                ,29854956 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735809     nrdconta
                                ,1          inpessoa
                                ,3095694946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 335258     nrdconta
                                ,1          inpessoa
                                ,7200302937 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 757004   nrdconta
                                ,2        inpessoa
                                ,12411694 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 788732      nrdconta
                                ,1           inpessoa
                                ,29347351920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 239348     nrdconta
                                ,1          inpessoa
                                ,4774270903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 381225      nrdconta
                                ,1           inpessoa
                                ,70172897904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 583383   nrdconta
                                ,2        inpessoa
                                ,23433149 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 590436     nrdconta
                                ,1          inpessoa
                                ,5204456945 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 539317  nrdconta
                                ,2       inpessoa
                                ,6922364 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 560154     nrdconta
                                ,1          inpessoa
                                ,8924601997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 404241      nrdconta
                                ,1           inpessoa
                                ,58746048987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 817767     nrdconta
                                ,1          inpessoa
                                ,5847003935 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 479225     nrdconta
                                ,1          inpessoa
                                ,1957369906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 159271      nrdconta
                                ,1           inpessoa
                                ,53825721949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 433632     nrdconta
                                ,1          inpessoa
                                ,8095351903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 795569   nrdconta
                                ,2        inpessoa
                                ,26595925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 634441   nrdconta
                                ,2        inpessoa
                                ,30065175 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 585700      nrdconta
                                ,1           inpessoa
                                ,13187795889 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 875023     nrdconta
                                ,1          inpessoa
                                ,4278233906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 493317     nrdconta
                                ,1          inpessoa
                                ,7270035938 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 604690     nrdconta
                                ,1          inpessoa
                                ,5490924985 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 776246     nrdconta
                                ,1          inpessoa
                                ,7442966926 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 895431     nrdconta
                                ,1          inpessoa
                                ,4022507969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 978760      nrdconta
                                ,1           inpessoa
                                ,10733961932 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 741949      nrdconta
                                ,1           inpessoa
                                ,51779684991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 269883      nrdconta
                                ,1           inpessoa
                                ,31023177900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 428248   nrdconta
                                ,2        inpessoa
                                ,22569746 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 776394      nrdconta
                                ,1           inpessoa
                                ,98796941987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 941956     nrdconta
                                ,1          inpessoa
                                ,9769875970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 886386   nrdconta
                                ,2        inpessoa
                                ,11475924 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 641383     nrdconta
                                ,1          inpessoa
                                ,5653229903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 684317     nrdconta
                                ,1          inpessoa
                                ,2775178936 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 638820      nrdconta
                                ,1           inpessoa
                                ,11147832935 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 772003     nrdconta
                                ,1          inpessoa
                                ,7123006941 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 633135     nrdconta
                                ,1          inpessoa
                                ,8350829974 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 780880   nrdconta
                                ,2        inpessoa
                                ,10922108 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 655279   nrdconta
                                ,2        inpessoa
                                ,18603628 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 426008  nrdconta
                                ,2       inpessoa
                                ,4464847 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 229458      nrdconta
                                ,1           inpessoa
                                ,58114335904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 773387     nrdconta
                                ,1          inpessoa
                                ,8087810902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 751600     nrdconta
                                ,1          inpessoa
                                ,4665175993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 335746   nrdconta
                                ,2        inpessoa
                                ,82855271 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 597040   nrdconta
                                ,2        inpessoa
                                ,28748153 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 127400     nrdconta
                                ,1          inpessoa
                                ,8382207898 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 547824      nrdconta
                                ,1           inpessoa
                                ,89049691900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 684074      nrdconta
                                ,1           inpessoa
                                ,26219497899 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 766968      nrdconta
                                ,1           inpessoa
                                ,10657115819 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 724882      nrdconta
                                ,1           inpessoa
                                ,72991674920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 644900      nrdconta
                                ,1           inpessoa
                                ,89027876991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 756318      nrdconta
                                ,1           inpessoa
                                ,60130113972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 408859     nrdconta
                                ,1          inpessoa
                                ,2981567926 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 425800   nrdconta
                                ,2        inpessoa
                                ,25228007 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 597600     nrdconta
                                ,1          inpessoa
                                ,1336465999 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 802336     nrdconta
                                ,1          inpessoa
                                ,8194018978 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 339156     nrdconta
                                ,1          inpessoa
                                ,7034370974 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 378216      nrdconta
                                ,1           inpessoa
                                ,62293303934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 441376     nrdconta
                                ,1          inpessoa
                                ,7696042939 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 811769   nrdconta
                                ,2        inpessoa
                                ,35031969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 471585     nrdconta
                                ,1          inpessoa
                                ,9100264911 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 728870     nrdconta
                                ,1          inpessoa
                                ,8538086944 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 460567      nrdconta
                                ,1           inpessoa
                                ,29988209991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 736619      nrdconta
                                ,1           inpessoa
                                ,70041677200 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 818208   nrdconta
                                ,2        inpessoa
                                ,19946683 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 691704      nrdconta
                                ,1           inpessoa
                                ,69420505987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 5681        nrdconta
                                ,1           inpessoa
                                ,52638529915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 239798      nrdconta
                                ,1           inpessoa
                                ,72067810987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 268593     nrdconta
                                ,1          inpessoa
                                ,4372297939 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 703087      nrdconta
                                ,1           inpessoa
                                ,94764816920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754161      nrdconta
                                ,1           inpessoa
                                ,94107688100 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 521493   nrdconta
                                ,2        inpessoa
                                ,14374769 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 359068   nrdconta
                                ,2        inpessoa
                                ,25144907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 822825   nrdconta
                                ,2        inpessoa
                                ,36590030 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 489484     nrdconta
                                ,1          inpessoa
                                ,3761850905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 698202     nrdconta
                                ,1          inpessoa
                                ,9596034928 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 510327      nrdconta
                                ,1           inpessoa
                                ,82098514972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 351016     nrdconta
                                ,1          inpessoa
                                ,5945609935 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732893     nrdconta
                                ,1          inpessoa
                                ,6851889900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 860018      nrdconta
                                ,1           inpessoa
                                ,85089001200 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 646377   nrdconta
                                ,2        inpessoa
                                ,30636600 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 715662     nrdconta
                                ,1          inpessoa
                                ,5520801959 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 712019     nrdconta
                                ,1          inpessoa
                                ,4126903909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 843580   nrdconta
                                ,2        inpessoa
                                ,34467425 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 699764     nrdconta
                                ,1          inpessoa
                                ,8520255990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 491527     nrdconta
                                ,1          inpessoa
                                ,8681948911 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 451290     nrdconta
                                ,1          inpessoa
                                ,3691151981 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 774065   nrdconta
                                ,2        inpessoa
                                ,16846718 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 635995      nrdconta
                                ,1           inpessoa
                                ,94725225215 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742686      nrdconta
                                ,1           inpessoa
                                ,86868837968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 452092     nrdconta
                                ,1          inpessoa
                                ,5130723902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 719374     nrdconta
                                ,1          inpessoa
                                ,3676902920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 689726      nrdconta
                                ,1           inpessoa
                                ,79152694968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 534870    nrdconta
                                ,1         inpessoa
                                ,839666926 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 889806     nrdconta
                                ,1          inpessoa
                                ,8149775960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 555916   nrdconta
                                ,2        inpessoa
                                ,18111552 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 298786      nrdconta
                                ,1           inpessoa
                                ,23717866087 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 606936     nrdconta
                                ,1          inpessoa
                                ,7248663964 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 627984      nrdconta
                                ,1           inpessoa
                                ,63118009934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 753505     nrdconta
                                ,1          inpessoa
                                ,8716715900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 576620  nrdconta
                                ,2       inpessoa
                                ,8675984 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 386715   nrdconta
                                ,2        inpessoa
                                ,16888719 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754005      nrdconta
                                ,1           inpessoa
                                ,49637479953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 788740     nrdconta
                                ,1          inpessoa
                                ,4790832902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 824194     nrdconta
                                ,1          inpessoa
                                ,7153868917 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 736538   nrdconta
                                ,2        inpessoa
                                ,29874841 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 504173   nrdconta
                                ,2        inpessoa
                                ,13914637 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 682098     nrdconta
                                ,1          inpessoa
                                ,5457380912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 632775      nrdconta
                                ,1           inpessoa
                                ,67959326991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765775    nrdconta
                                ,1         inpessoa
                                ,722575980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 489409   nrdconta
                                ,2        inpessoa
                                ,23232270 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 752339      nrdconta
                                ,1           inpessoa
                                ,82138141934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 166081      nrdconta
                                ,1           inpessoa
                                ,38844125072 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 638994     nrdconta
                                ,1          inpessoa
                                ,6636392983 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 529419   nrdconta
                                ,2        inpessoa
                                ,27471845 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 820156     nrdconta
                                ,1          inpessoa
                                ,3592877941 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765708      nrdconta
                                ,1           inpessoa
                                ,85119539904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 691224    nrdconta
                                ,1         inpessoa
                                ,161910211 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 683523      nrdconta
                                ,1           inpessoa
                                ,38586588806 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 468592     nrdconta
                                ,1          inpessoa
                                ,6109354961 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 384828     nrdconta
                                ,1          inpessoa
                                ,1178213900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 499366   nrdconta
                                ,2        inpessoa
                                ,26408953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 648540   nrdconta
                                ,2        inpessoa
                                ,24899461 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 251828      nrdconta
                                ,1           inpessoa
                                ,18376423894 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 896578     nrdconta
                                ,1          inpessoa
                                ,4516155907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 513237   nrdconta
                                ,2        inpessoa
                                ,19570627 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 625345      nrdconta
                                ,1           inpessoa
                                ,58551735934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 906840     nrdconta
                                ,1          inpessoa
                                ,9041719903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 486400   nrdconta
                                ,2        inpessoa
                                ,20769746 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 767638   nrdconta
                                ,2        inpessoa
                                ,33986890 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 646687      nrdconta
                                ,1           inpessoa
                                ,58609563049 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 724653   nrdconta
                                ,2        inpessoa
                                ,33729090 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 830860      nrdconta
                                ,1           inpessoa
                                ,93686650959 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 671681      nrdconta
                                ,1           inpessoa
                                ,87292041949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 209252     nrdconta
                                ,1          inpessoa
                                ,8068392955 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 840009      nrdconta
                                ,1           inpessoa
                                ,10276078969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 740004     nrdconta
                                ,1          inpessoa
                                ,7719164938 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 799700   nrdconta
                                ,2        inpessoa
                                ,84717925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 657310     nrdconta
                                ,1          inpessoa
                                ,9130529905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 473006    nrdconta
                                ,1         inpessoa
                                ,346655951 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 609340   nrdconta
                                ,2        inpessoa
                                ,24135913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 771309   nrdconta
                                ,2        inpessoa
                                ,19951766 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765929   nrdconta
                                ,2        inpessoa
                                ,31528255 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 229121      nrdconta
                                ,1           inpessoa
                                ,30412955806 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 882968     nrdconta
                                ,1          inpessoa
                                ,6844753918 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 182885   nrdconta
                                ,2        inpessoa
                                ,21164175 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 652415   nrdconta
                                ,2        inpessoa
                                ,20037929 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 634476     nrdconta
                                ,1          inpessoa
                                ,7632752986 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 433306     nrdconta
                                ,1          inpessoa
                                ,4859238907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 269387   nrdconta
                                ,2        inpessoa
                                ,85237402 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 653667      nrdconta
                                ,1           inpessoa
                                ,72060212987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 203076     nrdconta
                                ,1          inpessoa
                                ,6359730901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 594423   nrdconta
                                ,2        inpessoa
                                ,17461646 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 909785     nrdconta
                                ,1          inpessoa
                                ,7839032940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 540714     nrdconta
                                ,1          inpessoa
                                ,8630340983 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 373150     nrdconta
                                ,1          inpessoa
                                ,6166971982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 472050     nrdconta
                                ,1          inpessoa
                                ,5841588907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 657956   nrdconta
                                ,2        inpessoa
                                ,30348188 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 619450   nrdconta
                                ,2        inpessoa
                                ,20038011 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 645001      nrdconta
                                ,1           inpessoa
                                ,61360660925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 727717   nrdconta
                                ,2        inpessoa
                                ,33139837 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 509671     nrdconta
                                ,1          inpessoa
                                ,9297324991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 508128      nrdconta
                                ,1           inpessoa
                                ,72014679991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 318558   nrdconta
                                ,2        inpessoa
                                ,13756356 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 604526   nrdconta
                                ,2        inpessoa
                                ,12840896 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 509299     nrdconta
                                ,1          inpessoa
                                ,4811344928 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 666165      nrdconta
                                ,1           inpessoa
                                ,21801240906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 723088      nrdconta
                                ,1           inpessoa
                                ,61434989380 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 463906   nrdconta
                                ,2        inpessoa
                                ,18687449 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 632902   nrdconta
                                ,2        inpessoa
                                ,16462554 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 268658  nrdconta
                                ,2       inpessoa
                                ,5076174 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 296554      nrdconta
                                ,1           inpessoa
                                ,73958638953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 511846     nrdconta
                                ,1          inpessoa
                                ,5942262950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 386529      nrdconta
                                ,1           inpessoa
                                ,61205478949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 548162  nrdconta
                                ,2       inpessoa
                                ,1137430 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 581577  nrdconta
                                ,2       inpessoa
                                ,7139632 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 509531   nrdconta
                                ,2        inpessoa
                                ,12539492 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 477532   nrdconta
                                ,2        inpessoa
                                ,79370391 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 604054  nrdconta
                                ,2       inpessoa
                                ,3739942 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 551562     nrdconta
                                ,1          inpessoa
                                ,5700336910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 306177      nrdconta
                                ,1           inpessoa
                                ,35106972949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 629006     nrdconta
                                ,1          inpessoa
                                ,1488615985 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 649031   nrdconta
                                ,2        inpessoa
                                ,31330059 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 441058      nrdconta
                                ,1           inpessoa
                                ,41869273915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 658383     nrdconta
                                ,1          inpessoa
                                ,8342988996 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 370061    nrdconta
                                ,1         inpessoa
                                ,493447903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 929913   nrdconta
                                ,2        inpessoa
                                ,17762143 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 800074      nrdconta
                                ,1           inpessoa
                                ,10521112974 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 698750     nrdconta
                                ,1          inpessoa
                                ,9537149935 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 680290  nrdconta
                                ,2       inpessoa
                                ,7069777 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 726010      nrdconta
                                ,1           inpessoa
                                ,39965503915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 189286   nrdconta
                                ,2        inpessoa
                                ,23478700 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 972789     nrdconta
                                ,1          inpessoa
                                ,7617113927 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743054      nrdconta
                                ,1           inpessoa
                                ,12335235460 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 966355     nrdconta
                                ,1          inpessoa
                                ,7596149979 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 643920     nrdconta
                                ,1          inpessoa
                                ,8876261907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 611166    nrdconta
                                ,1         inpessoa
                                ,563972912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 899747     nrdconta
                                ,1          inpessoa
                                ,5869973937 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 738646      nrdconta
                                ,1           inpessoa
                                ,11231090952 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 563498     nrdconta
                                ,1          inpessoa
                                ,4415131905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 441350      nrdconta
                                ,1           inpessoa
                                ,57648620944 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 571520    nrdconta
                                ,1         inpessoa
                                ,366278959 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 739553   nrdconta
                                ,2        inpessoa
                                ,34014638 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 621722   nrdconta
                                ,2        inpessoa
                                ,18759257 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 556920  nrdconta
                                ,2       inpessoa
                                ,3686309 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 158828     nrdconta
                                ,1          inpessoa
                                ,4148288956 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 723886      nrdconta
                                ,1           inpessoa
                                ,12160177946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 167100   nrdconta
                                ,2        inpessoa
                                ,23759770 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 790656   nrdconta
                                ,2        inpessoa
                                ,34623498 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 589527     nrdconta
                                ,1          inpessoa
                                ,3720871916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 747661      nrdconta
                                ,1           inpessoa
                                ,93666861920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 225649     nrdconta
                                ,1          inpessoa
                                ,6784781988 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 317896    nrdconta
                                ,1         inpessoa
                                ,442688903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 468100   nrdconta
                                ,2        inpessoa
                                ,17589779 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 699993    nrdconta
                                ,1         inpessoa
                                ,529136945 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 443581      nrdconta
                                ,1           inpessoa
                                ,68405375953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 479268      nrdconta
                                ,1           inpessoa
                                ,10070644985 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 680958   nrdconta
                                ,2        inpessoa
                                ,27397340 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 567647      nrdconta
                                ,1           inpessoa
                                ,98975749053 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 642215      nrdconta
                                ,1           inpessoa
                                ,11766459943 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732095   nrdconta
                                ,2        inpessoa
                                ,33884045 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 796891   nrdconta
                                ,2        inpessoa
                                ,33394390 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 606618      nrdconta
                                ,1           inpessoa
                                ,49293788934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 551538   nrdconta
                                ,2        inpessoa
                                ,13508538 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 762350      nrdconta
                                ,1           inpessoa
                                ,11576425940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 207942     nrdconta
                                ,1          inpessoa
                                ,3208406975 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 355992     nrdconta
                                ,1          inpessoa
                                ,6768731971 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 745375   nrdconta
                                ,2        inpessoa
                                ,27629152 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 867802      nrdconta
                                ,1           inpessoa
                                ,10656481978 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735132     nrdconta
                                ,1          inpessoa
                                ,6180240930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735620      nrdconta
                                ,1           inpessoa
                                ,42192951949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 227056      nrdconta
                                ,1           inpessoa
                                ,63491087953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 431567   nrdconta
                                ,2        inpessoa
                                ,15872283 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732788   nrdconta
                                ,2        inpessoa
                                ,31987206 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 670731    nrdconta
                                ,1         inpessoa
                                ,909975906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 609544   nrdconta
                                ,2        inpessoa
                                ,27090882 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 843369     nrdconta
                                ,1          inpessoa
                                ,6259020929 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 716049      nrdconta
                                ,1           inpessoa
                                ,73970247934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 504114    nrdconta
                                ,1         inpessoa
                                ,521212910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 291412      nrdconta
                                ,1           inpessoa
                                ,44923082968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 642223      nrdconta
                                ,1           inpessoa
                                ,33082813844 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 625310     nrdconta
                                ,1          inpessoa
                                ,6860143916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 462608     nrdconta
                                ,1          inpessoa
                                ,9527386942 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 228109   nrdconta
                                ,2        inpessoa
                                ,11524440 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 759767     nrdconta
                                ,1          inpessoa
                                ,3098700971 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 235091      nrdconta
                                ,1           inpessoa
                                ,29374740982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 267287      nrdconta
                                ,1           inpessoa
                                ,59703970915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 166545     nrdconta
                                ,1          inpessoa
                                ,2705039945 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 600431   nrdconta
                                ,2        inpessoa
                                ,22429688 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732265     nrdconta
                                ,1          inpessoa
                                ,5119567975 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 391999   nrdconta
                                ,2        inpessoa
                                ,13587163 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 310000    nrdconta
                                ,1         inpessoa
                                ,835393950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 673862      nrdconta
                                ,1           inpessoa
                                ,68404930910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 872369      nrdconta
                                ,1           inpessoa
                                ,13455942407 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 198870     nrdconta
                                ,1          inpessoa
                                ,3733561961 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 451240   nrdconta
                                ,2        inpessoa
                                ,12390611 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 727709     nrdconta
                                ,1          inpessoa
                                ,9605249910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 730475   nrdconta
                                ,2        inpessoa
                                ,34018197 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 615730     nrdconta
                                ,1          inpessoa
                                ,9338516938 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 515337     nrdconta
                                ,1          inpessoa
                                ,5229659971 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 166219   nrdconta
                                ,2        inpessoa
                                ,72431976 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 382175     nrdconta
                                ,1          inpessoa
                                ,4276933900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 938912      nrdconta
                                ,1           inpessoa
                                ,80022369988 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 853623     nrdconta
                                ,1          inpessoa
                                ,6468421969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 515256   nrdconta
                                ,2        inpessoa
                                ,17053490 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 855189   nrdconta
                                ,2        inpessoa
                                ,36062605 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 165883      nrdconta
                                ,1           inpessoa
                                ,32271417953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 587419      nrdconta
                                ,1           inpessoa
                                ,72040700978 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 698415      nrdconta
                                ,1           inpessoa
                                ,12547394910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732966     nrdconta
                                ,1          inpessoa
                                ,9408314905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 912034   nrdconta
                                ,2        inpessoa
                                ,28906880 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 345016      nrdconta
                                ,1           inpessoa
                                ,53678702953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 694878      nrdconta
                                ,1           inpessoa
                                ,70277809258 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 646709     nrdconta
                                ,1          inpessoa
                                ,5400400965 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 514861     nrdconta
                                ,1          inpessoa
                                ,7059814957 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755095      nrdconta
                                ,1           inpessoa
                                ,68410662949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 530743     nrdconta
                                ,1          inpessoa
                                ,7711036973 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 665525      nrdconta
                                ,1           inpessoa
                                ,98887092915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 696056   nrdconta
                                ,2        inpessoa
                                ,24253222 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 625604      nrdconta
                                ,1           inpessoa
                                ,47744599845 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 733326     nrdconta
                                ,1          inpessoa
                                ,3957415993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 463183      nrdconta
                                ,1           inpessoa
                                ,72053208953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 813320   nrdconta
                                ,2        inpessoa
                                ,29954051 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 313076      nrdconta
                                ,1           inpessoa
                                ,35120703968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 822981   nrdconta
                                ,2        inpessoa
                                ,27191270 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 582980    nrdconta
                                ,1         inpessoa
                                ,517056992 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 655872   nrdconta
                                ,2        inpessoa
                                ,23667243 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 819522      nrdconta
                                ,1           inpessoa
                                ,10598664980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742384      nrdconta
                                ,1           inpessoa
                                ,36898796801 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 713023     nrdconta
                                ,1          inpessoa
                                ,6101545164 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 673587     nrdconta
                                ,1          inpessoa
                                ,7825911911 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 502065     nrdconta
                                ,1          inpessoa
                                ,5329834910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 806358      nrdconta
                                ,1           inpessoa
                                ,89687809949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 599034      nrdconta
                                ,1           inpessoa
                                ,92030610968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 542725     nrdconta
                                ,1          inpessoa
                                ,8459563960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743330     nrdconta
                                ,1          inpessoa
                                ,3277796914 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 510262     nrdconta
                                ,1          inpessoa
                                ,4838943970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 722227      nrdconta
                                ,1           inpessoa
                                ,27828824300 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 628433      nrdconta
                                ,1           inpessoa
                                ,94833591987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735647     nrdconta
                                ,1          inpessoa
                                ,8079666903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 511048  nrdconta
                                ,2       inpessoa
                                ,3587050 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 566748      nrdconta
                                ,1           inpessoa
                                ,92027580930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 529648    nrdconta
                                ,1         inpessoa
                                ,890134928 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 694010   nrdconta
                                ,2        inpessoa
                                ,30593445 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 694533   nrdconta
                                ,2        inpessoa
                                ,31066659 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 633291   nrdconta
                                ,2        inpessoa
                                ,30584457 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 382973     nrdconta
                                ,1          inpessoa
                                ,6933871908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 571660      nrdconta
                                ,1           inpessoa
                                ,47392282972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 722197     nrdconta
                                ,1          inpessoa
                                ,2092772970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 703575   nrdconta
                                ,2        inpessoa
                                ,19726049 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 633380   nrdconta
                                ,2        inpessoa
                                ,21560754 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 709662     nrdconta
                                ,1          inpessoa
                                ,2901657257 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 813036   nrdconta
                                ,2        inpessoa
                                ,26576632 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 739413     nrdconta
                                ,1          inpessoa
                                ,4538392901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 584053   nrdconta
                                ,2        inpessoa
                                ,84717925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 552992   nrdconta
                                ,2        inpessoa
                                ,13645165 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 450499     nrdconta
                                ,1          inpessoa
                                ,3737859922 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 749842     nrdconta
                                ,1          inpessoa
                                ,8881284952 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 822299     nrdconta
                                ,1          inpessoa
                                ,3430411971 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 792306   nrdconta
                                ,2        inpessoa
                                ,28735903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 757969     nrdconta
                                ,1          inpessoa
                                ,6736630436 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 399280   nrdconta
                                ,2        inpessoa
                                ,15807031 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 633089     nrdconta
                                ,1          inpessoa
                                ,4963549905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 782530     nrdconta
                                ,1          inpessoa
                                ,1207917060 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 797162     nrdconta
                                ,1          inpessoa
                                ,3958189903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 695530   nrdconta
                                ,2        inpessoa
                                ,29273147 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 713252      nrdconta
                                ,1           inpessoa
                                ,92027580930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 596280   nrdconta
                                ,2        inpessoa
                                ,28629032 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 489999     nrdconta
                                ,1          inpessoa
                                ,4195913977 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735272    nrdconta
                                ,1         inpessoa
                                ,349831980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 239739      nrdconta
                                ,1           inpessoa
                                ,98797077968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 517127      nrdconta
                                ,1           inpessoa
                                ,52032973987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 750433      nrdconta
                                ,1           inpessoa
                                ,80897991915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 819840   nrdconta
                                ,2        inpessoa
                                ,14603194 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 294802   nrdconta
                                ,2        inpessoa
                                ,10470252 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 319090    nrdconta
                                ,1         inpessoa
                                ,438767900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 865524      nrdconta
                                ,1           inpessoa
                                ,11650232888 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 676667   nrdconta
                                ,2        inpessoa
                                ,11235580 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 466964   nrdconta
                                ,2        inpessoa
                                ,15390249 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 600423     nrdconta
                                ,1          inpessoa
                                ,9337395916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 664790   nrdconta
                                ,2        inpessoa
                                ,24530570 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 514659   nrdconta
                                ,2        inpessoa
                                ,19987137 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 382035  nrdconta
                                ,2       inpessoa
                                ,1674533 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 617709      nrdconta
                                ,1           inpessoa
                                ,37553225878 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 519863   nrdconta
                                ,2        inpessoa
                                ,19066289 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 746100     nrdconta
                                ,1          inpessoa
                                ,8044069950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 588911      nrdconta
                                ,1           inpessoa
                                ,41148651870 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 712337      nrdconta
                                ,1           inpessoa
                                ,29568072934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 473090      nrdconta
                                ,1           inpessoa
                                ,94900680982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 729973   nrdconta
                                ,2        inpessoa
                                ,33951111 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 720798   nrdconta
                                ,2        inpessoa
                                ,23366410 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 733580   nrdconta
                                ,2        inpessoa
                                ,21851339 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 545180    nrdconta
                                ,1         inpessoa
                                ,367331993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725420    nrdconta
                                ,1         inpessoa
                                ,428059961 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 748528      nrdconta
                                ,1           inpessoa
                                ,11233536974 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 800872      nrdconta
                                ,1           inpessoa
                                ,11004348959 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 657530   nrdconta
                                ,2        inpessoa
                                ,21631427 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 671770     nrdconta
                                ,1          inpessoa
                                ,3590781920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 761303   nrdconta
                                ,2        inpessoa
                                ,83447276 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 729450     nrdconta
                                ,1          inpessoa
                                ,8428078963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 748471      nrdconta
                                ,1           inpessoa
                                ,71429808934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742643   nrdconta
                                ,2        inpessoa
                                ,29674916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 748820     nrdconta
                                ,1          inpessoa
                                ,8945757910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 689661      nrdconta
                                ,1           inpessoa
                                ,68398980915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 722669  nrdconta
                                ,2       inpessoa
                                ,6147520 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 813044   nrdconta
                                ,2        inpessoa
                                ,35301816 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 219266      nrdconta
                                ,1           inpessoa
                                ,43830390904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 194581      nrdconta
                                ,1           inpessoa
                                ,77966767787 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 769690      nrdconta
                                ,1           inpessoa
                                ,10278678980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 680931   nrdconta
                                ,2        inpessoa
                                ,76377613 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 780324     nrdconta
                                ,1          inpessoa
                                ,1020669900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 673250      nrdconta
                                ,1           inpessoa
                                ,89012658934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 740250     nrdconta
                                ,1          inpessoa
                                ,1747247995 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 760005     nrdconta
                                ,1          inpessoa
                                ,8915623975 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 823325   nrdconta
                                ,2        inpessoa
                                ,36514170 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735434     nrdconta
                                ,1          inpessoa
                                ,9779729925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 530190     nrdconta
                                ,1          inpessoa
                                ,1576880117 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 637041   nrdconta
                                ,2        inpessoa
                                ,21583362 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 385700     nrdconta
                                ,1          inpessoa
                                ,7871994948 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 711322     nrdconta
                                ,1          inpessoa
                                ,9116615905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 670421   nrdconta
                                ,2        inpessoa
                                ,29156616 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 748994      nrdconta
                                ,1           inpessoa
                                ,44828519904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 720763     nrdconta
                                ,1          inpessoa
                                ,4077525950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 522163     nrdconta
                                ,1          inpessoa
                                ,6744129902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 753637   nrdconta
                                ,2        inpessoa
                                ,20200949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 441570  nrdconta
                                ,2       inpessoa
                                ,5885103 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 209554     nrdconta
                                ,1          inpessoa
                                ,7704804979 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 608564     nrdconta
                                ,1          inpessoa
                                ,1772642924 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 780375      nrdconta
                                ,1           inpessoa
                                ,35157534949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 498068   nrdconta
                                ,2        inpessoa
                                ,19656780 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 574864      nrdconta
                                ,1           inpessoa
                                ,67041884953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 796000   nrdconta
                                ,2        inpessoa
                                ,29170868 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 730947     nrdconta
                                ,1          inpessoa
                                ,7656801901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 736090     nrdconta
                                ,1          inpessoa
                                ,6558923971 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 528706  nrdconta
                                ,2       inpessoa
                                ,2652070 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 663760   nrdconta
                                ,2        inpessoa
                                ,25118048 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 450561   nrdconta
                                ,2        inpessoa
                                ,14116061 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 833606     nrdconta
                                ,1          inpessoa
                                ,8529107977 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 768278   nrdconta
                                ,2        inpessoa
                                ,34803298 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 623253     nrdconta
                                ,1          inpessoa
                                ,8977813921 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 442550      nrdconta
                                ,1           inpessoa
                                ,92028241934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 813230     nrdconta
                                ,1          inpessoa
                                ,4876098913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 663573      nrdconta
                                ,1           inpessoa
                                ,87104300910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 343170  nrdconta
                                ,2       inpessoa
                                ,4230130 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 851647      nrdconta
                                ,1           inpessoa
                                ,15459286735 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 598682    nrdconta
                                ,1         inpessoa
                                ,567186911 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 692760      nrdconta
                                ,1           inpessoa
                                ,11755379935 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 697664     nrdconta
                                ,1          inpessoa
                                ,1812549997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 219851     nrdconta
                                ,1          inpessoa
                                ,5893236955 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 766992   nrdconta
                                ,2        inpessoa
                                ,32657798 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 305626      nrdconta
                                ,1           inpessoa
                                ,43938256915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 572489     nrdconta
                                ,1          inpessoa
                                ,8030438990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 150029      nrdconta
                                ,1           inpessoa
                                ,86424246991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 204471      nrdconta
                                ,1           inpessoa
                                ,71987231953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 500828      nrdconta
                                ,1           inpessoa
                                ,29275920982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725790      nrdconta
                                ,1           inpessoa
                                ,10443798982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 674540      nrdconta
                                ,1           inpessoa
                                ,93667388934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 718130   nrdconta
                                ,2        inpessoa
                                ,28074442 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 606499      nrdconta
                                ,1           inpessoa
                                ,53741820725 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 772810   nrdconta
                                ,2        inpessoa
                                ,19298183 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 466786     nrdconta
                                ,1          inpessoa
                                ,2609680996 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764353     nrdconta
                                ,1          inpessoa
                                ,7367480910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 384720     nrdconta
                                ,1          inpessoa
                                ,3499346907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 204048      nrdconta
                                ,1           inpessoa
                                ,68464665920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 534315      nrdconta
                                ,1           inpessoa
                                ,48522929904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 649147     nrdconta
                                ,1          inpessoa
                                ,6072754996 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 635529   nrdconta
                                ,2        inpessoa
                                ,72377906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 822779     nrdconta
                                ,1          inpessoa
                                ,1016382995 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 669237   nrdconta
                                ,2        inpessoa
                                ,18366847 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 929786     nrdconta
                                ,1          inpessoa
                                ,9784405954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 504220   nrdconta
                                ,2        inpessoa
                                ,26723391 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 649236     nrdconta
                                ,1          inpessoa
                                ,7074902942 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 738441   nrdconta
                                ,2        inpessoa
                                ,34140682 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 637335     nrdconta
                                ,1          inpessoa
                                ,4992514901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 543381     nrdconta
                                ,1          inpessoa
                                ,5410830903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 553450   nrdconta
                                ,2        inpessoa
                                ,17805137 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 831069     nrdconta
                                ,1          inpessoa
                                ,7185190940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 553999   nrdconta
                                ,2        inpessoa
                                ,15587078 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 649015      nrdconta
                                ,1           inpessoa
                                ,74967630987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 719102   nrdconta
                                ,2        inpessoa
                                ,33230027 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 202924      nrdconta
                                ,1           inpessoa
                                ,97033839987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 670049   nrdconta
                                ,2        inpessoa
                                ,27812175 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 681636   nrdconta
                                ,2        inpessoa
                                ,32044374 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 642851   nrdconta
                                ,2        inpessoa
                                ,26229722 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 617717     nrdconta
                                ,1          inpessoa
                                ,7652142962 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765198     nrdconta
                                ,1          inpessoa
                                ,4714119907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 718459     nrdconta
                                ,1          inpessoa
                                ,6373902960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 839906     nrdconta
                                ,1          inpessoa
                                ,8641834966 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 652296     nrdconta
                                ,1          inpessoa
                                ,5599487946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 488275   nrdconta
                                ,2        inpessoa
                                ,22737207 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 455580    nrdconta
                                ,1         inpessoa
                                ,598311971 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 761435     nrdconta
                                ,1          inpessoa
                                ,9264745963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 608599      nrdconta
                                ,1           inpessoa
                                ,10971790957 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 687286     nrdconta
                                ,1          inpessoa
                                ,7690087710 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 661040      nrdconta
                                ,1           inpessoa
                                ,86671600910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 772100     nrdconta
                                ,1          inpessoa
                                ,7559339905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 834688     nrdconta
                                ,1          inpessoa
                                ,5110153485 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 690856   nrdconta
                                ,2        inpessoa
                                ,32176754 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 665983      nrdconta
                                ,1           inpessoa
                                ,69197768987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 853062      nrdconta
                                ,1           inpessoa
                                ,12644783992 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 384143      nrdconta
                                ,1           inpessoa
                                ,67418686900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 229210  nrdconta
                                ,2       inpessoa
                                ,6921719 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 700215     nrdconta
                                ,1          inpessoa
                                ,4750257923 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 626694  nrdconta
                                ,2       inpessoa
                                ,1964354 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 777927   nrdconta
                                ,2        inpessoa
                                ,11642901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 644307      nrdconta
                                ,1           inpessoa
                                ,45273219949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 894397      nrdconta
                                ,1           inpessoa
                                ,30217076882 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 381179     nrdconta
                                ,1          inpessoa
                                ,8622412946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 477990     nrdconta
                                ,1          inpessoa
                                ,7179706981 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 543403  nrdconta
                                ,2       inpessoa
                                ,8689455 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 428175      nrdconta
                                ,1           inpessoa
                                ,64922677968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 929654      nrdconta
                                ,1           inpessoa
                                ,26020099890 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 661848      nrdconta
                                ,1           inpessoa
                                ,77101383904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 581720     nrdconta
                                ,1          inpessoa
                                ,5274724922 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 708976   nrdconta
                                ,2        inpessoa
                                ,11938551 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 383325      nrdconta
                                ,1           inpessoa
                                ,29117593972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 663441      nrdconta
                                ,1           inpessoa
                                ,10170364976 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 585106   nrdconta
                                ,2        inpessoa
                                ,21681514 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 729361      nrdconta
                                ,1           inpessoa
                                ,60987219987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 829013     nrdconta
                                ,1          inpessoa
                                ,1054893950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 466379      nrdconta
                                ,1           inpessoa
                                ,24846494870 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 404390      nrdconta
                                ,1           inpessoa
                                ,31249574900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 760781     nrdconta
                                ,1          inpessoa
                                ,3941137999 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 793841   nrdconta
                                ,2        inpessoa
                                ,13567221 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 726540      nrdconta
                                ,1           inpessoa
                                ,63280663920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 661961     nrdconta
                                ,1          inpessoa
                                ,2076102310 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 562831      nrdconta
                                ,1           inpessoa
                                ,63824906953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 202061      nrdconta
                                ,1           inpessoa
                                ,59995068915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 710105      nrdconta
                                ,1           inpessoa
                                ,68415745915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 714097     nrdconta
                                ,1          inpessoa
                                ,7797309922 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 690015     nrdconta
                                ,1          inpessoa
                                ,4645836919 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 642754      nrdconta
                                ,1           inpessoa
                                ,10971401993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 582786     nrdconta
                                ,1          inpessoa
                                ,4111277993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 473626     nrdconta
                                ,1          inpessoa
                                ,8216514980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 293377      nrdconta
                                ,1           inpessoa
                                ,76865401972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 660159   nrdconta
                                ,2        inpessoa
                                ,11991982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 750166     nrdconta
                                ,1          inpessoa
                                ,7960678995 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 619523    nrdconta
                                ,1         inpessoa
                                ,855860995 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 498769      nrdconta
                                ,1           inpessoa
                                ,79132898991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 589861     nrdconta
                                ,1          inpessoa
                                ,9557054956 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 383880   nrdconta
                                ,2        inpessoa
                                ,15584127 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 763195      nrdconta
                                ,1           inpessoa
                                ,67339565949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 618691   nrdconta
                                ,2        inpessoa
                                ,13547770 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 748404      nrdconta
                                ,1           inpessoa
                                ,61331287987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 835579      nrdconta
                                ,1           inpessoa
                                ,38404117934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 711381     nrdconta
                                ,1          inpessoa
                                ,5753855962 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 744719     nrdconta
                                ,1          inpessoa
                                ,5037447941 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 854174      nrdconta
                                ,1           inpessoa
                                ,38230488991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 605530      nrdconta
                                ,1           inpessoa
                                ,19583687847 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 707988  nrdconta
                                ,2       inpessoa
                                ,9025056 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 629847      nrdconta
                                ,1           inpessoa
                                ,17724959803 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 604780     nrdconta
                                ,1          inpessoa
                                ,6114867920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 720747   nrdconta
                                ,2        inpessoa
                                ,33317147 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 682349      nrdconta
                                ,1           inpessoa
                                ,66081700925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 307947      nrdconta
                                ,1           inpessoa
                                ,75095181991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 723169      nrdconta
                                ,1           inpessoa
                                ,12477143905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 716901     nrdconta
                                ,1          inpessoa
                                ,9092411981 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 618896      nrdconta
                                ,1           inpessoa
                                ,93682646949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 542091      nrdconta
                                ,1           inpessoa
                                ,42155207972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742953     nrdconta
                                ,1          inpessoa
                                ,1110508476 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 662526     nrdconta
                                ,1          inpessoa
                                ,7750001913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 647098   nrdconta
                                ,2        inpessoa
                                ,31028561 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 508110   nrdconta
                                ,2        inpessoa
                                ,18446554 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 590290   nrdconta
                                ,2        inpessoa
                                ,26715840 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 832987  nrdconta
                                ,2       inpessoa
                                ,8990505 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 518859      nrdconta
                                ,1           inpessoa
                                ,89089120963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 440094      nrdconta
                                ,1           inpessoa
                                ,82448159904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 611476   nrdconta
                                ,2        inpessoa
                                ,27460027 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 428213    nrdconta
                                ,1         inpessoa
                                ,738753920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 545953     nrdconta
                                ,1          inpessoa
                                ,3418140912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755770     nrdconta
                                ,1          inpessoa
                                ,4637870992 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 165913      nrdconta
                                ,1           inpessoa
                                ,48061247968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 659452      nrdconta
                                ,1           inpessoa
                                ,10845471988 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 626112      nrdconta
                                ,1           inpessoa
                                ,72055499904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 722308   nrdconta
                                ,2        inpessoa
                                ,17525265 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 509566    nrdconta
                                ,1         inpessoa
                                ,413022900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 696293      nrdconta
                                ,1           inpessoa
                                ,39961826949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 317225     nrdconta
                                ,1          inpessoa
                                ,3694234969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 713449     nrdconta
                                ,1          inpessoa
                                ,7415961994 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 620165      nrdconta
                                ,1           inpessoa
                                ,54078326072 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 752789     nrdconta
                                ,1          inpessoa
                                ,7966364941 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 405906      nrdconta
                                ,1           inpessoa
                                ,31255515953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 454478   nrdconta
                                ,2        inpessoa
                                ,85306827 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 559199     nrdconta
                                ,1          inpessoa
                                ,9745673960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 309478     nrdconta
                                ,1          inpessoa
                                ,6110918954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 680117      nrdconta
                                ,1           inpessoa
                                ,10647550970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 218014   nrdconta
                                ,2        inpessoa
                                ,23325829 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 389625      nrdconta
                                ,1           inpessoa
                                ,79181783949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 498246    nrdconta
                                ,1         inpessoa
                                ,797769900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 200492     nrdconta
                                ,1          inpessoa
                                ,3944345959 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754420   nrdconta
                                ,2        inpessoa
                                ,20403398 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 239828     nrdconta
                                ,1          inpessoa
                                ,9206731980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725048      nrdconta
                                ,1           inpessoa
                                ,11045666998 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 978922    nrdconta
                                ,1         inpessoa
                                ,342125907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 153826      nrdconta
                                ,1           inpessoa
                                ,89046609987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 253162      nrdconta
                                ,1           inpessoa
                                ,19362293900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725129      nrdconta
                                ,1           inpessoa
                                ,70017368219 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 486531     nrdconta
                                ,1          inpessoa
                                ,9202251959 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 821497   nrdconta
                                ,2        inpessoa
                                ,32441337 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 590525     nrdconta
                                ,1          inpessoa
                                ,5277013946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 737178     nrdconta
                                ,1          inpessoa
                                ,4603425929 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 642770      nrdconta
                                ,1           inpessoa
                                ,65796187953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 851779     nrdconta
                                ,1          inpessoa
                                ,7657966947 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 339636    nrdconta
                                ,1         inpessoa
                                ,890467900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725498   nrdconta
                                ,2        inpessoa
                                ,13106045 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 646148   nrdconta
                                ,2        inpessoa
                                ,31222191 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 692000     nrdconta
                                ,1          inpessoa
                                ,7137115900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 661244     nrdconta
                                ,1          inpessoa
                                ,3671834986 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 914720   nrdconta
                                ,2        inpessoa
                                ,14461633 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 887870     nrdconta
                                ,1          inpessoa
                                ,5421647951 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 351520      nrdconta
                                ,1           inpessoa
                                ,89018290963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 830658    nrdconta
                                ,1         inpessoa
                                ,536740909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 945455      nrdconta
                                ,1           inpessoa
                                ,44729790987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 604186   nrdconta
                                ,2        inpessoa
                                ,26253180 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 713198    nrdconta
                                ,1         inpessoa
                                ,600133974 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 653179   nrdconta
                                ,2        inpessoa
                                ,24504929 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 767204      nrdconta
                                ,1           inpessoa
                                ,15155861977 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 216429     nrdconta
                                ,1          inpessoa
                                ,4811760980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 229563     nrdconta
                                ,1          inpessoa
                                ,3411840986 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 318841    nrdconta
                                ,1         inpessoa
                                ,500732906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 686573  nrdconta
                                ,2       inpessoa
                                ,8393824 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 468177     nrdconta
                                ,1          inpessoa
                                ,8603376930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 517020    nrdconta
                                ,1         inpessoa
                                ,401073963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 867586     nrdconta
                                ,1          inpessoa
                                ,4254509960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 590533      nrdconta
                                ,1           inpessoa
                                ,62685163972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 559113     nrdconta
                                ,1          inpessoa
                                ,7906816684 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 744832      nrdconta
                                ,1           inpessoa
                                ,35362075888 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 269930      nrdconta
                                ,1           inpessoa
                                ,79189725972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 631973     nrdconta
                                ,1          inpessoa
                                ,3200554932 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 631868      nrdconta
                                ,1           inpessoa
                                ,97029033949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 778915   nrdconta
                                ,2        inpessoa
                                ,35249667 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 911151   nrdconta
                                ,2        inpessoa
                                ,39630772 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 449229    nrdconta
                                ,1         inpessoa
                                ,764324918 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 641200   nrdconta
                                ,2        inpessoa
                                ,31037615 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 766348      nrdconta
                                ,1           inpessoa
                                ,10930258401 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 697036   nrdconta
                                ,2        inpessoa
                                ,29239912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 487341   nrdconta
                                ,2        inpessoa
                                ,22368437 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 492566   nrdconta
                                ,2        inpessoa
                                ,26042207 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 752959      nrdconta
                                ,1           inpessoa
                                ,93690940915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 331716     nrdconta
                                ,1          inpessoa
                                ,5149986950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 640590     nrdconta
                                ,1          inpessoa
                                ,4956212933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 456705     nrdconta
                                ,1          inpessoa
                                ,7267581919 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 381829    nrdconta
                                ,1         inpessoa
                                ,623774933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 661295      nrdconta
                                ,1           inpessoa
                                ,41925211991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 727911     nrdconta
                                ,1          inpessoa
                                ,8030176937 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 699780    nrdconta
                                ,1         inpessoa
                                ,935240993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 771686   nrdconta
                                ,2        inpessoa
                                ,21197903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 467847      nrdconta
                                ,1           inpessoa
                                ,71975985915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 670189   nrdconta
                                ,2        inpessoa
                                ,30917227 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 774588     nrdconta
                                ,1          inpessoa
                                ,3705107984 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 606847     nrdconta
                                ,1          inpessoa
                                ,7910498926 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 633275    nrdconta
                                ,1         inpessoa
                                ,557313929 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 779156      nrdconta
                                ,1           inpessoa
                                ,64215660904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 772410      nrdconta
                                ,1           inpessoa
                                ,61314307991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 446246     nrdconta
                                ,1          inpessoa
                                ,6242424983 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 158488      nrdconta
                                ,1           inpessoa
                                ,18083870900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 670766      nrdconta
                                ,1           inpessoa
                                ,11899667946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743569      nrdconta
                                ,1           inpessoa
                                ,85123323953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 307181      nrdconta
                                ,1           inpessoa
                                ,37976788949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 554170     nrdconta
                                ,1          inpessoa
                                ,5443144928 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 964131   nrdconta
                                ,2        inpessoa
                                ,23433116 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 652776     nrdconta
                                ,1          inpessoa
                                ,8521830971 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 682365   nrdconta
                                ,2        inpessoa
                                ,29302044 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 702358     nrdconta
                                ,1          inpessoa
                                ,6449102918 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 454516      nrdconta
                                ,1           inpessoa
                                ,38074176991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725056   nrdconta
                                ,2        inpessoa
                                ,33575958 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 516538      nrdconta
                                ,1           inpessoa
                                ,22545344915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 853399     nrdconta
                                ,1          inpessoa
                                ,1311222740 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 381543     nrdconta
                                ,1          inpessoa
                                ,2710181940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 733431     nrdconta
                                ,1          inpessoa
                                ,7363318913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 589918      nrdconta
                                ,1           inpessoa
                                ,75547350982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 505862   nrdconta
                                ,2        inpessoa
                                ,22507522 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743283      nrdconta
                                ,1           inpessoa
                                ,37984381968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 585637      nrdconta
                                ,1           inpessoa
                                ,46103295904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 381411      nrdconta
                                ,1           inpessoa
                                ,24809438953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 905291      nrdconta
                                ,1           inpessoa
                                ,13163875939 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 559687     nrdconta
                                ,1          inpessoa
                                ,5926027969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754390      nrdconta
                                ,1           inpessoa
                                ,37768719972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 699489   nrdconta
                                ,2        inpessoa
                                ,31746721 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 588296   nrdconta
                                ,2        inpessoa
                                ,18304266 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 664278   nrdconta
                                ,2        inpessoa
                                ,20196115 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 654159     nrdconta
                                ,1          inpessoa
                                ,9622732950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 589705    nrdconta
                                ,1         inpessoa
                                ,604422989 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 560499      nrdconta
                                ,1           inpessoa
                                ,42125359987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 668877      nrdconta
                                ,1           inpessoa
                                ,10080458963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 593141     nrdconta
                                ,1          inpessoa
                                ,6190011608 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 312193   nrdconta
                                ,2        inpessoa
                                ,80111180 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 504718      nrdconta
                                ,1           inpessoa
                                ,60981375367 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 663018   nrdconta
                                ,2        inpessoa
                                ,20644257 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 522171     nrdconta
                                ,1          inpessoa
                                ,8649012914 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 202088      nrdconta
                                ,1           inpessoa
                                ,50819267953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 206644      nrdconta
                                ,1           inpessoa
                                ,70317805274 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 451517   nrdconta
                                ,2        inpessoa
                                ,15309463 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 378062     nrdconta
                                ,1          inpessoa
                                ,7875785928 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 536660      nrdconta
                                ,1           inpessoa
                                ,97004391949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 251313   nrdconta
                                ,2        inpessoa
                                ,11708858 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 721468   nrdconta
                                ,2        inpessoa
                                ,10470252 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 339083      nrdconta
                                ,1           inpessoa
                                ,49161458953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 740276   nrdconta
                                ,2        inpessoa
                                ,21598663 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735370   nrdconta
                                ,2        inpessoa
                                ,20435083 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 706035   nrdconta
                                ,2        inpessoa
                                ,20160320 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 717711   nrdconta
                                ,2        inpessoa
                                ,18731871 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 751294     nrdconta
                                ,1          inpessoa
                                ,7241680952 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 451878   nrdconta
                                ,2        inpessoa
                                ,10699923 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 740640     nrdconta
                                ,1          inpessoa
                                ,7627344930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 716723   nrdconta
                                ,2        inpessoa
                                ,32921014 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 335134      nrdconta
                                ,1           inpessoa
                                ,95238905068 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 597520   nrdconta
                                ,2        inpessoa
                                ,19964995 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 739235     nrdconta
                                ,1          inpessoa
                                ,5616841978 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 800015     nrdconta
                                ,1          inpessoa
                                ,7340217983 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 631507   nrdconta
                                ,2        inpessoa
                                ,28431772 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732397   nrdconta
                                ,2        inpessoa
                                ,33944388 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 472689   nrdconta
                                ,2        inpessoa
                                ,20525650 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 748870   nrdconta
                                ,2        inpessoa
                                ,13011687 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 217441      nrdconta
                                ,1           inpessoa
                                ,80367488949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 932841      nrdconta
                                ,1           inpessoa
                                ,11224563956 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 319740   nrdconta
                                ,2        inpessoa
                                ,13650836 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 985791     nrdconta
                                ,1          inpessoa
                                ,2012366996 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 514667      nrdconta
                                ,1           inpessoa
                                ,41711300004 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 485586      nrdconta
                                ,1           inpessoa
                                ,82257469968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 615552   nrdconta
                                ,2        inpessoa
                                ,29468462 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 793620      nrdconta
                                ,1           inpessoa
                                ,10989899969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 763152     nrdconta
                                ,1          inpessoa
                                ,5680969912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 615897     nrdconta
                                ,1          inpessoa
                                ,7499720926 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 599123   nrdconta
                                ,2        inpessoa
                                ,18598024 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 767867      nrdconta
                                ,1           inpessoa
                                ,68412452968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 468622      nrdconta
                                ,1           inpessoa
                                ,55740448972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 738026      nrdconta
                                ,1           inpessoa
                                ,80764118900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 403075      nrdconta
                                ,1           inpessoa
                                ,65661400934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 392316      nrdconta
                                ,1           inpessoa
                                ,61881953904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 235237   nrdconta
                                ,2        inpessoa
                                ,22529343 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 632066     nrdconta
                                ,1          inpessoa
                                ,8909389974 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 631485   nrdconta
                                ,2        inpessoa
                                ,23285793 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 509361      nrdconta
                                ,1           inpessoa
                                ,10813525900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 440809   nrdconta
                                ,2        inpessoa
                                ,13518914 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 650285     nrdconta
                                ,1          inpessoa
                                ,1483274942 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 194298     nrdconta
                                ,1          inpessoa
                                ,1091400954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 768979     nrdconta
                                ,1          inpessoa
                                ,1851191909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 699020   nrdconta
                                ,2        inpessoa
                                ,33025202 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743690    nrdconta
                                ,1         inpessoa
                                ,621783935 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 498270      nrdconta
                                ,1           inpessoa
                                ,54306604934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 676268   nrdconta
                                ,2        inpessoa
                                ,30437443 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 658596     nrdconta
                                ,1          inpessoa
                                ,9457892976 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 332747     nrdconta
                                ,1          inpessoa
                                ,7267577997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 680982   nrdconta
                                ,2        inpessoa
                                ,32597259 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765945   nrdconta
                                ,2        inpessoa
                                ,33789106 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 833754    nrdconta
                                ,1         inpessoa
                                ,424003929 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 723258   nrdconta
                                ,2        inpessoa
                                ,31787315 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 409553     nrdconta
                                ,1          inpessoa
                                ,6047931979 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 428841   nrdconta
                                ,2        inpessoa
                                ,25100399 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 762938      nrdconta
                                ,1           inpessoa
                                ,32739832800 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 663484     nrdconta
                                ,1          inpessoa
                                ,6424828966 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 387983      nrdconta
                                ,1           inpessoa
                                ,82180806949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 798860     nrdconta
                                ,1          inpessoa
                                ,4811823907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 722960   nrdconta
                                ,2        inpessoa
                                ,31423229 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743160     nrdconta
                                ,1          inpessoa
                                ,7140691916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 488208      nrdconta
                                ,1           inpessoa
                                ,43994830915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 339210   nrdconta
                                ,2        inpessoa
                                ,23993411 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 678252   nrdconta
                                ,2        inpessoa
                                ,26877531 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 875783     nrdconta
                                ,1          inpessoa
                                ,8716430905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 723371      nrdconta
                                ,1           inpessoa
                                ,72028742968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 567701   nrdconta
                                ,2        inpessoa
                                ,17739520 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 216160   nrdconta
                                ,2        inpessoa
                                ,24007026 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 830402     nrdconta
                                ,1          inpessoa
                                ,3000599908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 520667  nrdconta
                                ,2       inpessoa
                                ,7646282 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 314315      nrdconta
                                ,1           inpessoa
                                ,72733969900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 663859     nrdconta
                                ,1          inpessoa
                                ,6404888971 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 850250   nrdconta
                                ,2        inpessoa
                                ,37127043 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 756717      nrdconta
                                ,1           inpessoa
                                ,12668458951 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 723630      nrdconta
                                ,1           inpessoa
                                ,89162030906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 923443     nrdconta
                                ,1          inpessoa
                                ,9128185900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 290424      nrdconta
                                ,1           inpessoa
                                ,60668121904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 443433    nrdconta
                                ,1         inpessoa
                                ,412982927 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 718203      nrdconta
                                ,1           inpessoa
                                ,65712803968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 652660      nrdconta
                                ,1           inpessoa
                                ,98799223953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 573043      nrdconta
                                ,1           inpessoa
                                ,10104722916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 783137     nrdconta
                                ,1          inpessoa
                                ,6681205925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 507148     nrdconta
                                ,1          inpessoa
                                ,7520509907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 567205   nrdconta
                                ,2        inpessoa
                                ,26702586 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 381420     nrdconta
                                ,1          inpessoa
                                ,8793370954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 235270      nrdconta
                                ,1           inpessoa
                                ,94773416904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 584908     nrdconta
                                ,1          inpessoa
                                ,2898438391 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 634999   nrdconta
                                ,2        inpessoa
                                ,10978282 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 521442  nrdconta
                                ,2       inpessoa
                                ,8821136 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 632007  nrdconta
                                ,2       inpessoa
                                ,9430722 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 441724      nrdconta
                                ,1           inpessoa
                                ,29340756991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 502200   nrdconta
                                ,2        inpessoa
                                ,26650925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755109      nrdconta
                                ,1           inpessoa
                                ,12108572945 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 724254   nrdconta
                                ,2        inpessoa
                                ,27624175 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 800775     nrdconta
                                ,1          inpessoa
                                ,5401501340 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 681318   nrdconta
                                ,2        inpessoa
                                ,25161623 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 606596      nrdconta
                                ,1           inpessoa
                                ,11852475994 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 196940      nrdconta
                                ,1           inpessoa
                                ,65677048968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 888958   nrdconta
                                ,2        inpessoa
                                ,12149538 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 702773   nrdconta
                                ,2        inpessoa
                                ,95806048 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 654140      nrdconta
                                ,1           inpessoa
                                ,10402375920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 484695     nrdconta
                                ,1          inpessoa
                                ,9100705985 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 522961     nrdconta
                                ,1          inpessoa
                                ,9586443906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765953     nrdconta
                                ,1          inpessoa
                                ,7472974951 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 963275     nrdconta
                                ,1          inpessoa
                                ,5149986950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 651990      nrdconta
                                ,1           inpessoa
                                ,68517017900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 627151   nrdconta
                                ,2        inpessoa
                                ,29438581 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 307688     nrdconta
                                ,1          inpessoa
                                ,4379207986 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 751057  nrdconta
                                ,2       inpessoa
                                ,5859050 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 659070   nrdconta
                                ,2        inpessoa
                                ,11167882 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 579920      nrdconta
                                ,1           inpessoa
                                ,42192501900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 599344      nrdconta
                                ,1           inpessoa
                                ,40974409855 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 548154     nrdconta
                                ,1          inpessoa
                                ,6811195940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 514918      nrdconta
                                ,1           inpessoa
                                ,90130057991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 228273     nrdconta
                                ,1          inpessoa
                                ,7619633910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 800686      nrdconta
                                ,1           inpessoa
                                ,22009722884 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 760498      nrdconta
                                ,1           inpessoa
                                ,82178453953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 656739     nrdconta
                                ,1          inpessoa
                                ,2130380999 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 649961      nrdconta
                                ,1           inpessoa
                                ,28250230949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 191132      nrdconta
                                ,1           inpessoa
                                ,82152454987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 427896      nrdconta
                                ,1           inpessoa
                                ,46976256920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 343340     nrdconta
                                ,1          inpessoa
                                ,8865238933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 419117   nrdconta
                                ,2        inpessoa
                                ,25105058 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 153788      nrdconta
                                ,1           inpessoa
                                ,79199542900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 331872   nrdconta
                                ,2        inpessoa
                                ,24709451 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 640964     nrdconta
                                ,1          inpessoa
                                ,8612873983 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 521906     nrdconta
                                ,1          inpessoa
                                ,5193339930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 772828   nrdconta
                                ,2        inpessoa
                                ,28176025 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 758159   nrdconta
                                ,2        inpessoa
                                ,34498581 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 666513      nrdconta
                                ,1           inpessoa
                                ,98857150968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 723649      nrdconta
                                ,1           inpessoa
                                ,12161627945 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 628913   nrdconta
                                ,2        inpessoa
                                ,30263568 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 507326     nrdconta
                                ,1          inpessoa
                                ,9475197931 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 429104      nrdconta
                                ,1           inpessoa
                                ,95634746949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 612839   nrdconta
                                ,2        inpessoa
                                ,27680478 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 719692      nrdconta
                                ,1           inpessoa
                                ,76761339987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 607177     nrdconta
                                ,1          inpessoa
                                ,2103056906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 682160     nrdconta
                                ,1          inpessoa
                                ,4147861300 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743267    nrdconta
                                ,1         inpessoa
                                ,500539901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 624624     nrdconta
                                ,1          inpessoa
                                ,1520301901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 464503  nrdconta
                                ,2       inpessoa
                                ,5317362 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 453625      nrdconta
                                ,1           inpessoa
                                ,68466285920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 319104     nrdconta
                                ,1          inpessoa
                                ,1997026082 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 737372   nrdconta
                                ,2        inpessoa
                                ,81604381 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725269   nrdconta
                                ,2        inpessoa
                                ,26240984 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 852708      nrdconta
                                ,1           inpessoa
                                ,77034678391 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 477567      nrdconta
                                ,1           inpessoa
                                ,71981330968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 656402   nrdconta
                                ,2        inpessoa
                                ,21962177 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743755      nrdconta
                                ,1           inpessoa
                                ,50168487934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 460133   nrdconta
                                ,2        inpessoa
                                ,14120948 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 666467   nrdconta
                                ,2        inpessoa
                                ,25228007 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 332518      nrdconta
                                ,1           inpessoa
                                ,59238046034 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 789119   nrdconta
                                ,2        inpessoa
                                ,32656145 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 664030      nrdconta
                                ,1           inpessoa
                                ,66518440910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 702617      nrdconta
                                ,1           inpessoa
                                ,85098191904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 913650   nrdconta
                                ,2        inpessoa
                                ,10192761 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 960381     nrdconta
                                ,1          inpessoa
                                ,6860143916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 779393     nrdconta
                                ,1          inpessoa
                                ,9473806477 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755869     nrdconta
                                ,1          inpessoa
                                ,5023940993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 536407     nrdconta
                                ,1          inpessoa
                                ,8140948993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 796433     nrdconta
                                ,1          inpessoa
                                ,4933489998 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 841188   nrdconta
                                ,2        inpessoa
                                ,35796498 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725994     nrdconta
                                ,1          inpessoa
                                ,6151491971 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 568015     nrdconta
                                ,1          inpessoa
                                ,5048659945 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 739014      nrdconta
                                ,1           inpessoa
                                ,93668740968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 726699     nrdconta
                                ,1          inpessoa
                                ,4075816931 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 547522     nrdconta
                                ,1          inpessoa
                                ,1726653960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 629308  nrdconta
                                ,2       inpessoa
                                ,9007316 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735930    nrdconta
                                ,1         inpessoa
                                ,459451952 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 556998      nrdconta
                                ,1           inpessoa
                                ,24826707991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 697125     nrdconta
                                ,1          inpessoa
                                ,4937164910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 724092   nrdconta
                                ,2        inpessoa
                                ,22482779 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 720410   nrdconta
                                ,2        inpessoa
                                ,19994316 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 557340   nrdconta
                                ,2        inpessoa
                                ,18936418 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 313289      nrdconta
                                ,1           inpessoa
                                ,64064905920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742627      nrdconta
                                ,1           inpessoa
                                ,22686628880 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 235288   nrdconta
                                ,2        inpessoa
                                ,11876561 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 448001   nrdconta
                                ,2        inpessoa
                                ,15209391 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 749737     nrdconta
                                ,1          inpessoa
                                ,8579707986 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754056     nrdconta
                                ,1          inpessoa
                                ,2902515081 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 655520   nrdconta
                                ,2        inpessoa
                                ,31063610 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 625574   nrdconta
                                ,2        inpessoa
                                ,23244276 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 614181      nrdconta
                                ,1           inpessoa
                                ,72047917972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 216011      nrdconta
                                ,1           inpessoa
                                ,71275096972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 409073      nrdconta
                                ,1           inpessoa
                                ,58606653934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 433071     nrdconta
                                ,1          inpessoa
                                ,8704097947 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 506524      nrdconta
                                ,1           inpessoa
                                ,81565100972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 737712    nrdconta
                                ,1         inpessoa
                                ,637206983 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 669164     nrdconta
                                ,1          inpessoa
                                ,7511631983 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742740     nrdconta
                                ,1          inpessoa
                                ,4247820907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 385352      nrdconta
                                ,1           inpessoa
                                ,90245202900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 650331  nrdconta
                                ,2       inpessoa
                                ,8965347 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 318299     nrdconta
                                ,1          inpessoa
                                ,3224589000 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 390283     nrdconta
                                ,1          inpessoa
                                ,1100369996 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 706922      nrdconta
                                ,1           inpessoa
                                ,71997776987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 641758     nrdconta
                                ,1          inpessoa
                                ,3431629970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 505331      nrdconta
                                ,1           inpessoa
                                ,55603467991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 331627      nrdconta
                                ,1           inpessoa
                                ,74315544949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 553212     nrdconta
                                ,1          inpessoa
                                ,4200591995 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 297690      nrdconta
                                ,1           inpessoa
                                ,79172512920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 596922      nrdconta
                                ,1           inpessoa
                                ,56028520934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 891754     nrdconta
                                ,1          inpessoa
                                ,2963883196 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 777110      nrdconta
                                ,1           inpessoa
                                ,93298510025 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 647128  nrdconta
                                ,2       inpessoa
                                ,7668632 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 387355     nrdconta
                                ,1          inpessoa
                                ,6432059933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 511838    nrdconta
                                ,1         inpessoa
                                ,389603970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 721484   nrdconta
                                ,2        inpessoa
                                ,28409251 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 676594      nrdconta
                                ,1           inpessoa
                                ,38104210904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 713511      nrdconta
                                ,1           inpessoa
                                ,85121100906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 956473   nrdconta
                                ,2        inpessoa
                                ,40084970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 591890      nrdconta
                                ,1           inpessoa
                                ,38939217888 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 797782     nrdconta
                                ,1          inpessoa
                                ,8612873983 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 376280   nrdconta
                                ,2        inpessoa
                                ,10470252 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 649244      nrdconta
                                ,1           inpessoa
                                ,10058074937 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 717940   nrdconta
                                ,2        inpessoa
                                ,26868900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 756881     nrdconta
                                ,1          inpessoa
                                ,3056380928 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 342416      nrdconta
                                ,1           inpessoa
                                ,35177403904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 580570   nrdconta
                                ,2        inpessoa
                                ,84717925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 748250   nrdconta
                                ,2        inpessoa
                                ,23940728 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 530212     nrdconta
                                ,1          inpessoa
                                ,3821574941 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 486990   nrdconta
                                ,2        inpessoa
                                ,22331974 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 892734     nrdconta
                                ,1          inpessoa
                                ,3802697910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 964778    nrdconta
                                ,1         inpessoa
                                ,575083999 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 662259     nrdconta
                                ,1          inpessoa
                                ,8611144937 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 594547     nrdconta
                                ,1          inpessoa
                                ,9683673996 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 733660      nrdconta
                                ,1           inpessoa
                                ,32706287810 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 332429     nrdconta
                                ,1          inpessoa
                                ,4703288940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 772720   nrdconta
                                ,2        inpessoa
                                ,35075819 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 519677   nrdconta
                                ,2        inpessoa
                                ,21923000 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 722340     nrdconta
                                ,1          inpessoa
                                ,4213425959 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 759422     nrdconta
                                ,1          inpessoa
                                ,3252474042 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 757233   nrdconta
                                ,2        inpessoa
                                ,17059343 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743119      nrdconta
                                ,1           inpessoa
                                ,46683089949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 652563   nrdconta
                                ,2        inpessoa
                                ,30942307 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 597155   nrdconta
                                ,2        inpessoa
                                ,28754975 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 239631     nrdconta
                                ,1          inpessoa
                                ,6489268930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 749990      nrdconta
                                ,1           inpessoa
                                ,14810692922 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 954756   nrdconta
                                ,2        inpessoa
                                ,32950281 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 870404   nrdconta
                                ,2        inpessoa
                                ,32551824 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 216810   nrdconta
                                ,2        inpessoa
                                ,21062465 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 507377 nrdconta
                                ,2      inpessoa
                                ,77724  nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 699438    nrdconta
                                ,1         inpessoa
                                ,675293995 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 512206  nrdconta
                                ,2       inpessoa
                                ,6987141 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 753769      nrdconta
                                ,1           inpessoa
                                ,11517354935 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 493325   nrdconta
                                ,2        inpessoa
                                ,17724085 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 606561   nrdconta
                                ,2        inpessoa
                                ,29083554 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 653683     nrdconta
                                ,1          inpessoa
                                ,4962801988 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 709999     nrdconta
                                ,1          inpessoa
                                ,3620500908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 684180      nrdconta
                                ,1           inpessoa
                                ,12128553962 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 677086     nrdconta
                                ,1          inpessoa
                                ,4592582900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 672742     nrdconta
                                ,1          inpessoa
                                ,6162333965 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 662070   nrdconta
                                ,2        inpessoa
                                ,31827893 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 737100      nrdconta
                                ,1           inpessoa
                                ,86281280504 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 608904     nrdconta
                                ,1          inpessoa
                                ,1957173920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764620     nrdconta
                                ,1          inpessoa
                                ,2781128384 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 294446      nrdconta
                                ,1           inpessoa
                                ,97004391949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 453498      nrdconta
                                ,1           inpessoa
                                ,52342468920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 618837   nrdconta
                                ,2        inpessoa
                                ,29905946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 733636     nrdconta
                                ,1          inpessoa
                                ,8762188933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 709859     nrdconta
                                ,1          inpessoa
                                ,3451986973 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 167401     nrdconta
                                ,1          inpessoa
                                ,1632439999 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 905747      nrdconta
                                ,1           inpessoa
                                ,73528749920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 693456   nrdconta
                                ,2        inpessoa
                                ,23903745 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 310115      nrdconta
                                ,1           inpessoa
                                ,42049687915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 384763   nrdconta
                                ,2        inpessoa
                                ,16543348 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 491934   nrdconta
                                ,2        inpessoa
                                ,24494084 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 486191   nrdconta
                                ,2        inpessoa
                                ,19515120 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 817996     nrdconta
                                ,1          inpessoa
                                ,7408907947 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 582581      nrdconta
                                ,1           inpessoa
                                ,17337533896 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 729159      nrdconta
                                ,1           inpessoa
                                ,93682166904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 219371      nrdconta
                                ,1           inpessoa
                                ,56012411049 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754854     nrdconta
                                ,1          inpessoa
                                ,9074418902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 228818      nrdconta
                                ,1           inpessoa
                                ,68379765915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 696366     nrdconta
                                ,1          inpessoa
                                ,6745719916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 814024     nrdconta
                                ,1          inpessoa
                                ,5597414992 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 464813   nrdconta
                                ,2        inpessoa
                                ,19307498 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 166790     nrdconta
                                ,1          inpessoa
                                ,4513332921 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 303666     nrdconta
                                ,1          inpessoa
                                ,8084268937 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 733610     nrdconta
                                ,1          inpessoa
                                ,5474300948 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 429708   nrdconta
                                ,2        inpessoa
                                ,22438300 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 377481   nrdconta
                                ,2        inpessoa
                                ,16570415 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 660841      nrdconta
                                ,1           inpessoa
                                ,50820311987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742848     nrdconta
                                ,1          inpessoa
                                ,4381683994 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 621510      nrdconta
                                ,1           inpessoa
                                ,10474537978 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 154199      nrdconta
                                ,1           inpessoa
                                ,60957603991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 545031    nrdconta
                                ,1         inpessoa
                                ,518031942 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 761516     nrdconta
                                ,1          inpessoa
                                ,6276855367 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725471    nrdconta
                                ,1         inpessoa
                                ,729202976 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 708720      nrdconta
                                ,1           inpessoa
                                ,28647771850 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 528960    nrdconta
                                ,1         inpessoa
                                ,433069937 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 751731      nrdconta
                                ,1           inpessoa
                                ,94857946904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 307971      nrdconta
                                ,1           inpessoa
                                ,65064011920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 670804      nrdconta
                                ,1           inpessoa
                                ,54983509968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 692590      nrdconta
                                ,1           inpessoa
                                ,12322044989 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 747220     nrdconta
                                ,1          inpessoa
                                ,4007969965 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 667730      nrdconta
                                ,1           inpessoa
                                ,83245839200 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 438995  nrdconta
                                ,2       inpessoa
                                ,6273555 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735736   nrdconta
                                ,2        inpessoa
                                ,31855210 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 716685      nrdconta
                                ,1           inpessoa
                                ,68308663915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 443468   nrdconta
                                ,2        inpessoa
                                ,15601210 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 636207      nrdconta
                                ,1           inpessoa
                                ,10044977921 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 780707   nrdconta
                                ,2        inpessoa
                                ,18708102 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 592935     nrdconta
                                ,1          inpessoa
                                ,6134759929 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 940429     nrdconta
                                ,1          inpessoa
                                ,5926716900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 534544      nrdconta
                                ,1           inpessoa
                                ,38052440963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 315923      nrdconta
                                ,1           inpessoa
                                ,50969803915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 633763  nrdconta
                                ,2       inpessoa
                                ,3182707 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 491039   nrdconta
                                ,2        inpessoa
                                ,12118211 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 578894     nrdconta
                                ,1          inpessoa
                                ,5591780938 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 748200   nrdconta
                                ,2        inpessoa
                                ,24923743 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 508942   nrdconta
                                ,2        inpessoa
                                ,23246266 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 449300   nrdconta
                                ,2        inpessoa
                                ,79370391 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 682853   nrdconta
                                ,2        inpessoa
                                ,32461727 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 767468      nrdconta
                                ,1           inpessoa
                                ,13502419892 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 523283   nrdconta
                                ,2        inpessoa
                                ,18168544 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754552      nrdconta
                                ,1           inpessoa
                                ,10098080954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 292877     nrdconta
                                ,1          inpessoa
                                ,7870025933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 156779      nrdconta
                                ,1           inpessoa
                                ,79214975949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 538671     nrdconta
                                ,1          inpessoa
                                ,8329785904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 750123     nrdconta
                                ,1          inpessoa
                                ,6575979963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 731803      nrdconta
                                ,1           inpessoa
                                ,10630578923 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 695610     nrdconta
                                ,1          inpessoa
                                ,8502948946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 204692      nrdconta
                                ,1           inpessoa
                                ,31056393904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 680133     nrdconta
                                ,1          inpessoa
                                ,9473812957 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 736201   nrdconta
                                ,2        inpessoa
                                ,10727300 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 642991     nrdconta
                                ,1          inpessoa
                                ,6711386930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 609641   nrdconta
                                ,2        inpessoa
                                ,29065038 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743348   nrdconta
                                ,2        inpessoa
                                ,34181921 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 815837   nrdconta
                                ,2        inpessoa
                                ,30831254 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 746509   nrdconta
                                ,2        inpessoa
                                ,21699803 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 772550   nrdconta
                                ,2        inpessoa
                                ,18749178 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 712965   nrdconta
                                ,2        inpessoa
                                ,29372143 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 519405      nrdconta
                                ,1           inpessoa
                                ,58259600900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 589128     nrdconta
                                ,1          inpessoa
                                ,9031276952 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 797570   nrdconta
                                ,2        inpessoa
                                ,20319811 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 718360      nrdconta
                                ,1           inpessoa
                                ,15137035874 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 536466   nrdconta
                                ,2        inpessoa
                                ,18466249 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 756156     nrdconta
                                ,1          inpessoa
                                ,4073612948 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 737224     nrdconta
                                ,1          inpessoa
                                ,5951522951 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 397784      nrdconta
                                ,1           inpessoa
                                ,49645285968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 628484   nrdconta
                                ,2        inpessoa
                                ,29691719 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 460125      nrdconta
                                ,1           inpessoa
                                ,55131565987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 791717   nrdconta
                                ,2        inpessoa
                                ,32517471 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 504076      nrdconta
                                ,1           inpessoa
                                ,65796020234 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 534161      nrdconta
                                ,1           inpessoa
                                ,71556494904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 589446    nrdconta
                                ,1         inpessoa
                                ,385493959 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 537160      nrdconta
                                ,1           inpessoa
                                ,34623647900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 644927      nrdconta
                                ,1           inpessoa
                                ,90157184900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 772755   nrdconta
                                ,2        inpessoa
                                ,26374734 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 227552  nrdconta
                                ,2       inpessoa
                                ,2764461 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 687561     nrdconta
                                ,1          inpessoa
                                ,3785639988 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 203483      nrdconta
                                ,1           inpessoa
                                ,49859862915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 638072     nrdconta
                                ,1          inpessoa
                                ,2495043917 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 712868     nrdconta
                                ,1          inpessoa
                                ,1955903921 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 604720     nrdconta
                                ,1          inpessoa
                                ,5591855962 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 663352   nrdconta
                                ,2        inpessoa
                                ,12674088 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 677400      nrdconta
                                ,1           inpessoa
                                ,39775127904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 847801   nrdconta
                                ,2        inpessoa
                                ,26595925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 951560     nrdconta
                                ,1          inpessoa
                                ,4702319981 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 628352      nrdconta
                                ,1           inpessoa
                                ,10755714997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 882003     nrdconta
                                ,1          inpessoa
                                ,4563070955 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 753513     nrdconta
                                ,1          inpessoa
                                ,8886901933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 215155     nrdconta
                                ,1          inpessoa
                                ,6504083908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 699470     nrdconta
                                ,1          inpessoa
                                ,9725542975 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 635286     nrdconta
                                ,1          inpessoa
                                ,6017473999 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 678953   nrdconta
                                ,2        inpessoa
                                ,22552208 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 615692      nrdconta
                                ,1           inpessoa
                                ,11579717926 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 918326     nrdconta
                                ,1          inpessoa
                                ,5333552908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732761   nrdconta
                                ,2        inpessoa
                                ,31804174 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 663727   nrdconta
                                ,2        inpessoa
                                ,13515757 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 557005   nrdconta
                                ,2        inpessoa
                                ,18362430 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 489883  nrdconta
                                ,2       inpessoa
                                ,4226818 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 297330      nrdconta
                                ,1           inpessoa
                                ,53365399020 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 721336      nrdconta
                                ,1           inpessoa
                                ,67623468472 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 341908     nrdconta
                                ,1          inpessoa
                                ,2016833939 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 716235     nrdconta
                                ,1          inpessoa
                                ,8949648954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 772631     nrdconta
                                ,1          inpessoa
                                ,9575386930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 569550   nrdconta
                                ,2        inpessoa
                                ,24629734 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 758280     nrdconta
                                ,1          inpessoa
                                ,4738741217 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 660736      nrdconta
                                ,1           inpessoa
                                ,42462940987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 658537  nrdconta
                                ,2       inpessoa
                                ,4610037 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 741035     nrdconta
                                ,1          inpessoa
                                ,9992218924 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 857785    nrdconta
                                ,1         inpessoa
                                ,436477904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 493449    nrdconta
                                ,1         inpessoa
                                ,716584913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 520020      nrdconta
                                ,1           inpessoa
                                ,96289775715 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 673595     nrdconta
                                ,1          inpessoa
                                ,6783806944 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 507547      nrdconta
                                ,1           inpessoa
                                ,42126541991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 706655     nrdconta
                                ,1          inpessoa
                                ,5946454927 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 203912     nrdconta
                                ,1          inpessoa
                                ,7800742970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 768910     nrdconta
                                ,1          inpessoa
                                ,2975137966 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 307246      nrdconta
                                ,1           inpessoa
                                ,62291769987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 713228      nrdconta
                                ,1           inpessoa
                                ,45864934020 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 769967     nrdconta
                                ,1          inpessoa
                                ,8617102900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 330035     nrdconta
                                ,1          inpessoa
                                ,5473642969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 651346      nrdconta
                                ,1           inpessoa
                                ,10844482978 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 571580   nrdconta
                                ,2        inpessoa
                                ,20208028 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732338     nrdconta
                                ,1          inpessoa
                                ,2931177997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 648183     nrdconta
                                ,1          inpessoa
                                ,9781558903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 313777      nrdconta
                                ,1           inpessoa
                                ,19382383972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 811211   nrdconta
                                ,2        inpessoa
                                ,23534229 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755621     nrdconta
                                ,1          inpessoa
                                ,5522913908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 651591     nrdconta
                                ,1          inpessoa
                                ,6984577900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 564869  nrdconta
                                ,2       inpessoa
                                ,9624911 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 687677   nrdconta
                                ,2        inpessoa
                                ,24697543 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 296813     nrdconta
                                ,1          inpessoa
                                ,2623774978 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 521639     nrdconta
                                ,1          inpessoa
                                ,6029387910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 663239      nrdconta
                                ,1           inpessoa
                                ,11122589905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 810533      nrdconta
                                ,1           inpessoa
                                ,10559961928 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 690350      nrdconta
                                ,1           inpessoa
                                ,79199518953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 299847      nrdconta
                                ,1           inpessoa
                                ,72005688991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 313491     nrdconta
                                ,1          inpessoa
                                ,7627935970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 459585   nrdconta
                                ,2        inpessoa
                                ,15448174 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 753289     nrdconta
                                ,1          inpessoa
                                ,4483160990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 358690   nrdconta
                                ,2        inpessoa
                                ,24785018 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 639818      nrdconta
                                ,1           inpessoa
                                ,82188785991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 668095     nrdconta
                                ,1          inpessoa
                                ,1963795636 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 810070     nrdconta
                                ,1          inpessoa
                                ,7403846940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 729736   nrdconta
                                ,2        inpessoa
                                ,33849245 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 739570   nrdconta
                                ,2        inpessoa
                                ,34131285 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 488798      nrdconta
                                ,1           inpessoa
                                ,79188613968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 729671      nrdconta
                                ,1           inpessoa
                                ,93678371949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 518840   nrdconta
                                ,2        inpessoa
                                ,21802826 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 763039      nrdconta
                                ,1           inpessoa
                                ,10214198936 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 804568     nrdconta
                                ,1          inpessoa
                                ,8565531902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 620068      nrdconta
                                ,1           inpessoa
                                ,99617617404 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 462390      nrdconta
                                ,1           inpessoa
                                ,56115334934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 455822    nrdconta
                                ,1         inpessoa
                                ,548607923 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 627771    nrdconta
                                ,1         inpessoa
                                ,379028905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 473634     nrdconta
                                ,1          inpessoa
                                ,2690659972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 740420     nrdconta
                                ,1          inpessoa
                                ,5825339965 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 494771    nrdconta
                                ,1         inpessoa
                                ,492580952 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 811629     nrdconta
                                ,1          inpessoa
                                ,3809591947 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 498920     nrdconta
                                ,1          inpessoa
                                ,5389691997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 559105      nrdconta
                                ,1           inpessoa
                                ,40686945832 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 586056      nrdconta
                                ,1           inpessoa
                                ,12362837912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 856010  nrdconta
                                ,2       inpessoa
                                ,7510212 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 229504    nrdconta
                                ,1         inpessoa
                                ,333489950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 745189     nrdconta
                                ,1          inpessoa
                                ,6664018969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765872   nrdconta
                                ,2        inpessoa
                                ,33855336 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 804274   nrdconta
                                ,2        inpessoa
                                ,13435162 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 737666      nrdconta
                                ,1           inpessoa
                                ,89298306920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 639494      nrdconta
                                ,1           inpessoa
                                ,43185054806 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 712434   nrdconta
                                ,2        inpessoa
                                ,23667243 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 685135      nrdconta
                                ,1           inpessoa
                                ,58263209900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 617725      nrdconta
                                ,1           inpessoa
                                ,11846700990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 489972     nrdconta
                                ,1          inpessoa
                                ,6899401908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 608491     nrdconta
                                ,1          inpessoa
                                ,9662665870 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 578401    nrdconta
                                ,1         inpessoa
                                ,674916930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 477443     nrdconta
                                ,1          inpessoa
                                ,9429217984 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 729922      nrdconta
                                ,1           inpessoa
                                ,40843688068 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754277   nrdconta
                                ,2        inpessoa
                                ,34214770 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 542881      nrdconta
                                ,1           inpessoa
                                ,89144600968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 514764      nrdconta
                                ,1           inpessoa
                                ,63115000944 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 718726   nrdconta
                                ,2        inpessoa
                                ,21290043 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 258512     nrdconta
                                ,1          inpessoa
                                ,5707035907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 19976     nrdconta
                                ,1         inpessoa
                                ,385050968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 784702     nrdconta
                                ,1          inpessoa
                                ,2416561928 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735019   nrdconta
                                ,2        inpessoa
                                ,27383455 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725706     nrdconta
                                ,1          inpessoa
                                ,8290639945 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 389773  nrdconta
                                ,2       inpessoa
                                ,3345635 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 343048   nrdconta
                                ,2        inpessoa
                                ,23933368 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755524     nrdconta
                                ,1          inpessoa
                                ,3666909906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 729990     nrdconta
                                ,1          inpessoa
                                ,8888447946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 553018     nrdconta
                                ,1          inpessoa
                                ,3372422910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 253200     nrdconta
                                ,1          inpessoa
                                ,2959765940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 855960     nrdconta
                                ,1          inpessoa
                                ,8858836910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 718602   nrdconta
                                ,2        inpessoa
                                ,30371954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 567507      nrdconta
                                ,1           inpessoa
                                ,94859477987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 751235   nrdconta
                                ,2        inpessoa
                                ,34320823 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 641820      nrdconta
                                ,1           inpessoa
                                ,94892644900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 761125     nrdconta
                                ,1          inpessoa
                                ,9806115988 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 797669      nrdconta
                                ,1           inpessoa
                                ,71995331953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 650528     nrdconta
                                ,1          inpessoa
                                ,6031877902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 737720     nrdconta
                                ,1          inpessoa
                                ,6397309908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 712426      nrdconta
                                ,1           inpessoa
                                ,10302094997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 657255      nrdconta
                                ,1           inpessoa
                                ,40051549808 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 639370   nrdconta
                                ,2        inpessoa
                                ,24246048 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 574848     nrdconta
                                ,1          inpessoa
                                ,8559505954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 780227   nrdconta
                                ,2        inpessoa
                                ,22590224 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 383031      nrdconta
                                ,1           inpessoa
                                ,69421889991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 753343   nrdconta
                                ,2        inpessoa
                                ,34228382 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 756385   nrdconta
                                ,2        inpessoa
                                ,32772590 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 760536     nrdconta
                                ,1          inpessoa
                                ,6524286901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 335789      nrdconta
                                ,1           inpessoa
                                ,89089723900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 946761   nrdconta
                                ,2        inpessoa
                                ,19176716 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 805734   nrdconta
                                ,2        inpessoa
                                ,16914081 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 811831   nrdconta
                                ,2        inpessoa
                                ,34560291 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 621773      nrdconta
                                ,1           inpessoa
                                ,12368176489 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 758116      nrdconta
                                ,1           inpessoa
                                ,68340389904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 976555     nrdconta
                                ,1          inpessoa
                                ,4778256999 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 456500      nrdconta
                                ,1           inpessoa
                                ,89083563987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 652857     nrdconta
                                ,1          inpessoa
                                ,2589493258 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 932523     nrdconta
                                ,1          inpessoa
                                ,9369382933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 465895      nrdconta
                                ,1           inpessoa
                                ,63636557904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 738581   nrdconta
                                ,2        inpessoa
                                ,29532046 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 383783    nrdconta
                                ,1         inpessoa
                                ,134620089 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 492655      nrdconta
                                ,1           inpessoa
                                ,42189381991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 770035     nrdconta
                                ,1          inpessoa
                                ,7986868988 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 783919      nrdconta
                                ,1           inpessoa
                                ,77034678391 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 738654     nrdconta
                                ,1          inpessoa
                                ,7578305956 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 582018   nrdconta
                                ,2        inpessoa
                                ,15872283 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 954721     nrdconta
                                ,1          inpessoa
                                ,8175711914 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 533106      nrdconta
                                ,1           inpessoa
                                ,44712723904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 457434     nrdconta
                                ,1          inpessoa
                                ,3769288912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 551660      nrdconta
                                ,1           inpessoa
                                ,24798525987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 166162   nrdconta
                                ,2        inpessoa
                                ,16714557 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 520624     nrdconta
                                ,1          inpessoa
                                ,3558813901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 472077      nrdconta
                                ,1           inpessoa
                                ,21729662900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754820     nrdconta
                                ,1          inpessoa
                                ,7316952598 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725617     nrdconta
                                ,1          inpessoa
                                ,5134511969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 674559    nrdconta
                                ,1         inpessoa
                                ,666038970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 371599   nrdconta
                                ,2        inpessoa
                                ,12918279 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 641219    nrdconta
                                ,1         inpessoa
                                ,486652904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 407119      nrdconta
                                ,1           inpessoa
                                ,90818717572 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 310867     nrdconta
                                ,1          inpessoa
                                ,3803367905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 153508    nrdconta
                                ,1         inpessoa
                                ,521212910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 758345   nrdconta
                                ,2        inpessoa
                                ,27017346 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 773301     nrdconta
                                ,1          inpessoa
                                ,8630439920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 504610     nrdconta
                                ,1          inpessoa
                                ,9334805986 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 646890   nrdconta
                                ,2        inpessoa
                                ,26520689 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 303216     nrdconta
                                ,1          inpessoa
                                ,3964549924 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 606294      nrdconta
                                ,1           inpessoa
                                ,91866553020 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 653853     nrdconta
                                ,1          inpessoa
                                ,2423071914 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 537900      nrdconta
                                ,1           inpessoa
                                ,97021458991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 646253   nrdconta
                                ,2        inpessoa
                                ,13194232 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 592064   nrdconta
                                ,2        inpessoa
                                ,25024763 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 672262      nrdconta
                                ,1           inpessoa
                                ,11977793967 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 268470     nrdconta
                                ,1          inpessoa
                                ,6555494980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 683752     nrdconta
                                ,1          inpessoa
                                ,4439320937 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 484733     nrdconta
                                ,1          inpessoa
                                ,5314006979 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765694     nrdconta
                                ,1          inpessoa
                                ,8038711980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 724491     nrdconta
                                ,1          inpessoa
                                ,2772362906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725307     nrdconta
                                ,1          inpessoa
                                ,9375469840 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 460494   nrdconta
                                ,2        inpessoa
                                ,74081282 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 721140      nrdconta
                                ,1           inpessoa
                                ,91128595168 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 597295   nrdconta
                                ,2        inpessoa
                                ,23461168 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 299901  nrdconta
                                ,2       inpessoa
                                ,6345842 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 768316     nrdconta
                                ,1          inpessoa
                                ,4158927919 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 862673    nrdconta
                                ,1         inpessoa
                                ,911648933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 491543      nrdconta
                                ,1           inpessoa
                                ,12849808989 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 292095     nrdconta
                                ,1          inpessoa
                                ,5841378937 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 619639     nrdconta
                                ,1          inpessoa
                                ,7554286927 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 771643   nrdconta
                                ,2        inpessoa
                                ,29702715 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 791334   nrdconta
                                ,2        inpessoa
                                ,35615602 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 489417      nrdconta
                                ,1           inpessoa
                                ,42023050944 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 501930     nrdconta
                                ,1          inpessoa
                                ,9071549992 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 682101      nrdconta
                                ,1           inpessoa
                                ,12244277933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 760358    nrdconta
                                ,1         inpessoa
                                ,815600011 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 715735   nrdconta
                                ,2        inpessoa
                                ,33378338 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 761826   nrdconta
                                ,2        inpessoa
                                ,31228449 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 680834      nrdconta
                                ,1           inpessoa
                                ,12935394909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 648205     nrdconta
                                ,1          inpessoa
                                ,9484453945 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 858455      nrdconta
                                ,1           inpessoa
                                ,11483491978 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 589586      nrdconta
                                ,1           inpessoa
                                ,79906206934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 339520     nrdconta
                                ,1          inpessoa
                                ,9493705927 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 504866     nrdconta
                                ,1          inpessoa
                                ,6887823969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 536733    nrdconta
                                ,1         inpessoa
                                ,900956933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 702986      nrdconta
                                ,1           inpessoa
                                ,47579781972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 656380      nrdconta
                                ,1           inpessoa
                                ,11848840993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 657093   nrdconta
                                ,2        inpessoa
                                ,31687828 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 618160     nrdconta
                                ,1          inpessoa
                                ,7504776955 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 798592     nrdconta
                                ,1          inpessoa
                                ,4650170966 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 648728      nrdconta
                                ,1           inpessoa
                                ,97074519987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 639842   nrdconta
                                ,2        inpessoa
                                ,30657474 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 520098 nrdconta
                                ,2      inpessoa
                                ,107316 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 828483   nrdconta
                                ,2        inpessoa
                                ,36324686 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 592366   nrdconta
                                ,2        inpessoa
                                ,28097758 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 646652   nrdconta
                                ,2        inpessoa
                                ,30198613 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 801240   nrdconta
                                ,2        inpessoa
                                ,35973534 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 426032   nrdconta
                                ,2        inpessoa
                                ,25321307 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 597791      nrdconta
                                ,1           inpessoa
                                ,47464496949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 642584     nrdconta
                                ,1          inpessoa
                                ,8065568971 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 945340     nrdconta
                                ,1          inpessoa
                                ,9484463908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755028     nrdconta
                                ,1          inpessoa
                                ,9480856905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 747700     nrdconta
                                ,1          inpessoa
                                ,5010222957 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 727849   nrdconta
                                ,2        inpessoa
                                ,28697847 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 390038   nrdconta
                                ,2        inpessoa
                                ,13747674 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 479411  nrdconta
                                ,2       inpessoa
                                ,9396446 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 756539     nrdconta
                                ,1          inpessoa
                                ,7569198948 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 467197      nrdconta
                                ,1           inpessoa
                                ,82188840925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 699039   nrdconta
                                ,2        inpessoa
                                ,29782518 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 778648      nrdconta
                                ,1           inpessoa
                                ,35385570982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 839558   nrdconta
                                ,2        inpessoa
                                ,23497891 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 371009     nrdconta
                                ,1          inpessoa
                                ,7088250950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 152030      nrdconta
                                ,1           inpessoa
                                ,67339760997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 538710   nrdconta
                                ,2        inpessoa
                                ,18962000 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 808113   nrdconta
                                ,2        inpessoa
                                ,15812603 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 371459      nrdconta
                                ,1           inpessoa
                                ,64940470920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 225681     nrdconta
                                ,1          inpessoa
                                ,3540579958 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 705020     nrdconta
                                ,1          inpessoa
                                ,1522410945 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 386367   nrdconta
                                ,2        inpessoa
                                ,15084459 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 493589   nrdconta
                                ,2        inpessoa
                                ,95886735 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 766097   nrdconta
                                ,2        inpessoa
                                ,27058297 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 651230      nrdconta
                                ,1           inpessoa
                                ,62541005504 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 487961   nrdconta
                                ,2        inpessoa
                                ,15091949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 632830     nrdconta
                                ,1          inpessoa
                                ,8601209963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 485780     nrdconta
                                ,1          inpessoa
                                ,9465948993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 464090      nrdconta
                                ,1           inpessoa
                                ,79927149972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 751510      nrdconta
                                ,1           inpessoa
                                ,12421398932 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 536369     nrdconta
                                ,1          inpessoa
                                ,5274667945 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 675296     nrdconta
                                ,1          inpessoa
                                ,7735605994 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 763357      nrdconta
                                ,1           inpessoa
                                ,18842968900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 507350   nrdconta
                                ,2        inpessoa
                                ,21112108 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 819743   nrdconta
                                ,2        inpessoa
                                ,36616518 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 713120      nrdconta
                                ,1           inpessoa
                                ,11368636993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 493465  nrdconta
                                ,2       inpessoa
                                ,7346722 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 723991   nrdconta
                                ,2        inpessoa
                                ,33787399 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 605077     nrdconta
                                ,1          inpessoa
                                ,7136287901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 687510   nrdconta
                                ,2        inpessoa
                                ,11561723 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 660140   nrdconta
                                ,2        inpessoa
                                ,13953714 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742856      nrdconta
                                ,1           inpessoa
                                ,38357470963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 637947      nrdconta
                                ,1           inpessoa
                                ,10887276970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 761524      nrdconta
                                ,1           inpessoa
                                ,11283090929 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 744336     nrdconta
                                ,1          inpessoa
                                ,5586044552 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 306282      nrdconta
                                ,1           inpessoa
                                ,48302996904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 194166    nrdconta
                                ,1         inpessoa
                                ,352933909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 595756   nrdconta
                                ,2        inpessoa
                                ,28135708 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755613      nrdconta
                                ,1           inpessoa
                                ,98794574987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 643246     nrdconta
                                ,1          inpessoa
                                ,7093194958 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 680508     nrdconta
                                ,1          inpessoa
                                ,4485339955 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 670448   nrdconta
                                ,2        inpessoa
                                ,28723441 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 740403     nrdconta
                                ,1          inpessoa
                                ,9851862916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 643556      nrdconta
                                ,1           inpessoa
                                ,24748528915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 502073     nrdconta
                                ,1          inpessoa
                                ,6578607943 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 946427     nrdconta
                                ,1          inpessoa
                                ,6370288993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754994      nrdconta
                                ,1           inpessoa
                                ,14113845980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 407062      nrdconta
                                ,1           inpessoa
                                ,38336146920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 766240    nrdconta
                                ,1         inpessoa
                                ,522257984 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 759937      nrdconta
                                ,1           inpessoa
                                ,27893309806 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 618365      nrdconta
                                ,1           inpessoa
                                ,94789509915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 730920      nrdconta
                                ,1           inpessoa
                                ,11621912957 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 379670     nrdconta
                                ,1          inpessoa
                                ,1444196960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 756474     nrdconta
                                ,1          inpessoa
                                ,3811051997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 717525      nrdconta
                                ,1           inpessoa
                                ,10853358958 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 574783      nrdconta
                                ,1           inpessoa
                                ,98912550934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 598739      nrdconta
                                ,1           inpessoa
                                ,59238046034 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 864595      nrdconta
                                ,1           inpessoa
                                ,91985285053 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 686794     nrdconta
                                ,1          inpessoa
                                ,1774163942 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 199052     nrdconta
                                ,1          inpessoa
                                ,2412158975 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 675520   nrdconta
                                ,2        inpessoa
                                ,10514643 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 708178     nrdconta
                                ,1          inpessoa
                                ,2879914906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 697796   nrdconta
                                ,2        inpessoa
                                ,24149022 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 730343     nrdconta
                                ,1          inpessoa
                                ,9486625905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 762784   nrdconta
                                ,2        inpessoa
                                ,34773304 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 381764      nrdconta
                                ,1           inpessoa
                                ,76817865972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743810   nrdconta
                                ,2        inpessoa
                                ,34317069 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 695661     nrdconta
                                ,1          inpessoa
                                ,7131252921 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 772739   nrdconta
                                ,2        inpessoa
                                ,35158965 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742651   nrdconta
                                ,2        inpessoa
                                ,31568464 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 538507      nrdconta
                                ,1           inpessoa
                                ,25196189904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 707996   nrdconta
                                ,2        inpessoa
                                ,18502885 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 316997     nrdconta
                                ,1          inpessoa
                                ,9127756963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 636932     nrdconta
                                ,1          inpessoa
                                ,8371588933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 472573     nrdconta
                                ,1          inpessoa
                                ,6724486963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 542768   nrdconta
                                ,2        inpessoa
                                ,18136389 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 253588      nrdconta
                                ,1           inpessoa
                                ,18193013972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 569895     nrdconta
                                ,1          inpessoa
                                ,5520987955 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 510033   nrdconta
                                ,2        inpessoa
                                ,18306254 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 705438    nrdconta
                                ,1         inpessoa
                                ,794810942 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 165891     nrdconta
                                ,1          inpessoa
                                ,4713855901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 736589   nrdconta
                                ,2        inpessoa
                                ,34063663 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725315   nrdconta
                                ,2        inpessoa
                                ,20352065 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 724246     nrdconta
                                ,1          inpessoa
                                ,5946924907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 536938     nrdconta
                                ,1          inpessoa
                                ,2120219907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 516830   nrdconta
                                ,2        inpessoa
                                ,13606436 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 736406      nrdconta
                                ,1           inpessoa
                                ,11477755918 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 441449     nrdconta
                                ,1          inpessoa
                                ,5391720907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 782319   nrdconta
                                ,2        inpessoa
                                ,32961130 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 657140   nrdconta
                                ,2        inpessoa
                                ,28250204 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 166588  nrdconta
                                ,2       inpessoa
                                ,8787386 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 585718   nrdconta
                                ,2        inpessoa
                                ,22366502 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 378003     nrdconta
                                ,1          inpessoa
                                ,7361144918 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 444510     nrdconta
                                ,1          inpessoa
                                ,2832377912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 727172     nrdconta
                                ,1          inpessoa
                                ,3172722929 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 821330   nrdconta
                                ,2        inpessoa
                                ,31120266 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 673099   nrdconta
                                ,2        inpessoa
                                ,31222126 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 968293   nrdconta
                                ,2        inpessoa
                                ,32816789 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 793752   nrdconta
                                ,2        inpessoa
                                ,26799604 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 239801      nrdconta
                                ,1           inpessoa
                                ,18312012915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 215899    nrdconta
                                ,1         inpessoa
                                ,562894993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 702978      nrdconta
                                ,1           inpessoa
                                ,41863194991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 511595     nrdconta
                                ,1          inpessoa
                                ,1816892947 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 701556     nrdconta
                                ,1          inpessoa
                                ,3676902920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 623288     nrdconta
                                ,1          inpessoa
                                ,8286303997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 664413     nrdconta
                                ,1          inpessoa
                                ,4114382984 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 678694      nrdconta
                                ,1           inpessoa
                                ,95594019987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 647942   nrdconta
                                ,2        inpessoa
                                ,13407570 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732419   nrdconta
                                ,2        inpessoa
                                ,17148194 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 386820     nrdconta
                                ,1          inpessoa
                                ,2577117914 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 493260   nrdconta
                                ,2        inpessoa
                                ,25226710 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 306908     nrdconta
                                ,1          inpessoa
                                ,5364234908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742279      nrdconta
                                ,1           inpessoa
                                ,53128672920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 219533      nrdconta
                                ,1           inpessoa
                                ,66021049934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 880094     nrdconta
                                ,1          inpessoa
                                ,4094014985 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 661635   nrdconta
                                ,2        inpessoa
                                ,31897445 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 916056   nrdconta
                                ,2        inpessoa
                                ,38237125 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 209562      nrdconta
                                ,1           inpessoa
                                ,35647779972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 803766   nrdconta
                                ,2        inpessoa
                                ,35982144 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 728160     nrdconta
                                ,1          inpessoa
                                ,4065979951 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 687154      nrdconta
                                ,1           inpessoa
                                ,11299988946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 317209      nrdconta
                                ,1           inpessoa
                                ,61526738953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 342556      nrdconta
                                ,1           inpessoa
                                ,91864526904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 316687     nrdconta
                                ,1          inpessoa
                                ,5869679907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 870501     nrdconta
                                ,1          inpessoa
                                ,6478194906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 331457   nrdconta
                                ,2        inpessoa
                                ,24515503 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 782300   nrdconta
                                ,2        inpessoa
                                ,23561662 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 215848   nrdconta
                                ,2        inpessoa
                                ,23846656 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 691127   nrdconta
                                ,2        inpessoa
                                ,10557913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755150     nrdconta
                                ,1          inpessoa
                                ,4951078163 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 489476     nrdconta
                                ,1          inpessoa
                                ,7720329988 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 520942      nrdconta
                                ,1           inpessoa
                                ,73364274991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 598100   nrdconta
                                ,2        inpessoa
                                ,28843479 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 473669    nrdconta
                                ,1         inpessoa
                                ,538012960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 731250     nrdconta
                                ,1          inpessoa
                                ,8973142984 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 776181   nrdconta
                                ,2        inpessoa
                                ,31554593 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 670383     nrdconta
                                ,1          inpessoa
                                ,7542017918 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 587907     nrdconta
                                ,1          inpessoa
                                ,7356545900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 458465      nrdconta
                                ,1           inpessoa
                                ,33164143800 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732389    nrdconta
                                ,1         inpessoa
                                ,758856970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 631515      nrdconta
                                ,1           inpessoa
                                ,95502670910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 645737      nrdconta
                                ,1           inpessoa
                                ,11893441903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 573175     nrdconta
                                ,1          inpessoa
                                ,6857632936 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 653012   nrdconta
                                ,2        inpessoa
                                ,97547987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 204218      nrdconta
                                ,1           inpessoa
                                ,82125465949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 628506   nrdconta
                                ,2        inpessoa
                                ,13104080 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 664987     nrdconta
                                ,1          inpessoa
                                ,4901243993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 636029      nrdconta
                                ,1           inpessoa
                                ,48483567920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 492167     nrdconta
                                ,1          inpessoa
                                ,4103765909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 679771     nrdconta
                                ,1          inpessoa
                                ,6269671205 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 560707   nrdconta
                                ,2        inpessoa
                                ,19981186 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 587290     nrdconta
                                ,1          inpessoa
                                ,1584667990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 302406    nrdconta
                                ,1         inpessoa
                                ,632905964 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725447     nrdconta
                                ,1          inpessoa
                                ,7605556993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 588032     nrdconta
                                ,1          inpessoa
                                ,8269184926 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 701220      nrdconta
                                ,1           inpessoa
                                ,42240298987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743089     nrdconta
                                ,1          inpessoa
                                ,9494101952 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 679623   nrdconta
                                ,2        inpessoa
                                ,21307504 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732753     nrdconta
                                ,1          inpessoa
                                ,4863777922 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 611212   nrdconta
                                ,2        inpessoa
                                ,18167757 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 559245   nrdconta
                                ,2        inpessoa
                                ,17975336 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 822051   nrdconta
                                ,2        inpessoa
                                ,17632828 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 718637     nrdconta
                                ,1          inpessoa
                                ,7370447995 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 720321     nrdconta
                                ,1          inpessoa
                                ,3430137896 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 576239   nrdconta
                                ,2        inpessoa
                                ,21461684 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 701483    nrdconta
                                ,1         inpessoa
                                ,343797976 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 720879      nrdconta
                                ,1           inpessoa
                                ,71980261920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 499790   nrdconta
                                ,2        inpessoa
                                ,25058846 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 761990   nrdconta
                                ,2        inpessoa
                                ,33828839 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 696412   nrdconta
                                ,2        inpessoa
                                ,18563373 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 646318     nrdconta
                                ,1          inpessoa
                                ,5372854901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735000     nrdconta
                                ,1          inpessoa
                                ,4527434942 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 239127 nrdconta
                                ,2      inpessoa
                                ,110126 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 332089      nrdconta
                                ,1           inpessoa
                                ,84216816134 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 652059      nrdconta
                                ,1           inpessoa
                                ,89182340900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 676284   nrdconta
                                ,2        inpessoa
                                ,26484392 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 562912   nrdconta
                                ,2        inpessoa
                                ,15008163 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 297615      nrdconta
                                ,1           inpessoa
                                ,92077587920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 309966     nrdconta
                                ,1          inpessoa
                                ,3717012959 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 669733   nrdconta
                                ,2        inpessoa
                                ,31975425 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 808970      nrdconta
                                ,1           inpessoa
                                ,94835993934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 758817  nrdconta
                                ,2       inpessoa
                                ,5572034 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 805009   nrdconta
                                ,2        inpessoa
                                ,36030777 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 465160   nrdconta
                                ,2        inpessoa
                                ,17010780 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 312630      nrdconta
                                ,1           inpessoa
                                ,51201216915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 674192   nrdconta
                                ,2        inpessoa
                                ,15582360 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 449008   nrdconta
                                ,2        inpessoa
                                ,14338976 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 680575   nrdconta
                                ,2        inpessoa
                                ,32683977 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 544523  nrdconta
                                ,2       inpessoa
                                ,6112677 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 464201      nrdconta
                                ,1           inpessoa
                                ,20167830015 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 502600   nrdconta
                                ,2        inpessoa
                                ,81463804 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 628530     nrdconta
                                ,1          inpessoa
                                ,5929433992 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 574945     nrdconta
                                ,1          inpessoa
                                ,7584945643 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 638714  nrdconta
                                ,2       inpessoa
                                ,7913880 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 473200     nrdconta
                                ,1          inpessoa
                                ,8930300901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 658804     nrdconta
                                ,1          inpessoa
                                ,5043012927 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 933783     nrdconta
                                ,1          inpessoa
                                ,5202325690 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 718998    nrdconta
                                ,1         inpessoa
                                ,653824980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 684627   nrdconta
                                ,2        inpessoa
                                ,28606336 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 723550   nrdconta
                                ,2        inpessoa
                                ,15375927 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 477362     nrdconta
                                ,1          inpessoa
                                ,2830568940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 949590     nrdconta
                                ,1          inpessoa
                                ,5003068930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 633143   nrdconta
                                ,2        inpessoa
                                ,29618654 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 491918     nrdconta
                                ,1          inpessoa
                                ,6827569977 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 583880      nrdconta
                                ,1           inpessoa
                                ,37968408920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 780359      nrdconta
                                ,1           inpessoa
                                ,59719214953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 403679      nrdconta
                                ,1           inpessoa
                                ,75984520915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 400335   nrdconta
                                ,2        inpessoa
                                ,78211265 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 509396      nrdconta
                                ,1           inpessoa
                                ,67342965987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 615498   nrdconta
                                ,2        inpessoa
                                ,26165600 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 574694      nrdconta
                                ,1           inpessoa
                                ,64108520963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754951     nrdconta
                                ,1          inpessoa
                                ,4458162527 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 425990     nrdconta
                                ,1          inpessoa
                                ,6690685942 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 442569      nrdconta
                                ,1           inpessoa
                                ,42204747904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 663654   nrdconta
                                ,2        inpessoa
                                ,31029582 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 638358   nrdconta
                                ,2        inpessoa
                                ,20084782 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 767530      nrdconta
                                ,1           inpessoa
                                ,70187550506 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 384291     nrdconta
                                ,1          inpessoa
                                ,4980193900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 251054    nrdconta
                                ,1         inpessoa
                                ,613966996 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 700894    nrdconta
                                ,1         inpessoa
                                ,377344907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 509728      nrdconta
                                ,1           inpessoa
                                ,59238046034 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 637114      nrdconta
                                ,1           inpessoa
                                ,62308696915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 580228     nrdconta
                                ,1          inpessoa
                                ,8110438946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 729213      nrdconta
                                ,1           inpessoa
                                ,86895486968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 332062     nrdconta
                                ,1          inpessoa
                                ,6823561157 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765732     nrdconta
                                ,1          inpessoa
                                ,4293518959 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755133   nrdconta
                                ,2        inpessoa
                                ,28906085 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 749982     nrdconta
                                ,1          inpessoa
                                ,2508787981 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 791121      nrdconta
                                ,1           inpessoa
                                ,12856909906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 710113      nrdconta
                                ,1           inpessoa
                                ,42004772972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743437     nrdconta
                                ,1          inpessoa
                                ,5994409456 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 404853      nrdconta
                                ,1           inpessoa
                                ,44511990930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 295809   nrdconta
                                ,2        inpessoa
                                ,11772663 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 215376     nrdconta
                                ,1          inpessoa
                                ,8729995990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 514691     nrdconta
                                ,1          inpessoa
                                ,7529426974 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 696994   nrdconta
                                ,2        inpessoa
                                ,24992987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 517321     nrdconta
                                ,1          inpessoa
                                ,3343477931 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 455571      nrdconta
                                ,1           inpessoa
                                ,22239944900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 722030     nrdconta
                                ,1          inpessoa
                                ,4238757955 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742660     nrdconta
                                ,1          inpessoa
                                ,4658790980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755060    nrdconta
                                ,1         inpessoa
                                ,468411992 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 803375      nrdconta
                                ,1           inpessoa
                                ,79172822953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 676659     nrdconta
                                ,1          inpessoa
                                ,9193177909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 469564    nrdconta
                                ,1         inpessoa
                                ,906685966 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764434     nrdconta
                                ,1          inpessoa
                                ,6751734930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 589659   nrdconta
                                ,2        inpessoa
                                ,27766230 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 607703   nrdconta
                                ,2        inpessoa
                                ,20280358 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 842982      nrdconta
                                ,1           inpessoa
                                ,31711365890 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 468789      nrdconta
                                ,1           inpessoa
                                ,72000023991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 808024      nrdconta
                                ,1           inpessoa
                                ,10256100918 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 616974      nrdconta
                                ,1           inpessoa
                                ,76010554934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 509264    nrdconta
                                ,1         inpessoa
                                ,655874992 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 838624    nrdconta
                                ,1         inpessoa
                                ,533236967 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 696870      nrdconta
                                ,1           inpessoa
                                ,94784060944 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 705845      nrdconta
                                ,1           inpessoa
                                ,72053330910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 772542     nrdconta
                                ,1          inpessoa
                                ,5602127984 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 331651  nrdconta
                                ,2       inpessoa
                                ,5942894 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 563218      nrdconta
                                ,1           inpessoa
                                ,49729420963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 386600     nrdconta
                                ,1          inpessoa
                                ,7680995958 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 487392     nrdconta
                                ,1          inpessoa
                                ,5252926913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754048     nrdconta
                                ,1          inpessoa
                                ,3967792986 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 610224     nrdconta
                                ,1          inpessoa
                                ,9480739933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743178      nrdconta
                                ,1           inpessoa
                                ,75091526900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 384003      nrdconta
                                ,1           inpessoa
                                ,82132917949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 864986     nrdconta
                                ,1          inpessoa
                                ,5543204957 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 730769     nrdconta
                                ,1          inpessoa
                                ,1459748123 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 985163   nrdconta
                                ,2        inpessoa
                                ,29974046 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 489069   nrdconta
                                ,2        inpessoa
                                ,23014561 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 651966      nrdconta
                                ,1           inpessoa
                                ,94886296904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755710   nrdconta
                                ,2        inpessoa
                                ,34440111 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 615412   nrdconta
                                ,2        inpessoa
                                ,29675133 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 756652      nrdconta
                                ,1           inpessoa
                                ,13974374990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 655791   nrdconta
                                ,2        inpessoa
                                ,23060246 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 386014     nrdconta
                                ,1          inpessoa
                                ,1068824816 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 657646     nrdconta
                                ,1          inpessoa
                                ,8392279905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 351725     nrdconta
                                ,1          inpessoa
                                ,2628785935 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 517283     nrdconta
                                ,1          inpessoa
                                ,4043887957 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 745570     nrdconta
                                ,1          inpessoa
                                ,9118103901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 432326   nrdconta
                                ,2        inpessoa
                                ,21651793 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 310077      nrdconta
                                ,1           inpessoa
                                ,44323620900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 484768      nrdconta
                                ,1           inpessoa
                                ,42653231972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 780014     nrdconta
                                ,1          inpessoa
                                ,5325647903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 858862      nrdconta
                                ,1           inpessoa
                                ,35190027953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 807567   nrdconta
                                ,2        inpessoa
                                ,34291783 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 401412      nrdconta
                                ,1           inpessoa
                                ,85130621972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 515361   nrdconta
                                ,2        inpessoa
                                ,20279738 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 644110   nrdconta
                                ,2        inpessoa
                                ,28400529 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 926957   nrdconta
                                ,2        inpessoa
                                ,35522487 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 768723   nrdconta
                                ,2        inpessoa
                                ,34720745 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 804940     nrdconta
                                ,1          inpessoa
                                ,4674864925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 194530      nrdconta
                                ,1           inpessoa
                                ,80816452920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 744506   nrdconta
                                ,2        inpessoa
                                ,14852497 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 517232     nrdconta
                                ,1          inpessoa
                                ,1305977912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 631108   nrdconta
                                ,2        inpessoa
                                ,29961004 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 730149     nrdconta
                                ,1          inpessoa
                                ,3601886995 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 726940      nrdconta
                                ,1           inpessoa
                                ,11820663990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 608289   nrdconta
                                ,2        inpessoa
                                ,29152471 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 726133      nrdconta
                                ,1           inpessoa
                                ,10902427946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 759996      nrdconta
                                ,1           inpessoa
                                ,21768471991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 506869   nrdconta
                                ,2        inpessoa
                                ,27116753 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 826979    nrdconta
                                ,1         inpessoa
                                ,791412938 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 851426   nrdconta
                                ,2        inpessoa
                                ,31711006 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 637807      nrdconta
                                ,1           inpessoa
                                ,68553790959 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 208698     nrdconta
                                ,1          inpessoa
                                ,4282495901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 308323     nrdconta
                                ,1          inpessoa
                                ,5048635922 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742970      nrdconta
                                ,1           inpessoa
                                ,12500177424 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 206610      nrdconta
                                ,1           inpessoa
                                ,48253677049 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 691135      nrdconta
                                ,1           inpessoa
                                ,68396953953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 747904      nrdconta
                                ,1           inpessoa
                                ,57684472968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 723690     nrdconta
                                ,1          inpessoa
                                ,2969222930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 456209  nrdconta
                                ,2       inpessoa
                                ,2143608 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 660922     nrdconta
                                ,1          inpessoa
                                ,4152802901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 814989      nrdconta
                                ,1           inpessoa
                                ,88548007915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 504378     nrdconta
                                ,1          inpessoa
                                ,5801996907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 341983      nrdconta
                                ,1           inpessoa
                                ,53410734953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 650242      nrdconta
                                ,1           inpessoa
                                ,79215980997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743666      nrdconta
                                ,1           inpessoa
                                ,64433250953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 682535     nrdconta
                                ,1          inpessoa
                                ,4887072937 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 478890     nrdconta
                                ,1          inpessoa
                                ,7435414999 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 319511      nrdconta
                                ,1           inpessoa
                                ,38033275987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 762261      nrdconta
                                ,1           inpessoa
                                ,79158935991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 745790      nrdconta
                                ,1           inpessoa
                                ,10017131928 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 508233     nrdconta
                                ,1          inpessoa
                                ,5872096909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 812382  nrdconta
                                ,2       inpessoa
                                ,7240345 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 331813   nrdconta
                                ,2        inpessoa
                                ,15337349 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 208361      nrdconta
                                ,1           inpessoa
                                ,82143234953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 489255    nrdconta
                                ,1         inpessoa
                                ,580918904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 633348      nrdconta
                                ,1           inpessoa
                                ,11267015993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 385255    nrdconta
                                ,1         inpessoa
                                ,711664919 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 518204   nrdconta
                                ,2        inpessoa
                                ,19735036 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 660892     nrdconta
                                ,1          inpessoa
                                ,7282445940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 511072     nrdconta
                                ,1          inpessoa
                                ,4603828969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 667005     nrdconta
                                ,1          inpessoa
                                ,8409389932 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 487910  nrdconta
                                ,2       inpessoa
                                ,4896830 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 541923      nrdconta
                                ,1           inpessoa
                                ,89181638949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 465712      nrdconta
                                ,1           inpessoa
                                ,94893608991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 433624   nrdconta
                                ,2        inpessoa
                                ,25452646 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 767875      nrdconta
                                ,1           inpessoa
                                ,10771509979 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 126756      nrdconta
                                ,1           inpessoa
                                ,29878563855 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 548286    nrdconta
                                ,1         inpessoa
                                ,584599951 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 385654     nrdconta
                                ,1          inpessoa
                                ,3386780857 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 748110      nrdconta
                                ,1           inpessoa
                                ,21965858821 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 729094   nrdconta
                                ,2        inpessoa
                                ,33606990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 632651     nrdconta
                                ,1          inpessoa
                                ,9024886945 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 196266    nrdconta
                                ,1         inpessoa
                                ,969678975 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 733237    nrdconta
                                ,1         inpessoa
                                ,433479914 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 707589     nrdconta
                                ,1          inpessoa
                                ,5189463982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 622192      nrdconta
                                ,1           inpessoa
                                ,11047913909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732672     nrdconta
                                ,1          inpessoa
                                ,3756887901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 394351      nrdconta
                                ,1           inpessoa
                                ,35229837934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 635782     nrdconta
                                ,1          inpessoa
                                ,9679188981 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 852511     nrdconta
                                ,1          inpessoa
                                ,7055151929 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 373940     nrdconta
                                ,1          inpessoa
                                ,4355871967 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 398527     nrdconta
                                ,1          inpessoa
                                ,6965905905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 440574     nrdconta
                                ,1          inpessoa
                                ,1894119967 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 691780     nrdconta
                                ,1          inpessoa
                                ,4743427940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 555436   nrdconta
                                ,2        inpessoa
                                ,15671552 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 358819      nrdconta
                                ,1           inpessoa
                                ,68411049949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 616559   nrdconta
                                ,2        inpessoa
                                ,29403369 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 506486   nrdconta
                                ,2        inpessoa
                                ,23053420 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 663565      nrdconta
                                ,1           inpessoa
                                ,79651178949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 378020   nrdconta
                                ,2        inpessoa
                                ,15611836 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 468991      nrdconta
                                ,1           inpessoa
                                ,75342596904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 503657      nrdconta
                                ,1           inpessoa
                                ,11842832905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 297194    nrdconta
                                ,1         inpessoa
                                ,646484940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 909130     nrdconta
                                ,1          inpessoa
                                ,8092220948 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 499110      nrdconta
                                ,1           inpessoa
                                ,60352094915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 318698      nrdconta
                                ,1           inpessoa
                                ,60380039915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 314641      nrdconta
                                ,1           inpessoa
                                ,10191123870 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 508705      nrdconta
                                ,1           inpessoa
                                ,91041597991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 846260   nrdconta
                                ,2        inpessoa
                                ,36297478 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 252794     nrdconta
                                ,1          inpessoa
                                ,4281876928 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764892     nrdconta
                                ,1          inpessoa
                                ,3643829965 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 632988   nrdconta
                                ,2        inpessoa
                                ,12539492 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 654116   nrdconta
                                ,2        inpessoa
                                ,25314005 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 810843   nrdconta
                                ,2        inpessoa
                                ,26597285 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 45845       nrdconta
                                ,1           inpessoa
                                ,76105512953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 537640  nrdconta
                                ,2       inpessoa
                                ,5599181 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 817627      nrdconta
                                ,1           inpessoa
                                ,11987185951 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 543969      nrdconta
                                ,1           inpessoa
                                ,94803889953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 804991   nrdconta
                                ,2        inpessoa
                                ,35522487 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764574     nrdconta
                                ,1          inpessoa
                                ,8005019939 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 733598      nrdconta
                                ,1           inpessoa
                                ,10614457980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 624870      nrdconta
                                ,1           inpessoa
                                ,37985442987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 697389      nrdconta
                                ,1           inpessoa
                                ,10899697917 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 529788      nrdconta
                                ,1           inpessoa
                                ,10493295976 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 627330      nrdconta
                                ,1           inpessoa
                                ,59489570982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 729299   nrdconta
                                ,2        inpessoa
                                ,28965284 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 651931   nrdconta
                                ,2        inpessoa
                                ,24917005 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755117     nrdconta
                                ,1          inpessoa
                                ,5590677980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 730424     nrdconta
                                ,1          inpessoa
                                ,9647358903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 447307      nrdconta
                                ,1           inpessoa
                                ,46869247900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 680796   nrdconta
                                ,2        inpessoa
                                ,31904446 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 661147   nrdconta
                                ,2        inpessoa
                                ,20763693 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 790672   nrdconta
                                ,2        inpessoa
                                ,30136376 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764108      nrdconta
                                ,1           inpessoa
                                ,15142013999 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 529389     nrdconta
                                ,1          inpessoa
                                ,6665964922 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 746320   nrdconta
                                ,2        inpessoa
                                ,33846701 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 832995      nrdconta
                                ,1           inpessoa
                                ,19404220949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 816973   nrdconta
                                ,2        inpessoa
                                ,34114288 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 422231      nrdconta
                                ,1           inpessoa
                                ,92114083934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 932680     nrdconta
                                ,1          inpessoa
                                ,9912922948 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 382345     nrdconta
                                ,1          inpessoa
                                ,4171511950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 855499     nrdconta
                                ,1          inpessoa
                                ,5134511969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 591025      nrdconta
                                ,1           inpessoa
                                ,10342650912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 645656     nrdconta
                                ,1          inpessoa
                                ,8207791993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 659568   nrdconta
                                ,2        inpessoa
                                ,31799948 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 569674  nrdconta
                                ,2       inpessoa
                                ,8025357 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 611840   nrdconta
                                ,2        inpessoa
                                ,29206948 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 676420      nrdconta
                                ,1           inpessoa
                                ,68466102949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 196630     nrdconta
                                ,1          inpessoa
                                ,7906275900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 761540     nrdconta
                                ,1          inpessoa
                                ,7605122993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 610674     nrdconta
                                ,1          inpessoa
                                ,9072622952 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 686395   nrdconta
                                ,2        inpessoa
                                ,27313252 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 623024      nrdconta
                                ,1           inpessoa
                                ,89015673934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 734136   nrdconta
                                ,2        inpessoa
                                ,29646970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 468924      nrdconta
                                ,1           inpessoa
                                ,82369860987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 744530     nrdconta
                                ,1          inpessoa
                                ,4529888967 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 637106      nrdconta
                                ,1           inpessoa
                                ,11221269992 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 399698      nrdconta
                                ,1           inpessoa
                                ,35647779972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 612456      nrdconta
                                ,1           inpessoa
                                ,49755536949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 574368   nrdconta
                                ,2        inpessoa
                                ,21067718 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 641782    nrdconta
                                ,1         inpessoa
                                ,989221903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 712922      nrdconta
                                ,1           inpessoa
                                ,11895781906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 780804     nrdconta
                                ,1          inpessoa
                                ,9982059904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 148440   nrdconta
                                ,2        inpessoa
                                ,79392304 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 532320     nrdconta
                                ,1          inpessoa
                                ,4292072981 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 760544     nrdconta
                                ,1          inpessoa
                                ,5706986932 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 626198   nrdconta
                                ,2        inpessoa
                                ,20019704 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 787817   nrdconta
                                ,2        inpessoa
                                ,25113839 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 621757      nrdconta
                                ,1           inpessoa
                                ,75631571315 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 644749     nrdconta
                                ,1          inpessoa
                                ,4329259370 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 830291   nrdconta
                                ,2        inpessoa
                                ,36085571 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 215546   nrdconta
                                ,2        inpessoa
                                ,15519687 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 580155      nrdconta
                                ,1           inpessoa
                                ,32863322168 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 752924      nrdconta
                                ,1           inpessoa
                                ,71995935972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 630071     nrdconta
                                ,1          inpessoa
                                ,7973520902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 818054   nrdconta
                                ,2        inpessoa
                                ,36536458 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 298700  nrdconta
                                ,2       inpessoa
                                ,9307806 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 751383   nrdconta
                                ,2        inpessoa
                                ,34395911 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 464910     nrdconta
                                ,1          inpessoa
                                ,5686895937 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 464309   nrdconta
                                ,2        inpessoa
                                ,14195778 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 469840   nrdconta
                                ,2        inpessoa
                                ,20231476 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 758850      nrdconta
                                ,1           inpessoa
                                ,12263935940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 676144   nrdconta
                                ,2        inpessoa
                                ,30872393 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 845876   nrdconta
                                ,2        inpessoa
                                ,35088363 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 507431   nrdconta
                                ,2        inpessoa
                                ,27213758 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 598658     nrdconta
                                ,1          inpessoa
                                ,9789461976 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725749   nrdconta
                                ,2        inpessoa
                                ,27853077 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 558133  nrdconta
                                ,2       inpessoa
                                ,2129851 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 156442     nrdconta
                                ,1          inpessoa
                                ,5044195952 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 851981   nrdconta
                                ,2        inpessoa
                                ,36251812 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 795151    nrdconta
                                ,1         inpessoa
                                ,358422965 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 786810   nrdconta
                                ,2        inpessoa
                                ,30361565 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 168351     nrdconta
                                ,1          inpessoa
                                ,4161634919 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 704679   nrdconta
                                ,2        inpessoa
                                ,14322568 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 403458     nrdconta
                                ,1          inpessoa
                                ,6305904944 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 128813      nrdconta
                                ,1           inpessoa
                                ,10842174818 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 500860   nrdconta
                                ,2        inpessoa
                                ,21316580 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 699853     nrdconta
                                ,1          inpessoa
                                ,5717135998 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 701998   nrdconta
                                ,2        inpessoa
                                ,11254114 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 585645      nrdconta
                                ,1           inpessoa
                                ,63489783972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725404   nrdconta
                                ,2        inpessoa
                                ,33830825 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 689602     nrdconta
                                ,1          inpessoa
                                ,6875489937 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735876     nrdconta
                                ,1          inpessoa
                                ,4851930941 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 758124      nrdconta
                                ,1           inpessoa
                                ,10142058912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 614084     nrdconta
                                ,1          inpessoa
                                ,5387912929 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 523160     nrdconta
                                ,1          inpessoa
                                ,1305977912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 397393     nrdconta
                                ,1          inpessoa
                                ,5556304980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 717207   nrdconta
                                ,2        inpessoa
                                ,27844142 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 545490   nrdconta
                                ,2        inpessoa
                                ,86841129 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 607282     nrdconta
                                ,1          inpessoa
                                ,5019832952 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 680052      nrdconta
                                ,1           inpessoa
                                ,11782529900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 659690      nrdconta
                                ,1           inpessoa
                                ,21757748806 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 166146     nrdconta
                                ,1          inpessoa
                                ,2141638909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 595233     nrdconta
                                ,1          inpessoa
                                ,7606553912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 302309      nrdconta
                                ,1           inpessoa
                                ,89851153915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 196223     nrdconta
                                ,1          inpessoa
                                ,6116583997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 205460     nrdconta
                                ,1          inpessoa
                                ,4875871970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 426121     nrdconta
                                ,1          inpessoa
                                ,2707001961 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 477451      nrdconta
                                ,1           inpessoa
                                ,68421907972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 767280   nrdconta
                                ,2        inpessoa
                                ,23692651 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 941760      nrdconta
                                ,1           inpessoa
                                ,10273692941 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 472611   nrdconta
                                ,2        inpessoa
                                ,11938304 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743305      nrdconta
                                ,1           inpessoa
                                ,80101166966 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 720828      nrdconta
                                ,1           inpessoa
                                ,90176480900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 700479   nrdconta
                                ,2        inpessoa
                                ,14963605 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764361   nrdconta
                                ,2        inpessoa
                                ,34459625 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 697079     nrdconta
                                ,1          inpessoa
                                ,3105926909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 656879   nrdconta
                                ,2        inpessoa
                                ,10782909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 646067     nrdconta
                                ,1          inpessoa
                                ,6566918914 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 663328   nrdconta
                                ,2        inpessoa
                                ,12094265 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 459844     nrdconta
                                ,1          inpessoa
                                ,6920148960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 811319     nrdconta
                                ,1          inpessoa
                                ,9015576920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 750565     nrdconta
                                ,1          inpessoa
                                ,5745625910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 622249   nrdconta
                                ,2        inpessoa
                                ,29601212 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 643190  nrdconta
                                ,2       inpessoa
                                ,5935132 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 496731     nrdconta
                                ,1          inpessoa
                                ,4505159906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 845744   nrdconta
                                ,2        inpessoa
                                ,36340153 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 370932     nrdconta
                                ,1          inpessoa
                                ,2857061951 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765651      nrdconta
                                ,1           inpessoa
                                ,78668239953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754463    nrdconta
                                ,1         inpessoa
                                ,735713936 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 604968     nrdconta
                                ,1          inpessoa
                                ,9639371971 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 862177   nrdconta
                                ,2        inpessoa
                                ,26983535 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 746622      nrdconta
                                ,1           inpessoa
                                ,10003246990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 780260      nrdconta
                                ,1           inpessoa
                                ,92345816953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 651362   nrdconta
                                ,2        inpessoa
                                ,22857732 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 766275     nrdconta
                                ,1          inpessoa
                                ,2923218990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 202223  nrdconta
                                ,2       inpessoa
                                ,5897312 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 511536      nrdconta
                                ,1           inpessoa
                                ,67342418900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 463388   nrdconta
                                ,2        inpessoa
                                ,15040270 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755338      nrdconta
                                ,1           inpessoa
                                ,10309277906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755044     nrdconta
                                ,1          inpessoa
                                ,3244808905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 561134      nrdconta
                                ,1           inpessoa
                                ,49120301634 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 209376   nrdconta
                                ,2        inpessoa
                                ,11514235 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 707503     nrdconta
                                ,1          inpessoa
                                ,8645956977 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 467030    nrdconta
                                ,1         inpessoa
                                ,476186986 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 800210     nrdconta
                                ,1          inpessoa
                                ,3089646838 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 697400   nrdconta
                                ,2        inpessoa
                                ,13429771 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 409960    nrdconta
                                ,1         inpessoa
                                ,394532945 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 620424      nrdconta
                                ,1           inpessoa
                                ,60057203920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 318922      nrdconta
                                ,1           inpessoa
                                ,42404126920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 884081   nrdconta
                                ,2        inpessoa
                                ,36606984 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 659630  nrdconta
                                ,2       inpessoa
                                ,3626867 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 854840     nrdconta
                                ,1          inpessoa
                                ,7139065969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 637530   nrdconta
                                ,2        inpessoa
                                ,29959138 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 695378     nrdconta
                                ,1          inpessoa
                                ,4796443908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 158003      nrdconta
                                ,1           inpessoa
                                ,72006188968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 735477     nrdconta
                                ,1          inpessoa
                                ,8673943744 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 763632     nrdconta
                                ,1          inpessoa
                                ,2270718917 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 587940   nrdconta
                                ,2        inpessoa
                                ,13594781 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 356441      nrdconta
                                ,1           inpessoa
                                ,48629634987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 786381     nrdconta
                                ,1          inpessoa
                                ,2036133924 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 805157     nrdconta
                                ,1          inpessoa
                                ,6971872509 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725161     nrdconta
                                ,1          inpessoa
                                ,7806768904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 299049      nrdconta
                                ,1           inpessoa
                                ,90231473915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 529567   nrdconta
                                ,2        inpessoa
                                ,23680396 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 543080      nrdconta
                                ,1           inpessoa
                                ,94833338904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 697621   nrdconta
                                ,2        inpessoa
                                ,85309516 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 759970      nrdconta
                                ,1           inpessoa
                                ,72494565200 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 598364     nrdconta
                                ,1          inpessoa
                                ,6133446935 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 342750   nrdconta
                                ,2        inpessoa
                                ,22511856 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 159905      nrdconta
                                ,1           inpessoa
                                ,72733888900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 768596  nrdconta
                                ,2       inpessoa
                                ,3281036 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 562947     nrdconta
                                ,1          inpessoa
                                ,9481008932 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 706850   nrdconta
                                ,2        inpessoa
                                ,16573152 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 730939   nrdconta
                                ,2        inpessoa
                                ,18091161 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 631922   nrdconta
                                ,2        inpessoa
                                ,30483319 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 547107   nrdconta
                                ,2        inpessoa
                                ,21090023 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 620874   nrdconta
                                ,2        inpessoa
                                ,26009745 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765538     nrdconta
                                ,1          inpessoa
                                ,4238404955 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 720933     nrdconta
                                ,1          inpessoa
                                ,2790308942 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 590355      nrdconta
                                ,1           inpessoa
                                ,69998574749 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 294624  nrdconta
                                ,2       inpessoa
                                ,8689455 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 880060      nrdconta
                                ,1           inpessoa
                                ,12391589476 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 395528     nrdconta
                                ,1          inpessoa
                                ,1954519966 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 780294   nrdconta
                                ,2        inpessoa
                                ,23284129 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 744557     nrdconta
                                ,1          inpessoa
                                ,4265141900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 696889    nrdconta
                                ,1         inpessoa
                                ,384484913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 149306     nrdconta
                                ,1          inpessoa
                                ,6873607908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 712450     nrdconta
                                ,1          inpessoa
                                ,6945642909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 521132   nrdconta
                                ,2        inpessoa
                                ,22066941 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 759678     nrdconta
                                ,1          inpessoa
                                ,4863794266 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 342777     nrdconta
                                ,1          inpessoa
                                ,9621939925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 623865     nrdconta
                                ,1          inpessoa
                                ,7325891938 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 653004      nrdconta
                                ,1           inpessoa
                                ,72312378949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 607754   nrdconta
                                ,2        inpessoa
                                ,11522631 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 599433     nrdconta
                                ,1          inpessoa
                                ,8602755902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 697010     nrdconta
                                ,1          inpessoa
                                ,9449389900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 816752     nrdconta
                                ,1          inpessoa
                                ,5917898928 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 610887    nrdconta
                                ,1         inpessoa
                                ,629955964 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 704059   nrdconta
                                ,2        inpessoa
                                ,17888740 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 192546      nrdconta
                                ,1           inpessoa
                                ,82129410944 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 622338   nrdconta
                                ,2        inpessoa
                                ,30078933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 317160     nrdconta
                                ,1          inpessoa
                                ,4494936952 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 723843    nrdconta
                                ,1         inpessoa
                                ,908113994 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 588733    nrdconta
                                ,1         inpessoa
                                ,646233947 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 534269      nrdconta
                                ,1           inpessoa
                                ,84634561972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 552070   nrdconta
                                ,2        inpessoa
                                ,17308023 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 804371     nrdconta
                                ,1          inpessoa
                                ,1373548274 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 379921 nrdconta
                                ,2      inpessoa
                                ,584303 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 427926     nrdconta
                                ,1          inpessoa
                                ,9104395913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 576190   nrdconta
                                ,2        inpessoa
                                ,21122675 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 739359   nrdconta
                                ,2        inpessoa
                                ,29814091 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 770400      nrdconta
                                ,1           inpessoa
                                ,59238046034 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 672602      nrdconta
                                ,1           inpessoa
                                ,72228261904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 344915   nrdconta
                                ,2        inpessoa
                                ,24523628 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 758825      nrdconta
                                ,1           inpessoa
                                ,98793411987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 691470     nrdconta
                                ,1          inpessoa
                                ,1012552926 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 751103     nrdconta
                                ,1          inpessoa
                                ,1010623974 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 382701     nrdconta
                                ,1          inpessoa
                                ,7869228931 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 724904     nrdconta
                                ,1          inpessoa
                                ,1203753039 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 331961      nrdconta
                                ,1           inpessoa
                                ,70297858270 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 346292      nrdconta
                                ,1           inpessoa
                                ,99078309920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 804819   nrdconta
                                ,2        inpessoa
                                ,36129537 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 723061     nrdconta
                                ,1          inpessoa
                                ,4542387976 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 748129   nrdconta
                                ,2        inpessoa
                                ,34331914 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 715506     nrdconta
                                ,1          inpessoa
                                ,1931986908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 708402     nrdconta
                                ,1          inpessoa
                                ,6324701948 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 651850   nrdconta
                                ,2        inpessoa
                                ,31513006 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 713171      nrdconta
                                ,1           inpessoa
                                ,89109546987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 521000   nrdconta
                                ,2        inpessoa
                                ,22732339 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 454060      nrdconta
                                ,1           inpessoa
                                ,24656425885 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 851000   nrdconta
                                ,2        inpessoa
                                ,18597718 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 590096     nrdconta
                                ,1          inpessoa
                                ,2956678930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 798258   nrdconta
                                ,2        inpessoa
                                ,35988174 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 651532   nrdconta
                                ,2        inpessoa
                                ,27610756 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 611735   nrdconta
                                ,2        inpessoa
                                ,15593929 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 951366     nrdconta
                                ,1          inpessoa
                                ,4932814950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 201103     nrdconta
                                ,1          inpessoa
                                ,6685630957 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 737941  nrdconta
                                ,2       inpessoa
                                ,7847108 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 587486   nrdconta
                                ,2        inpessoa
                                ,27736937 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 599921   nrdconta
                                ,2        inpessoa
                                ,18428827 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764973      nrdconta
                                ,1           inpessoa
                                ,72061189920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 560103     nrdconta
                                ,1          inpessoa
                                ,9527527945 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 787256   nrdconta
                                ,2        inpessoa
                                ,35606941 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 220531     nrdconta
                                ,1          inpessoa
                                ,8877900970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 727008   nrdconta
                                ,2        inpessoa
                                ,12212805 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764566     nrdconta
                                ,1          inpessoa
                                ,4371293905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 453900    nrdconta
                                ,1         inpessoa
                                ,358422965 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 861626  nrdconta
                                ,2       inpessoa
                                ,5137265 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 580180      nrdconta
                                ,1           inpessoa
                                ,77782259991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 566870  nrdconta
                                ,2       inpessoa
                                ,3644855 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 718408      nrdconta
                                ,1           inpessoa
                                ,47705060906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 671428   nrdconta
                                ,2        inpessoa
                                ,12673973 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 51314       nrdconta
                                ,1           inpessoa
                                ,62895648972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 685755      nrdconta
                                ,1           inpessoa
                                ,59642041987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 493651      nrdconta
                                ,1           inpessoa
                                ,32026798800 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 520926     nrdconta
                                ,1          inpessoa
                                ,9128185900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 344850     nrdconta
                                ,1          inpessoa
                                ,5561315927 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 781541   nrdconta
                                ,2        inpessoa
                                ,31657942 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 612642  nrdconta
                                ,2       inpessoa
                                ,1280366 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 239879      nrdconta
                                ,1           inpessoa
                                ,18600794900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 478067   nrdconta
                                ,2        inpessoa
                                ,19198349 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 763594      nrdconta
                                ,1           inpessoa
                                ,81594259100 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 648779     nrdconta
                                ,1          inpessoa
                                ,6683673934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 857076   nrdconta
                                ,2        inpessoa
                                ,80664535 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 710024     nrdconta
                                ,1          inpessoa
                                ,5837133941 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 468193    nrdconta
                                ,1         inpessoa
                                ,355741946 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 560057      nrdconta
                                ,1           inpessoa
                                ,89184386991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 722570      nrdconta
                                ,1           inpessoa
                                ,52034186915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 778729      nrdconta
                                ,1           inpessoa
                                ,90282469915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 219770     nrdconta
                                ,1          inpessoa
                                ,7329673927 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 303690    nrdconta
                                ,1         inpessoa
                                ,951465988 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 686980     nrdconta
                                ,1          inpessoa
                                ,5209593967 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 623423     nrdconta
                                ,1          inpessoa
                                ,9822841957 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 373109     nrdconta
                                ,1          inpessoa
                                ,7856312912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 727962     nrdconta
                                ,1          inpessoa
                                ,2307005943 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 429619   nrdconta
                                ,2        inpessoa
                                ,22210446 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 549045     nrdconta
                                ,1          inpessoa
                                ,6141431950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 252506    nrdconta
                                ,1         inpessoa
                                ,408071931 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 448281     nrdconta
                                ,1          inpessoa
                                ,5913280970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 516120 nrdconta
                                ,2      inpessoa
                                ,241553 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 652717     nrdconta
                                ,1          inpessoa
                                ,4350078908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 608971   nrdconta
                                ,2        inpessoa
                                ,28422997 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 883557      nrdconta
                                ,1           inpessoa
                                ,54078326072 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 359041     nrdconta
                                ,1          inpessoa
                                ,7167951919 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765678    nrdconta
                                ,1         inpessoa
                                ,608964263 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 704660     nrdconta
                                ,1          inpessoa
                                ,3901142940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 388246      nrdconta
                                ,1           inpessoa
                                ,44273185920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 567051     nrdconta
                                ,1          inpessoa
                                ,4502037940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 508764      nrdconta
                                ,1           inpessoa
                                ,61832251934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 756644      nrdconta
                                ,1           inpessoa
                                ,13974354964 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 746649      nrdconta
                                ,1           inpessoa
                                ,10444745998 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 872482   nrdconta
                                ,2        inpessoa
                                ,37993783 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 707724   nrdconta
                                ,2        inpessoa
                                ,85290302 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 442208      nrdconta
                                ,1           inpessoa
                                ,93656084904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 712264     nrdconta
                                ,1          inpessoa
                                ,8113836950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 488950      nrdconta
                                ,1           inpessoa
                                ,56833865949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 825484   nrdconta
                                ,2        inpessoa
                                ,32804084 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 502812      nrdconta
                                ,1           inpessoa
                                ,52034240987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765260   nrdconta
                                ,2        inpessoa
                                ,34897748 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 734640      nrdconta
                                ,1           inpessoa
                                ,10038478978 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 319821     nrdconta
                                ,1          inpessoa
                                ,5881263901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 620378      nrdconta
                                ,1           inpessoa
                                ,64428010982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 674028     nrdconta
                                ,1          inpessoa
                                ,1351048902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 597970  nrdconta
                                ,2       inpessoa
                                ,4600836 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 755680      nrdconta
                                ,1           inpessoa
                                ,12467187900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 729167   nrdconta
                                ,2        inpessoa
                                ,11406708 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 807478   nrdconta
                                ,2        inpessoa
                                ,34866118 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 505390      nrdconta
                                ,1           inpessoa
                                ,86376187900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 733032   nrdconta
                                ,2        inpessoa
                                ,24951866 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 702528   nrdconta
                                ,2        inpessoa
                                ,20446277 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 758558     nrdconta
                                ,1          inpessoa
                                ,5098085900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 466093     nrdconta
                                ,1          inpessoa
                                ,7497496956 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 616885   nrdconta
                                ,2        inpessoa
                                ,18974382 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 488348      nrdconta
                                ,1           inpessoa
                                ,47705060906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 747181   nrdconta
                                ,2        inpessoa
                                ,32079649 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 967459      nrdconta
                                ,1           inpessoa
                                ,31981502807 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 702579     nrdconta
                                ,1          inpessoa
                                ,6785852960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 836338   nrdconta
                                ,2        inpessoa
                                ,36279590 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 759961    nrdconta
                                ,1         inpessoa
                                ,884415988 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 727628   nrdconta
                                ,2        inpessoa
                                ,23701355 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 317098      nrdconta
                                ,1           inpessoa
                                ,57379645900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 685984  nrdconta
                                ,2       inpessoa
                                ,8638409 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 742961      nrdconta
                                ,1           inpessoa
                                ,66879590268 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 529133   nrdconta
                                ,2        inpessoa
                                ,17631757 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 710792   nrdconta
                                ,2        inpessoa
                                ,28012296 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 576832     nrdconta
                                ,1          inpessoa
                                ,7440525990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 691534     nrdconta
                                ,1          inpessoa
                                ,7137250955 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 351687     nrdconta
                                ,1          inpessoa
                                ,7535585990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 597872   nrdconta
                                ,2        inpessoa
                                ,17380900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725870    nrdconta
                                ,1         inpessoa
                                ,794008925 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 605921     nrdconta
                                ,1          inpessoa
                                ,9904556962 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 308056    nrdconta
                                ,1         inpessoa
                                ,392585995 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 752428   nrdconta
                                ,2        inpessoa
                                ,34547301 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 218944   nrdconta
                                ,2        inpessoa
                                ,24406606 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 503720     nrdconta
                                ,1          inpessoa
                                ,9093774999 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 725811   nrdconta
                                ,2        inpessoa
                                ,17740314 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 633917     nrdconta
                                ,1          inpessoa
                                ,5485692907 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 722200     nrdconta
                                ,1          inpessoa
                                ,8157733901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 505811      nrdconta
                                ,1           inpessoa
                                ,85103314991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 506265  nrdconta
                                ,2       inpessoa
                                ,3724955 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 218618      nrdconta
                                ,1           inpessoa
                                ,10394596927 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 581313      nrdconta
                                ,1           inpessoa
                                ,93653336953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 958905      nrdconta
                                ,1           inpessoa
                                ,91434815900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 768618  nrdconta
                                ,2       inpessoa
                                ,2291302 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 465658      nrdconta
                                ,1           inpessoa
                                ,45780889953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 518492     nrdconta
                                ,1          inpessoa
                                ,4159957609 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 508624     nrdconta
                                ,1          inpessoa
                                ,7311005906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 618705   nrdconta
                                ,2        inpessoa
                                ,19293693 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 647144      nrdconta
                                ,1           inpessoa
                                ,11559027932 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 674893   nrdconta
                                ,2        inpessoa
                                ,21520795 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 599948     nrdconta
                                ,1          inpessoa
                                ,2289283975 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 750182  nrdconta
                                ,2       inpessoa
                                ,8820171 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 748706      nrdconta
                                ,1           inpessoa
                                ,66597102991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 449180   nrdconta
                                ,2        inpessoa
                                ,17453629 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 774090      nrdconta
                                ,1           inpessoa
                                ,10425169952 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 488917     nrdconta
                                ,1          inpessoa
                                ,4400329976 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 651826      nrdconta
                                ,1           inpessoa
                                ,48966339972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764590      nrdconta
                                ,1           inpessoa
                                ,82108897968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 319171      nrdconta
                                ,1           inpessoa
                                ,43659683949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 550213     nrdconta
                                ,1          inpessoa
                                ,9257461939 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 488801     nrdconta
                                ,1          inpessoa
                                ,9511594966 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 740055     nrdconta
                                ,1          inpessoa
                                ,9640180980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 852295     nrdconta
                                ,1          inpessoa
                                ,5359950919 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 747246     nrdconta
                                ,1          inpessoa
                                ,8036120950 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 637696   nrdconta
                                ,2        inpessoa
                                ,19099634 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 737496      nrdconta
                                ,1           inpessoa
                                ,12768194980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 739626      nrdconta
                                ,1           inpessoa
                                ,12332986901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 807761   nrdconta
                                ,2        inpessoa
                                ,32893857 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 635731   nrdconta
                                ,2        inpessoa
                                ,28353237 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 372722     nrdconta
                                ,1          inpessoa
                                ,2512732967 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 226858     nrdconta
                                ,1          inpessoa
                                ,3525725906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 484636   nrdconta
                                ,2        inpessoa
                                ,83197376 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 443255      nrdconta
                                ,1           inpessoa
                                ,59482087968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 639052   nrdconta
                                ,2        inpessoa
                                ,30898476 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 215716   nrdconta
                                ,2        inpessoa
                                ,23935509 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 530506     nrdconta
                                ,1          inpessoa
                                ,7497672940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 736511      nrdconta
                                ,1           inpessoa
                                ,11743787944 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 678490   nrdconta
                                ,2        inpessoa
                                ,13726181 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 733342     nrdconta
                                ,1          inpessoa
                                ,9444055922 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 462365     nrdconta
                                ,1          inpessoa
                                ,2396825992 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 633747      nrdconta
                                ,1           inpessoa
                                ,65801210920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 836699      nrdconta
                                ,1           inpessoa
                                ,11387645900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 460974      nrdconta
                                ,1           inpessoa
                                ,44067208987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 746606   nrdconta
                                ,2        inpessoa
                                ,26470888 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 239666     nrdconta
                                ,1          inpessoa
                                ,9365658969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 657557   nrdconta
                                ,2        inpessoa
                                ,21228905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 196363      nrdconta
                                ,1           inpessoa
                                ,96950978987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 722073   nrdconta
                                ,2        inpessoa
                                ,31309766 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 433179    nrdconta
                                ,1         inpessoa
                                ,921991940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 446351      nrdconta
                                ,1           inpessoa
                                ,40178269972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 590479   nrdconta
                                ,2        inpessoa
                                ,26182582 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 623938   nrdconta
                                ,2        inpessoa
                                ,22205811 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 397563     nrdconta
                                ,1          inpessoa
                                ,6281291905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 515760      nrdconta
                                ,1           inpessoa
                                ,78536987987 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 671754     nrdconta
                                ,1          inpessoa
                                ,4696555933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 753300     nrdconta
                                ,1          inpessoa
                                ,7180972975 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 634425     nrdconta
                                ,1          inpessoa
                                ,8758046917 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 760730      nrdconta
                                ,1           inpessoa
                                ,70148245110 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 850241     nrdconta
                                ,1          inpessoa
                                ,5462201931 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 919446     nrdconta
                                ,1          inpessoa
                                ,9038039921 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 599662     nrdconta
                                ,1          inpessoa
                                ,9341454905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 700711   nrdconta
                                ,2        inpessoa
                                ,17061869 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 733393      nrdconta
                                ,1           inpessoa
                                ,89029232900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 459836   nrdconta
                                ,2        inpessoa
                                ,15175827 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 316776      nrdconta
                                ,1           inpessoa
                                ,69686530010 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 675237      nrdconta
                                ,1           inpessoa
                                ,11320658954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 385794   nrdconta
                                ,2        inpessoa
                                ,83791418 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 731358     nrdconta
                                ,1          inpessoa
                                ,2377657990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 766828      nrdconta
                                ,1           inpessoa
                                ,55600034920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 672041      nrdconta
                                ,1           inpessoa
                                ,38403234953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 381969     nrdconta
                                ,1          inpessoa
                                ,4812059933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 792586   nrdconta
                                ,2        inpessoa
                                ,27037428 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754986      nrdconta
                                ,1           inpessoa
                                ,13832542906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 699250   nrdconta
                                ,2        inpessoa
                                ,32047887 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 604267   nrdconta
                                ,2        inpessoa
                                ,23046379 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 825654      nrdconta
                                ,1           inpessoa
                                ,11395283940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 432598    nrdconta
                                ,1         inpessoa
                                ,400020980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 678180      nrdconta
                                ,1           inpessoa
                                ,79197051934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 751669      nrdconta
                                ,1           inpessoa
                                ,10665503954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 718548      nrdconta
                                ,1           inpessoa
                                ,12686599910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 556610     nrdconta
                                ,1          inpessoa
                                ,9493652971 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 630365   nrdconta
                                ,2        inpessoa
                                ,29913367 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 314811      nrdconta
                                ,1           inpessoa
                                ,89018117900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 309630     nrdconta
                                ,1          inpessoa
                                ,6083562988 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 733270      nrdconta
                                ,1           inpessoa
                                ,67339131949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 986577      nrdconta
                                ,1           inpessoa
                                ,61531146953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 746029   nrdconta
                                ,2        inpessoa
                                ,34370944 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 1002546 nrdconta
                                ,2       inpessoa
                                ,3771559 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 652377   nrdconta
                                ,2        inpessoa
                                ,27152659 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 409472     nrdconta
                                ,1          inpessoa
                                ,4181505910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 385328     nrdconta
                                ,1          inpessoa
                                ,4558021909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 717037   nrdconta
                                ,2        inpessoa
                                ,33257721 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 660299     nrdconta
                                ,1          inpessoa
                                ,8553443930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 970611   nrdconta
                                ,2        inpessoa
                                ,14007780 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765333   nrdconta
                                ,2        inpessoa
                                ,17298462 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 308757     nrdconta
                                ,1          inpessoa
                                ,6940071962 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 654388   nrdconta
                                ,2        inpessoa
                                ,29927304 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 606510      nrdconta
                                ,1           inpessoa
                                ,29197350125 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 651567    nrdconta
                                ,1         inpessoa
                                ,409835951 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 764655   nrdconta
                                ,2        inpessoa
                                ,30910462 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 596302     nrdconta
                                ,1          inpessoa
                                ,3687298930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 719013      nrdconta
                                ,1           inpessoa
                                ,12452172910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 765783     nrdconta
                                ,1          inpessoa
                                ,9717320942 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 727610     nrdconta
                                ,1          inpessoa
                                ,5430959910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 801828     nrdconta
                                ,1          inpessoa
                                ,4507362962 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 922501   nrdconta
                                ,2        inpessoa
                                ,34475438 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 648507      nrdconta
                                ,1           inpessoa
                                ,53100611934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 728845      nrdconta
                                ,1           inpessoa
                                ,12685851909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 630403      nrdconta
                                ,1           inpessoa
                                ,11204004900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 621480     nrdconta
                                ,1          inpessoa
                                ,6780508993 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 663344     nrdconta
                                ,1          inpessoa
                                ,9181197900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 757586      nrdconta
                                ,1           inpessoa
                                ,11470595940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 628697     nrdconta
                                ,1          inpessoa
                                ,1863628975 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 871893     nrdconta
                                ,1          inpessoa
                                ,3478566916 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 460478     nrdconta
                                ,1          inpessoa
                                ,7099829920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 704326    nrdconta
                                ,1         inpessoa
                                ,757079938 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 995304     nrdconta
                                ,1          inpessoa
                                ,6673768959 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 729345    nrdconta
                                ,1         inpessoa
                                ,495860921 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 785628     nrdconta
                                ,1          inpessoa
                                ,8651994931 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 544388      nrdconta
                                ,1           inpessoa
                                ,98854259934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 446092     nrdconta
                                ,1          inpessoa
                                ,8859010969 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 509191     nrdconta
                                ,1          inpessoa
                                ,7106376914 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 295175    nrdconta
                                ,1         inpessoa
                                ,358708931 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 497290     nrdconta
                                ,1          inpessoa
                                ,2590726996 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 384747      nrdconta
                                ,1           inpessoa
                                ,72046449991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 635499   nrdconta
                                ,2        inpessoa
                                ,27782419 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 791296      nrdconta
                                ,1           inpessoa
                                ,12925106927 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 627739   nrdconta
                                ,2        inpessoa
                                ,27879214 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754145      nrdconta
                                ,1           inpessoa
                                ,75899426187 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 861227      nrdconta
                                ,1           inpessoa
                                ,11100067485 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 612677     nrdconta
                                ,1          inpessoa
                                ,5760710567 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 506923     nrdconta
                                ,1          inpessoa
                                ,1624848958 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 446670      nrdconta
                                ,1           inpessoa
                                ,51240629915 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 889075     nrdconta
                                ,1          inpessoa
                                ,5213203990 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 317322      nrdconta
                                ,1           inpessoa
                                ,51705273904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732346      nrdconta
                                ,1           inpessoa
                                ,60379286904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 724980      nrdconta
                                ,1           inpessoa
                                ,11522064940 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 252484      nrdconta
                                ,1           inpessoa
                                ,10516154885 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 708380     nrdconta
                                ,1          inpessoa
                                ,9393097933 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 744107     nrdconta
                                ,1          inpessoa
                                ,9259892902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 387142    nrdconta
                                ,1         inpessoa
                                ,908618921 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 301701     nrdconta
                                ,1          inpessoa
                                ,7462400901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 785997      nrdconta
                                ,1           inpessoa
                                ,42830897889 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 843440     nrdconta
                                ,1          inpessoa
                                ,3634182962 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 818968     nrdconta
                                ,1          inpessoa
                                ,2101055937 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 699357   nrdconta
                                ,2        inpessoa
                                ,32261787 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 770167   nrdconta
                                ,2        inpessoa
                                ,23433116 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 640255  nrdconta
                                ,2       inpessoa
                                ,5950769 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 225428     nrdconta
                                ,1          inpessoa
                                ,4191737902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 737674   nrdconta
                                ,2        inpessoa
                                ,20083025 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 636487  nrdconta
                                ,2       inpessoa
                                ,5304188 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 196860      nrdconta
                                ,1           inpessoa
                                ,38268647949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 865150     nrdconta
                                ,1          inpessoa
                                ,7553700908 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 235261   nrdconta
                                ,2        inpessoa
                                ,24277338 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 455067      nrdconta
                                ,1           inpessoa
                                ,68463227953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 730874      nrdconta
                                ,1           inpessoa
                                ,11899775919 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 775053     nrdconta
                                ,1          inpessoa
                                ,9050730965 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 842320 nrdconta
                                ,2      inpessoa
                                ,736662 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 842893     nrdconta
                                ,1          inpessoa
                                ,6063210989 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 759449     nrdconta
                                ,1          inpessoa
                                ,7781505930 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 645206      nrdconta
                                ,1           inpessoa
                                ,79183050949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 673307   nrdconta
                                ,2        inpessoa
                                ,31485641 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 331350      nrdconta
                                ,1           inpessoa
                                ,48758507191 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 744000   nrdconta
                                ,2        inpessoa
                                ,23036948 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 591815     nrdconta
                                ,1          inpessoa
                                ,5196714901 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 503207     nrdconta
                                ,1          inpessoa
                                ,8727401960 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 750050    nrdconta
                                ,1         inpessoa
                                ,951465988 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 604240     nrdconta
                                ,1          inpessoa
                                ,9131667902 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 664006     nrdconta
                                ,1          inpessoa
                                ,3471686983 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 730807   nrdconta
                                ,2        inpessoa
                                ,26651705 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 473413   nrdconta
                                ,2        inpessoa
                                ,20821614 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 313645     nrdconta
                                ,1          inpessoa
                                ,3419485948 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 548448     nrdconta
                                ,1          inpessoa
                                ,3213953954 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 636975    nrdconta
                                ,1         inpessoa
                                ,366905970 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 550655     nrdconta
                                ,1          inpessoa
                                ,4812011906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 635839      nrdconta
                                ,1           inpessoa
                                ,11542463963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 404780    nrdconta
                                ,1         inpessoa
                                ,451262913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 489018      nrdconta
                                ,1           inpessoa
                                ,43994660904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 711977     nrdconta
                                ,1          inpessoa
                                ,3667976976 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 432806   nrdconta
                                ,2        inpessoa
                                ,26223425 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 933457      nrdconta
                                ,1           inpessoa
                                ,12245543963 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 166820     nrdconta
                                ,1          inpessoa
                                ,9534883905 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 749850     nrdconta
                                ,1          inpessoa
                                ,7831191941 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 388599      nrdconta
                                ,1           inpessoa
                                ,60053330978 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 564460   nrdconta
                                ,2        inpessoa
                                ,22068865 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 882178     nrdconta
                                ,1          inpessoa
                                ,5808640903 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 675466   nrdconta
                                ,2        inpessoa
                                ,26027271 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 542822   nrdconta
                                ,2        inpessoa
                                ,16818754 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 761230      nrdconta
                                ,1           inpessoa
                                ,66046190010 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 726745    nrdconta
                                ,1         inpessoa
                                ,773914978 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 791660   nrdconta
                                ,2        inpessoa
                                ,34626277 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 737852      nrdconta
                                ,1           inpessoa
                                ,75091160906 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 867489      nrdconta
                                ,1           inpessoa
                                ,81763905934 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 456470    nrdconta
                                ,1         inpessoa
                                ,535541910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 433209   nrdconta
                                ,2        inpessoa
                                ,26205727 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 582131     nrdconta
                                ,1          inpessoa
                                ,3597516955 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 605379   nrdconta
                                ,2        inpessoa
                                ,28960143 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 774502      nrdconta
                                ,1           inpessoa
                                ,61289434972 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 548294     nrdconta
                                ,1          inpessoa
                                ,2922664996 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 757624     nrdconta
                                ,1          inpessoa
                                ,6659145982 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 374954      nrdconta
                                ,1           inpessoa
                                ,71474927904 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 693421      nrdconta
                                ,1           inpessoa
                                ,89112237949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 859613   nrdconta
                                ,2        inpessoa
                                ,35671686 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 486868   nrdconta
                                ,2        inpessoa
                                ,16384882 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 658502   nrdconta
                                ,2        inpessoa
                                ,27306072 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 653233      nrdconta
                                ,1           inpessoa
                                ,11271263939 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 917591      nrdconta
                                ,1           inpessoa
                                ,45282551896 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 595691     nrdconta
                                ,1          inpessoa
                                ,8997844962 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 730980     nrdconta
                                ,1          inpessoa
                                ,4390422081 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 498335   nrdconta
                                ,2        inpessoa
                                ,26428786 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 692077   nrdconta
                                ,2        inpessoa
                                ,33059422 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 592960      nrdconta
                                ,1           inpessoa
                                ,90214773949 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 710237  nrdconta
                                ,2       inpessoa
                                ,2078433 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 716367   nrdconta
                                ,2        inpessoa
                                ,33345195 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 732435     nrdconta
                                ,1          inpessoa
                                ,4637344913 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 798517      nrdconta
                                ,1           inpessoa
                                ,86326945615 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 557498   nrdconta
                                ,2        inpessoa
                                ,10774605 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 658316     nrdconta
                                ,1          inpessoa
                                ,7441350956 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 536440      nrdconta
                                ,1           inpessoa
                                ,82453799991 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 228982      nrdconta
                                ,1           inpessoa
                                ,89072219953 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 820288   nrdconta
                                ,2        inpessoa
                                ,18597718 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 569925   nrdconta
                                ,2        inpessoa
                                ,27769197 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 302783      nrdconta
                                ,1           inpessoa
                                ,58922962968 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 946559      nrdconta
                                ,1           inpessoa
                                ,61039916333 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 677906     nrdconta
                                ,1          inpessoa
                                ,2028082976 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 518883   nrdconta
                                ,2        inpessoa
                                ,20044516 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 559091   nrdconta
                                ,2        inpessoa
                                ,19279227 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 561100     nrdconta
                                ,1          inpessoa
                                ,4555989910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 754234     nrdconta
                                ,1          inpessoa
                                ,8843036912 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 659851      nrdconta
                                ,1           inpessoa
                                ,59097760291 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 671720     nrdconta
                                ,1          inpessoa
                                ,4553794918 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 506788     nrdconta
                                ,1          inpessoa
                                ,8183375910 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 518727      nrdconta
                                ,1           inpessoa
                                ,79166547920 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 751162    nrdconta
                                ,1         inpessoa
                                ,498083977 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 743011     nrdconta
                                ,1          inpessoa
                                ,6945365980 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 655724   nrdconta
                                ,2        inpessoa
                                ,21259271 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 468487     nrdconta
                                ,1          inpessoa
                                ,3272225900 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 655414   nrdconta
                                ,2        inpessoa
                                ,31525593 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 790559   nrdconta
                                ,2        inpessoa
                                ,28971060 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 344311     nrdconta
                                ,1          inpessoa
                                ,1461170931 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 731790      nrdconta
                                ,1           inpessoa
                                ,10015503909 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 317683     nrdconta
                                ,1          inpessoa
                                ,5480081918 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 664944   nrdconta
                                ,2        inpessoa
                                ,31425043 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 612502  nrdconta
                                ,2       inpessoa
                                ,8821136 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 167495   nrdconta
                                ,2        inpessoa
                                ,22583729 nrcpfcnpj_base
                            FROM DUAL
                          UNION ALL
                          SELECT 681202    nrdconta
                                ,1         inpessoa
                                ,612568970 nrcpfcnpj_base
                            FROM DUAL  
                          UNION ALL
                          SELECT 583995   nrdconta
                                ,2        inpessoa
                                ,23590561 nrcpfcnpj_base
                            FROM DUAL) cnt
               /*    WHERE ((SELECT flglibera
                             FROM (SELECT h.*
                                     FROM tbcc_hist_param_pessoa_prod h
                                    WHERE h.cdcooper = 2
                                      AND h.cdproduto = 25 -- PreAprovado
                                      AND h.nrcpfcnpj_base = cnt.nrcpfcnpj_base
                                      AND (TRUNC(h.dtvigencia_paramet) IS NULL OR
                                          h.dtvigencia_paramet >= trunc(SYSDATE))
                                    ORDER BY h.idregistro DESC)
                            WHERE ROWNUM = 1) = 0)*/
                  
                  ) LOOP
    
      vr_dsmensagem := NULL;
      vr_nrregistro := vr_nrregistro + 1;
    
      BEGIN
      
        SELECT 1
          INTO vr_existe_ass
          FROM crapass ass
         WHERE ass.nrdconta = r_cnt.nrdconta
           AND ass.cdcooper = r_cnt.cdcooper;
      
      EXCEPTION
        WHEN OTHERS THEN
          vr_existe_ass := 0;
          vr_dsmensagem := 'Cooperado nao cadastrado';
      END;
    
      IF vr_existe_ass = 1 THEN
        
         OPEN cr_param (pr_cdcooper  => r_cnt.cdcooper,
                        pr_cpfcnpj   => r_cnt.nrcpfcnpj_base,
                        pr_tppessoa  => r_cnt.inpessoa);
         FETCH cr_param INTO rw_param;
         IF cr_param%NOTFOUND THEN      
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                         pr_des_text => vr_nrregistro || ';' || r_cnt.cdcooper || ';' ||
                                                        r_cnt.nrdconta || ';' || r_cnt.nrcpfcnpj_base || ';' ||
                                                        r_cnt.inpessoa|| ';' ||
                                                          'Nao encontrado Bloqueio tabela tbcc_param_pessoa_produto ');     
           vr_existe_ass:= 0;                                                                     
         ELSE

           OPEN his_param (pr_cdcooper  => r_cnt.cdcooper,
                          pr_cpfcnpj   => r_cnt.nrcpfcnpj_base,
                          pr_tppessoa  => r_cnt.inpessoa);
           FETCH his_param INTO rw_his_param;
           IF his_param%NOTFOUND THEN 
              vr_existe_ass:= 1;     
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                             pr_des_text => vr_nrregistro || ';' || r_cnt.cdcooper || ';' ||
                                                            r_cnt.nrdconta || ';' || r_cnt.nrcpfcnpj_base || ';' ||
                                                            r_cnt.inpessoa|| ';' ||
                                                            'Nao encontrado Historico de bloqueio, mesmo assim foi liberado');  
           ELSE
             IF rw_his_param.flglibera = 1 THEN
              vr_existe_ass:= 0;     
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                             pr_des_text => vr_nrregistro || ';' || r_cnt.cdcooper || ';' ||
                                                            r_cnt.nrdconta || ';' || r_cnt.nrcpfcnpj_base || ';' ||
                                                            r_cnt.inpessoa|| ';' ||
                                                            'Historico = liberado');                  
             END IF;
           END IF;
           CLOSE  his_param; 
         END IF;   
         CLOSE cr_param;
        
         
         IF  vr_existe_ass = 1 THEN  -- tudo certo, então faz processo            
           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                       pr_des_text => 'UPDATE  tbcc_param_pessoa_produto '||
                                                      ' set flglibera = 0'|| -- bloqueado
                                                      ' WHERE cdcooper = ' || r_cnt.cdcooper ||
                                                      '   AND cdproduto = 25 '||
                                                      '  AND nrcpfcnpj_base  = ' || r_cnt.nrcpfcnpj_base ||
                                                      '  AND tppessoa = ' || r_cnt.inpessoa || ';');

                 IF rw_his_param.dtvigencia_paramet is NULL THEN
                     vr_datavigencia := 'null';
                 ELSE    
                   vr_datavigencia := ''''||rw_his_param.dtvigencia_paramet||'''';
                 END IF;  
        
                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle,
                                         pr_des_text => 'INSERT INTO TBCC_HIST_PARAM_PESSOA_PROD(cdcooper,nrdconta,tppessoa,nrcpfcnpj_base,dtoperac, '||
                                                        'dtvigencia_paramet,cdproduto,cdoperac_produto,flglibera,idmotivo,cdoperad) '||                                  
                                                        ' VALUES(2,0,'
                                                        || rw_his_param.tppessoa ||','
                                                        || rw_his_param.nrcpfcnpj_base ||','
                                                        ||'sysdate,'
                                                        ||vr_datavigencia||','
                                                        || rw_his_param.cdproduto ||','
                                                        || rw_his_param.cdoperac_produto ||','
                                                        || rw_his_param.flglibera ||','
                                                        || rw_his_param.idmotivo ||','
                                                     || ''''||rw_his_param.cdoperad||'''' ||');'  );                                                      

         
              cada0006.pc_mantem_param_pessoa_prod(pr_cdcooper           => r_cnt.cdcooper,
                                                   pr_nrdconta           => r_cnt.nrdconta,
                                                   pr_cdproduto          => 25, -- 25-Pre-provado
                                                   pr_cdoperac_produto   => 1, -- Oferta
                                                   pr_flglibera          => 1,
                                                   pr_dtvigencia_paramet => NULL,
                                                   pr_idmotivo           => 19,
                                                   pr_cdoperad           => '1',
                                                   pr_idorigem           => 5,
                                                   pr_nmdatela           => 'ATENDA',
                                                   pr_dscritic           => vr_dscritic);
        END IF; --segundo if existe      
      END IF;
    
      IF vr_dscritic IS NOT NULL OR vr_dsmensagem IS NOT NULL THEN
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                       pr_des_text => vr_nrregistro || ';' || r_cnt.cdcooper || ';' ||
                                                      r_cnt.nrdconta || ';' || r_cnt.nrcpfcnpj_base || ';' ||
                                                      vr_dsmensagem);
      END IF;
    
    END LOOP;
  
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                   pr_des_text => 'Total de registros tratados no processo: ' ||
                                                  vr_nrregistro);

     gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                    ,pr_des_text => 'COMMIT;');
  
      COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                     pr_des_text => 'Erro: ' || vr_dsmensagem || ' SQLERRM: ' ||
                                                    SQLERRM);

     gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                    ,pr_des_text => 'COMMIT;');
      ROLLBACK;
  END;

  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
END;
/
