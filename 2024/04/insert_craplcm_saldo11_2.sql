BEGIN
insert into craplcm (DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO, CDHISTOR, NRSEQDIG, VLLANMTO, NRDCTABB, CDPESQBB, VLDOIPMF, NRAUTDOC, NRSEQUNI, CDBANCHQ, CDCMPCHQ, CDAGECHQ, NRCTACHQ, NRLOTCHQ, SQLOTCHQ, DTREFERE, HRTRANSA, CDOPERAD, DSIDENTI, CDCOOPER, NRDCTITG, DSCEDENT, CDCOPTFN, CDAGETFN, NRTERFIN, NRPAREPR, NRSEQAVA, NRAPLICA, CDORIGEM, IDLAUTOM, DTTRANS)
values (to_date('30/04/2024','dd/mm/yyyy'), 6, 100, 6902119, 99582821,345673, 1, 2661795, 230000.43, 115320, '6393500297191612', 0.00, 0, 0, 0, 0, 0, 0, 0, 0, to_date('30/04/2024', 'dd-mm-yyyy'), 67663, ' ', ' ', 11, '00115320', ' ', 0, 0, 0, 0, 0, 0, 8, 0, to_date('30/04/2024', 'dd-mm-yyyy'));

DELETE CREDITO.TBEPR_TRANSF_ARQUIVO_IMOB imo
            WHERE imo.cdcooper = 0
              AND imo.nrdconta = 0
              AND imo.idtipoarq = 2 -- Retorno
              AND imo.idtiporem = 'P' -- Pagamento
              AND imo.dtgeracao = to_date('30/04/2024','dd/mm/yyyy');
			  
COMMIT;
END;
