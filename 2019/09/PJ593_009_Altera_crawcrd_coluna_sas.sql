-- Adicionar coluna referencia do sas na tabela de proposta de cartao
ALTER TABLE CRAWCRD
ADD COLUMN IDLIMITE NUMBER NULL;

COMMENT ON COLUMN CRAWCRD.IDLIMITE IS
    'Chave artificial de identificacao do limite preaprovado do sas. Identificacao quando a proposta foi efetuada pelo limite pre aprovado';
