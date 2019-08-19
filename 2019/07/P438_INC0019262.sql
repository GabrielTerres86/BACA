-- P438_INC0019262_script_update_cancelar_contrato_limite_credito

update craplim
   set insitlim = 3
 where cdcooper = 16
   and nrdconta = 255068
   and nrctrlim = 56218;
   
   
update craplim
   set insitlim = 3
 where cdcooper = 1
   and nrdconta = 825328
   and nrctrlim = 9;
   
commit;
