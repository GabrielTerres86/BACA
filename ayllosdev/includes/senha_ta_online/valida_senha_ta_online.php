<?php
/*!
 * FONTE        : valida_senha_ta_online.php
 * CRIAÇÃO      : Anderson-Alan (Supero)
 * DATA CRIAÇÃO : Novembro/2018
 * OBJETIVO     : Solicita senha do TA ou Conta Online do cooperado.
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
	$nrcrcard = (isset($_POST["nrcrcard"])) ? $_POST["nrcrcard"] : "";
	$retorno  = (isset($_POST["retorno"])) ? $_POST["retorno"] : "";
	$validainternet = (isset($_POST['validainternet'])) ? $_POST['validainternet'] : '';

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0028.p</Bo>';
	$xml .= '		<Proc>valida-senha-ta-online</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '   	<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '    	<cdagecxa>'.$glbvars['cdagenci'].'</cdagecxa>';
	$xml .= '       <nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	//$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<nrcrcard>'.$nrcrcard.'</nrcrcard>';
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