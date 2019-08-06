-- Adicionar coluna referencia do sas na tabela de saldo diarios dos associados.
ALTER TABLE CRAPSDA
ADD COLUMN VLLIMCRDPA NUMBER(25,2) DEFAULT 0;

COMMENT ON COLUMN CRAPSDA.VLLIMCARCRDPA IS
    'Limite disponivel de Cartao pre-aprovado gerado pelo SAS';
