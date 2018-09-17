<?php 
/*!
 * FONTE         : efetuar_consultas.php
 * CRIAÇÃO       : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO  : 09/09/2014
 * OBJETIVO      : Efetuar consultas ao Ibratan. 
 *				   Projeto Automatização de Consultas em Propostas de Crédito.
 *
 * ALTERACOES    : 08/04/2015 - Permitir as consultas para o limite de credito (Jonata-RKAM) 
 *
 *				   30/06/2015 - Ajuste para atualizar o Risco do Emprestimo. (James)
 *
 *                 21/07/2015 - Exibir as mensagens corretamente (Gabriel-RKAM). 
 *
 *                 05/04/2016 - Incluir parametro na chamada da rotina mensageria
 *                              para verificar se deve verificar se proposta ja esta na esteira de credito.
 *                              PRJ207 - Esteira (Odirlei-AMcom). 
 *
 *                 30/10/2017 - Alterada rotina ao efetuar inclusão pela tela CADMAT. (PRJ339 - Reinert)
 */
	session_start();
	require_once('../config.php');
	require_once('../funcoes.php');		
	require_once('../controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	
    
	// Parametros enviados
	$nrdconta = $_POST['nrdconta'];
	$nrdocmto = $_POST['nrdocmto'];
	$inprodut = $_POST['inprodut'];
	$cddopcao = $_POST['cddopcao'];
	$inobriga = $_POST['inobriga'];
	$insolici = $_POST['insolici'];
    $flvalest = $_POST['flvalest']; //validar se ja esta na Esteira de Credito	
	$nmdatela = $_POST['nmdatela'];
	
	if ($insolici == 1) { // Solicitou as consultas
	
		$strnomacao = 'SSPC0001_SOLICITA_CONSULTA_BIRO';
			
		// Montar o xml para requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "    <cdoperad>".$glbvars['cdoperad']."</cdoperad>";
		$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "    <nrdocmto>".$nrdocmto."</nrdocmto>";
		$xml .= "    <inprodut>".$inprodut."</inprodut>";
        $xml .= "    <flvalest>".$flvalest."</flvalest>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
	 
		
		$xmlResult = mensageria($xml, "SSPC0001", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	
		$xmlObj    = simplexml_load_string($xmlResult);
				   
		// Se for da tela MATRIC (inprodut == 6), nao bloquear a tela e chamar tela CONTAS. 
		// Se for inclusão pela tela CADMAT chamar a tela CADCTA
		// Senao so bloquear TELA
		$metodo = ($inprodut == 6) ? ($nmdatela == 'CADMAT') ? "setaParametros('CADCTA','','$nrdconta','A'); direcionaTela('CADCTA','no');" : "setaParametros('CONTAS','','$nrdconta','M'); direcionaTela('CONTAS','no');" : "bloqueiaFundo(divRotina)";
		   
		// Se retornou erro		   
		if ($xmlObj->Erro->Registro->dscritic != '') {
		  $msgErro = utf8ToHtml($xmlObj->Erro->Registro->dscritic);
		  exibirErro('inform',$msgErro,'Alerta - Ayllos',$metodo, false);
		}
		else {
			exibirErro('inform','Consultas efetuadas com sucesso!','Alerta - Ayllos',$metodo, false);
		}
					
	}
	
	if ($inprodut == 1) { // Se for emprestimo, chamar a analise ctr
	
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0191.p</Bo>";
		$xml .= "		<Proc>efetua_analise_ctr</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<nrctrato>".$nrdocmto."</nrctrato>";	
		$xml .= "	</Dados>";
		$xml .= "</Root>";
	 	
		// Executa script para envio do XML
		$xmlResult = getDataXML($xml);
		
		// Cria objeto para classe de tratamento de XML
		$xml_analise = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xml_analise->roottag->tags[0]->name) == "ERRO") {
			exibirErro('inform',$xml_analise->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))", true);
			exit();
		}
		
		/* Atualiza o risco da proposta de emprestimo */
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0002.p</Bo>";
		$xml .= "		<Proc>atualiza_risco_proposta</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<nrctremp>".$nrdocmto."</nrctremp>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xml);
		
		// Cria objeto para classe de tratamento de XML
		$xml_analise = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xml_analise->roottag->tags[0]->name) == "ERRO") {
			exibirErro('inform',$xml_analise->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))", true);
			exit();
		}
	}
?>