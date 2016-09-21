create or replace force view cecred.vw_cliente as
select distinct
    case when length(nrcpfcgc) < 12 then 1
      else 2 end tipcli,
     nrcpfcgc as IdfcCli,
     nmprimtl as NmCli
  from
    crapass
  where
    incadpos = 2
--QUANDO O CPF É SEGUNDO TITULAR - NÃO ENVIA ESTA CONTA.
;

