
<?

session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();
//array com administradoras da cecred.
$funcaoAposErro = 'bloqueiaFundo(divRotina);';
$cecredADM      = Array(3, 11, 12, 13, 14, 15, 16, 17);
$cdcooper       = $glbvars["cdcooper"];
$nrdconta       = $_POST["nrdconta"];
$nrcrcard       = $_POST['nrcrcard'];
$cdAdmCartao    = $_POST['cdadmcrd'];
$cdadmcrd       = $_POST['cdadmcrd'];
$nrctrcrd       = $_POST['nrctrcrd'];
$cartaoCECRED   = in_array($cdAdmCartao, $cecredADM);
$nrPropostaEst  = $_POST['nrPropostaEst'];
$opcao          = null;
if(isset($_POST['opcao'])){
  $opcao        = $_POST['opcao']; /* G - GLOBAL OU D - DIFERENCIADO */
}
$limiteatual   = 0;
$limitetitular = 0;


try {
    if (!(validaInteiro($cdAdmCartao)))
        throw new Exception(utf8ToHtml("Cartão inválido"));
    if (!(validaInteiro($nrdconta)))
        throw new Exception(utf8ToHtml("Conta inválida"));
} catch (Exception $e) {
    exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);
    return;
}

// Só iremos validar as pendencias se for uma nova proposta
if(empty($nrPropostaEst)) {
    if (verificaPendencia($nrctrcrd, $nrdconta,$glbvars)){ exibirErro('error', utf8ToHtml("Proposta de alteração de limite pendente na esteira"),'Alerta - Aimaro',$funcaoAposErro); return;};
}
if (contaDoOperador($nrdconta, $glbvars)) exibirErro('error', utf8ToHtml("Não é possível solicitar alteração de limite para cartão de crédito da conta do Operador."),'Alerta - Aimaro',$funcaoAposErro);
if(is_null($opcao)){
  $titular = is_titular_card($nrctrcrd, $nrdconta,$glbvars,$limiteatual,$limitetitular);
} else if ($opcao == 'G'){
  $titular = true;
  is_titular_card($nrctrcrd, $nrdconta,$glbvars,$limiteatual,$limitetitular);
} else {
  $titular = false;
  is_titular_card($nrctrcrd, $nrdconta,$glbvars,$limiteatual,$limitetitular);
}
if ($titular){
  $dTituloTela = 'Alterar limite de crédito cartão titular';
} else {
  $dTituloTela = 'Alterar limite de crédito cartão adicional';
}


//if (!is_titular_card($nrctrcrd, $nrdconta,$glbvars)) exibirErro('error', utf8ToHtml("Não é possível solicitar alteração de limite para cartão de crédito adicional."),'Alerta - Aimaro',$funcaoAposErro);

?>
<script>
istitular = <? echo $titular? "true": "false"; ?>;

cdadmcrd = <? echo $cdadmcrd; ?>;
console.log("istitular "+istitular);
</script>
<?

