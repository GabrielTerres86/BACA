
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
$limiteatual   = 0;
$limitetitular = 0;


try {
    if (!(validaInteiro($cdAdmCartao)))
        throw new Exception(utf8ToHtml("Cartão inválido"));
    if (!(validaInteiro($nrdconta)))
        throw new Exception(utf8ToHtml("Conta inválida"));
} catch (Exception $e) {
    exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);
    return false;
}

if (contaDoOperador($nrdconta, $glbvars)) {
    exibirErro('error', utf8ToHtml("Não é possível solicitar alteração de limite para cartão de crédito da conta do Operador."),'Alerta - Aimaro',$funcaoAposErro);
    return false;
}
/*
if(is_null($opcao)){
  $titular = is_titular_card($nrctrcrd, $nrdconta,$glbvars,$limiteatual,$limitetitular);
} */
/* Sempre vamos editar a proposta do titular, pois adicional nao vai para esteira */
$titular = true;
is_titular_card($nrctrcrd, $nrdconta,$glbvars,$limiteatual,$limitetitular);

if ($titular){
  $dTituloTela = 'Alterar limite de crédito cartão titular';
} else {
  $dTituloTela = 'Alterar limite de crédito cartão adicional';
}

?>
<script>
istitular = <? echo $titular? "true": "false"; ?>;

cdadmcrd = <? echo $cdadmcrd; ?>;
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

$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "   <cdadmcrd>".$cdadmcrd."</cdadmcrd>";
$xml .= "   <tplimcrd>1</tplimcrd>"; // Alteração
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "ATENDA_CRD", "BUSCA_CONFIG_LIM_CRD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);
$xmlDados = $xmlObject->roottag->tags[0];

if (strtoupper($xmlDados->tags[0]->name) == 'ERRO') {
    $msgErro = $xmlDados->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlDados->tags[0]->cdata;
    }

    exibirErro('error',$msgErro,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
    
}else{
    //$limiteCartao = getByTagName($xmlDados->tags, "VR_VLLIMITE_MAXIMO");
    $vllimmin = getByTagName($xmlDados->tags, "VR_VLLIMITE_MINIMO");
    $vllimmax = getByTagName($xmlDados->tags, "VR_VLLIMITE_MAXIMO");
}

function strToNm($nrStr){
    return str_replace(",",".",str_replace(".","",$nrStr));
}

$vlsugmot = number_format(0,2,",",".");
$vlnovlim = number_format(0,2,",",".");

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
    var vlLimiteMaximo = <?php echo isset($limitetitular)? $limitetitular:"0"; ?>;
    var vlLimiteCartao = <?php echo empty($limiteCartao) ? 0 : $limiteCartao; ?>;
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
                    <td colspan="4">
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
            console.log("vlsugmot > vllimmax = "+vlsugmot > vllimmax);
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

                if (vlnovlim < 0) {
                    showError("error", "<? echo utf8ToHtml("Por favor, informe um valor para o novo limite."); ?>", "Alerta - Aimaro", "$('#nrcpfcgc','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
					return;
                }
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
				if( istitular &&(vlnovlim < vllimmin)){
					showError("error", "<? echo utf8ToHtml("Valor do limite solicitado abaixo do limite mínimo."); ?>", "Alerta - Aimaro", "$('#nrcpfcgc','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
					return;
				}else if(obgjustificativa  && vlnovlim > vlsugmot){
					if($("#justificativa").val().length == 0)
						showError("error", "<? echo utf8ToHtml("Por favor selecione uma justificativa."); ?>", "Alerta - Aimaro", "$('#nrcpfcgc','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
					else
						atualizaLimite();
				}else{
					atualizaLimite();
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
				atualizaLimite();
			}
			
		}
	verificaValor();
	faprovador = undefined;
</script>