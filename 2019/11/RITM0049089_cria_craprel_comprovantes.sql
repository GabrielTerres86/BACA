-- Criar registro de relatório
INSERT INTO craprel (cdrelato, nmrelato, nmformul, cdcooper, periodic)
(SELECT 789, 'COMPROVANTE DE PAGAMENTO DARF', '132col', cdcooper, 'Online' FROM crapcop);

INSERT INTO craprel (cdrelato, nmrelato, nmformul, cdcooper, periodic)
(SELECT 790, 'COMPROVANTE DE AGENDAMENTO DARF', '132col', cdcooper, 'Online' FROM crapcop);

INSERT INTO craprel (cdrelato, nmrelato, nmformul, cdcooper, periodic)
(SELECT 791, 'COMPROVANTE DE PAGAMENTO DAS', '132col', cdcooper, 'Online' FROM crapcop);

INSERT INTO craprel (cdrelato, nmrelato, nmformul, cdcooper, periodic)
(SELECT 792, 'COMPROVANTE DE AGENDAMENTO DAS', '132col', cdcooper, 'Online' FROM crapcop);

INSERT INTO craprel (cdrelato, nmrelato, nmformul, cdcooper, periodic)
(SELECT 793, 'COMPROVANTE DE PAGAMENTO/AGENDAMENTO GPS', '132col', cdcooper, 'Online' FROM crapcop);
-- Efetuar commit
COMMIT;
