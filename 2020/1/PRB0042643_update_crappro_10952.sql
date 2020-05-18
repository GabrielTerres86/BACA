--Atualizar crappro para corrigir um erro na coluna dsinform##3 de '#Pagador: # COMPENSADOS PINHEIRINHO LTDA - ME' para '#Pagador: COMPENSADOS PINHEIRINHO LTDA - ME'

UPDATE crappro SET crappro.dsinform##3 = 'Codigo de Barras: 75692807400000053511434201052993101776273001#Linha Digitavel: 75691.43428 01052.993100 17762.730012 2 80740000005351#FILLER#Pagador: COMPENSADOS PINHEIRINHO LTDA - ME#CPF/CNPJ Pagador: 11.869.861/0001-27#Vencimento: 15/11/2019#Valor Titulo: 53,51#Encargos: 0,00#Descontos: 0,00#CPF/CNPJ Beneficiario: 78.686.888/0001-55'
WHERE 1 = 1
AND crappro.dtmvtolt = '18/11/2019'
AND crappro.cdcooper = 14
AND crappro.dsprotoc = '2809.192C.0E12.0B13.3132.5B4D'
AND crappro.nrdconta = 10952;

COMMIT;