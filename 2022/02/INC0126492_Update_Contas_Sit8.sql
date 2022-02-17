DECLARE
  vr_dttransa    cecred.craplgm.dttransa%type;
  vr_hrtransa    cecred.craplgm.hrtransa%type;
  vr_nrdconta    cecred.crapass.nrdconta%type;
  vr_cdcooper    cecred.crapcop.cdcooper%type;
  vr_cdoperad    cecred.craplgm.cdoperad%TYPE;
  vr_dscritic    cecred.craplgm.dscritic%TYPE;
  vr_nrdrowid    ROWID;

  vr_dtmvtolt                     DATE;
  vr_nrdolote                     cecred.craplct.nrdolote%type;
  vr_busca                        VARCHAR2(100);
  vr_nrdocmto                     INTEGER;
  vr_nrseqdig                     INTEGER;
  vr_vldcotas                     NUMBER;
  vr_vldcotas_crapcot             NUMBER;

  CURSOR cr_crapass is
    SELECT t.cdagenci, t.cdsitdct, t.cdcooper, t.nrdconta, t.inpessoa
      FROM CRAPASS t
     WHERE 1=1
       AND (t.cdcooper,t.nrdconta) in ((7,190004),
                                       (11,553638),
                                       (1,9399399),
                                       (1,11591366),
                                       (5,176516),
                                       (10,93980),
                                       (10,128791),
                                       (11,208205),
                                       (11,304182),
                                       (11,337706),
                                       (11,453242),
                                       (11,453242),
                                       (11,698490),
                                       (14,46183),
                                       (9,282600),
                                       (1,2461935),
                                       (1,6248918),
                                       (1,8826994),
                                       (1,9644130),
                                       (1,9978984),
                                       (1,10072420),
                                       (1,10079262),
                                       (1,10537562),
                                       (1,10787224),
                                       (1,10913440),
                                       (1,11093625),
                                       (1,11196173),
                                       (1,11384530),
                                       (1,11551631),
                                       (1,11614609),
                                       (1,11636955),
                                       (1,11907231),
                                       (1,11948990))
  order by t.cdcooper, t.nrdconta;

  rg_crapass cr_crapass%rowtype;

BEGIN
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := GENE0002.fn_busca_time;

  FOR rg_crapass IN cr_crapass LOOP
    
    vr_cdcooper := rg_crapass.cdcooper;
    vr_nrdconta := rg_crapass.nrdconta;
  
    vr_nrdrowid := null;
    
    GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
                         pr_cdoperad => vr_cdoperad,
                         pr_dscritic => vr_dscritic,
                         pr_dsorigem => 'AIMARO',
                         pr_dstransa => 'Alteracao da situacao de conta por script - INC0126492',
                         pr_dttransa => vr_dttransa,
                         pr_flgtrans => 1,
                         pr_hrtransa => vr_hrtransa,
                         pr_idseqttl => 0,
                         pr_nmdatela => NULL,
                         pr_nrdconta => rg_crapass.nrdconta,
                         pr_nrdrowid => vr_nrdrowid);
  
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapass.cdsitdct',
                              pr_dsdadant => rg_crapass.cdsitdct,
                              pr_dsdadatu => 8);
  
    update crapass a
       set a.cdsitdct = 8
     where a.cdcooper = rg_crapass.cdcooper
       and a.nrdconta = rg_crapass.nrdconta;
  
    BEGIN
      SELECT dtmvtolt
        INTO vr_dtmvtolt
        FROM CECRED.crapdat
       WHERE cdcooper = rg_crapass.cdcooper;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      
        dbms_output.put_line(chr(10) ||
                             'Não encontrado crapdat para cooperativa ' ||
                             rg_crapass.cdcooper);
    END;
    
    vr_vldcotas_crapcot := 0;
    
    BEGIN
      SELECT nvl(vldcotas,0)
        INTO vr_vldcotas_crapcot
        FROM CECRED.crapcot
       WHERE nrdconta = rg_crapass.nrdconta
         AND cdcooper = rg_crapass.cdcooper;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      
        dbms_output.put_line(chr(10) ||
                             'Não encontrado registro em crapcot para conta ' ||
                             rg_crapass.nrdconta);
        vr_vldcotas_crapcot := 0;
      
    END;
    
    IF vr_vldcotas_crapcot > 0 THEN
      
      vr_nrdolote := 600040;
      
      vr_busca := TRIM(to_char(rg_crapass.cdcooper)) || ';' ||
                          TRIM(to_char(vr_dtmvtolt,'DD/MM/RRRR')) || ';' ||
                          TRIM(to_char(rg_crapass.cdagenci)) || ';' ||
                          '100;' || 
                          vr_nrdolote;
                          
      vr_nrdocmto := fn_sequence('CRAPLCT','NRDOCMTO', vr_busca);
                                 
      vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG',''||rg_crapass.cdcooper||';'||
                                                                  TRIM(to_char(vr_dtmvtolt, 'DD/MM/RRRR'))||';'||
                                                                  rg_crapass.cdagenci||
                                                                  ';100;'|| 
                                                                  vr_nrdolote);
    
      INSERT INTO CECRED.craplct
        (cdcooper,
         cdagenci,
         cdbccxlt,
         nrdolote,
         dtmvtolt,
         cdhistor,
         nrctrpla,
         nrdconta,
         nrdocmto,
         nrseqdig,
         vllanmto,
         CDOPEORI,
         DTINSORI)
      VALUES
        (rg_crapass.cdcooper,
         rg_crapass.cdagenci,
         100,
         vr_nrdolote,
         vr_dtmvtolt,
         decode(rg_crapass.inpessoa,1,2079,2080),
         0,
         rg_crapass.nrdconta,
         vr_nrdocmto,
         vr_nrseqdig,
         vr_vldcotas_crapcot,
         1,
         sysdate);
      
      vr_nrdrowid := null;
      
      GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
                           pr_cdoperad => vr_cdoperad,
                           pr_dscritic => vr_dscritic,
                           pr_dsorigem => 'AIMARO',
                           pr_dstransa => 'Alteração de Cotas e devolução - INC0126492',
                           pr_dttransa => vr_dttransa,
                           pr_flgtrans => 1,
                           pr_hrtransa => vr_hrtransa,
                           pr_idseqttl => 0,
                           pr_nmdatela => NULL,
                           pr_nrdconta => rg_crapass.nrdconta,
                           pr_nrdrowid => vr_nrdrowid);
    
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'craplct.dtmvtolt',
                                pr_dsdadant => null,
                                pr_dsdadatu => vr_dtmvtolt);
    
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'craplct.vllanmto',
                                pr_dsdadant => null,
                                pr_dsdadatu => vr_vldcotas_crapcot);
    
      UPDATE CECRED.crapcot
         SET vldcotas = 0
       WHERE cdcooper = rg_crapass.cdcooper
         AND nrdconta = rg_crapass.nrdconta;
    
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'crapcot.vldcotas',
                                pr_dsdadant => vr_vldcotas_crapcot,
                                pr_dsdadatu => 0);
    
      UPDATE CECRED.TBCOTAS_DEVOLUCAO a
         SET a.vlcapital =
             (a.vlcapital + vr_vldcotas_crapcot)
       WHERE CDCOOPER = rg_crapass.cdcooper
         AND NRDCONTA = rg_crapass.nrdconta
         AND TPDEVOLUCAO = 3;
         
    END IF;
    
  end loop;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao alterar situação cooperativa/conta (' ||
                            vr_cdcooper || '/' || vr_nrdconta || ') - ' ||
                            SQLERRM);
END;
