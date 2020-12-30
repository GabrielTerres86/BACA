-- PRB0044013
update crapprm c set c.dsvlrprm = '500' where c.cdacesso = 'QTD_MAX_REG_PAGFOR';
--
commit;
