DECLARE

  vr_cdcooper cecred.crapass.cdcooper%TYPE := 1;
  vr_nrdconta cecred.crapass.nrdconta%TYPE := 14520257;
  
BEGIN
  
  DELETE FROM cecred.crappep a
  WHERE a.cdcooper = vr_cdcooper
    AND a.nrdconta = vr_nrdconta
    AND a.nrctremp IN (5755532,5755555); 
  
  UPDATE cecred.crawepr a
  SET a.insitapr = 1
     ,a.insitest = 3
  WHERE a.cdcooper = vr_cdcooper
    AND a.nrdconta = vr_nrdconta
    AND a.nrctremp IN (5755532,5755555); 
    
  UPDATE cecred.tbepr_renegociacao a 
  SET a.dtlibera = TO_DATE('04/12/2023','DD/MM/YYYY')
  WHERE a.cdcooper = vr_cdcooper 
    AND a.nrdconta = vr_nrdconta
    AND a.nrctremp = 7651259; 
    
  INSERT INTO cecred.crapepr (dtmvtolt,
                              cdagenci,
                              cdbccxlt,
                              nrdolote,
                              nrdconta,
                              nrctremp,
                              cdfinemp,
                              cdlcremp,
                              dtultpag,
                              nrctaav1,
                              nrctaav2,
                              qtpreemp,
                              qtprepag,
                              txjuremp,
                              vljuracu,
                              vljurmes,
                              vlpagmes,
                              vlpreemp,
                              vlsdeved,
                              vlemprst,
                              cdempres,
                              inliquid,
                              nrcadast,
                              qtprecal,
                              qtmesdec,
                              dtinipag,
                              flgpagto,
                              dtdpagto,
                              indpagto,
                              vliofepr,
                              vlprejuz,
                              vlsdprej,
                              inprejuz,
                              vljraprj,
                              vljrmprj,
                              dtprejuz,
                              tpdescto,
                              cdcooper,
                              tpemprst,
                              txmensal,
                              vlservtx,
                              vlpagstx,
                              vljuratu,
                              vlajsdev,
                              dtrefjur,
                              diarefju,
                              flliqmen,
                              mesrefju,
                              anorefju,
                              flgdigit,
                              vlsdvctr,
                              qtlcalat,
                              qtpcalat,
                              vlsdevat,
                              vlpapgat,
                              vlppagat,
                              qtmdecat,
                              qttolatr,
                              cdorigem,
                              vltarifa,
                              vltariof,
                              vltaxiof,
                              nrconbir,
                              inconcje,
                              vlttmupr,
                              vlttjmpr,
                              vlpgmupr,
                              vlpgjmpr,
                              qtimpctr,
                              dtliquid,
                              dtultest,
                              dtapgoib,
                              iddcarga,
                              cdopeori,
                              cdageori,
                              dtinsori,
                              cdopeefe,
                              dtliqprj,
                              vlsprjat,
                              dtrefatu,
                              idfiniof,
                              vliofcpl,
                              vliofadc,
                              vlsprojt,
                              dtrefcor,
                              idquaprc,
                              vlpagiof,
                              vlaqiofc,
                              inrisco_refin,
                              dtinicio_atraso_refin,
                              qtdias_atraso_refin,
                              vliofpri,
                              vltiofpr,
                              vlpiofpr,
                              vlsaldo_refinanciado,
                              iddacao_bens,
                              vliofpriantprej,
                              vliofadiantprej)
                              (SELECT tbepr_renegociacao_crapepr.dtmvtolt,
                                      tbepr_renegociacao_crapepr.cdagenci,
                                      tbepr_renegociacao_crapepr.cdbccxlt,
                                      tbepr_renegociacao_crapepr.nrdolote,
                                      tbepr_renegociacao_crapepr.nrdconta,
                                      tbepr_renegociacao_crapepr.nrctremp,
                                      tbepr_renegociacao_crapepr.cdfinemp,
                                      tbepr_renegociacao_crapepr.cdlcremp,
                                      tbepr_renegociacao_crapepr.dtultpag,
                                      tbepr_renegociacao_crapepr.nrctaav1,
                                      tbepr_renegociacao_crapepr.nrctaav2,
                                      tbepr_renegociacao_crapepr.qtpreemp,
                                      tbepr_renegociacao_crapepr.qtprepag,
                                      tbepr_renegociacao_crapepr.txjuremp,
                                      tbepr_renegociacao_crapepr.vljuracu,
                                      tbepr_renegociacao_crapepr.vljurmes,
                                      tbepr_renegociacao_crapepr.vlpagmes,
                                      tbepr_renegociacao_crapepr.vlpreemp,
                                      tbepr_renegociacao_crapepr.vlsdeved,
                                      tbepr_renegociacao_crapepr.vlemprst,
                                      tbepr_renegociacao_crapepr.cdempres,
                                      tbepr_renegociacao_crapepr.inliquid,
                                      tbepr_renegociacao_crapepr.nrcadast,
                                      tbepr_renegociacao_crapepr.qtprecal,
                                      tbepr_renegociacao_crapepr.qtmesdec,
                                      tbepr_renegociacao_crapepr.dtinipag,
                                      tbepr_renegociacao_crapepr.flgpagto,
                                      tbepr_renegociacao_crapepr.dtdpagto,
                                      tbepr_renegociacao_crapepr.indpagto,
                                      tbepr_renegociacao_crapepr.vliofepr,
                                      tbepr_renegociacao_crapepr.vlprejuz,
                                      tbepr_renegociacao_crapepr.vlsdprej,
                                      tbepr_renegociacao_crapepr.inprejuz,
                                      tbepr_renegociacao_crapepr.vljraprj,
                                      tbepr_renegociacao_crapepr.vljrmprj,
                                      tbepr_renegociacao_crapepr.dtprejuz,
                                      tbepr_renegociacao_crapepr.tpdescto,
                                      tbepr_renegociacao_crapepr.cdcooper,
                                      tbepr_renegociacao_crapepr.tpemprst,
                                      tbepr_renegociacao_crapepr.txmensal,
                                      tbepr_renegociacao_crapepr.vlservtx,
                                      tbepr_renegociacao_crapepr.vlpagstx,
                                      tbepr_renegociacao_crapepr.vljuratu,
                                      tbepr_renegociacao_crapepr.vlajsdev,
                                      tbepr_renegociacao_crapepr.dtrefjur,
                                      tbepr_renegociacao_crapepr.diarefju,
                                      tbepr_renegociacao_crapepr.flliqmen,
                                      tbepr_renegociacao_crapepr.mesrefju,
                                      tbepr_renegociacao_crapepr.anorefju,
                                      tbepr_renegociacao_crapepr.flgdigit,
                                      tbepr_renegociacao_crapepr.vlsdvctr,
                                      tbepr_renegociacao_crapepr.qtlcalat,
                                      tbepr_renegociacao_crapepr.qtpcalat,
                                      tbepr_renegociacao_crapepr.vlsdevat,
                                      tbepr_renegociacao_crapepr.vlpapgat,
                                      tbepr_renegociacao_crapepr.vlppagat,
                                      tbepr_renegociacao_crapepr.qtmdecat,
                                      tbepr_renegociacao_crapepr.qttolatr,
                                      tbepr_renegociacao_crapepr.cdorigem,
                                      tbepr_renegociacao_crapepr.vltarifa,
                                      tbepr_renegociacao_crapepr.vltariof,
                                      tbepr_renegociacao_crapepr.vltaxiof,
                                      tbepr_renegociacao_crapepr.nrconbir,
                                      tbepr_renegociacao_crapepr.inconcje,
                                      tbepr_renegociacao_crapepr.vlttmupr,
                                      tbepr_renegociacao_crapepr.vlttjmpr,
                                      tbepr_renegociacao_crapepr.vlpgmupr,
                                      tbepr_renegociacao_crapepr.vlpgjmpr,
                                      tbepr_renegociacao_crapepr.qtimpctr,
                                      tbepr_renegociacao_crapepr.dtliquid,
                                      tbepr_renegociacao_crapepr.dtultest,
                                      tbepr_renegociacao_crapepr.dtapgoib,
                                      tbepr_renegociacao_crapepr.iddcarga,
                                      tbepr_renegociacao_crapepr.cdopeori,
                                      tbepr_renegociacao_crapepr.cdageori,
                                      tbepr_renegociacao_crapepr.dtinsori,
                                      tbepr_renegociacao_crapepr.cdopeefe,
                                      tbepr_renegociacao_crapepr.dtliqprj,
                                      tbepr_renegociacao_crapepr.vlsprjat,
                                      tbepr_renegociacao_crapepr.dtrefatu,
                                      tbepr_renegociacao_crapepr.idfiniof,
                                      tbepr_renegociacao_crapepr.vliofcpl,
                                      tbepr_renegociacao_crapepr.vliofadc,
                                      tbepr_renegociacao_crapepr.vlsprojt,
                                      tbepr_renegociacao_crapepr.dtrefcor,
                                      tbepr_renegociacao_crapepr.idquaprc,
                                      tbepr_renegociacao_crapepr.vlpagiof,
                                      tbepr_renegociacao_crapepr.vlaqiofc,
                                      tbepr_renegociacao_crapepr.inrisco_refin,
                                      tbepr_renegociacao_crapepr.dtinicio_atraso_refin,
                                      tbepr_renegociacao_crapepr.qtdias_atraso_refin,
                                      tbepr_renegociacao_crapepr.vliofpri,
                                      tbepr_renegociacao_crapepr.vltiofpr,
                                      tbepr_renegociacao_crapepr.vlpiofpr,
                                      tbepr_renegociacao_crapepr.vlsaldo_refinanciado,
                                      tbepr_renegociacao_crapepr.iddacao_bens,
                                      tbepr_renegociacao_crapepr.vliofpriantprej,
                                      tbepr_renegociacao_crapepr.vliofadiantprej 
                                 FROM cecred.tbepr_renegociacao_crapepr 
                                WHERE cdcooper = vr_cdcooper
                                  AND nrdconta = vr_nrdconta 
                                  AND nrctremp IN (5755532,5755555)
                                  AND nrversao = 2);

  INSERT INTO cecred.craplem (dtmvtolt,
                              cdagenci,
                              cdbccxlt,
                              nrdolote,
                              nrdconta,
                              nrdocmto,
                              cdhistor,
                              nrseqdig,
                              nrctremp,
                              vllanmto,
                              dtpagemp,
                              txjurepr,
                              vlpreemp,
                              nrautdoc,
                              nrsequni,
                              cdcooper,
                              nrparepr,
                              nrseqava,
                              dtestorn,
                              cdorigem,
                              dthrtran,
                              qtdiacal,
                              vltaxper,
                              vltaxprd,
                              nrdoclcm) 
                              (SELECT tbepr_renegociacao_craplem.dtmvtolt,
                                      tbepr_renegociacao_craplem.cdagenci,
                                      tbepr_renegociacao_craplem.cdbccxlt,
                                      tbepr_renegociacao_craplem.nrdolote,
                                      tbepr_renegociacao_craplem.nrdconta,
                                      tbepr_renegociacao_craplem.nrdocmto,
                                      tbepr_renegociacao_craplem.cdhistor,
                                      tbepr_renegociacao_craplem.nrseqdig,
                                      tbepr_renegociacao_craplem.nrctremp,
                                      tbepr_renegociacao_craplem.vllanmto,
                                      tbepr_renegociacao_craplem.dtpagemp,
                                      tbepr_renegociacao_craplem.txjurepr,
                                      tbepr_renegociacao_craplem.vlpreemp,
                                      tbepr_renegociacao_craplem.nrautdoc,
                                      tbepr_renegociacao_craplem.nrsequni,
                                      tbepr_renegociacao_craplem.cdcooper,
                                      tbepr_renegociacao_craplem.nrparepr,
                                      tbepr_renegociacao_craplem.nrseqava,
                                      tbepr_renegociacao_craplem.dtestorn,
                                      tbepr_renegociacao_craplem.cdorigem,
                                      tbepr_renegociacao_craplem.dthrtran,
                                      tbepr_renegociacao_craplem.qtdiacal,
                                      tbepr_renegociacao_craplem.vltaxper,
                                      tbepr_renegociacao_craplem.vltaxprd,
                                      tbepr_renegociacao_craplem.nrdoclcm
                                 FROM cecred.tbepr_renegociacao_craplem
                                WHERE cdcooper = vr_cdcooper
                                  AND nrdconta = vr_nrdconta 
                                  AND nrctremp IN (5755532,5755555)
                                  AND nrversao = 2);


  INSERT INTO cecred.crappep(cdcooper,
                             nrdconta,
                             nrctremp,
                             nrparepr,
                             vlparepr,
                             vljurpar,
                             vlmtapar,
                             vlmrapar,
                             vlmtzpar,
                             dtvencto,
                             dtultpag,
                             vlpagpar,
                             vlpagmta,
                             vlpagmra,
                             inliquid,
                             vldespar,
                             vlsdvpar,
                             vljinpar,
                             vlpagjin,
                             vlsdvatu,
                             vljura60,
                             vlsdvsji,
                             inprejuz,
                             dtrefatu,
                             vliofcpl,
                             vliofadc,
                             vltaxatu,
                             vlpagiof,
                             vltariof,
                             vliofpri,
                             dtdstjur,
                             vldstcor,
                             vldstrem,
                             inlqdrefin) 
                             (SELECT tbepr_renegociacao_crappep.cdcooper,
                                     tbepr_renegociacao_crappep.nrdconta,
                                     tbepr_renegociacao_crappep.nrctremp,
                                     tbepr_renegociacao_crappep.nrparepr,
                                     tbepr_renegociacao_crappep.vlparepr,
                                     tbepr_renegociacao_crappep.vljurpar,
                                     tbepr_renegociacao_crappep.vlmtapar,
                                     tbepr_renegociacao_crappep.vlmrapar,
                                     tbepr_renegociacao_crappep.vlmtzpar,
                                     tbepr_renegociacao_crappep.dtvencto,
                                     tbepr_renegociacao_crappep.dtultpag,
                                     tbepr_renegociacao_crappep.vlpagpar,
                                     tbepr_renegociacao_crappep.vlpagmta,
                                     tbepr_renegociacao_crappep.vlpagmra,
                                     tbepr_renegociacao_crappep.inliquid,
                                     tbepr_renegociacao_crappep.vldespar,
                                     tbepr_renegociacao_crappep.vlsdvpar,
                                     tbepr_renegociacao_crappep.vljinpar,
                                     tbepr_renegociacao_crappep.vlpagjin,
                                     tbepr_renegociacao_crappep.vlsdvatu,
                                     tbepr_renegociacao_crappep.vljura60,
                                     tbepr_renegociacao_crappep.vlsdvsji,
                                     tbepr_renegociacao_crappep.inprejuz,
                                     tbepr_renegociacao_crappep.dtrefatu,
                                     tbepr_renegociacao_crappep.vliofcpl,
                                     tbepr_renegociacao_crappep.vliofadc,
                                     tbepr_renegociacao_crappep.vltaxatu,
                                     tbepr_renegociacao_crappep.vlpagiof,
                                     tbepr_renegociacao_crappep.vltariof,
                                     tbepr_renegociacao_crappep.vliofpri,
                                     tbepr_renegociacao_crappep.dtdstjur,
                                     tbepr_renegociacao_crappep.vldstcor,
                                     tbepr_renegociacao_crappep.vldstrem,
                                     tbepr_renegociacao_crappep.inlqdrefin
                                FROM cecred.tbepr_renegociacao_crappep
                               WHERE cdcooper = vr_cdcooper
                                 AND nrdconta = vr_nrdconta 
                                 AND nrctremp IN (5755532,5755555)
                                 AND nrversao = 2);

  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK; 
    RAISE_application_error(-20500, SQLERRM);
END;
