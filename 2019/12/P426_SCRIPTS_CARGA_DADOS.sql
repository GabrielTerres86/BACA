--------------------------------------------------------------------------------
-- INCLUSÃO DE PARAMETRO DO VALOR DO LIMITE/DIA DO DEPOSITO DE CHEQUE NA TB045
--------------------------------------------------------------------------------
-- **** Deverá ser feito o script para todas as cooperativas, verifica os valores para pessoa fisica e juridica
-- **** Deverá ter o valor para o Operacional e para Ailos
update craptab 
set dstextab = dstextab||'000000002000,00;000000300000,00'
where  craptab.nmsistem = 'CRED' and
                            craptab.tptabela = 'GENERI'     AND
                            craptab.cdempres = 0            AND
                            craptab.cdacesso = 'LIMINTERNT' and
                            craptab.cdcooper = 1  and    -- coperativa
                            craptab.tpregist in (1,2); --  fisica e Juridica
COMMIT;

--------------------------------------- 
-- INCLUSÃO DE PARAMETRO DE E-MAIL
---------------------------------------
-- select * from crapprm where upper(cdacesso) like '%EMAIL_CHEQUE_MOBILE%'
-- Script para cadastrar email utilizado no processo do termo de aceito do deposito de cheque mobile
-- ******* Deverá ser cadastrado para todas as cooperativas  ***********
insert into crapprm 
values ('CRED',1,'EMAIL_CHEQUE_MOBILE', 'Email utilizado processo de deposito de cheque Mobile','josiane.stiehler@amcom.com.br',null);

COMMIT;
