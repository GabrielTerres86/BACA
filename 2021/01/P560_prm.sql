
INSERT INTO crapprm
  (nmsistem
  ,cdcooper
  ,cdacesso
  ,dstexprm
  ,dsvlrprm) 
VALUES
  ('CRED' --nmsistem
   ,0     --cdcooper
   ,'OBSERV_SALDO_RECUP' --cdacesso
   ,'Observacao a ser apresentada quando retornar saldo devedor para cooperado' --dstexprm
   ,'Os valores apresentados poderão sofrer alterações devido aos encargos de cobrança.' --dsvlrprm
   );
COMMIT;




