-- Ajustar o sequencial dos conv�nios que o Bancoob enviou fora de sequ�ncia para ent�o permitir a integra��o
update crapcon c set c.nrseqint = 116
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((296, 4, 10))
/
update crapcon c set c.nrseqint = 4
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((296, 4, 14))
/
update crapcon c set c.nrseqint = 2
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((430, 4, 10))
/
update crapcon c set c.nrseqint = 3
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((430, 4, 16))
/
update crapcon c set c.nrseqint = 2
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((80, 4, 8))
/
update crapcon c set c.nrseqint = 2
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((80, 4, 9))
/
update crapcon c set c.nrseqint = 2
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((80, 4, 10))
/
update crapcon c set c.nrseqint = 3
 where (c.cdempcon, c.cdsegmto, c.cdcooper) in ((80, 4, 11))
/
commit
/
