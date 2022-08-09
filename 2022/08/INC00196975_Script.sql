BEGIN
  
  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'CANTINHO N. COMERCIO DE GENEROS ALIMENTICIOS LTDA' 
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '00452271000188';

  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'LUZZITANA I. E C. DE CONFECCOES LTDA - EIRELI'
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '01428987000102';
  
  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'TRANSFERETRANSPORTES N. E INTERNACIONAIS LTDA' 
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '05844455000107';

  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'DEBORA P. DOS SANTOS TERCEIRIZACAO DE MAO DE OBRA' 
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '16902810000173';
  
  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'ELECTROCARE C. I. E EXPORTACAO DE EQUIPAMENTO' 
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '20367625000101';
  
  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'CIA D. M. C. DE MOVEIS E ELETRODOMESTICOS LTDA'
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '30580694000144';
  
  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'ANDREIA R DE S DE A. COMERCIO DE BEBIDAS LTDA'
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '31477860000225';
  
  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'CASA M. C. DE ROUPAS MOVEIS E ELETRODOMESTICOS'
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '35536312000107';


  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'O CHOCOLATEIRO IND. E COMERCIO DE CHOCOLATES LTDA'
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '36432055000118';

  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'INDUSTRIAL 3D I. DE MAQUINAS E FERRAMENTAS LTDA'
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '38251073000129';

  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'FINANCA A. GESTAO FINANCEIRA E TERCEIRIZACAO LTDA'
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '40702784000114 ';

  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'PONIK C. DE IMOVEIS E GESTAO DE DOCUMENTOS LTDA'
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '42259384000101';

  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'CONSULTORIA E G. DE PROJETOS GESSNER LTDA'
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '44494269000147';

  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'IRMAOS Q. SERVICOS DE LIMPEZA PROFISSIONAL LTDA'
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '45699699000168';

  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'AUTONIVELAR C. E S. PARA CONSTRUCAO CIVIL LTDA'
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '45761799000177';

  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'ADRIANA A. SAMUEL DO NASCIMENTO SANTOS 03742835912'
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '45985028000163';

  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = 'VALDESIO C. RODRIGUES DOS SANTOS 06376666906'
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '46860493000130';
  
  UPDATE cecredleg.tbjdddabnf_beneficiarioif@jdnpcsql
  SET "Nom_RzSocBenfcrio" = '3 A S C. E M. DE EQUIPAMENTOS DE MOVIMENTACAO'
  WHERE "TpPessoaBenfcrio" = 'J'
  AND "CNPJ_CPFBenfcrio" = '46977320000105';

  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'INC00196975');
    ROLLBACK;                         
END;
