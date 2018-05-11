<? 
/*!
 * FONTE        : valida_pagamentos_geral.php
 * CRIAÇÃO      : Marceo L. Pereira (GATI)
 * DATA CRIAÇÃO : 25/10/2011
 * OBJETIVO     : Valida dados do pagamento
 *
 * ALTERACOES	: 25/02/2013 - Incluir parametro de numero do contrato (Gabriel).
 *                24/05/2013 - Incluir camada nas includes "../" (Lucas R.).  
 *			      22/04/2014 - Ajuste para verificar se o usuario possui permissao para fazer o pagamento. (James) 		
 *				  09/06/2014 - Ajuste no bloqueio da tela do pagamento da parcela. (James)
 *				  24/01/2018 - Adicionada solicitacao de senha de coordenador para utilizacao do saldo bloqueado no pagamento (Luis Fernando - GFT)
 */
?>
 
<?
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');	
	require_once('../../../../class/xmlfile.php');
	isPostMethod();		
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'P')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos');
	}
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$dtrefere = (isset($_POST['dtrefere'])) ? $_POST['dtrefere'] : '';
	$vlapagar = (isset($_POST['vlapagar'])) ? $_POST['vlapagar'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';

	// Monta o xml de requisição
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
?>
