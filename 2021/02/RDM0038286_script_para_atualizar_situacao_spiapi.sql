--Ajuste Situação Legado
delete 
from "TbJdPiSpiApi_OpDebitoSt"
where "IdStOpDebito" in
(
    select a."IdStOpDebito"
    from "TbJdPiSpiApi_OpDebitoSt" a 
    inner join "TbJdPiSpiApi_OpDebito" b on (a."IdReqOpDebitoJdPi"= b."IdReqOpDebitoJdPi" and b."DtHrLiquidacao" is null)
    where a."StOpDebito" = '0'
      and exists ( 
        select 1   
        from "TbJdPiSpiApi_OpDebitoSt" c
        where c."IdReqOpDebitoJdPi" = b."IdReqOpDebitoJdPi"
          and c."StOpDebito" = 3)
     and trunc(b."DtHrRequisicao") < '21/02/2021'
);
commit;
