--INC0036708 - Mensagem de alerta

update crawcrd crd
   set crd.dtrejeit = null
where crd.cdcooper = 1
  and crd.nrdconta = 11004924
  and crd.nrcrcard = 6393500117003195;
  
COMMIT;
