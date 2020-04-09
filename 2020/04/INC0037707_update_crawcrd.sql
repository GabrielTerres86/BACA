--INC0037707 Retirar data de rejeitada. Cartão está em uso.

update crawcrd crd
set crd.dtrejeit = null
where crd.cdcooper = 1
  and crd.nrdconta = 10974113
  and crd.nrcrcard = 5474080150789673;
  
 COMMIT;
