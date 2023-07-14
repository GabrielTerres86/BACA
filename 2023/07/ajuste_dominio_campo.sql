begin

  UPDATE cecred.tbgen_dominio_campo
     SET dscodigo = 'Cartão de Crédito Cabal'
   WHERE cddominio = 19 
     AND nmdominio = 'TPCATEG_RECIPROCIDADE';

    UPDATE cecred.tbgen_dominio_campo
     SET dscodigo = 'Cartão de Crédito Clássico'
   WHERE cddominio = 20 
     AND nmdominio = 'TPCATEG_RECIPROCIDADE';

  commit;
end;
