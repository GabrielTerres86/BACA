BEGIN
UPDATE cecred.crapprm p
    SET p.dsvlrprm = '01/04/2024;0;0;0'
  WHERE p.cdacesso = 'RISCO_CARTAO_BACEN'
    AND p.dsvlrprm = '01/04/2024;0;0;3';
COMMIT;   
END ;