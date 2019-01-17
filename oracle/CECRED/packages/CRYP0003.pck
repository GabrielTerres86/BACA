CREATE OR REPLACE PACKAGE CECRED.CRYP0003 AS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : CRYP0003
    Sistema  : Procedimentos para criptografia de chaves RSA
    Sigla    : CRED
    Autor    : Renato Darosci - Supero
    Data     : Novermbro/2018                   Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: -----
   Objetivo  : Package para conster as especificações para a chamada das rotinas java source

    Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/

-- Rotina de encrypt para a mensagem, utilizando a chave 3DES
FUNCTION encrypt3Des(pr_dsxmlarq VARCHAR2,pr_dschvdes VARCHAR2) RETURN VARCHAR2
AS
LANGUAGE JAVA NAME 'CipRSAUtil.encrypt3Des(java.lang.String,java.lang.String) return java.lang.String';

-- Rotina de encrypt da chave 3DES, utilizando a chave publica da CIP
FUNCTION encrypt3DesKey(pr_dschvdes VARCHAR2,pr_dschvpub VARCHAR2) RETURN VARCHAR2
AS
LANGUAGE JAVA NAME 'CipRSAUtil.encrypt3DesKey(java.lang.String,java.lang.String) return java.lang.String';

-- Rotina de decrypt para a mensagem
FUNCTION decrypt3Des(ENCRYPTED_TEXT VARCHAR2,HASH_KEY VARCHAR2) RETURN VARCHAR2
AS
LANGUAGE JAVA NAME 'CipRSAUtil.decrypt3Des (java.lang.String,java.lang.String) return java.lang.String';

-- Rotina de decrypt para as chaves 3Des
FUNCTION decrypt3DesKey(ENCRYPTED_TEXT VARCHAR2,PUBLIC_KEY VARCHAR2) RETURN VARCHAR2
AS
LANGUAGE JAVA NAME 'CipRSAUtil.decrypt3DesKey (java.lang.String,java.lang.String) return java.lang.String';

-- Rotina de assinatura digital
FUNCTION signHashSHA256(HASH_MESSAGE VARCHAR2,PUBLIC_KEY VARCHAR2) RETURN VARCHAR2
AS
LANGUAGE JAVA NAME 'CipRSAUtil.signHashSHA256(java.lang.String,java.lang.String) return java.lang.String';

-- Rotina de verificação de assinatura
FUNCTION verifyHashSHA256(hash_message VARCHAR2,signned_hash VARCHAR2, public_key VARCHAR2) RETURN BOOLEAN
AS
LANGUAGE JAVA NAME 'CipRSAUtil.verifyHashSHA256 (java.lang.String,java.lang.String,java.lang.String) return java.lang.Boolean';

-- Rotina para gerar o hash do XML
FUNCTION getXmlHash(pr_dsxmlarq  VARCHAR2) RETURN VARCHAR2
AS
LANGUAGE JAVA NAME 'CipRSAUtil.getXmlHash (java.lang.String) return java.lang.String';

-- Rotina para gerar a chave 3DES de 24 bytes
FUNCTION get3DESKey RETURN VARCHAR2
  AS
  LANGUAGE JAVA NAME 'CipRSAUtil.get3DESKey() return java.lang.String';
  
-- Rotina para Compactar conteúdos no formato GZIP
FUNCTION gzipCompress(pr_dsmensag  IN VARCHAR2) RETURN VARCHAR2
  AS
  LANGUAGE JAVA NAME 'CipGZIPCompress.getCompress(java.lang.String) return java.lang.String';

-- Rotina para Descompactar conteúdos no formato GZIP
FUNCTION gzipDecompress(pr_dsmsgzip  IN VARCHAR2) RETURN VARCHAR2
  AS
  LANGUAGE JAVA NAME 'CipGZIPCompress.getDecompress(java.lang.String) return java.lang.String';

-- Rotina para Criptografar e Compactar o arquivo CIP, gerado pela Ailos
FUNCTION escritaArquivoPCPS(pr_nrserieCIP   IN VARCHAR2
                           ,pr_nrserieAilos IN VARCHAR2
                           ,pr_dschaveprv   IN VARCHAR2
                           ,pr_dschavepub   IN VARCHAR2
                           ,pr_dsarquivoXML IN VARCHAR2
                           ,pr_dsarquivoCip IN VARCHAR2) RETURN VARCHAR2 AS 
  LANGUAGE JAVA NAME 'CipRSAUtil.escritaArquivoPCPS(java.lang.String
                                                   ,java.lang.String
                                                   ,java.lang.String
                                                   ,java.lang.String
                                                   ,java.lang.String
                                                   ,java.lang.String) return java.lang.String';

-- Rotina para Descriptografar e Descompactar o arquivo CIP, gerando um arquivo XML para leitura
FUNCTION leituraArquivoPCPS(pr_nrserieCIP   IN VARCHAR2
                           ,pr_nrserieAilos IN VARCHAR2
                           ,pr_dschaveprv   IN VARCHAR2
                           ,pr_dschavepub   IN VARCHAR2
                           ,pr_dsarquivoCip IN VARCHAR2
                           ,pr_dsarquivoXML IN VARCHAR2) RETURN VARCHAR2 AS 
  LANGUAGE JAVA NAME 'CipRSAUtil.leituraArquivoPCPS(java.lang.String
                                                   ,java.lang.String
                                                   ,java.lang.String
                                                   ,java.lang.String
                                                   ,java.lang.String
                                                   ,java.lang.String) return java.lang.String';
                           

END CRYP0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CRYP0003 IS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : CRYP0003
    Sistema  : Procedimentos para criptografia de chaves RSA
    Sigla    : CRED
    Autor    : Renato Darosci - Supero
    Data     : Novermbro/2018                   Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: -----
   Objetivo  : Package para conter as especificações para a chamada das rotinas java source

    Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/


END CRYP0003;
/
