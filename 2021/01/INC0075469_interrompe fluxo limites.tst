PL/SQL Developer Test script 3.0
177
-- Created on 21/01/2021 by F0030401
DECLARE
  -- Local variables here
  i           INTEGER;
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(1000);
  vr_des_erro VARCHAR2(3);
BEGIN
  /*
    F pr_tpctrlim = 1 THEN
    vr_obj_efetivar.put('produtoCreditoSegmentoCodigo', 8);
    ELSIF pr_tpctrlim = 3 THEN
    vr_obj_efetivar.put('produtoCreditoSegmentoCodigo', 5);
  END IF;
  */
  dbms_output.enable(1000000);
  -- Test statements here
  FOR rw_crawlim IN (SELECT w.rowid, w.*
                       FROM crawlim w
                      WHERE w.tpctrlim = 1 --8
                        AND( (w.cdcooper = 1
                        AND w.nrdconta in (11382368 ,10930370 ,2955458 ,8489033 ,6758150 ,10111239 ,8068097 ,9905782 ,8285020 ,11516232 ,8713146)
                        and w.nrctrlim in (293326 ,200644 ,213589 ,292147 ,292861 ,294413 ,292979 ,294906 ,294324 ,295066 ,225157)
                          ) 
                        or
                          (w.cdcooper = 7
                        AND w.nrdconta in (363855 ,350001 ,13340 ,119652)
                        and w.nrctrlim in (107288 ,105735 ,107279 ,394303)
                          )
                        or
                          (w.cdcooper = 9
                        AND w.nrdconta in (17760 ,160237 ,153311 ,340839 ,175242 ,291048 ,334260 ,303534 ,327948 ,342734)
                        and w.nrctrlim in (106214 ,108175 ,108084 ,107773 ,108043 ,104262 ,107032 ,108201 ,108117 ,108202)
                          )
                        or
                          (w.cdcooper = 13
                        AND w.nrdconta in (133167)
                        and w.nrctrlim in (117251)
                          )
                        or
                          (w.cdcooper = 14
                        AND w.nrdconta in (13706, 11177)
                        and w.nrctrlim in (107869, 107729)
                          )
                        or
                          (w.cdcooper = 16
                        AND w.nrdconta in (807672)
                        and w.nrctrlim in (120767)
                          )
                        
                          )
                          
                        AND NOT EXISTS
                      (SELECT 1
                               FROM CRAPLIM P
                              WHERE P.CDCOOPER = W.CDCOOPER
                                AND P.NRDCONTA = W.NRDCONTA
                                AND P.NRCTRLIM = W.NRCTRLIM
                                AND P.TPCTRLIM = W.TPCTRLIM)) LOOP
  
    ESTE0003.pc_interrompe_proposta_lim_est(pr_cdcooper => rw_crawlim.cdcooper,
                                            pr_cdagenci => rw_crawlim.cdagenci,
                                            pr_cdoperad => NVL(rw_crawlim.cdopeste,
                                                               rw_crawlim.cdoperad),
                                            pr_cdorigem => 5,
                                            pr_nrdconta => rw_crawlim.nrdconta,
                                            pr_nrctrlim => rw_crawlim.nrctrlim,
                                            pr_tpctrlim => rw_crawlim.tpctrlim,
                                            pr_dtmvtolt => TRUNC(SYSDATE),
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
  
    IF NVL(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
      DBMS_OUTPUT.put_line('Erro ao enviar reinicio de fluxo tipo 8. Cooperativa: ' || rw_crawlim.cdcooper || 
                           ' proposta:' || rw_crawlim.nrctrlim || 
                           ' conta: ' || rw_crawlim.nrdconta); 
    ELSE
      update crawlim lim
         set insitest = 0,
             dtenvest = null,
             hrenvest = 0,
             cdopeste = ' ',
             insitapr = 0,
             dtaprova = null,
             hraprova = 0,
             cdopeapr = null
       where lim.ROWID = rw_crawlim.rowid;
    
    END IF;
  
  END LOOP;
  
  FOR rw_crawlim IN (SELECT w.rowid, w.*
                       FROM crawlim w
                      WHERE w.tpctrlim = 3 --5
                        AND( (w.cdcooper = 2
                        AND w.nrdconta in (666602 ,836532 ,674621)
                        and w.nrctrlim in (1204,1206,1211)
                          ) 
                        or
                          (w.cdcooper = 6
                        AND w.nrdconta in (209694)
                        and w.nrctrlim in (394)
                          )
                        or
                          (w.cdcooper = 7
                        AND w.nrdconta in (251283)
                        and w.nrctrlim in (1190)
                          )
                        or
                          (w.cdcooper = 8
                        AND w.nrdconta in (51420)
                        and w.nrctrlim in (91)
                          )
                        or
                          (w.cdcooper = 9
                        AND w.nrdconta in (358401 ,153346 ,347876 ,343072 ,300977 ,262927 ,315320 ,348139 ,173541)
                        and w.nrctrlim in (1656 ,1650 ,1629 ,1661 ,1659 ,1653 ,1658 ,1638 ,1654)
                          )
                        or
                          (w.cdcooper = 12
                        AND w.nrdconta in (108359)
                        and w.nrctrlim in (358)
                          )
                        or
                          (w.cdcooper = 13
                        AND w.nrdconta in (152838)
                        and w.nrctrlim in (1103)
                          )
                        or
                          (w.cdcooper = 14
                        AND w.nrdconta in (230766)
                        and w.nrctrlim in (1056)
                          )
                        
                          )
                          
                        AND NOT EXISTS
                      (SELECT 1
                               FROM CRAPLIM P
                              WHERE P.CDCOOPER = W.CDCOOPER
                                AND P.NRDCONTA = W.NRDCONTA
                                AND P.NRCTRLIM = W.NRCTRLIM
                                AND P.TPCTRLIM = W.TPCTRLIM)) LOOP
  
    ESTE0003.pc_interrompe_proposta_lim_est(pr_cdcooper => rw_crawlim.cdcooper,
                                            pr_cdagenci => rw_crawlim.cdagenci,
                                            pr_cdoperad => NVL(rw_crawlim.cdopeste,
                                                               rw_crawlim.cdoperad),
                                            pr_cdorigem => 5,
                                            pr_nrdconta => rw_crawlim.nrdconta,
                                            pr_nrctrlim => rw_crawlim.nrctrlim,
                                            pr_tpctrlim => rw_crawlim.tpctrlim,
                                            pr_dtmvtolt => TRUNC(SYSDATE),
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic);
  
    IF NVL(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
      DBMS_OUTPUT.put_line('Erro ao enviar reinicio de fluxo tipo 5. Cooperativa: ' || rw_crawlim.cdcooper || 
                           ' proposta:' || rw_crawlim.nrctrlim || 
                           ' conta: ' || rw_crawlim.nrdconta); 
    ELSE
      update crawlim lim
         set insitest = 0,
             dtenvest = null,
             hrenvest = 0,
             cdopeste = ' ',
             insitapr = 0,
             dtaprova = null,
             hraprova = 0,
             cdopeapr = null
       where lim.ROWID = rw_crawlim.rowid;
    
    END IF;
  
  END LOOP;
  commit;
END;
0
0
