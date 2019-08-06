-- Adicionar coluna referencia do sas na tabela de saldo diarios dos associados.

ALTER TABLE CRAPSDA
MODIFY(VLLIMCRDPA NUMBER(25,2) DEFAULT 0);
