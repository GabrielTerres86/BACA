<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 14/05/2011
 * OBJETIVO     : Capturar dados para tela AUTORI
 * --------------
 * ALTERAÇÕES   : 05/08/2013 - Remover procedure verifica-tabela-exec  pois 
 * --------------			   nao sera mais utilizada (Lucas R.).
 *
 * 				  19/05/2014 - Ajustes referentes ao Projeto debito Automatico
 *							   Softdesk 148330 (Lucas R.)
 */ 
?>
		

<?	
	session_start();	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$dsdconta = (isset($_POST['dsdconta'])) ? $_POST['dsdconta'] : '' ;
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$cdhistor = (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : '' ;
	$cdrefere = (isset($_POST['cdrefere'])) ? $_POST['cdrefere'] : '' ;
	$nrseqdig = (isset($_POST['nrseqdig'])) ? $_POST['nrseqdig'] : '' ;
	$flgsicre = (isset($_POST['flgsicre'])) ? $_POST['flgsicre'] : '' ;
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = '';
	switch($operacao) {
		case ''  : $cddopcao = 'C';                                             											break;
		case 'C1': $cddopcao = 'C'; $procedure = 'valida-conta'; 	$mtdErro = '';											break;
		case 'C2': $cddopcao = 'C'; $procedure = 'busca-autori';   	$mtdErro = '$(\'#cdhistor\',\'#frmAutori\').focus();'; 	break;
		case 'I1': $cddopcao = 'I'; $procedure = 'valida-conta'; 	$mtdErro = '';											break;
		case 'E1': $cddopcao = 'E'; $procedure = 'valida-conta'; 	$mtdErro = '';											break;
		case 'E3': $cddopcao = 'E'; $procedure = 'busca-autori'; 	$mtdErro = 'controlaOperacao(\'\');';					break;
		case 'R1': $cddopcao = 'R'; $procedure = 'valida-conta'; 	$mtdErro = '';  										break;
		case 'R4': $cddopcao = 'R'; $procedure = 'busca-autori'; 	$mtdErro = 'controlaOperacao(\'\');'; 					break;
		case 'S1': $cddopcao = 'S'; $procedure = 'valida-conta'; 	$mtdErro = '';  										break;

	}
			
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Autori','',false);
	}
	
	// Se conta informada não for um número inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Autori','',false);
	
	if ($operacao != '' and $operacao != 'I6') {	
		
		// Monta o xml de requisição
		$xmlAutori  = "";
		$xmlAutori .= "<Root>";
		$xmlAutori .= "	<Cabecalho>";
		$xmlAutori .= "		<Bo>b1wgen0092.p</Bo>";
		$xmlAutori .= "		<Proc>".$procedure."</Proc>";
		$xmlAutori .= "	</Cabecalho>";
		$xmlAutori .= "	<Dados>";
		$xmlAutori .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlAutori .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlAutori .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlAutori .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlAutori .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlAutori .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xmlAutori .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xmlAutori .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlAutori .= "		<idseqttl>".$nrseqdig."</idseqttl>";
		$xmlAutori .= "		<cddopcao>".$cddopcao."</cddopcao>";
		$xmlAutori .= "		<cdhistor>".$cdhistor."</cdhistor>";
		$xmlAutori .= "		<cdrefere>".$cdrefere."</cdrefere>";
		$xmlAutori .= "     <flgsicre>".$flgsicre."</flgsicre>";
		$xmlAutori .= "	</Dados>";
		$xmlAutori .= "</Root>";
	
		// Executa script para envio do XML e cria objeto para classe de tratamento de XML
		$xmlResult 	= getDataXML($xmlAutori);
		$xmlObjeto 	= getObjectXML($xmlResult);		

		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
			$operacao = '';
			$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
			$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
			if (!empty($nmdcampo)) { $mtdErro = "$('#".$nmdcampo."','#frmAutori').focus();";    }
			exibirErro('error',$msgErro,'Alerta - Autori',$mtdErro,false);
		} 

		$registros 	= $xmlObjeto->roottag->tags[0]->tags;
	} 
	
	// pega o nome do associado
	if (in_array($operacao, array("C1","I1", "E1", "R1", "S1"))) {
		
		// pega os dados da conta
		$cdsitdtl 	= $xmlObjeto->roottag->tags[0]->attributes['CDSITDTL'];	
		$dsdconta 	= $xmlObjeto->roottag->tags[0]->attributes['NMPRIMTL'];

	} else if ($operacao == "") {
  		// inicializa
 		$dsdconta	= '';
	}
	 
	include('form_cabecalho.php');
	
	// exibi o formulario 
	if (in_array($operacao, array("C1","I1", "E1", "R1", "E3", "R4"))) {	    
		include('form_autori.php');	
	}

	// exibe a tabela na consulta
	else if (in_array($operacao, array("C2"))) {
		include('tab_autori.php');	
	}
	
	// exibi a tela de SMS
	else if (in_array($operacao, array("S1"))) {
		include('manter_rotina_sms.php');
		include('form_sms.php');
	}
	
?>

<script type='text/javascript'>
	
	// Alimenta as variáveis globais
	operacao = '<? echo $operacao; ?>';
	nrdconta = '<? echo $nrdconta; ?>';
	dsdconta = '<? echo $dsdconta; ?>';
	cdsitdtl = '<? echo $cdsitdtl; ?>'; 
	
	controlaLayout();
	controlaFoco();		
	
	if (operacao == 'R4') { 	
		$('#flgsicre','#frmAutori').desabilitaCampo(); 
		setTimeout("$('#dshistor','#frmAutori').desabilitaCampo().focus();",0);   
		setTimeout("$('#btSalvarR5','#divBotoes').focus();",0); 
	}
	if (operacao == 'I1') { controlaOperacao('I2'); }
	if (operacao == 'R1') { controlaOperacao('R2'); }
	if (operacao == 'E3') { showConfirmacao("Deseja cancelar este optante do servico de Debito Automatico?", "Confirmacao - Aimaro","controlaOperacao(\'E5\')","controlaOperacao(\'\');",'sim.gif','nao.gif');  }  //controlaOperacao('E5');
	
</script>
