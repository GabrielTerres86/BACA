<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 11/01/2013
 * OBJETIVO     : Rotina para manter as operações da tela MANCCF
 * --------------
 * ALTERAÇÕES   :  Adicionado parametro de cddopcao para poder validar as permissoes SD 302218. (Kelvin)
 *                 24/11/2015 - a procedure buscaContrato estava sendo chamada sem passar cddopcao
 *                              (Tiago SD354305)
 *                
 *                 13/01/2016 - Ajustado pois dependendo da acao o CDDOPCAO nao vinha preenchido acusando
 *                              que o operador nao tinha permissao de acesso (Tiago/Elton SD 379410)
 * -------------- 
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Inicializa	
$procedure = '';
$retornoAposErro = '';

// Recebe a operação que está sendo realizada
$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrseqdig = (isset($_POST['nrseqdig'])) ? $_POST['nrseqdig'] : 0;
$nmoperad = (isset($_POST['nmoperad'])) ? $_POST['nmoperad'] : '';
$dtfimest = (isset($_POST['dtfimest'])) ? $_POST['dtfimest'] : '?';
$flgctitg = (isset($_POST['flgctitg'])) ? $_POST['flgctitg'] : 0;
$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : 0;
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$nrcheque = (isset($_POST['nrcheque'])) ? $_POST['nrcheque'] : 0;
$vlcheque = (isset($_POST['vlcheque'])) ? $_POST['vlcheque'] : 0;


switch ($operacao) {
    case 'titular' :
        $procedure = 'Grava_Titular';
        $retornoAposErro = 'bloqueiaFundo($(\'#divRotina\'));';
		$cddopcao = 'X';
        break;
    case 'regulariza':
        $procedure = 'Grava_Regulariza';
        $retornoAposErro = '';
		$cddopcao = 'R';
        break;
    case 'refazRegulariza':
        $procedure = 'Refaz_Regulariza';
        $retornoAposErro = '';
		$cddopcao = 'R';
        break;
	case 'incluiCCF':
        $procedure = 'Inclui_CCF';
        $retornoAposErro = 'bloqueiaFundo($(\'#divRotina\'));';
		$cddopcao = 'R';
        break;
}

	if ($operacao != 'incluiCCF'){
		if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
			exibirErro('error',$msgError,'Alerta - Aimaro','',false);
		}		
	}

	if ($operacao == 'incluiCCF'){
		
		// Monta o xml dinâmico de acordo com a operação 
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Cabecalho>";
		$xml .= "	    <Bo>b1wgen0143.p</Bo>";
		$xml .= "        <Proc>".$procedure."</Proc>";
		$xml .= "  </Cabecalho>";
		$xml .= "  <Dados>";
		$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
		$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';			
		$xml .= '       <nrcheque>'.$nrcheque.'</nrcheque>';
		$xml .= '       <vlcheque>'.$vlcheque.'</vlcheque>';
		$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
		$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
		$xml .= '       <nmoperad>'.$nmoperad.'</nmoperad>';		
		$xml .= '       <dtfimest>'.$dtfimest.'</dtfimest>';		
		$xml .= '       <flgctitg>'.$flgctitg.'</flgctitg>';
	
	}else{
		// Monta o xml dinâmico de acordo com a operação 
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "  <Cabecalho>";
		$xml .= "	    <Bo>b1wgen0143.p</Bo>";
		$xml .= "        <Proc>".$procedure."</Proc>";
		$xml .= "  </Cabecalho>";
		$xml .= "  <Dados>";
		$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
		$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
		$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
		$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
		$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
		$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';		
		$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';		
		$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';			
		$xml .= '       <nrseqdig>'.$nrseqdig.'</nrseqdig>';		
		$xml .= '       <nmoperad>'.$nmoperad.'</nmoperad>';		
		$xml .= '       <dtfimest>'.$dtfimest.'</dtfimest>';		
		$xml .= '       <flgctitg>'.$flgctitg.'</flgctitg>';		
		$xml .= '       <idseqttl>'.$idseqttl.'</idseqttl>';	
	}
	
	$xml .= "  </Dados>";
	$xml .= "</Root>";	

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;		
		exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro,false);
	}
	
	// Busca os dados do contrato e os avalista
	if ( $operacao == 'titular' ) {		

		echo "fechaRotina( $('#divRotina') );buscaContrato('X');";
		
	// Valida os dados do avalista, antes de salvar	
	} else if ( $operacao == 'regulariza' || $operacao == 'refazRegulariza') {
	
		$msgconfi	= $xmlObjeto->roottag->tags[0]->attributes['MSGCONFI'];
		$nmoperad	= $xmlObjeto->roottag->tags[0]->attributes['NMOPERAD'];
		$dtfimest	= $xmlObjeto->roottag->tags[0]->attributes['DTFIMEST'];
		$flgctitg	= $xmlObjeto->roottag->tags[0]->attributes['FLGCTITG'];
		
		echo "hideMsgAguardo();";		
		echo "$('.linhaReg input[name=aplicacao]:checked').parent().parent().find('.dtfimest').html('".$dtfimest."');";
		echo "$('.linhaReg input[name=aplicacao]:checked').parent().parent().find('.nmoperad').html('".$nmoperad."');";
		echo "$('.linhaReg input[name=aplicacao]:checked').parent().parent().find('.flgctitg').html('".$flgctitg."');";
		
		/*echo "hideMsgAguardo();";
		echo "$( '.dtfimest', linha ).html('".$dtfimest."');";
		echo "$( '.nmoperad', linha ).html('".$nmoperad."');";
		echo "$( '.flgctitg', linha ).html('".$flgctitg."');";*/
		
		if( $msgconfi != "" ){
		
			exibirErro('inform',$msgconfi,'Alerta - Aimaro','',false);
			
		}
	
	}else if ($operacao = 'incluiCCF'){
		$msgconfi	= $xmlObjeto->roottag->tags[0]->attributes['MSGCONFI'];
		if( $msgconfi != "" ){
			echo "buscaContrato('CCF');";
			echo "fechaRotina($('#divRotina'));";
			exibirErro('inform', $msgconfi, 'Alerta - Aimaro', '', false);
		}
	}
?>