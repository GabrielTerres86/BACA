
DELETE
FROM tbcadast_pessoa_fisica_resp
WHERE idpessoa = 21587347;

insert into tbcadast_pessoa_fisica_resp (IDPESSOA, NRSEQ_RESP_LEGAL, IDPESSOA_RESP_LEGAL, CDRELACIONAMENTO, CDOPERAD_ALTERA)
values (21587347, 1, 21587515, 2, '1');

COMMIT;
