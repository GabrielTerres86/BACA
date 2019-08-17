begin

UPDATE crapprm p SET dsvlrprm = 'fabricio@ailos.coop.br,rodrigo.siewerdt@ailos.coop.br,lucas.ranghetti@ailos.coop.br,ademir.fink@ailos.coop.br,cartoes@ailos.coop.br'
 WHERE p.nmsistem = 'CRED'
 AND   p.cdacesso = 'CRD_RESPONSAVEL';

 commit;
 
end;
 