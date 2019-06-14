<?php
/*!
 * FONTE        : valida_senha_magnetico.php
 * CRIAÇÃO      : Jonata
 * DATA CRIAÇÃO : Marco/2017
 * OBJETIVO     : Valida senha do cartão magnético do cooperado.
 * --------------
 * ALTERAÇÕES   : 
 * 
 * -------------- 
 */ 
?>

<?php	

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");		
		
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : "";
	$cddsenha = (isset($_POST["cddsenha"])) ? $_POST["cddsenha"] : "";
	$retorno  = (isset($_POST["retorno"])) ? $_POST["retorno"] : "";
	$validainternet = (isset($_POST['validainternet'])) ? $_POST['validainternet'] : '';
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0092.p</Bo>';
	$xml .= '		<Proc>valida_senha_cooperado</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '   <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<vlintrnt>'.$validainternet.'</vlintrnt>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<flgerlog>yes</flgerlog>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<cddsenha>'.$cddsenha.'</cddsenha>';
	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
    exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
	}
  
  echo $retorno;

?>