function contaDoOperador($nrdconta, $glbvars){

    $cdoperad = $glbvars['cdoperad'];
    $nrcrcard = $_POST['nrcrcard'];

    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>$nrdconta</nrdconta>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $admresult = mensageria($xml, "ATENDA_CRD", "VALIDAR_OPERADOR_ALTERACAO_LIMITE", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $admxmlObj = getObjectXML($admresult);
    $xml_adm =  simplexml_load_string($admresult);
    
    $existeConta = $xml_adm->Dados->contas->conta->existeconta;
    $titular = $xml_adm->Dados->contas->conta->titular;

    if(($existeConta == "N") && ($titular == "N"))
        return false;
    else
        return true;
}


function is_titular_card($nrctrcrd, $nrdconta,$glbvars, &$limiteatual,&$limitetitular)
{
	
	
	
    /*$xmlGetDadosCartao  = "";
	$xmlGetDadosCartao .= "<Root>";
	$xmlGetDadosCartao .= "	<Cabecalho>";
	$xmlGetDadosCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlGetDadosCartao .= "		<Proc>consulta_dados_cartao</Proc>";
	$xmlGetDadosCartao .= "	</Cabecalho>";
	$xmlGetDadosCartao .= "	<Dados>";
	$xmlGetDadosCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlGetDadosCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDadosCartao .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosCartao .= "	</Dados>";
	$xmlGetDadosCartao .= "</Root>";
	$xmlResult = getDataXML($xmlGetDadosCartao);

	//Cria objeto para classe de tratamento de XML
	$xmlObjNovoCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjNovoCartao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
    $dados = $xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags;
    $dsgraupr = strlen( getByTagName($dados,"dsgraupr")); 
    if($dsgraupr > 0 && getByTagName($dados, "dsgraupr")!="Primeiro Titular")
        return false;
    else*/
    $logXML  = "<Root>";
	$logXML .= " <Dados>";
	$logXML .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$logXML .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$logXML .= " </Dados>";
	$logXML .= "</Root>";
	$admresult = mensageria($logXML, "ATENDA_CRD", "VALIDAR_EH_TITULAR", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$procXML = simplexml_load_string($admresult);
	
	$titular = $procXML->Dados->contas->conta->titular;
	$limiteatual   = 0;
	$limitetitular = 0;
	if (isset($procXML->Dados->contas->conta->limiteatual)){
		$limiteatual   = $procXML->Dados->contas->conta->limiteatual;
	}
	if (isset($procXML->Dados->contas->conta->limitetitular)){
		$limitetitular = $procXML->Dados->contas->conta->limitetitular;
	}
	echo "<!-- " . $limiteatual . "--> ";
	echo "<script> limiteatualCC = ".$limiteatual." ; </script>";
	echo "<!-- " . $limitetitular . "--> ";
	echo "<!-- ";  print_r($procXML); echo "--> "; 
	if($titular == 'S')
		return true;
	else
		return false;

}

function verificaPendencia($nrctrcrd, $nrdconta,$glbvars){
	$logXML  = "<Root>";
	$logXML .= " <Dados>";
	$logXML .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$logXML .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$logXML .= " </Dados>";
	$logXML .= "</Root>";
	$admresult = mensageria($logXML, "ATENDA_CRD", "VALIDA_ALT_PEND_ESTEIRA", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	
	$procXML = simplexml_load_string($admresult);
	
	
	if((isset($procXML->Dados->inf->proposta)) && (strlen($procXML->Dados->inf->proposta) > 0) )
		return true;
	else
		return false;
}

function strToNm($nrStr){
    return str_replace(",",".",str_replace(".","",$nrStr));
}

$vllimmax = number_format(0,2,",",".");
$vllimmin = number_format(0,2,",",".");
$vlsugmot = number_format(0,2,",",".");
$vlnovlim = number_format(0,2,",",".");


  // Vamos chamar o motor apenas se for titular.
  if ($titular) {

    // Montar o xml de Requisicao
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";	
    $xml .= " </Dados>";
    $xml .= "</Root>";
    $xmlResult = mensageria($xml, "ATENDA_CRD", "SUGESTAO_LIMITE_CRD_ALT", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$objXml = simplexml_load_string($xmlResult);
	echo "<!-- SUGESTAO_LIMITE_CRD_ALT \n   $xmlResult  \n -->";
		
	if(isset($objXml->Erro) && (strlen($objXml->Erro->Registro->dscritic) > 0)){
		$mssg = str_replace(" ]"," ]<br>", $objXml->Erro->Registro->dscritic);
		$mssg =  str_replace("\u00C3\u0192\u00C2\u00A1","a",$mssg);
			echo"<script>showError('error', '".utf8ToHtml($mssg)."', 'Alerta - Aimaro', 'voltaDiv(0, 1, 4);') </script>";
	}
	$xmlObj = getObjectXML($xmlResult);
	
	$mensagem = $objXml->Dados->sugestoes->sugestao->mensagem;
	
	//mensagem contingencia
	$contingenciaIbra = trim($objXml->Dados->sugestoes->sugestao->contingencia_ibra);

	$contingenciaMoto = trim($objXml->Dados->sugestoes->sugestao->contingencia_mot);



	$contigenciaAtiva = false;//(strlen(contingenciaIbra) > 0)||(strlen($contingenciaMoto) > 0);

	if(($contingenciaMoto!="") || ($contingenciaIbra!="")){
		$msgconti = "";
		if(strlen($contingenciaIbra) > 0){
			$msgconti .="$contingenciaIbra";
		}
		if(strlen($contingenciaMoto) > 0){
			$msgconti .= (strlen($msgconti) >0)? "<br> $contingenciaMoto":"$contingenciaMoto";
		}
		$contigenciaAtiva = true;
		echo"<script>showError('inform', '".utf8ToHtml($msgconti)."', 'Alerta - Aimaro', ''); globalesteira = true; </script>";
	}
	else
	{
		$mensagem =utf8ToHtml( str_replace("Ã§Ã£","ção",$mensagem));
	
		$arMessage = explode("###", $mensagem);
		$dsmensag1 = '<div style=\"text-align:left;\">'.$arMessage[0].'</div>';
		$dsmensag2 = '';
		if (count($arMessage) > 1) {
			$dsmensag2 = $arMessage[1];
			$dsmensag2 = str_replace('[APROVAR]',  '<img src=\"../../../imagens/geral/motor_APROVAR.png\"  height=\"20\" width=\"20\" style=\"vertical-align:middle;margin-bottom:2px;\">', $dsmensag2);
			$dsmensag2 = str_replace('[DERIVAR]',  '<img src=\"../../../imagens/geral/motor_DERIVAR.png\"  height=\"20\" width=\"20\" style=\"vertical-align:middle;margin-bottom:2px;\">', $dsmensag2);
			$dsmensag2 = str_replace('[INFORMAR]', '<img src=\"../../../imagens/geral/motor_INFORMAR.png\" height=\"20\" width=\"20\" style=\"vertical-align:middle;margin-bottom:2px;\">', $dsmensag2);
			$dsmensag2 = str_replace('[REPROVAR]', '<img src=\"../../../imagens/geral/motor_REPROVAR.png\" height=\"20\" width=\"20\" style=\"vertical-align:middle;margin-bottom:2px;\">', $dsmensag2);
			$dsmensag2 = '<div style=\"text-align:left; height:100px; overflow-x:hidden; padding-right:25px; font-size:11px; font-weight:normal;\">'.$dsmensag2.'</div>';
		}		
		
		if(strlen($mensagem) > 0 && !$contigenciaAtiva){
			echo '<script> showError("inform","'.$dsmensag1.$dsmensag2.'","Alerta - Aimaro","bloqueiaFundo(divRotina);");</script>';
		}
	}
	
	//fim contingencia
	
    //$json_sugestoes = json_decode($xmlObj->roottag->tags[0]->tags[1]->tags[0]->tags[0]->cdata,true);
	$json_sugestoes = json_decode($xmlObj->roottag->tags[0]->tags[2]->tags[0]->tags[0]->cdata,true);
	
	
	$protocolo = ($json_sugestoes["protocolo"]);
    
	$idacionamento = $xmlObj->roottag->tags[0]->tags[1]->tags[0]->tags[1]->cdata;
    $cartoes = $json_sugestoes["categoriasCartaoCecred"];

    $sugestoes = $json_sugestoes["indicadoresGeradosRegra"]["sugestaoCartaoCecred"];	
	echo '<!-- SUGESTAO '; print_r($sugestoes); echo '-->';
    $qtdSugestoes =  count($sugestoes);
    $sugestoesMotor = array();
    for($j = 0; $j < $qtdSugestoes; $j++){
        $sugestao = $sugestoes[$j];
        $sugestoesMotor[ $sugestao['codigoCategoria']] = $sugestao['vlLimite'];
    }

    if(count($cartoes) == 0){
	//echo "Sem opçoes para a conta.";
	}
	$cartao = null;
    foreach($cartoes as $key=>$opt){
        if(strval($opt['codigo']) == strval($cdadmcrd)){
            $cartao = $opt;
            break;
        }else{
			echo "<!--key:$key   opt:$opt -->";
		}

    }	


    $xml  = "";
    $xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <cdadmcrd>".$cdadmcrd."</cdadmcrd>";
	$xml .= "   <tplimcrd>1</tplimcrd>"; // Alteração
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResultLimite = mensageria($xml, "ATENDA_CRD", "BUSCA_CONFIG_LIM_CRD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjectLimite = getObjectXML($xmlResultLimite);
	$xmlDadosLimite = $xmlObjectLimite->roottag->tags[0];

	if (strtoupper($xmlDadosLimite->tags[0]->name) == 'ERRO') {
	    $msgErro = $xmlDadosLimite->tags[0]->tags[0]->tags[4]->cdata;
	    if ($msgErro == "") {
	        $msgErro = $xmlDadosLimite->tags[0]->cdata;
	    }

	    exibirErro('error',$msgErro,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);

	}else{
	    $vllimmin = getByTagName($xmlDadosLimite->tags, "VR_VLLIMITE_MINIMO");
		$vllimmax =  getByTagName($xmlDadosLimite->tags, "VR_VLLIMITE_MAXIMO");
	}
	if(!is_null($cartao)){
		$dados = $xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags;
		$dslimite = getByTagName($dados,"DSLIMITE");
		$eDslimite = explode("#",$dslimite);
		echo "<script>vlLimiteMaximo =".$cartao['vlLimiteMaximo']." ; </script>";
		echo "<!-- teste japones -->";
        if(isset($sugestoesMotor[$cartao['codigo']])){
            $vlsugmot = number_format($sugestoesMotor[$cartao['codigo']],2,",",".");
            $vlnovlim = number_format($sugestoesMotor[$cartao['codigo']],2,",",".");
        }

	 
	}else{
		echo "<!-- Cartao NUlo -->";
		echo "<script>vlLimiteMaximo = 0 ; </script>";
	}
  }
?>

<style>
    [title] {
        background-color: rgb(255, 246, 143);
    }

    #tooltip * {
        font-size: 10px;
        font-weight: normal;
        font-family: Tahoma;
    }
</style>

<script>
<? if(isset($protocolo)){
		echo "protocolo = '$protocolo';";
	}?>
    $('#nmtitcrd').tooltip();
    $('#nmextttl').tooltip();
    $("#vlsugmot").setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
    $("#vlnovlim").setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
	$("#vllimdif").setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");  
     if(inpessoa !=2)
        $(".rowLimit").hide();
</script>

<form action="" name="frmNovoCartao" id="frmNovoCartao" method="post" onSubmit="return false;">
    <div id="divDadosNovoCartao">
        <fieldset id="fldsetnew" style="text-align: center;">
            <p style="padding-top:10px">
                <h3><? echo utf8ToHtml($dTituloTela); ?></h3>
            </p>
            <p>
                <br>
<?php if($titular) { 
      /* Alteração de titular */ ?>
            <table>
                <tr>
                    <td>
                        <label for="nrcartao" class="rotulo txtNormalBold"><? echo utf8ToHtml("Nrº cartão:") ?></label>
                    </td>
                    
                    <td>
                        <input type="text" value='' id="nrcartao" name="nrcartao"
                               class="campoTelaSemBorda" disabled>
                    </td>
				</tr>
				<tr>                    
                    <td>
                        <label for="vllimtit" class="rotulo txtNormalBold"><? echo utf8ToHtml("Limite atual") ?>:</label>
                    </td>
                    <td>
                        <input type="text" value='<? echo number_format(str_replace(",",".",$limiteatual),2,",","."); ?>' id="vllimtit" name="vllimtit"
						
                               class="campoTelaSemBorda" disabled>
                    </td>
                </tr>
				<tr>
                    <script>
                        $("#nrcartao").val(formatNrcartao('<? echo $nrcrcard; ?>'));
                    </script>
                    <td>
                        <label for="vllimmin" class="rotulo txtNormalBold"><? echo utf8ToHtml("Valor Mínimo") ?>:</label>
                    </td>
                    <td>
                        <input type="text" value='<? echo number_format(str_replace(",",".",$vllimmin),2,",","."); ?>' id="vllimmin" name="vllimmin"
                               class="campoTelaSemBorda" disabled>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="vlsugmot" class="rotulo txtNormalBold"><? echo utf8ToHtml("Valor Sugerido") ?>
                            :</label>
                    </td>
                    <td>
                        <input  type="text" id="vlsugmot" name="vlsugmot"value="<? echo $vlsugmot; ?>" class="campoTelaSemBorda" disabled>
                    </td>
				</tr>
				<tr>	                    
					<td>
                        <label for="vlnovlim" class="rotulo txtNormalBold"><? echo utf8ToHtml("Novo Limite") ?>
                            :</label>
                    </td>
                    <td>
                        <input onchange="verificaValor()" type="text" id="vlnovlim" name="vlnovlim" class="campo" value='<? echo $vlnovlim; number_format(str_replace(",",".",$vlnovlim),2,",","."); ?>'>
                    </td>
                </tr>
                <tr id='justificativaRow'>
                    <td>
                        <label for="justificativa" class="rotulo txtNormalBold"><? echo utf8ToHtml("Justificativa") ?>
                            :</label>
                    </td>
                    <td colspan=4>
                        <!-- <input type="text" id="justificativa" name="justificativa" class="campoTelaSemBorda"  style="width:100%"> -->
						<select id="justificativa" class="campoTelaSemBorda"  style="width:100%">
							<option value=""><? echo utf8ToHtml('Selecione uma opção');?> </option>
							<option value="<? echo utf8ToHtml('Atualizacao da renda.');?>"><? echo utf8ToHtml('Atualizacao da renda.');?> </option>
							<option value="<? echo utf8ToHtml('Compra de bens ou servicos.');?>"><? echo utf8ToHtml('Compra de bens ou servicos');?> </option>
							<option value="<? echo utf8ToHtml('Compra de viagens.');?>"><? echo utf8ToHtml('Compra de viagens');?> </option>
						</select>
                    </td>
                    
                    
                    <td>
                        
                    </td>
                </tr>
                <tr id="tplimiterow">
                    <td>
                        
                    <td>
                    <td>
                        <label  class="rotulo txtNormalBold"><? echo utf8ToHtml("Limite Global") ?>
                            <input type="radio" id="tplimite" name="tplimite" class="campoTelaSemBorda" value='G'></label>
                    </td>
                    <td>
                        <label fr="" class="rotulo txtNormalBold"><? echo utf8ToHtml("Limite Adicional") ?>
                        <input type="radio" id="tplimite" name="tplimite" class="campoTelaSemBorda" value='A'></label>
                    <td>
                    <td>

                    </td>
                </tr>
            </table>
<?php } else { 
      /* Alteração de adiconal */ ?>
	  <script>
	  vlLimiteMaximo = <? echo isset($limitetitular)? $limitetitular:"0"; ?>;
	  </script>

		<table>
                <tr>
                    <td>
                        <label for="nrcartao" class="rotulo txtNormalBold"><? echo utf8ToHtml("Nrº cartão:") ?></label>
                    <td>
                    <td>
                        <input type="text" value='' id="nrcartao" name="nrcartao" class="campoTelaSemBorda" disabled>
						<script>
                        $("#nrcartao").val(formatNrcartao('<? echo $nrcrcard; ?>'));
                        </script>
                    </td>
				</tr>
				<tr>                    
                    <td>
                        <label for="vllimtit" class="rotulo txtNormalBold"><? echo utf8ToHtml("Limite Titular") ?>:</label>
                    <td>
                    <td>
                        <input type="text" value='<? echo number_format(str_replace(",",".",$limitetitular),2,",","."); ?>' id="vllimmin" name="vllimmin"
						
                               class="campoTelaSemBorda" disabled>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="vllimatu" class="rotulo txtNormalBold"><? echo utf8ToHtml("Valor Atual Diferenciado") ?>
                            :</label>
                    <td>
                    <td>
						<input type="text" value='<? echo number_format(str_replace(",",".",$limiteatual),2,",","."); ?>' id="vllimatu" name="vllimatu"
                               class="campoTelaSemBorda" disabled>                        
                    </td>
				</tr>
				<tr>
                    <td>
                        <label for="vllimdif" class="rotulo txtNormalBold"><? echo utf8ToHtml("Valor Novo Limite Diferenciado") ?>
                            :</label>
                    <td>
                    <td>
					    <input onchange="verificaValorDif()" type="text" id="vllimdif" name="vllimdif" class="campoTelaSemBorda" >
                    </td>
                </tr>
				<!-- 
                <tr id='justificativaRow'>
                    <td>
                        <label for="justificativa" class="rotulo txtNormalBold"><? echo utf8ToHtml("Justificativa") ?>
                            :</label>
                    <td>
                    <td colspan=4>
                        <input type="text" id="justificativa" name="justificativa" class="campoTelaSemBorda"  style="width:100%">
                    </td>
                    
                    
                    <td>
                        
                    </td>
                </tr>
                <tr id="tplimiterow">
                    <td>
                        
                    <td>
                    <td>
                        <label  class="rotulo txtNormalBold"><? echo utf8ToHtml("Limite Global") ?>
                            <input type="radio" id="tplimite" name="tplimite" class="campoTelaSemBorda" value='G'></label>
                    </td>
                    <td>
                        <label fr="" class="rotulo txtNormalBold"><? echo utf8ToHtml("Limite Adicional") ?>
                        <input type="radio" id="tplimite" name="tplimite" class="campoTelaSemBorda" value='A'></label>
                    <td>
                    <td>

                    </td>
                </tr>
				-->
            </table>

<?php }  ?>
            </p>
        </fieldset>
        <div id="divBotoes">
            <input type="image" src="<?echo $UrlImagens; ?>botoes/voltar.gif"
                   onClick="voltaDiv(0, 1, 4);
                   return false;"/>
            <input type="image" id="btSalvar" src="<?echo $UrlImagens; ?>botoes/concluir.gif"
                   onClick="enviarSolicitacao();">
        </div>

    </div>
</form>

<script type="text/javascript">
    controlaLayout('frmNovoCartao');
	var obgjustificativa = false;

    $("#divOpcoesDaOpcao1").css("display", "block");
    $("#divConteudoCartoes").css("display", "none");
    $("#vlnovlim").keyup(function(evt) {
        verificaValor();
    })

    function verificaValor(){
            var vllimmax  = <? echo strToNm($vllimmax);?>;
			var vllimmin  = <? echo strToNm($vllimmin);?>;
			var vlsugmot = parseFloat($("#vlsugmot").val().replace(/\./g,'').replace(",","."));
			var vlnovlim = parseFloat($("#vlnovlim").val().replace(/\./g,'').replace(",","."));
            console.log("NovoLimite > vlsugmot = "+vlnovlim > vlsugmot);
            if(vlnovlim > vlsugmot ){ 
				$("#justificativaRow").show();
				obgjustificativa = true;
			}
            else{
				obgjustificativa = false;
				$("#justificativaRow").hide();
			}
    }
	
	function verificaValorDif(){
		var vllimtit = <? echo strToNm($limitetitular);?>;
		var vllimdif = parseFloat($("#vllimdif").val().replace(/\./g,'').replace(",","."));
		if(vllimdif > vllimtit){
			showError("error", "O Limite deve ser igual ou menor que o Limite do Titular.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            return false;
		}
		return true;
	}

    mostraDivDadosCartao();
    hideMsgAguardo();
    bloqueiaFundo(divRotina);
    $('#dsadmcrd', '#frmNovoCartao').focus();
/* Para manter escondido sempre. Agora vira por parametro  
	if(inpessoa !=2) */
        $("#tplimiterow").hide();
    $("#justificativaRow").hide();    
	
	var vllimmin;
	var vllimmax;
	var justificativa;
	var vlnovlim;
	

		function enviarSolicitacao(){
			if(istitular){
			
				vllimmax  = <? echo strToNm($vllimmax);?>;
				vllimmin  = <? echo strToNm($vllimmin);?>;
				vlsugmot = parseFloat($("#vlsugmot").val().replace(/\./g,'').replace(",","."));
				vlnovlim = parseFloat($("#vlnovlim").val().replace(/\./g,'').replace(",","."));

				if(obgjustificativa && $("#justificativa").val().length == 0){
					showError("error", "<? echo utf8ToHtml("Por favor,selecione uma justificativa."); ?>", "Alerta - Aimaro", "$('#nrcpfcgc','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
					return;
				}
				if(vlnovlim > vllimmax){
					showError("error", "<? echo utf8ToHtml("Não é possível solicitar um valor de limite acima do limite da categoria."); ?>", "Alerta - Aimaro", "$('#nrcpfcgc','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
					return;
				}
				
				var tipo = undefined;
				if(inpessoa == 2){
					tipo = '<? echo (is_null($opcao))? '' : $opcao; ?>';  /* $("#tplimite").val();	 */
				}
				if( istitular && (vlnovlim < vllimmin)){
					showError("error", "<? echo utf8ToHtml("Valor do limite solicitado abaixo do limite mínimo."); ?>", "Alerta - Aimaro", "$('#nrcpfcgc','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
					return;
				}else if(obgjustificativa  && vlnovlim > vlsugmot){
					if($("#justificativa").val().length == 0)
						showError("error", "<? echo utf8ToHtml("Por favor selecione uma justificativa."); ?>", "Alerta - Aimaro", "$('#vlnovlim','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
					else
						alterarBancoob(false,inpessoa,tipo,<?echo $nrctrcrd; ?> );
						//senhaCoordenador("alterarBancoob(false,"+inpessoa+",'"+tipo+"' )");
				}else{
					//alterarBancoob(false,inpessoa,tipo );
					alterarBancoob(true,inpessoa,tipo,<?echo $nrctrcrd; ?> );
				}
			} else {
				vlnovlim = parseFloat($("#vllimdif").val().replace(/\./g,'').replace(",","."));
				if(!verificaValorDif()){
					return;
				}
				var tipo = undefined;
				if(inpessoa == 2){
					tipo = '<? echo (is_null($opcao))? '' : $opcao; ?>';
				}
				alterarBancoob(true,inpessoa,tipo,<?echo $nrctrcrd; ?>);
			}
			
		}
	verificaValor();
	faprovador = undefined;
</script>