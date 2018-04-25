-- Este script corrige a duplicidade de registros na tabela
-- O script insere_mtvatvprb_tbgen_motivo.sql foi executado mais de uma vez em Producao
delete tbgen_batch_controle t
where t.idcontrole in(35994,35995,35996,35997,35998,35999,
                      36000,36001,36002,36003,36004,36005,36006)
  and t.cdprogra = 'RISC0003.PC_RISCO_CENTRAL_OCR';
commit;
/