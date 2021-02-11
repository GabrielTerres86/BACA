-- Inserindo novas PRMs
  INSERT INTO CRAPPRM
        (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  VALUES
    ('CRED',
     0,
     'MSG_BLOQ_CONTRATACAO',
     'Mensagem de bloqueio na contratacao de proposta de emprestimo por alguma restricao',
     'A proposta já foi contratada. Para efetivar a o operação, autorize a transação pendente!');
    
-- Inclusão de novo parametro na mensageria para novo tipo de limite por CPF/CNPJ
  update CRAPACA
     set LSTPARAM = 'pr_idsegmento, pr_dssegmento, pr_qtsimulacoes_padrao, pr_nrvariacao_parc, pr_nrmax_proposta, pr_nrintervalo_proposta, pr_dssegmento_detalhada, pr_qtdias_validade, pr_tplimite_valor, pr_perm_pessoa_fisica, pr_perm_pessoa_juridica'
   where NMDEACAO = 'SEGEMP_ALTERA_SEG';
      
  delete tbgen_dominio_campo where NMDOMINIO='TPLIMITE_VALOR_SEGMENTO';
  insert into tbgen_dominio_campo values ('TPLIMITE_VALOR_SEGMENTO', 1, 'por proposta');
  insert into tbgen_dominio_campo values ('TPLIMITE_VALOR_SEGMENTO', 2, 'por CPF/CNPJ raiz');
  
COMMIT;  
