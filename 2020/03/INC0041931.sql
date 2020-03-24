update crapepr set vliofepr = 350.54, vlpreemp = 539.40, vlemprst = 25600.54 where cdcooper = 13 and nrdconta = 295159 and nrctremp = 59436;

update crawepr set percetop = 20.14, vlpreemp = 539.40 where cdcooper = 13 and nrdconta = 295159 and nrctremp = 59436;

update crappep set vlparepr = 539.40, vlpagpar = 0, vlsdvpar = 539.40, vlsdvsji = 539.40  where cdcooper = 13 and nrdconta = 295159 and nrctremp = 59436;

update tbepr_consignado set pejuro_anual = 19.56, pecet_anual = 20.14  where cdcooper = 13 and nrdconta = 295159 and nrctremp = 59436;

INSERT INTO tbgen_iof_lancamento
                    (cdcooper
                    ,nrdconta
                    ,dtmvtolt
                    ,tpproduto
                    ,tpiof
                    ,nrcontrato
                    ,idlautom
                    ,dtmvtolt_lcm
                    ,cdagenci_lcm
                    ,cdbccxlt_lcm
                    ,nrdolote_lcm
                    ,nrseqdig_lcm
                    ,inimunidade
                    ,vliof)
             VALUES (13
                    ,295159
                    ,to_date('24-03-2020', 'dd-mm-yyyy')
                    ,1
                    ,1 --> IOF Principal
                    ,59436
                    ,null
                    ,to_date('24-03-2020', 'dd-mm-yyyy')
                    ,1
                    ,100
                    ,59436
                    ,null
                    ,0
                    ,350.54);
 

insert into craplem (DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO, CDHISTOR, NRSEQDIG, NRCTREMP, VLLANMTO, DTPAGEMP, TXJUREPR, VLPREEMP, NRAUTDOC, NRSEQUNI, CDCOOPER, NRPAREPR, PROGRESS_RECID, NRSEQAVA, DTESTORN, CDORIGEM, DTHRTRAN, QTDIACAL, VLTAXPER, VLTAXPRD)
values (to_date('24-03-2020', 'dd-mm-yyyy'), 1, 100, 600005, 295159, 18, 2304, 20, 59436, 350.54, to_date('24-03-2020', 'dd-mm-yyyy'), 0.0005000, 0.00, 0, 0, 13, 0, null, 0, null, 5, sysdate, 0, 0.00000000, 0.00000000);

commit;
