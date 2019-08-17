UPDATE crapaca
   SET crapaca.lstparam = 'pr_idrecipr,pr_nrdconta'
 WHERE crapaca.nmdeacao = 'CANCELA_DESCONTO';

 commit;