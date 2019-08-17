-- Alter sequence

alter sequence CECRED.SEQ_TEDENVIO maxvalue 99999999;

-- Modify the last number

alter sequence CECRED.SEQ_TEDENVIO increment by 65000000 nocache;

select CECRED.SEQ_TEDENVIO.nextval from dual;

alter sequence CECRED.SEQ_TEDENVIO increment by 1 cache 20;

