-- PRB0043867
-- Ajustar o sequencial dos convênios que tiveram arquivos gerados manualmente.
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, nrsequen, cdsitret, nmarquiv, qtdoctos, vldoctos)
values (1, 7, 8460004, '02/12/2020', 8, 2, '3239-EF00000800000000846000420201202.CNV', 3, 491.34);
update crapcon c
   set c.nrseqatu = c.nrseqatu + 1
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((4, 4, 1));
-- Ajustar o sequencial dos convênios que o Bancoob enviou fora de sequência para então permitir a integração
update crapcon c set c.nrseqint = 4
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((2, 4, 1));
update crapcon c set c.nrseqint = 2
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((2, 4, 16));
update crapcon c set c.nrseqint = 30
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((296, 4, 14));
update crapcon c set c.nrseqint = 2
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((2, 4, 9));
update crapcon c set c.nrseqint = 2
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((2, 4, 12));
commit;
