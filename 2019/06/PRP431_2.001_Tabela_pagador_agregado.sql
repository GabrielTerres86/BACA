CREATE TABLE tbcobran_pagador_agregado (
    cdcooper         NUMBER(5) NOT NULL,
    nrdconta         NUMBER(10) NOT NULL,
    inpessoapagdr    NUMBER(5) NOT NULL,
    nrcpfcgcpagdr    NUMBER(25) NOT NULL,
    nmpagdr          VARCHAR2(100) NOT NULL,
    inpessoagrg      NUMBER(5) NOT NULL,
    nrcpfcgcagrg     NUMBER(25) NOT NULL,
    nmagrg           VARCHAR2(100) NOT NULL,
    idsituacao       NUMBER(1) NOT NULL,
    dtcadastro       DATE,
    dtretorno        DATE,
    dtadesao         DATE,
    dtcancelamento   DATE
);

COMMENT ON COLUMN tbcobran_pagador_agregado.cdcooper IS
    'Codigo cooperativa.';

COMMENT ON COLUMN tbcobran_pagador_agregado.nrdconta IS
    'Numero da conta do associado.';

COMMENT ON COLUMN tbcobran_pagador_agregado.inpessoapagdr IS
    'Tipo de pessoa Pagador (1 - fisica, 2 - juridica).';

COMMENT ON COLUMN tbcobran_pagador_agregado.nrcpfcgcpagdr IS
    'Numero do CPF/CGC do pagador.';

COMMENT ON COLUMN tbcobran_pagador_agregado.nmpagdr IS
    'Nome do Pagador.';

COMMENT ON COLUMN tbcobran_pagador_agregado.inpessoagrg IS
    'Tipo de pessoa agregado (1 - fisica, 2 - juridica).';

COMMENT ON COLUMN tbcobran_pagador_agregado.nrcpfcgcagrg IS
    'Numero do CPF/CGC do agregado.';

COMMENT ON COLUMN tbcobran_pagador_agregado.nmagrg IS
    'Nome do Agregado.';

COMMENT ON COLUMN tbcobran_pagador_agregado.idsituacao IS
    'Indica a situacao do pagador agregado(Aguardando aprovacao/Ativo).';

COMMENT ON COLUMN tbcobran_pagador_agregado.dtcadastro IS
    'Data do envio da JD.';

COMMENT ON COLUMN tbcobran_pagador_agregado.dtretorno IS
    'Data de retorno.';

COMMENT ON COLUMN tbcobran_pagador_agregado.dtadesao IS
    'Data de adesao.';

COMMENT ON COLUMN tbcobran_pagador_agregado.dtcancelamento IS
    'Data de Cancelamento.';
	