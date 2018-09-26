<?php
/*!
 * FONTE        : valida_senha_internet.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : Novembro/2015
 * OBJETIVO     : Valida senha do beneficiário.
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
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
  $nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : "";
	$idseqttl = (isset($_POST["idseqttl"])) ? $_POST["idseqttl"] : "";
	$cddsenha = (isset($_POST["cddsenha"])) ? $_POST["cddsenha"] : "";
	$retorno  = (isset($_POST["retorno"])) ? $_POST["retorno"] : "";
	
	// Monta o xml de requisição
	$xmlLogdda  = '';
	$xmlLogdda .= '<Root>';
	$xmlLogdda .= '	 <Cabecalho>';
	$xmlLogdda .= '    <Bo>b1wgen0015.p</Bo>';
	$xmlLogdda .= '    <Proc>verifica-senha-internet</Proc>';
	$xmlLogdda .= '  </Cabecalho>';
	$xmlLogdda .= '  <Dados>';
	$xmlLogdda .= '    <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xmlLogdda .= '    <cdagecxa>'.$glbvars['cdagenci'].'</cdagecxa>';
	$xmlLogdda .= '    <nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xmlLogdda .= '    <cdopecxa>'.$glbvars['cdoperad'].'</cdopecxa>';
	$xmlLogdda .= '    <nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xmlLogdda .= '    <idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xmlLogdda .= '    <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xmlLogdda .= '    <nrdconta>'.$nrdconta.'</nrdconta>';
	$xmlLogdda .= '    <idseqttl>'.$idseqttl.'</idseqttl>';
	$xmlLogdda .= '    <cddsenha>'.$cddsenha.'</cddsenha>';
	$xmlLogdda .= '    <cdsnhrep>'.$cddsenha.'</cdsnhrep>';
	$xmlLogdda .= '  </Dados>';
	$xmlLogdda .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = getDataXML($xmlLogdda);
	$xmlObjeto = getObjectXML($xmlResult);		
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
    exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','',false);
	}
  echo $retorno;
  ?>