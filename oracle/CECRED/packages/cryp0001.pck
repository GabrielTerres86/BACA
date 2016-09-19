CREATE OR REPLACE PACKAGE CECRED.CRYP0001 AS
/*..............................................................................

   Programa: CRYP0001
   Sistema : Procedimentos e funcoes para criptografar a senha do PINBLOCK
   Sigla   : CRED
   Autor   : James Prust Júnior
   Data    : Julho/2014                Ultima Atualizacao:

   Dados referentes ao programa:

   Objetivo  : Cryptografar a senha do PINBLOCK.
.................................................................................*/
  PROCEDURE pc_get_pin_block(pr_pinblock   IN VARCHAR2 --> Senha
                            ,pr_workingkey IN VARCHAR2 --> WorkingKey
                            ,pr_xmllog     IN VARCHAR2 --> XML com informações de LOG
                            ,pr_cdcritic   OUT PLS_INTEGER --> Código da crítica
                            ,pr_dscritic   OUT VARCHAR2 --> Descrição da crítica
                            ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                            ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro   OUT VARCHAR2);
                          
END CRYP0001;
/

CREATE OR REPLACE PACKAGE BODY CECRED.CRYP0001 wrapped 
a000000
b2
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
b
97e 422
pdcdsI7j+ONqeTGJ90bFU+4PZVMwgzsruiCDfI4Zgp0VBmzDjCEfWoS+w0oQ5/NwF9zy7j7m
7X5a/VgRKs1rJD/cWuxGwDtvqEtqOrxOOs5OoXpZYLT7kcd7gKJHAFxcKkZz8kRrrs96r71Q
2vuF72sdNX2+VqDGbl8nQeNJ+gSoXWUhlax0LVALaPkK0VL+cV9xi19wPxxI34jQvrdZchXz
8kb9U6LcOkypNC0sRVamW9tSVoEMtOu3nucaGVl+XwFuuCBKXVVwua9SOd9rNq56P58nnj/n
5n4dlsgeIN1PksKvUpNla2fUVGfl73NY8iTdfUwH3f4qhOg0KWuoR+EccpRDUbeAxtHjYrij
0kZeQVIfeGlmTQAIarQe+yCmDDlr87Fn0Cmdp/mcAsjLOeAgVf58sogXaYV93MzeKuy+Y65V
RfIjAwOoVQP97dojVjNgnOWQhJmL0Xdj3Uy4uItGo16XLk7BBUUg1WPImHB28qSyBbIViB8N
cXUxfqvsGDInIVy2OW90oG95/acmxE0xGsIWgXoEuqJJq6AyXOqy2Qn0SA05YTheXHgmotUf
Y1F2PEv0FsIeeTuyowyCTd6GyQV3rxEpn9llDfu+HLREMygeYuxS2QklzQjKD8cm1kx3Xsc8
XgD0xzPNzb13kzD0V42/qXGDfv7MTY1sdvETJYvXDGXoVeU1No+mXdjo9SC1+ZL0+Xo7D6ez
5eo9qyeUADscUcZD/BJk/JLkJcKjzQw7GEj4TEUwX4fikr4FpHDKVb9VyK6OnDrKynRLXgWg
/i5aZE/2TSyKn1Juogccn7Z18RpeStZ6uZg2TjYaQafWCD7cwFbqcpfeLxWTL4SX/TJ2+Bnd
eI2F3LijhHXzpeGcF7AzP+eb+7Z0Nc5aPwPy9z7a5MDVlFRk76DjUGojOvgqkryHepY8fUPe
gQs3ZUJ4WjUgIIW136c6SUNBA/alJO3xGiJxE+QJRWYYh/hVMC5zosdSDcGlcWyOVQpGrj7E
53CgA0K28Ywou2eQ8my8kO3JMrzkHRfLjkI=
/

