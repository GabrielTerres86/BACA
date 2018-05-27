
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
$nrctrcrd       = $_POST['nrctrcrd'];


try {
    if (!(validaInteiro($cdAdmCartao)))
        throw new Exception(utf8ToHtml("Cartão inválido"));
    if (!(validaInteiro($nrdconta)))
        throw new Exception(utf8ToHtml("Conta inválida"));
} catch (Exception $e) {
    exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro);
    return;
}

if (contaDoOperador($nrdconta, $glbvars)) exibirErro('error', utf8ToHtml("Não é possível solicitar alteração de limite para cartão de crédito da conta do Operador."),'Alerta - Ayllos',$funcaoAposErro);

if (!is_titular_card($nrctrcrd, $nrdconta,$glbvars)) exibirErro('error', utf8ToHtml("Não é possível solicitar alteração de limite para cartão de crédito adicional."),'Alerta - Ayllos',$funcaoAposErro);


function contaDoOperador($nrdconta, $glbvars){

    $cdoperad = $glbvars['cdoperad'];
    $nrcrcard = $_POST['nrcrcard'];

    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>$nrdconta</nrdconta>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $admresult = mensageria($xml, "ATENDA_CRD", "VALIDAR_OPERADOR_ALTERACAO_LIMITE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $admxmlObj = getObjectXML($admresult);
    $xml_adm =  simplexml_load_string($admresult);
    
    $existeConta = $xml_adm->Dados->contas->conta->existeconta;
    $titular = $xml_adm->Dados->contas->conta->titular;

    if(($existeConta == "N") && ($titular == "N"))
        return false;
    else
        return true;
}


function is_titular_card($nrctrcrd, $nrdconta,$glbvars)
{
    $xmlGetDadosCartao  = "";
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
    else
        return true;

}


function strToNm($nrStr){
    return str_replace(",",".",str_replace(".","",$nrStr));
}
$vllimmax = "0,00";
$vllimmin = "0,00";

    // Montar o xml de Requisicao
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= " </Dados>";
    $xml .= "</Root>";
    $xmlResult = mensageria($xml, "ATENDA_CRD", "SUGESTAO_LIMITE_CRD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    $json_sugestoes = json_decode($xmlObj->roottag->tags[0]->tags[1]->tags[0]->tags[0]->cdata,true);
    $idacionamento = $xmlObj->roottag->tags[0]->tags[1]->tags[0]->tags[1]->cdata;
    $cartoes = $json_sugestoes["categoriasCartaoCecred"];

    $sugestoes = $json_sugestoes["indicadoresGeradosRegra"]["sugestaoCartaoCecred"];	
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
        }

    }
	if(!is_null($cartao)){
		$dados = $xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags;
		$dslimite = getByTagName($dados,"DSLIMITE");
		$eDslimite = explode("#",$dslimite);
		$vllimmin = $cartao['vlLimiteMinimo'];
		$vllimmax =  $cartao['vlLimiteMaximo'];
        if(isset($sugestoesMotor[$cartao['codigo']]))
            $vlsugmot = number_format($sugestoesMotor[$cartao['codigo']],2,",",".");
        else
            $vlsugmot = 0;		 
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
    $('#nmtitcrd').tooltip();
    $('#nmextttl').tooltip();
    $("#vlsugmot").setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
    if(inpessoa !=2)
        $(".rowLimit").hide();
</script>

<form action="" name="frmNovoCartao" id="frmNovoCartao" method="post" onSubmit="return false;">
    <div id="divDadosNovoCartao">
        <fieldset id="fldsetnew" style="text-align: center;">
            <p style="padding-top:10px">
                <h3><? echo utf8ToHtml("Alterar limite de crédito"); ?></h3>
            </p>
            <p>
                <br>
            <table>
                <tr>
                    <td>
                        <label for="nrcartao" class="rotulo txtNormalBold"><? echo utf8ToHtml("Nrº cartão:") ?>:</label>
                    <td>
                    <td>
                        <input type="text" value='<? echo $nrcrcard; ?>' id="nrcartao" name="nrcartao"
                               class="campoTelaSemBorda" disabled>
                    </td>
                    <td>
                        <label for="vllimmin" class="rotulo txtNormalBold"><? echo utf8ToHtml("Valor Mínimo") ?>:</label>
                    <td>
                    <td>
                        <input type="text" value='<? echo number_format(str_replace(",",".",$vllimmin),2,",","."); ?>' id="vllimmin" name="vllimmin"
                               class="campoTelaSemBorda" disabled>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="vlsugmot" class="rotulo txtNormalBold"><? echo utf8ToHtml("Valor Sugerido") ?>
                            :</label>
                    <td>
                    <td>
                        <input type="text" id="vlsugmot" name="vlsugmot" class="campoTelaSemBorda" value='<? echo number_format(str_replace(",",".",$vlsugmot),2,",","."); ?>'>
                    </td>
                    <td>
                        <label for="vllimmax" class="rotulo txtNormalBold"><? echo utf8ToHtml("Valor Máximo") ?>
                            :</label>
                    <td>
                    <td>
                        <input  type="text" id="vllimmax" name="vllimmax"value="<? echo $vlsugmot; ?>" class="campoTelaSemBorda" disabled>
                    </td>
                </tr>
                </tr>
                <tr id="tplimiterow">
                    <td>
                        
                    <td>
                    <td>
                        <label  class="rotulo txtNormalBold"><? echo utf8ToHtml("Limite Global") ?>
                            <input type="radio" id="tplimite" name="tplimite" class="campoTelaSemBorda" value='global'></label>
                    </td>
                    <td>
                        <label fr="" class="rotulo txtNormalBold"><? echo utf8ToHtml("Limite Individual") ?>
                        <input type="radio" id="tplimite" name="tplimite" class="campoTelaSemBorda" value='individual'></label>
                    <td>
                    <td>

                    </td>
                </tr>
            </table>
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


    $("#divOpcoesDaOpcao1").css("display", "block");
    $("#divConteudoCartoes").css("display", "none");

    mostraDivDadosCartao();
    hideMsgAguardo();
    bloqueiaFundo(divRotina);
    $('#dsadmcrd', '#frmNovoCartao').focus();
    if(inpessoa !=2)
        $("#tplimiterow").hide();

	<?php if(!is_null($cartao)){?>
		function enviarSolicitacao(){
			var vllimmax  = <? echo strToNm($vlsugmot);?>;
			var vllimmin  = <? echo strToNm($vllimmin);?>;
			var valorSugerido = parseFloat($("#vlsugmot").val().replace(/\./g,'').replace(",","."));
			if (valorSugerido > 49500)
			{
				showError("error", "<? echo utf8ToHtml("Valor de limite solicitado acima do limite máximo de R$49.500,00."); ?>", "Alerta - Ayllos", "$('#nrcpfcgc','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
				return;
			}
            
            if(valorSugerido == 0){
                showError("error", "Por favor informe um valor sugerido para o novo limite.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                return;
            }
			if(valorSugerido > vllimmax){
				
			}else if(valorSugerido < vllimmin){

			}else{
                 alterarBancoob(false);
			}
		}
	<?php } else{?>
		//$("#fldsetnew").html("<?echo utf8ToHtml('Não existem linhas de crédito disponíveis para esse cartão.');?>");
        //$("#fldsetnew").css({height:30, 'padding-top':15});
	<?}?>
</script>