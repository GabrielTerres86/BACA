DECLARE

   vr_idcarga crapcpa.iddcarga%TYPE;
   
   CURSOR cr_cooperados IS
   select a.cdcooper,a.nrcpfcnpj_base,y.dtmvtolt
       from cecred.crawepr w, 
            cecred.crapdat y,
            cecred.crapepr p,
            cecred.crapass a,
            cecred.crapdat d            
       where w.FLFINANCIASEGPRESTAMISTA = 1 
       and w.FLGGARAD = 1 
       and p.INLIQUID = 0 
       and p.cdfinemp = 68 
       and p.DTMVTOLT >= '01/03/2023' 
       and w.cdcooper = 13 
       and y.cdcooper = w.cdcooper
       and p.cdcooper = w.cdcooper and p.nrdconta = w.nrdconta and p.NRCTREMP = w.NRCTREMP
       and a.cdcooper = w.cdcooper and a.nrdconta = w.nrdconta 
       and d.cdcooper = w.cdcooper 
       and not exists (SELECT 1
                         FROM cecred.crapcpa cpa,
                              cecred.tbepr_carga_pre_aprv car 
                        WHERE cpa.cdcooper = w.cdcooper 
                          AND cpa.tppessoa = a.INPESSOA 
                          AND cpa.nrcpfcnpj_base = a.NRCPFCNPJ_BASE 
                          AND cpa.iddcarga = car.idcarga 
                          AND car.indsituacao_carga = 2 
                          AND car.flgcarga_bloqueada = 0 
                          AND car.dtfinal_vigencia >= d.DTMVTOLT 
                          AND cpa.cdsituacao = 'A');
   rw_cooperados cr_cooperados%ROWTYPE;                         
BEGIN
  INSERT INTO cecred.tbepr_carga_pre_aprv(cdcooper
                                  ,dtcalculo
                                  ,tpcarga 
                                  ,dscarga
                                  ,dtliberacao
                                  ,dtfinal_vigencia
                                  ,dsmensagem_aviso
                                  ,indsituacao_carga
                                  ,flgcarga_bloqueada
                                  ,skcarga_sas
                                  ,qtcarga_pf
                                  ,qtcarga_pj
                                  ,vllimite_total
                                  ,cdoperad_libera)
                            VALUES(13
                                  ,'04/04/2023'
                                  ,1
                                  ,'INC0262696'
                                  ,'04/04/2023'
                                  ,'07/04/2023'
                                  ,'INC0262696'
                                  ,2
                                  ,0
                                  ,0
                                  ,6
                                  ,0
                                  ,6
                                  ,'1')
                          RETURNING idcarga 
                               INTO vr_idcarga;
                               
  FOR rw_cooperados IN cr_cooperados LOOP
    INSERT INTO cecred.crapcpa (cdcooper
                        ,nrdconta
                        ,dtmvtolt
                        ,iddcarga
                        ,tppessoa
                        ,nrcpfcnpj_base
                        ,cdlcremp
                        ,vlpot_parc_maximo
                        ,vlpot_lim_max
                        ,cdsituacao
                        ,vlcalpar
                        ,vlcalpre
                        ,dsfaixa_risco)
                 VALUES (rw_cooperados.cdcooper
                        ,0
                        ,rw_cooperados.dtmvtolt
                        ,vr_idcarga
                        ,1
                        ,rw_cooperados.nrcpfcnpj_base
                        ,421
                        ,1
                        ,1
                        ,'A'
                        ,1
                        ,1
                        ,'R21');    
  END LOOP;
COMMIT;                                 
EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
    raise_application_error(-20500,SQLERRM);    
END;
