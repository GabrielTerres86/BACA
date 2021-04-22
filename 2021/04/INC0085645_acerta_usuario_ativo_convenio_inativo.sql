UPDATE tbepr_cdc_usuario
SET flgbloque=1, flgativo=0
WHERE idusuario in
(
SELECT  u.IDUSUARIO
FROM    tbepr_cdc_usuario_vinculo   uv
       ,tbepr_cdc_usuario           u
       ,tbsite_cooperado_cdc        tcc
       ,crapcdr                     cdr
WHERE tcc.idcooperado_cdc = uv.idcooperado_cdc
AND   u.idusuario = uv.idusuario
AND   u.dslogin = 'APP_COOPERADO'
AND   cdr.cdcooper = tcc.cdcooper
AND   cdr.nrdconta = tcc.nrdconta
AND   u.flgativo = 1
AND   cdr.flgconve = 0
)
/

commit
/

