BEGIN
  
  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'PERFIGLASS C. DE VIDROS PERFIS E ACESSORIOS LTDA' 
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '17317267000100';

  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'ELLE E E. INDUSTRIA E COMERCIO DE CONFECCOES LTDA'
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '40225341000180';
  
  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'ANGELICA V. MENDES DO AMARAL DA SILVA 06904147903' 
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '47150526000111';

  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'ASSOCIACAO DE P. E AMIGOS DO AUTISTA RIO NEGRINHO' 
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '47221614000167';

  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'INC00196975');
    ROLLBACK;                         
END;
