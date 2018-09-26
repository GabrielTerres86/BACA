<?php
	/*!
	 * FONTE        : grava_responsaveis.php
	 * CRIAÇÃO      : Jean Michel
	 * DATA CRIAÇÃO : 27/11/2015
	 * OBJETIVO     : Salva dados referente aos poder("Assinar Operação Autoatendimento") de Responsaveis
	 *
	 * ALTERACOES   : 31/08/2016 - Alteracao da procedure para parametro de quantidade minima de ass. conjunta,
	 *							   SD.514239 (Jean Michel). 
	 *
	 */
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '0';
	$responsa = (isset($_POST['responsa'])) ? $_POST['responsa'] : '';
	$qtminast = (isset($_POST['qtminast'])) ? $_POST['qtminast'] : '0';
	$cddpoder = 10;
	$flgerror = false;
		
	// Leitura de dados para salvar poder de responsaveis
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0058.p</Bo>";
	$xml .= "		<Proc>grava_resp_ass_conjunta</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<idseqttl>0</idseqttl>';	
	$xml .= '		<responsa>'.$responsa.'</responsa>';
	$xml .= '		<qtminast>'.$qtminast.'</qtminast>';
	$xml .= "	</Dados>";
	$xml .= "</Root>";	
	 
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);	
			
	// Se ocorrer um erro, mostra crítica
	if(strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO'){
		$flgerror = true;
		$dscritic = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;					
	}
	
	// Verifica se houve algum erro nas atualizacoes
	if($flgerror){
		exibirErro('error',$dscritic,'Alerta - Aimaro','blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));',false);
	}else{
		//exibirErro('inform','Atualiza&ccedil;&atilde;o efetuada com sucesso.','Alerta - Aimaro','acessaOpcaoAba(7, 0, \"@\");',false);
		exibirErro('inform','Atualiza&ccedil;&atilde;o efetuada com sucesso.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
	}
?>