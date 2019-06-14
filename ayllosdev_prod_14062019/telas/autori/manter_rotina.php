<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 14/05/2011 
 * OBJETIVO     : Rotina para manter as operações da tela AUTORI
 * --------------
 * ALTERAÇÕES   : 19/05/2014 - Ajustes referentes ao Projeto debito Automatico
 * --------------			   Softdesk 148330 (Lucas R.)
 *
 *				  29/07/2015 - Incluir validação para variavel $mtdErro limpar o dshistor caso 
 *							   historico for zerado (Lucas Ranghetti #311450).
 * 
 *                15/10/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *
 *				  18/04/2016 - Incluir validacoes referentes a melhoria 141 "Incluir senha do Cartao Magnetico 
 *							   para digitação do cooperado" (Lucas Ranghetti #436229)
 *							    
 *				  17/06/2016 - M181 - Alterar o CDAGENCI para passar o CDPACTRA (Rafael Maciel - RKAM)
 *
 *                30/11/2016 - P341-Automatização BACENJUD - Alterado para passar como parametro o código do 
 *                             departamento ao invés da descrição (Renato Darosci - Supero)
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
		
	// Recebe a operação que está sendo realizada
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ; 
	$nrseqdig = (isset($_POST['nrseqdig'])) ? $_POST['nrseqdig'] : 1  ; 
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;	
	$cdhistor = (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : '' ;
	$dshistor = (isset($_POST['dshistor'])) ? $_POST['dshistor'] : '' ;
	$cdrefere = (isset($_POST['cdrefere'])) ? $_POST['cdrefere'] : '' ;
	
	$dtlimite = (isset($_POST['dtlimite'])) ? $_POST['dtlimite'] : '' ;
	$cddddtel = (isset($_POST['cddddtel'])) ? $_POST['cddddtel'] : '' ;
	$dtautori = (isset($_POST['dtautori'])) ? $_POST['dtautori'] : '' ;
	$dtcancel = (isset($_POST['dtcancel'])) ? $_POST['dtcancel'] : '' ;
	$dtultdeb = (isset($_POST['dtultdeb'])) ? $_POST['dtultdeb'] : '' ;
	$dtvencto = 0;
	$nmfatura = (isset($_POST['nmfatura'])) ? $_POST['nmfatura'] : '' ;
	$nmempres = (isset($_POST['nmempres'])) ? $_POST['nmempres'] : '' ;
	$cdsitdtl = (isset($_POST['cdsitdtl'])) ? $_POST['cdsitdtl'] : '' ;
	$flgsicre = (isset($_POST['flgsicre'])) ? $_POST['flgsicre'] : '' ;
	$flgmanua = (isset($_POST['flgmanua'])) ? $_POST['flgmanua'] : '' ;
	
	$codbarra = (isset($_POST['codbarra'])) ? $_POST['codbarra'] : '' ;
	$fatura01 = (isset($_POST['fatura01'])) ? $_POST['fatura01'] : '' ;
	$fatura02 = (isset($_POST['fatura02'])) ? $_POST['fatura02'] : '' ;
	$fatura03 = (isset($_POST['fatura03'])) ? $_POST['fatura03'] : '' ;
	$fatura04 = (isset($_POST['fatura04'])) ? $_POST['fatura04'] : '' ;
	$executandoProdutos = (isset($_POST['executandoProdutos'])) ? $_POST['executandoProdutos'] : '' ;
	$flginassele = (isset($_POST['flginassele'])) ? $_POST['flginassele'] : 0 ;
	
	$jaexecutou = 0;
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure 	= '';
	$mtdErro	= '';
	$retorno 	= '';
	switch($operacao) {
		case 'I2': $cddopcao = 'I'; $procedure = 'valida-prej-tit'; 	 $mtdErro = 'controlaOperacao(\'\');';  $retorno = ""; 							break;
		//case 'I4': $cddopcao = 'I'; $procedure = 'valida-dados'; 		 $mtdErro = 'unblockBackground();';  	$retorno = "controlaOperacao('I5');";	break;
		case 'I4': $cddopcao = 'I'; $procedure = 'valida-dados'; 		 $mtdErro = 'unblockBackground();';  	$retorno = "mostraSenha();";	break;
		case 'I5': $cddopcao = 'I'; $procedure = 'grava-dados'; 		 $mtdErro = 'unblockBackground();';  	$retorno = ($executandoProdutos == 'true') ? "voltarAtenda();" : "controlaOperacao('I1');"; 	break;
		//case 'E5': $cddopcao = 'E'; $procedure = 'valida-dados'; 		 $mtdErro = 'controlaOperacao(\'\');';  $retorno = "controlaOperacao('E6');"; 	break;
		case 'E5': $cddopcao = 'E'; $procedure = 'valida-dados'; 		 $mtdErro = 'controlaOperacao(\'\');';  $retorno = "mostraSenha();"; 	break;
		case 'E6': $cddopcao = 'E'; $procedure = 'grava-dados'; 		 $mtdErro = 'controlaOperacao(\'\');';  $retorno = "controlaOperacao('');"; 	break;
		case 'R2': $cddopcao = 'R'; $procedure = 'valida-oper'; 		 $mtdErro = 'controlaOperacao(\'\');';  $retorno = ""; 							break;
		//case 'R5': $cddopcao = 'R'; $procedure = 'valida-dados'; 		 $mtdErro = 'unblockBackground();';  	$retorno = "controlaOperacao('R6');"; 	break;
		case 'R5': $cddopcao = 'R'; $procedure = 'valida-dados'; 		 $mtdErro = 'unblockBackground();';  	$retorno = "mostraSenha();"; 	break;
		case 'R6': $cddopcao = 'R'; $procedure = 'grava-dados'; 		 $mtdErro = 'unblockBackground();';		$retorno = "controlaOperacao('');"; 	break;
		case 'GC': $cddopcao = 'I'; $procedure = 'Gera_Conta_Consorcio'; $mtdErro = 'unblockBackground();';		$retorno = "";   break;
		default:   $mtdErro   = 'controlaOperacao(\'\');'; return false;
	}

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Autori','',false);
	}
	
	$bo = ($operacao == 'GC') ? 'b1wgen0074.p' : 'b1wgen0092.p';
		
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>" . $bo . "</Bo>";
	$xml .= "		<Proc>".$procedure."</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<cddepart>".$glbvars["cddepart"]."</cddepart>";
    $xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$nrseqdig."</idseqttl>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "		<cdhistor>".$cdhistor."</cdhistor>";
	$xml .= "		<cdrefere>".$cdrefere."</cdrefere>";
	$xml .= "		<dtlimite>".$dtlimite."</dtlimite>";
	$xml .= "		<cddddtel>".$cddddtel."</cddddtel>";
	$xml .= "		<dtiniatr>".$dtautori."</dtiniatr>";
	$xml .= "		<dtfimatr>".$dtcancel."</dtfimatr>";
	$xml .= "		<dtultdeb>".$dtultdeb."</dtultdeb>";
	$xml .= "		<dtvencto>0</dtvencto>";
	$xml .= "		<nmfatura>".$nmfatura."</nmfatura>";
	$xml .= "		<cdsitdtl>".$cdsitdtl."</cdsitdtl>";
	$xml .= "		<flgsicre>".$flgsicre."</flgsicre>";
	$xml .= "		<flgmanua>".$flgmanua."</flgmanua>";
	$xml .= "		<codbarra>".$codbarra."</codbarra>";
	$xml .= "		<fatura01>".$fatura01."</fatura01>";
	$xml .= "		<fatura02>".$fatura02."</fatura02>";
	$xml .= "		<fatura03>".$fatura03."</fatura03>";
	$xml .= "		<fatura04>".$fatura04."</fatura04>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if ( !empty($nmdcampo) ) { 
			if ( ($procedure == 'valida-dados') && ($cdhistor == 0) && ($cddopcao == 'I') ){
				$mtdErro = "$('#".$nmdcampo."','#frmAutori').focus();$('#dshistor','#frmAutori').val('');";  
			}else{
				$mtdErro = "$('#".$nmdcampo."','#frmAutori').focus();";  
			}
		}
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);		
	} 
	
	echo "hideMsgAguardo();";
	
	if(!$executandoProdutos){
		if ($flginassele != 0) {
			if ($operacao == 'I5'){
				echo "AtualizaInassele('".$flginassele."');"; 
				$jaexecutou == 1;
			}else if(($operacao == 'E6') || ($operacao == 'R6')){
				echo "AtualizaInassele('".$flginassele."');";
				$jaexecutou == 1;
			}
		}
	}
	
	if($jaexecutou == 0){
		echo $retorno;
	}

?>