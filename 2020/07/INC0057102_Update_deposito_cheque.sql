update tbchq_deposito_cheque_mob set insituacao = 4 where idseqdeposito = 381;
update tbchq_deposito_cheque_mob set dsmotivo_recusa = 'Formalistica' where idseqdeposito = 381;
update tbchq_deposito_cheque_mob set origem_recusa = 1 where idseqdeposito = 381;
COMMIT;
