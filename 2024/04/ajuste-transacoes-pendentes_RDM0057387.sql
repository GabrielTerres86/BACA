begin
UPDATE
tbcc_lancamentos_pendentes pend
set 
pend.IDSITUACAO = 'P'
where
pend.IDSITUACAO in ('A') and
pend.CDPRODUTO = 53 and
pend.idtransacao in
(
423552494,
423552495
);
commit;
end;