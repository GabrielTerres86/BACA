BEGIN
--Liberar Contrato 1502282 pois esta liquidado.
UPDATE tbgar_cobertura_operacao
   SET insituacao = 2
      ,cdoperador_desbloq = 1
      ,vldesbloq = 0
      ,dtdesbloq = SYSDATE
 WHERE idcobertura = 13329;  
 
--Retirar idcobope 32614 Conta 15270 e Contrato 3183512
update crawepr e 
   set idcobope = 0,
       idcobefe = 0
 where e.cdcooper = 1 and e.nrdconta = 15270 and e.nrctremp = 3183512;
 
--Atualizar idcobope 32614 de contrato 3183512 para 3180685
UPDATE tbgar_cobertura_operacao o
   SET o.nrcontrato = 3180685 
 WHERE idcobertura = 32614; 
 COMMIT;
EXCEPTION
  WHEN OTHERS THEN
   ROLLBACK;
END;
