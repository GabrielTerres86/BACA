begin
  UPDATE CECRED.TBEPR_CONSIGNADO_PAGAMENTO
   SET INSTATUS = 2
 WHERE IDSEQUENCIA = 1175197
   AND CDCOOPER = 14
   AND NRDCONTA = 310190
   AND NRCTREMP = 40091;
   
  COMMIT;
exception
  when others then
    rollback;
    raise_application_error(-20500, SQLERRM);
end;
