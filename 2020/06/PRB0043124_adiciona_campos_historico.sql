/*
  PRB0043124 - Script para adicionar os campos que terão suas alterações monitoradas pelo controle de histórico
  
  Dioni - Supero
*/

INSERT INTO tbcadast_campo_historico ( NMTABELA_ORACLE, NMCAMPO, DSCAMPO)
VALUES('TBCADAST_PESSOA_FISICA', 'TPPREFERENCIACONTATO', 'Preferencia de contato (Dominio:TPPREFERENCIACONTATO)');

INSERT INTO tbcadast_campo_historico ( NMTABELA_ORACLE, NMCAMPO, DSCAMPO)
VALUES('TBCADAST_PESSOA_FISICA','TPPCD', 'Tipo de PCD (Dominio:TPPCD)');

INSERT INTO tbcadast_campo_historico ( NMTABELA_ORACLE, NMCAMPO, DSCAMPO)
VALUES('TBCADAST_PESSOA_FISICA','TPNECESSIDADEPCD', 'Tipo de necessidade de PCD (Dominio:TPNECESSIDADEPCD)');

INSERT INTO tbcadast_campo_historico ( NMTABELA_ORACLE, NMCAMPO, DSCAMPO)
VALUES('TBCADAST_PESSOA_JURIDICA', 'TPPREFERENCIACONTATO', 'Preferencia de contato (Dominio:TPPREFERENCIACONTATO)');

INSERT INTO tbcadast_campo_historico ( NMTABELA_ORACLE, NMCAMPO, DSCAMPO)
VALUES('TBCADAST_PESSOA_JURIDICA', 'TPPREFERATENDIMENTO', 'Preferencia de atendimento');

INSERT INTO tbcadast_campo_historico ( NMTABELA_ORACLE, NMCAMPO, DSCAMPO)
VALUES('TBCADAST_PESSOA_RENDA', 'INRENDACOMPROVADA', 'Indicativo de renda comprovada. 0 - Nao comprovada; 1 - Comprovada');

COMMIT;