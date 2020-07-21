update crapepr
set  vlsdprej = vlsdprej - 1956.5
    ,vljrmprj = 0
    ,vljraprj = 0
where cdcooper = 1
and   nrdconta = 3867188
and   nrctremp = 279472
and   VLSDPREJ = 110651.1
and   VLJRMPRJ = 1956.5
and   VLJRAPRJ = 1956.5;

commit;