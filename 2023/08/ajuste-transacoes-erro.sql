begin
UPDATE
tbcc_lancamentos_pendentes pend
set 
pend.IDSITUACAO = 'P'
where
pend.IDSITUACAO in ('E') and
pend.CDPRODUTO = 53 and
pend.idtransacao in
(
284908601,
284908598,
284908734,
284908730,
284908727,
284908731
);
commit;
end;