-- DDLs para o Incidente INC0034042
-- 28/02/2019 - Ana - Envolti
-- Ajuste data pagamento para contas e contratos cfe planilha

update crapepr e set e.dtdpagto = '28/03/2019'
where e.cdcooper = 7
and   e.nrdconta = 26379
and   e.nrctremp = 9515;

update crapepr e set e.dtdpagto = '20/12/2018'
where e.cdcooper = 1
and   e.nrdconta = 3645681
and   e.nrctremp = 262726;

COMMIT;
