﻿--Update da obter dados atenda Revitalização
UPDATE crapaca aca SET aca.nmproced = 'obterDadosAtendaWeb', aca.nmpackag = NULL WHERE aca.nrseqaca = 490 AND aca.nmpackag = 'CADA0004' AND aca.nmproced = 'pc_carrega_dados_atenda_web';

COMMIT;