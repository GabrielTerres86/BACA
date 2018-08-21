<? 
/*!
 * FONTE        : valida_pagamentos_geral.php
 * CRIA��O      : Marceo L. Pereira (GATI)
 * DATA CRIA��O : 25/10/2011
 * OBJETIVO     : Valida dados do pagamento
 *
 * ALTERACOES	: 25/02/2013 - Incluir parametro de numero do contrato (Gabriel).
 *                24/05/2013 - Incluir camada nas includes "../" (Lucas R.).  
 *			      22/04/2014 - Ajuste para verificar se o usuario possui permissao para fazer o pagamento. (James) 		
 *				  09/06/2014 - Ajuste no bloqueio da tela do pagamento da parcela. (James)
 *				  24/01/2018 - Adicionada solicitacao de senha de coordenador para utilizacao do saldo bloqueado no pagamento (Luis Fernando - GFT)
 *				  21/08/2018 - Exibir mensagem de conta em prejuizo
 *   			               PJ 450 - Diego Simas - AMcom	
 */
?>
 
<?
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');	
	require_once('../../../../class/xmlfile.php');
	isPostMethod();		
	
	// Verifica permiss�es de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'P')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos');
	}
	
	// Guardo os par�metos do POST em vari�veis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$dtrefere = (isset($_POST['dtrefere'])) ? $_POST['dtrefere'] : '';
	$vlapagar = (isset($_POST['vlapagar'])) ? $_POST['vlapagar'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';

	// Mensageria referente a situa��o de preju�zo	
	// Diego Simas (AMcom) 
	// In�cio  
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_ATENDA_DEPOSVIS", "CONSULTA_PREJU_CC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
	$xmlObjeto = getObjectXML($xmlResult);	

	$param = $xmlObjeto->roottag->tags[0]->tags[0];

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"controlaOperacao('');",false); 
	}else{
		$inprejuz = getByTagName($param->tags,'inprejuz');	    
	}

	if($inprejuz == 1 && $vlapagar != 0){
		exibirErro('error',utf8_encode('Conta em preju�zo, pagamento deve ser efetuado atrav�s da op��o Bloqueado Preju�zo.'),'Alerta - Ayllos',$mtdErro,false);
	}else{
	// Fim
	// Diego Simas (AMcom) 

		// Monta o xml de requisi��o
		$xml .= "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0084b.p</Bo>";
		$xml .= "		<Proc>valida_pagamentos_geral</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
		$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
		$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
		$xml .= "		<dtrefere>".$glbvars["dtmvtolt"]."</dtrefere>";
		$xml .= "		<vlapagar>".$vlapagar."</vlapagar>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xml);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObj = getObjectXML($xmlResult);
			
		$mtdErro = 'bloqueiaFundo(divRotina);';
			
		if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$mtdErro,false);
		}else if( strtoupper($xmlObj->roottag->tags[0]->tags[0]->name) == 'REGISTRO' ) {
			$mensagem = $xmlObj->roottag->tags[0]->tags[0]->tags;
			$tipo = getByTagName($mensagem,'inconfir');
			if($tipo==1){
				echo 'showConfirmacao("'.getByTagName($mensagem,'dsmensag').'","Confirma&ccedil;&atilde;o - Ayllos","verificaAbreTelaPagamentoAvalista();","hideMsgAguardo();bloqueiaFundo(	divRotina);","sim.gif","nao.gif");';
			}
			elseif($tipo==2){
				echo 'showConfirmacao("'.getByTagName($mensagem,'dsmensag').'","Confirma&ccedil;&atilde;o - Ayllos","pedeSenhaCoordenador(2,\"verificaAbreTelaPagamentoAvalista()\",\"divRotina\")","hideMsgAguardo();bloqueiaFundo(	divRotina);","sim.gif","nao.gif");';
			}
			else{
				echo 'showConfirmacao("'.getByTagName($mensagem,'dsmensag').'","Confirma&ccedil;&atilde;o - Ayllos","pedeSenhaCoordenador(2,\"showConfirmacao(\'Saldo em conta insuficiente para pagamento da parcela. Confirma pagamento?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'verificaAbreTelaPagamentoAvalista()\',\'hideMsgAguardo();bloqueiaFundo(	divRotina);\',\'sim.gif\',\'nao.gif\')\",\"divRotina\")","hideMsgAguardo();bloqueiaFundo(	divRotina);","sim.gif","nao.gif");';
			}
		}else{	
			echo 'confirmaPagamento();'; 
		}

	}
?>
