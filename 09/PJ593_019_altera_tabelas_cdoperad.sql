-- alterar tipo de dado do campo cdoperad

ALTER TABLE tbcrd_preaprov_bloqueio MODIFY(cdoperad VARCHAR2(10));

ALTER TABLE tbcrd_preaprov_histcarga MODIFY(cdoperad VARCHAR2(10));

ALTER TABLE tbcrd_preaprov_recusa MODIFY(cdoperad VARCHAR2(10));