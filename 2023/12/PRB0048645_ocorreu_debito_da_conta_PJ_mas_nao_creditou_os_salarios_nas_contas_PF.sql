DECLARE 
  vr_nrdrowid        ROWID;
  vr_nmprograma      CECRED.tbgen_prglog.cdprograma%TYPE := 'Nao creditou salarios - PRB0048645';
   
  CURSOR cr_crapemp(pr_cdempres IN CECRED.crapemp.cdempres%TYPE) IS 
    SELECT *
      FROM CECRED.crapemp emp
     WHERE emp.cdempres = pr_cdempres
       AND emp.cdcooper = 12
       AND emp.nrdconta = 144290;
  rw_crapemp cr_crapemp%ROWTYPE;
BEGIN
  BEGIN
    OPEN cr_crapemp(pr_cdempres => 441);
    FETCH cr_crapemp INTO rw_crapemp;
    
    CECRED.GENE0001.pc_gera_log(pr_cdcooper => rw_crapemp.cdcooper
                               ,pr_nrdconta => rw_crapemp.nrdconta
                               ,pr_idseqttl => 1
                               ,pr_cdoperad => 't0035324'
                               ,pr_dscritic => 'Registro atualizado com sucesso.'
                               ,pr_dsorigem => 'PAGTO'
                               ,pr_dstransa => vr_nmprograma
                               ,pr_dttransa => TRUNC(SYSDATE)
                               ,pr_flgtrans => 1
                               ,pr_hrtransa => CECRED.GENE0002.fn_busca_time
                               ,pr_nmdatela => 'PRB0048645'
                               ,pr_nrdrowid => vr_nrdrowid);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.nmextemp'
                                    ,pr_dsdadant => rw_crapemp.nmextemp
                                    ,pr_dsdadatu => NULL);    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.nmresemp'
                                    ,pr_dsdadant => rw_crapemp.nmresemp
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.sgempres'
                                    ,pr_dsdadant => rw_crapemp.sgempres
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cddescto##1'
                                    ,pr_dsdadant => rw_crapemp.cddescto##1
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cddescto##2'
                                    ,pr_dsdadant => rw_crapemp.cddescto##2
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cddescto##3'
                                    ,pr_dsdadant => rw_crapemp.cddescto##3
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cddescto##4'
                                    ,pr_dsdadant => rw_crapemp.cddescto##4
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cddescto##5'
                                    ,pr_dsdadant => rw_crapemp.cddescto##5
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cddescto##6'
                                    ,pr_dsdadant => rw_crapemp.cddescto##6
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cddescto##7'
                                    ,pr_dsdadant => rw_crapemp.cddescto##7
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cddescto##8'
                                    ,pr_dsdadant => rw_crapemp.cddescto##8
                                    ,pr_dsdadatu => NULL);    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cddescto##9'
                                    ,pr_dsdadant => rw_crapemp.cddescto##9
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cddescto##10'
                                    ,pr_dsdadant => rw_crapemp.cddescto##10
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.dtavscot'
                                    ,pr_dsdadant => rw_crapemp.dtavscot
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.dtavsemp'
                                    ,pr_dsdadant => rw_crapemp.dtavsemp
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.inavscot'
                                    ,pr_dsdadant => rw_crapemp.inavscot
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.inavsemp'
                                    ,pr_dsdadant => rw_crapemp.inavsemp
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.tpdebcot'
                                    ,pr_dsdadant => rw_crapemp.tpdebcot
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.tpdebemp'
                                    ,pr_dsdadant => rw_crapemp.tpdebemp
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.tpdebden'
                                    ,pr_dsdadant => rw_crapemp.tpdebden
                                    ,pr_dsdadatu => NULL);                                                                                                                                                                                                                                    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.inavsden'
                                    ,pr_dsdadant => rw_crapemp.inavsden
                                    ,pr_dsdadatu => NULL);    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.dtavsden'
                                    ,pr_dsdadant => rw_crapemp.dtavsden
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.tpdebppr'
                                    ,pr_dsdadant => rw_crapemp.tpdebppr
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.inavsppr'
                                    ,pr_dsdadant => rw_crapemp.inavsppr
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.dtavsppr'
                                    ,pr_dsdadant => rw_crapemp.dtavsppr
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cdempfol'
                                    ,pr_dsdadant => rw_crapemp.cdempfol
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.flgpagto'
                                    ,pr_dsdadant => rw_crapemp.flgpagto
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.dtavsseg'
                                    ,pr_dsdadant => rw_crapemp.dtavsseg
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.inavsseg'
                                    ,pr_dsdadant => rw_crapemp.inavsseg
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.tpdebseg'
                                    ,pr_dsdadant => rw_crapemp.tpdebseg
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.dtavssau'
                                    ,pr_dsdadant => rw_crapemp.dtavssau
                                    ,pr_dsdadatu => NULL);    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.inavssau'
                                    ,pr_dsdadant => rw_crapemp.inavssau
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.tpdebsau'
                                    ,pr_dsdadant => rw_crapemp.tpdebsau
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.tpconven'
                                    ,pr_dsdadant => rw_crapemp.tpconven
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.indescsg'
                                    ,pr_dsdadant => rw_crapemp.indescsg
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.dtfchfol'
                                    ,pr_dsdadant => rw_crapemp.dtfchfol
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.nrarqepr'
                                    ,pr_dsdadant => rw_crapemp.nrarqepr
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.dsdemail'
                                    ,pr_dsdadant => rw_crapemp.dsdemail
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cdufdemp'
                                    ,pr_dsdadant => rw_crapemp.cdufdemp
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.nrdocnpj'
                                    ,pr_dsdadant => rw_crapemp.nrdocnpj
                                    ,pr_dsdadatu => NULL);     
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.dsendemp'
                                    ,pr_dsdadant => rw_crapemp.dsendemp
                                    ,pr_dsdadatu => NULL);    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.dscomple'
                                    ,pr_dsdadant => rw_crapemp.dscomple
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.nmbairro'
                                    ,pr_dsdadant => rw_crapemp.nmbairro
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.nrfonemp'
                                    ,pr_dsdadant => rw_crapemp.nrfonemp
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.nmcidade'
                                    ,pr_dsdadant => rw_crapemp.nmcidade
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.nrfaxemp'
                                    ,pr_dsdadant => rw_crapemp.nrfaxemp
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.nrcepend'
                                    ,pr_dsdadant => rw_crapemp.nrcepend
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.nrendemp'
                                    ,pr_dsdadant => rw_crapemp.nrendemp
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cdcooper'
                                    ,pr_dsdadant => rw_crapemp.cdcooper
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.flgarqrt'
                                    ,pr_dsdadant => rw_crapemp.flgarqrt
                                    ,pr_dsdadatu => NULL);    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.flgvlddv'
                                    ,pr_dsdadant => rw_crapemp.flgvlddv
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cdcontar'
                                    ,pr_dsdadant => rw_crapemp.cdcontar
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.nrdconta'
                                    ,pr_dsdadant => rw_crapemp.nrdconta
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.idtpempr'
                                    ,pr_dsdadant => rw_crapemp.idtpempr
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.dtultufp'
                                    ,pr_dsdadant => rw_crapemp.dtultufp
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.dtavsufp'
                                    ,pr_dsdadant => rw_crapemp.dtavsufp
                                    ,pr_dsdadatu => NULL);    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.flgpgtib'
                                    ,pr_dsdadant => rw_crapemp.flgpgtib
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.vllimfol'
                                    ,pr_dsdadant => rw_crapemp.vllimfol
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.nmcontat'
                                    ,pr_dsdadant => rw_crapemp.nmcontat
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.flgdgfib'
                                    ,pr_dsdadant => rw_crapemp.flgdgfib
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cdoperad'
                                    ,pr_dsdadant => rw_crapemp.cdoperad
                                    ,pr_dsdadatu => NULL);    
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cdopeori'
                                    ,pr_dsdadant => rw_crapemp.cdopeori
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.cdageori'
                                    ,pr_dsdadant => rw_crapemp.cdageori
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.dtinsori'
                                    ,pr_dsdadant => rw_crapemp.dtinsori
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.dtlimdeb'
                                    ,pr_dsdadant => rw_crapemp.dtlimdeb
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.dtinccan'
                                    ,pr_dsdadant => rw_crapemp.dtinccan
                                    ,pr_dsdadatu => NULL);
    CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                    ,pr_nmdcampo => 'crapemp.nrdddemp'
                                    ,pr_dsdadant => rw_crapemp.nrdddemp
                                    ,pr_dsdadatu => NULL); 
    CLOSE cr_crapemp;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    CECRED.pc_internal_exception(pr_cdcooper => 0
                                ,pr_compleme => ' Script: => ' || vr_nmprograma ||
                                                ' Etapa: 1 - Salvar log informacoes do registro antes do update'); 
  END;
  
  BEGIN 
    OPEN cr_crapemp(pr_cdempres => 442);
    FETCH cr_crapemp INTO rw_crapemp;
    
    UPDATE CECRED.crapemp emp
       SET emp.nmextemp     = rw_crapemp.nmextemp
          ,emp.nmresemp     = rw_crapemp.nmresemp
          ,emp.sgempres     = rw_crapemp.sgempres
          ,emp.cddescto##1  = rw_crapemp.cddescto##1
          ,emp.cddescto##2  = rw_crapemp.cddescto##2
          ,emp.cddescto##3  = rw_crapemp.cddescto##3
          ,emp.cddescto##4  = rw_crapemp.cddescto##4
          ,emp.cddescto##5  = rw_crapemp.cddescto##5
          ,emp.cddescto##6  = rw_crapemp.cddescto##6
          ,emp.cddescto##7  = rw_crapemp.cddescto##7
          ,emp.cddescto##8  = rw_crapemp.cddescto##8
          ,emp.cddescto##9  = rw_crapemp.cddescto##9
          ,emp.cddescto##10 = rw_crapemp.cddescto##10
          ,emp.dtavscot     = rw_crapemp.dtavscot
          ,emp.dtavsemp     = rw_crapemp.dtavsemp
          ,emp.inavscot     = rw_crapemp.inavscot
          ,emp.inavsemp     = rw_crapemp.inavsemp
          ,emp.tpdebcot     = rw_crapemp.tpdebcot
          ,emp.tpdebemp     = rw_crapemp.tpdebemp
          ,emp.tpdebden     = rw_crapemp.tpdebden
          ,emp.inavsden     = rw_crapemp.inavsden
          ,emp.dtavsden     = rw_crapemp.dtavsden
          ,emp.tpdebppr     = rw_crapemp.tpdebppr
          ,emp.inavsppr     = rw_crapemp.inavsppr
          ,emp.dtavsppr     = rw_crapemp.dtavsppr
          ,emp.cdempfol     = rw_crapemp.cdempfol
          ,emp.flgpagto     = rw_crapemp.flgpagto
          ,emp.dtavsseg     = rw_crapemp.dtavsseg
          ,emp.inavsseg     = rw_crapemp.inavsseg
          ,emp.tpdebseg     = rw_crapemp.tpdebseg
          ,emp.dtavssau     = rw_crapemp.dtavssau
          ,emp.inavssau     = rw_crapemp.inavssau
          ,emp.tpdebsau     = rw_crapemp.tpdebsau
          ,emp.tpconven     = rw_crapemp.tpconven
          ,emp.indescsg     = rw_crapemp.indescsg
          ,emp.dtfchfol     = rw_crapemp.dtfchfol
          ,emp.nrarqepr     = rw_crapemp.nrarqepr
          ,emp.dsdemail     = rw_crapemp.dsdemail
          ,emp.cdufdemp     = rw_crapemp.cdufdemp
          ,emp.nrdocnpj     = rw_crapemp.nrdocnpj
          ,emp.dsendemp     = rw_crapemp.dsendemp
          ,emp.dscomple     = rw_crapemp.dscomple
          ,emp.nmbairro     = rw_crapemp.nmbairro
          ,emp.nrfonemp     = rw_crapemp.nrfonemp
          ,emp.nmcidade     = rw_crapemp.nmcidade
          ,emp.nrfaxemp     = rw_crapemp.nrfaxemp
          ,emp.nrcepend     = rw_crapemp.nrcepend
          ,emp.nrendemp     = rw_crapemp.nrendemp
          ,emp.cdcooper     = rw_crapemp.cdcooper
          ,emp.flgarqrt     = rw_crapemp.flgarqrt
          ,emp.flgvlddv     = rw_crapemp.flgvlddv
          ,emp.cdcontar     = rw_crapemp.cdcontar
          ,emp.nrdconta     = rw_crapemp.nrdconta
          ,emp.idtpempr     = rw_crapemp.idtpempr
          ,emp.dtultufp     = rw_crapemp.dtultufp
          ,emp.dtavsufp     = rw_crapemp.dtavsufp
          ,emp.flgpgtib     = rw_crapemp.flgpgtib
          ,emp.vllimfol     = rw_crapemp.vllimfol
          ,emp.nmcontat     = rw_crapemp.nmcontat
          ,emp.flgdgfib     = rw_crapemp.flgdgfib
          ,emp.cdoperad     = rw_crapemp.cdoperad
          ,emp.cdopeori     = rw_crapemp.cdopeori
          ,emp.cdageori     = rw_crapemp.cdageori
          ,emp.dtinsori     = rw_crapemp.dtinsori
          ,emp.dtlimdeb     = rw_crapemp.dtlimdeb
          ,emp.dtinccan     = rw_crapemp.dtinccan
          ,emp.nrdddemp     = rw_crapemp.nrdddemp
     WHERE emp.cdempres = 441
       AND emp.cdcooper = 12
       AND emp.nrdconta = 144290;
       
    CLOSE cr_crapemp;
       
    UPDATE CECRED.crapemp emp
       SET emp.flgpgtib = 0
     WHERE emp.cdempres = 442
       AND emp.cdcooper = 12
       AND emp.nrdconta = 144290;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    CECRED.pc_internal_exception(pr_cdcooper => 0
                                ,pr_compleme => ' Script: => ' || vr_nmprograma ||
                                                ' Etapa: 2 - Update crapemp');          
     
  END;                                                      
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  CECRED.pc_internal_exception(pr_cdcooper => 0
                              ,pr_compleme => ' Script: => ' || vr_nmprograma ||
                                              ' Etapa: 3 - Finalizacao execucao script');   
END;



   
   
   
   
   

