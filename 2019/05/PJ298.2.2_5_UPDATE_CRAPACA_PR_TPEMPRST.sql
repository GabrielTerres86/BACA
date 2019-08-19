-- incluir parametro para identificar o tipo de Emprestimo
UPDATE CRAPACA 
SET LSTPARAM = 'pr_inprejuz,pr_tpemprst'
WHERE NMDEACAO = 'BUSCA_PRAZO_VCTO_MAX'
  AND NMPACKAG = 'TELA_COBEMP';

COMMIT;