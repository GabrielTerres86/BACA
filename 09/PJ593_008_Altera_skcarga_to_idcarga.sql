
ALTER TABLE tbcrd_preaprov_recusa
RENAME COLUMN skcarga TO idcarga;

ALTER TABLE tbcrd_preaprov_limite
RENAME COLUMN skcarga TO idcarga;

ALTER TABLE tbcrd_preaprov_carga
RENAME COLUMN skcarga TO idcarga;

ALTER TABLE tbcrd_preaprov_bloqueio
RENAME COLUMN skcarga TO idcarga; 

ALTER TABLE tbcrd_preaprov_histcarga
RENAME COLUMN skcarga TO idcarga;