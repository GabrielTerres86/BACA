/* Usuários habilitados para realizar baixa forçada 
Nome                  Usuário F
Charles Loes Junior   F0030631
Daisy Darlene Zeitz               F0030868
Edenise Camargo dos Santos            F0030892
Gisela Terezinha Bittencourt Pacheco  F0033003
Rafael Imhof                          F0033030
Bruna Batschauer                      F0033035
*/
--CDCOOPER, UPPER(NMSISTEM), UPPER(TPTABELA), CDEMPRES, UPPER(CDACESSO), TPREGIST
INSERT INTO craptab (craptab.cdcooper
                    ,craptab.nmsistem
                    ,craptab.tptabela
                    ,craptab.cdempres
                    ,craptab.cdacesso
                    ,craptab.tpregist
                    ,craptab.dstextab)
            VALUES( 3
                   ,'CRED'
                   ,'GENERI'
                   ,0
                   ,'USRCOBRBAIXA'
                   ,1
                   ,'f0030631'); --Charles Loes Junior


INSERT INTO craptab (craptab.cdcooper
                    ,craptab.nmsistem
                    ,craptab.tptabela
                    ,craptab.cdempres
                    ,craptab.cdacesso
                    ,craptab.tpregist
                    ,craptab.dstextab)
            VALUES( 3
                   ,'CRED'
                   ,'GENERI'
                   ,0
                   ,'USRCOBRBAIXA'
                   ,2
                   ,'f0030868'); --Daisy Darlene Zeitz



INSERT INTO craptab (craptab.cdcooper
                    ,craptab.nmsistem
                    ,craptab.tptabela
                    ,craptab.cdempres
                    ,craptab.cdacesso
                    ,craptab.tpregist
                    ,craptab.dstextab)
            VALUES( 3
                   ,'CRED'
                   ,'GENERI'
                   ,0
                   ,'USRCOBRBAIXA'
                   ,3
                   ,'f0030892'); --Edenise Camargo dos Santos            



INSERT INTO craptab (craptab.cdcooper
                    ,craptab.nmsistem
                    ,craptab.tptabela
                    ,craptab.cdempres
                    ,craptab.cdacesso
                    ,craptab.tpregist
                    ,craptab.dstextab)
            VALUES( 3
                   ,'CRED'
                   ,'GENERI'
                   ,0
                   ,'USRCOBRBAIXA'
                   ,4
                   ,'f0033003'); --Gisela Terezinha Bittencourt Pacheco  



INSERT INTO craptab (craptab.cdcooper
                    ,craptab.nmsistem
                    ,craptab.tptabela
                    ,craptab.cdempres
                    ,craptab.cdacesso
                    ,craptab.tpregist
                    ,craptab.dstextab)
            VALUES( 3
                   ,'CRED'
                   ,'GENERI'
                   ,0
                   ,'USRCOBRBAIXA'
                   ,5
                   ,'f0033030'); --Rafael Imhof                          

INSERT INTO craptab (craptab.cdcooper
                    ,craptab.nmsistem
                    ,craptab.tptabela
                    ,craptab.cdempres
                    ,craptab.cdacesso
                    ,craptab.tpregist
                    ,craptab.dstextab)
            VALUES( 3
                   ,'CRED'
                   ,'GENERI'
                   ,0
                   ,'USRCOBRBAIXA'
                   ,6
                   ,'f0033035'); --Bruna Batschauer                      


commit;
