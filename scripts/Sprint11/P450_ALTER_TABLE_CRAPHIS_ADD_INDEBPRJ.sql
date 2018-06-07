ALTER TABLE cecred.craphis
	ADD COLUMN indebprj number(1) DEFAULT 0 not null;
Comment on column cecred.craphis.indebprj 'Indica se o histórico pode ser debitado em conta que esteja em prejuízo (0 - Não, 1 - Sim)';