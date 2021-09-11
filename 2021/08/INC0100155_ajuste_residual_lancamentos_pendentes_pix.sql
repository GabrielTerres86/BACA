BEGIN
UPDATE tbcc_lancamentos_pendentes
   SET idsituacao = 'M', dscritica = 'INC0100246'
 WHERE cdproduto = 53
   AND idsituacao = 'E'
   AND cdpesqbb LIKE '%EST%';
COMMIT;
END;