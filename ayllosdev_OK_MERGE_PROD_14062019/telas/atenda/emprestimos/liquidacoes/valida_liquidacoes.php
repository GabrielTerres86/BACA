<? 
/*!
 * FONTE        : valida_liquidacoes.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 06/04/2011 
 * OBJETIVO     : Valida registros da tela de liquidações de emprestimo
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 000: [21/09/2011] Ajuste do tratamento do retorno da valida-liquidacao-emprestimo - Marcelo L. Pereira (GATI)
   001: [10/07/2012] Validar sempre os contratos a serem liquidados (Gabriel).
   002: [25/02/2013] Enviar o numero do contrato para validacao (Gabriel).
   003: [21/02/2018] Incluído campo identificador do empréstimo a liquidar(Simas-AMcom).
   004: [07/02/2019] Incluindo parametro para controle de abertura e fechamento das mensagens em tela (Bruno Luiz Katzjarowski - Mout's)
 */
?>
 
<?
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');	
	require_once('../../../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : ''; 
	$dtmvtoep = (isset($_POST['dtmvtoep'])) ? $_POST['dtmvtoep'] : ''; 
	$qtlinsel = (isset($_POST['qtlinsel'])) ? $_POST['qtlinsel'] : '';
	$vlemprst = (isset($_POST['vlemprst'])) ? $_POST['vlemprst'] : '';
	$vlsdeved = (isset($_POST['vlsdeved'])) ? $_POST['vlsdeved'] : '';
	$tosdeved = (isset($_POST['tosdeved'])) ? $_POST['tosdeved'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
	$idenempr = (isset($_POST['idenempr'])) ? $_POST['idenempr'] : '';
			
	//bruno - prj 438 - bug 14400
	//controle de abertura/fechamento das mensagens de carregamento de alienacões
	$param1 = (isset($_POST['param1'])) ? $_POST['param1'] : '';
			
	$vlsdeved = str_replace(".","",$vlsdeved);
	$vlemprst = str_replace(".","",$vlemprst);
	$tosdeved = str_replace(".","",$tosdeved);
			  		
	// Monta o xml de requisição
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0002.p</Bo>";
	$xml .= "		<Proc>valida-liquidacao-emprestimos</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>"; 
	$xml .= "		<nrctremp>".$nrctremp."</nrctremp>"; 	
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";            
	$xml .= "		<dtmvtoep>".$dtmvtoep."</dtmvtoep>";            
	$xml .= "		<qtlinsel>".$qtlinsel."</qtlinsel>";            
	$xml .= "		<vlemprst>".$vlemprst."</vlemprst>";            
	$xml .= "		<vlsdeved>".$vlsdeved."</vlsdeved>";
	$xml .= "		<tosdeved>".$tosdeved."</tosdeved>";
	$xml .= "		<idenempr>".$idenempr."</idenempr>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
	
	$msgretor = trim($xmlObj->roottag->tags[0]->attributes['MSGRETOR']);
	$tpdretor = trim($xmlObj->roottag->tags[0]->attributes['TPDRETOR']);
	
	// exibirErro('error',$msgretor.' | '.$tpdretor,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	if( $tpdretor == 'D' ){
		
		$metodo = 'bloqueiaFundo($(\'#divUsoGenerico\'));';
		
		exibirErro('inform',$msgretor,'Alerta - Aimaro',$metodo,false);
		
	}else if( $tpdretor == 'M' ){
		
		$metodoSim = 'selecionaLiquidacao();bloqueiaFundo($(\'#divUsoGenerico\'));';		
		$metodoNao = 'bloqueiaFundo($(\'#divUsoGenerico\'));';
			
		exibirConfirmacao($msgretor,'Confirmação - Aimaro',$metodoSim,$metodoNao,false);	
	}
	else if ($tpdretor == 'MC') {
		
		$metodoSim = "atualizaArray('$operacao')";		
		$metodoNao = 'bloqueiaFundo(divRotina);';
			
		exibirConfirmacao($msgretor,'Confirmação - Aimaro',$metodoSim,$metodoNao,false);		
	}
	else if ($tpdretor == 'C') {
				
		echo ('atualizaArray("'.$operacao.'","", "'.$param1.'")'); //bruno - prj 438 - bug 14400
	
	}
	else if( $tpdretor == '' ){ 
			
		echo ('selecionaLiquidacao();');
		
	}	
					

			

		
?>