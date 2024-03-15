BEGIN

DELETE CREDITO.TBEPR_TRANSF_ARQUIVO_IMOB imo
            WHERE imo.cdcooper = 0
              AND imo.nrdconta = 0
              AND imo.idtipoarq = 2 -- Retorno
              AND imo.idtiporem = 'P' -- Pagamento
              AND imo.dtgeracao = to_date('15/03/2024', 'dd-mm-yyyy');
  
insert into craplcm (DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO, CDHISTOR, NRSEQDIG, VLLANMTO, NRDCTABB, CDPESQBB, VLDOIPMF, NRAUTDOC, NRSEQUNI, CDBANCHQ, CDCMPCHQ, CDAGECHQ, NRCTACHQ, NRLOTCHQ, SQLOTCHQ, DTREFERE, HRTRANSA, CDOPERAD, DSIDENTI, CDCOOPER, NRDCTITG, DSCEDENT, CDCOPTFN, CDAGETFN, NRTERFIN, NRPAREPR,  NRSEQAVA, NRAPLICA, CDORIGEM, IDLAUTOM, DTTRANS)
values (to_date('15/03/2024', 'dd-mm-yyyy'), 7, 85, 70000411, 99769190, 234765, 1, 36411, 222300.00, 230740, 'REC. ID E0000000020230504141856135471855', 0.00, 0, 0, 0, 0, 0, 0, 0, 0, to_date('15/03/2024', 'dd-mm-yyyy'), 40751, '996', '  ', 16, null, '  ', 0, 0, 0, 0,  0, 0, 21, 0, to_date('15/03/2024', 'dd-mm-yyyy'));


COMMIT;
END;
