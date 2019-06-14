<?

	session_cache_limiter("private");
	session_start();

	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();


    $xml = "<Root>
                <Cabecalho>
                    <Bo>b1wgen0182.p</Bo>
                    <Proc>consulta-administradora</Proc>
                </Cabecalho>
                <Dados>
                    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>
                    <cdagenci>0</cdagenci>
                    <nrdcaixa>0</nrdcaixa>
                    <cdoperad>1</cdoperad>
                    <idorigem>5</idorigem>
                    <nmdatela>ADMCRD</nmdatela>
                    <cdadmcrd></cdadmcrd>
                    <nmadmcrd></nmadmcrd>
                    <nriniseq>1</nriniseq>
                    <nrregist>20</nrregist>
                </Dados>
            </Root>";
    $xmlResult = getDataXML($xml,false);
    echo "/* $xmlResult */";

?>