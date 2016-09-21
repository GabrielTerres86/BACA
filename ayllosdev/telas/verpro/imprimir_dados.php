<?
/*!
 * FONTE        : imprimir_dados.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 01/11/2011
 * OBJETIVO     : Carregar dados para impressões do VERPRO	
 * --------------
 * ALTERAÇÕES   : 01/08/2014 - Alterar o programa para realizar as chamadas do Oracle ( Renato - Supero )
 * -------------- 
 */ 
?>

<? 
	
	session_cache_limiter("private");
	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	

	// Verifica se parâmetros necessários foram informados
	if (!isset($_POST['nrdconta']) || 
		!isset($_POST['nmprimtl']) ||
		!isset($_POST['cdtippro'])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	
	
	// Recebe as variaveis
	$nrdconta 	= $_POST['nrdconta'];
	$nmprimtl 	= $_POST['nmprimtl'];
	$cdtippro 	= $_POST['cdtippro'];
	$nrdocmto 	= $_POST['nrdocmto'];
	$nrseqaut 	= $_POST['nrseqaut'];
	$nmprepos 	= $_POST['nmprepos'];
	$nmoperad 	= $_POST['nmoperad'];
	$dttransa 	= $_POST['dttransa'];
	$hrautent 	= $_POST['hrautent'];
	$dtmvtolx 	= $_POST['dtmvtolt'];
	$dsprotoc   = $_POST['dsprotoc'];
	$label		= $_POST['label'];
	$label2		= $_POST['label2'];
	$valor		= $_POST['vldocmto'];
	$auxiliar 	= $_POST['auxiliar'];
	$auxiliar2	= $_POST['auxiliar2'];
	$auxiliar3	= $_POST['auxiliar3'];
	$auxiliar4	= $_POST['auxiliar4'];	
	$dsdbanco   = $_POST['dsdbanco'];
	$dsageban   = $_POST['dsageban'];
	$nrctafav   = $_POST['nrctafav'];
	$nmfavore   = $_POST['nmfavore'];
	$nrcpffav   = $_POST['nrcpffav'];
	$dsfinali   = $_POST['dsfinali'];
	$dstransf   = $_POST['dstransf'];
	$dslinha1   = $_POST['dslinha1'];
	$dslinha2   = $_POST['dslinha2'];
	$dslinha3   = $_POST['dslinha3'];
	$dsispbif   = $_POST['dsispbif'];
	$dspacote   = $_POST['dspacote'];
	$dtdiadeb   = $_POST['dtdiadeb'];
	$dtinivig   = $_POST['dtinivig'];
	
	
	$dsiduser 	= session_id();	

	if ( $cdtippro == '2' ) {
		$cdbarras   = $_POST['cdbarrax'];
		$lndigita   = $_POST['lndigitx'];
	
	} else if ( $cdtippro == '7' )	{
		$cdbarras   = $_POST['cdbarrax'];
		$lndigita   = '        '.$_POST['lndigitx'];
		
	} else {
		$cdbarras   = $_POST['cdbarras'];
		$lndigita   = $_POST['lndigita'];
	}
	
	$campospc = 'dslinha1' . '|' . 'dslinha2' . '|' . 'dslinha3';
	$dadosprc = $dslinha1 . ';' . $dslinha2 . ';' . $dslinha3;
	
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<nmprimtl>'.$nmprimtl.'</nmprimtl>';
	$xml .= '		<cdtippro>'.$cdtippro.'</cdtippro>';
	$xml .= '		<nrdocmto>'.$nrdocmto.'</nrdocmto>';
	$xml .= '		<nrseqaut>'.$nrseqaut.'</nrseqaut>';
	$xml .= '		<nmprepos>'.$nmprepos.'</nmprepos>';
	$xml .= '		<nmoperad>'.$nmoperad.'</nmoperad>';
	$xml .= '		<dttransa>'.$dttransa.'</dttransa>';
	$xml .= '		<hrautent>'.$hrautent.'</hrautent>';
	$xml .= '		<dtmvtolx>'.$dtmvtolx.'</dtmvtolx>';
	$xml .= '		<dsprotoc>'.$dsprotoc.'</dsprotoc>';
	$xml .= '		<cdbarras>'.$cdbarras.'</cdbarras>';
	$xml .= '		<lndigita>'.$lndigita.'</lndigita>';
	$xml .= '		<label>'.$label.'</label>';
	$xml .= '		<label2>'.$label2.'</label2>';
	$xml .= '		<valor>'.$valor.'</valor>';
	$xml .= '		<auxiliar >'.$auxiliar.'</auxiliar>';
	$xml .= '		<auxiliar2>'.$auxiliar2.'</auxiliar2>';
	$xml .= '		<auxiliar3>'.$auxiliar3.'</auxiliar3>';
	$xml .= '		<auxiliar4>'.$auxiliar4.'</auxiliar4>';	
	$xml .= '		<dsdbanco>'.$dsdbanco.'</dsdbanco>';
	$xml .= '		<dsispbif>'.$dsispbif.'</dsispbif>';
	$xml .= '		<dsageban>'.$dsageban.'</dsageban>';
	$xml .= '		<nrctafav>'.$nrctafav.'</nrctafav>';
	$xml .= '		<nmfavore>'.$nmfavore.'</nmfavore>';
	$xml .= '		<nrcpffav>'.$nrcpffav.'</nrcpffav>';
	$xml .= '		<dsfinali>'.$dsfinali.'</dsfinali>';
	$xml .= '		<dstransf>'.$dstransf.'</dstransf>';	
	$xml .= '		<dspacote>'.$dspacote.'</dspacote>';	
	$xml .= '		<dtdiadeb>'.$dtdiadeb.'</dtdiadeb>';	
	$xml .= '		<dtinivig>'.$dtinivig.'</dtinivig>';	
	$xml .= retornaXmlFilhos($campospc, $dadosprc, 'Inform', 'Linhas');
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "VERPRO", "IMPPROTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
	    exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);		 
    }
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjeto->roottag->cdata;
		
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	
	// Função para exibir erros na tela através de javascript
    function exibeErro($msgErro) { 
	  ?><script language="javascript">alert('<?php echo $msgErro; ?>');</script><?php
		exit();	
    }

?>