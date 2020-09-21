update   tbepr_cdc_vendedor u
set FLGATIVO=0
where idvendedor in
(SELECT  uv.idvendedor
FROM    tbepr_cdc_vendedor          v
       ,tbepr_cdc_usuario_vinculo   uv
       ,tbsite_cooperado_cdc        tcc
       ,crapass                     a
WHERE uv.idvendedor = v.idvendedor
AND   tcc.idcooperado_cdc = uv.idcooperado_cdc
AND   a.cdcooper = tcc.cdcooper
AND   a.nrdconta = tcc.nrdconta
AND   v.nrcpf = 00926970976
and   u.flgativo=1
);

commit;

