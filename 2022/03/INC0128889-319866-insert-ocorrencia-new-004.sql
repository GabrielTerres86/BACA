begin
  insert into crapaut aut
            (cdagenci, nrdcaixa, dtmvtolt, nrsequen, cdopecxa, hrautent, vldocmto, nrdocmto, tpoperac, cdstatus, estorno, nrseqaut, cdhistor, dslitera,
             blidenti, bltotpag, bltotrec, blsldini, blvalrec, inusodbl, nrdconta, nrdctadp, dsleitur, dsobserv, cdcooper, dsprotoc)       
         values        
            (90,900,To_Date('06/01/2022','DD/MM/YYYY'),1,996,35720,231990.00,5001,1,null,0,0,539,null,null,0,0,0,0,0,830968,0,null,null,1,'0124.4444.0401.0601.1601.3F01.1B');
  commit;
end;  
			