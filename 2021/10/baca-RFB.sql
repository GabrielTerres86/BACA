begin
update crappro
set crappro.dsinform##3 = 'Tpcaptura: 1#Solicitante: MAYA SILVA#Agente Arrecadador: 756 - BANCO SICOOB S.A.                                 #Agência: 3318 - ACENTRA                       #Tipo de Documento: DARF 81 COOP COD BARRAS 0064#Nome/Telefone: teste - 47991961348#Código de Barras: 85610000001514300641323131812437000105611304#Linha Digitável: 85610000001-2 51430064132-1 31318124370-7 00105611304-4#Data de Vencimento: 19/11/2021#Valor Total: 151,43#Descrição do Pagamento: darf 064 IB'
where crappro.dtmvtolt = '07/10/2021'
and crappro.cdcooper = 5
and crappro.nrdconta IN (314412)
AND crappro.vldocmto = 151.43;

update crappro
set crappro.dsinform##3 = 'Tpcaptura: 1#Solicitante: MAYA SILVA#Agente Arrecadador: 756 - BANCO SICOOB S.A.                                 #Agência: 3318 - ACENTRA                       #Tipo de Documento: DARF 81 COOP COD BARRAS 0153#Nome/Telefone: teste - 47991961351#Código de Barras: 85640000001000001531201112446657000113456204#Linha Digitável: 85640000001-9 00000153120-1 11124466570-4 00113456204-8#Data de Vencimento: 20/07/2021#Valor Total: 100,00#Descrição do Pagamento: darf 153'
where crappro.dtmvtolt = '07/10/2021'
and crappro.cdcooper = 5
and crappro.nrdconta IN (314412)
AND crappro.vldocmto = 100;

commit;

end;