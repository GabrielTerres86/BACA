<?php
/* !
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [25/09/2018] Lombardi (CECRED): Tratamento para nao permitir solicitacao de novos Cartoes BB.
 * 001: [18/10/2018] Lombardi (CECRED): Comentado tratamento para nao permitir solicitacao de novos Cartoes BB.
 * 002: [16/01/2019] Lombardi (CECRED): Tratamento para nao permitir solicitacao de novos Cartoes BB.
 */
?>

<?

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	$nrdconta = $_POST['nrdconta'];
	$inpessoa = $_POST['inpessoa'];
	
	$funcaoAposErro = 'bloqueiaFundo(divRotina);';

	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>$nrdconta</nrdconta>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	function startsWith($haystack, $needle)
	{
		 $length = strlen($needle);
		 return (substr($haystack, 0, $length) === $needle);
	}

	
	
	$admresult = mensageria($xml, "ATENDA_CRD", "VALIDAR_EXISTE_SENHA_APROV_CRD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlSenhaResult = simplexml_load_string($admresult);
	$cdsitdct = $xmlSenhaResult->Dados->senhas->senha->cdsitdct;

	if(isset($xmlSenhaResult->Erro->Registro->erro))
	{
		exibirErro('error',utf8ToHtml("(".$xmlSenhaResult->Erro->Registro->cdcritic.")".$xmlSenhaResult->Erro->Registro->dscritic),'Alerta - Aimaro',"");
		return;
	}
	$possuiSenha = ($xmlSenhaResult->Dados->senhas->senha->status == "OK");
	if(!$possuiSenha)
	{
		exibirErro('error',utf8ToHtml("Conta sem senha cadastrada. Vincule a senha para o cartão magnético ou libere a senha da Internet."),'Alerta - Aimaro',"");
		return;
	}
	
	$adicionalXML .= "<Root>";
	$adicionalXML .= " <Dados>";
	$adicionalXML .= "   <nrdconta>$nrdconta</nrdconta>";
	$adicionalXML .= " </Dados>";
	$adicionalXML .= "</Root>";
	$resultAdicionalXML = mensageria($adicionalXML, "ATENDA_CRD", "VERIFICAR_CARTOES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	//echo "/* \n  $resultAdicionalXML  \n */ ";
	$xmlAdicionalResult = simplexml_load_string($resultAdicionalXML);
	$habilitaDebitoAdicional = $xmlAdicionalResult->Dados->cartoes->cartao->debito_tit;
	$opcoesAdicional = array();
	$paramsKeys = array("nrctrmul","vllimmul","ddebimul","tppagtomul","nrctress","vllimess","ddebiess","tppagtoess");
	$crdParams = "{";
	//print_r( get_object_vars($xmlAdicionalResult->Dados->cartoes->cartao) );
	$jaTemEssencial = false;
	$jaTemMultiplo = false;
	foreach(get_object_vars($xmlAdicionalResult->Dados->cartoes->cartao) as $key => $value){
		if(startsWith($key, "mult") && (strlen($value) > 0)){
			array_push($opcoesAdicional, $value);
		}else{
			if(in_array($key,$paramsKeys))
				$crdParams .= " \"$key\" : \"$value\",";
		}
		if($key == "idastcjt"){
			echo  "<script>idastcjt = $value;</script>";
		}
		if($key == 'flgdebit' && (strlen($value) > 0) ){
			echo  "<script> typeof flgdebitp !== 'undefined' && (flgdebitp = $value);</script>";
		}
		if(!$jaTemEssencial && $key == 'multesseti' && (strlen($value) > 0) ){
			echo"<!-- \n Já tem Essencial >$value<   \n -->";
			$jaTemEssencial = true;
		}
		if(!$jaTemMultiplo && $key == 'multmastti' && (strlen($value) > 0) ){
			echo"<!-- \n Já tem mult >$value<   \n -->";
			$jaTemMultiplo = true;
		}
		if($inpessoa == 2 && $key == "nmempdeb"){
			echo  "<script> nmempdeb = '$value';</script>";
		}

		
		if($inpessoa == 2 && $key == "nmempmul"){
			echo  "<script> nmempmul = '$value';</script>";
		}
			
		//echo"<!-- \n >$key< >$value<   \n -->";
	}
	$desabilitarNovo = ($jaTemMultiplo && $jaTemEssencial) || ($jaTemMultiplo && $inpessoa == 2);
	
	
	
	$crdParams = substr($crdParams, 0, -1)."}";
	//echo "/* \n   $crdParams  \n   */ ";
	
	$strOpcoes =  implode("#",$opcoesAdicional);

	
	$habilitaMultiploAdicional = count($opcoesAdicional) > 0;
	$habilitaDebitoAdicional = strlen($xmlAdicionalResult->Dados->cartoes->cartao->debito_tit) > 0;
	
	
	echo "<!-- \n Adicional \n $resultAdicionalXML \n -->";
	//if($xmlSenhaResult->Dados->senhas[0])
	//$xml_adm =  simplexml_load_string($admresult);
	$nm = $xml_adm->Dados->cartoes->cartao->operador;
	

	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);
	function contaDoOperador($nrdconta,$glbvars ){
			//nrcrcard
			$xml .= "<Root>";
			$xml .= " <Dados>";
			$xml .= "   <nrdconta>$nrdconta</nrdconta>";
			$xml .= " </Dados>";
			$xml .= "</Root>";
			
			$admresult = mensageria($xml, "ATENDA_CRD", "VALIDAR_OPERADOR_ALTERACAO_LIMITE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$admxmlObj = getObjectXML($admresult);
			$xml_adm =  simplexml_load_string($admresult);
			$nm = $xml_adm->Dados->cartoes->cartao->operador;
			$result = "";
			foreach($nm as $key => $value){
				if($value != 'N')
					return true;
				break;
			}
			return false;
	}
	
	if (contaDoOperador($nrdconta,$glbvars)) exibirErro('error', utf8ToHtml("Não é possível solicitar cartão de crédito para a própria conta do Operador."),'Alerta - Aimaro',$funcaoAposErro);

	$sNomeCartaoDebito   = 'Cartão CECRED Débito';
	$sNomeCartaoMultiplo = 'Cartão CECRED Múltiplo';
	$sNomeCartaoBB       = 'Cartão Banco do Brasil';
	/* Se for pesso juridica, mudar o nome dos botoes */
	if(isset($inpessoa)){
		if($inpessoa > 1){
			$sNomeCartaoDebito   = 'Cartão CECRED Empresas Débito';
			$sNomeCartaoMultiplo = 'Cartão CECRED Empresas';
		}
	}
	
?>
<script>
<?if($cdsitdct == 5){ ?>
	var cdsitdct = <?php echo $cdsitdct; ?>;
<?}else{
	echo 'var cdsitdct = 0;';
}?>
$(document).ready(function(){
	if(inpessoa != 1)
		$("#bbcard").hide();
	
	<?php // Tratamento para nao permitir solicitacao de novos Cartoes BB
	$dtmvtolt = substr($glbvars["dtmvtolt"], 6, 4).'-'.substr($glbvars["dtmvtolt"], 3, 2).'-'.substr ($glbvars["dtmvtolt"], 0, 2);
	
	if ($glbvars["cdcooper"] == 10 &&  // Credcomin 
		strtotime($dtmvtolt) >= strtotime('2019-01-17') && strtotime($dtmvtolt) <= strtotime('2019-01-25')) {		 
		echo '$("#bbcard").hide();';
	}
	?>
	
	/*
	<?php // Tratamento para nao permitir solicitacao de novos Cartoes BB
	$dtmvtolt = substr($glbvars["dtmvtolt"], 6, 4).'-'.substr($glbvars["dtmvtolt"], 3, 2).'-'.substr ($glbvars["dtmvtolt"], 0, 2);
	
	if ((($glbvars["cdcooper"] == 10 || // Credcomin 
		 $glbvars["cdcooper"] == 08 || // Credelesc 
		 $glbvars["cdcooper"] == 05 || // Acentra 
		 $glbvars["cdcooper"] == 06 || // Credifiesc 
		 $glbvars["cdcooper"] == 02 || // Acredicoop 
		 $glbvars["cdcooper"] == 11 || // Credifoz 
		 $glbvars["cdcooper"] == 16) && // Alto Vale
		 strtotime($dtmvtolt) >= strtotime('2018-11-08') && strtotime($dtmvtolt) <= strtotime('2018-11-19')) ||
		($glbvars["cdcooper"] == 01 && // Viacredi
		 strtotime($dtmvtolt) >= strtotime('2018-11-14') && strtotime($dtmvtolt) <= strtotime('2018-11-23')) ||
		($glbvars["cdcooper"] == 12 && // Crevisc
		 strtotime($dtmvtolt) >= strtotime('2018-10-04') && strtotime($dtmvtolt) <= strtotime('2018-10-15')) ||
		($glbvars["cdcooper"] == 09 && // Transpocred
		 strtotime($dtmvtolt) >= strtotime('2018-10-10') && strtotime($dtmvtolt) <= strtotime('2018-10-19')) ||
		($glbvars["cdcooper"] == 07 && // Credcrea
		 strtotime($dtmvtolt) >= strtotime('2018-10-18') && strtotime($dtmvtolt) <= strtotime('2018-10-26'))) {		 
		echo '$("#bbcard").hide();';
	} 
	?> */
});
function goBB(opt){
	var cc = opt == 0? "bb":"dbt";
	
	if(cc == "dbt" &&inpessoa == 2 ){
		nmEmpresPla = nmempdeb;
	}
	showMsgAguardo("Aguarde, carregando dados para novo cart&atilde;o ...");
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/atenda/cartao_credito/novo_progress.php",
		data: {
			nrdconta: nrdconta,
			inpessoa: inpessoa,
			redirect: "html_ajax",
			tipo:cc
		},		
        error: function (objAjax, responseError, objExcept) {

			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divOpcoesDaOpcao1").html(response);			
		}				
	});
}

function goCecred(){
	<?
	if($desabilitarNovo){
			$mensagemDes = utf8ToHtml('O titular desta conta já possui Cartões CECRED de todas bandeiras disponíveis.');
			if($inpessoa ==2)
				$mensagemDes = utf8ToHtml('Esta conta já possui cartão de crédito CECRED titular.');
		?>
			showError("error", "<? echo $mensagemDes;?>", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			return;
		<?
	}
	?>
	showMsgAguardo("Aguarde, carregando dados para novo cart&atilde;o ...");
	if(cdsitdct == 5){
		showError("error", "<?php echo utf8ToHtml('Situação da conta permite apenas cartões de débito.');?>", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		//
		hideMsgAguardo();
		return;
	}
	if(inpessoa == 2){
		nmEmpresPla = nmempmul;
	}
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/atenda/cartao_credito/novo_cecred.php",
		data: {
			nrdconta: nrdconta,
			inpessoa: inpessoa,
			redirect: "html_ajax"
		},		
        error: function (objAjax, responseError, objExcept) {

			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divOpcoesDaOpcao1").html(response);			
		}				
	});
}

function goAdicional(cdadmcrd){
	if(inpessoa == 2){
		nmEmpresPla = nmempmul;
	}
	showMsgAguardo("Aguarde, carregando dados para novo cart&atilde;o ...");
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/atenda/cartao_credito/novo_progress.php",
		data: {
			nrdconta  : nrdconta,
			inpessoa  : inpessoa,
			redirect  : "html_ajax",
			tipo      : "cecred",
			dadostit  :<? echo $crdParams;?>,
			cdadmcrd  : cdadmcrd
		},		
        error: function (objAjax, responseError, objExcept) {

			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divOpcoesDaOpcao1").html(response);			
		}				
	});
}

</script>
<style>
[title] {
    background-color: rgb(255, 246, 143);
}

#tooltip * {
    font-size: 10px;
    font-weight: normal;
    font-family: Tahoma;
}
.dividr{
	margin-left: 20px !important;
}
</style>

<script>
    $('#nmtitcrd').tooltip();
    $('#nmextttl').tooltip();
</script>

<form action="" name="frmNovoCartao" id="frmNovoCartao" method="post" onSubmit="return false;">
    <div id="divDadosNovoCartao">
        <fieldset style="text-align: center;">
		<p style="padding-top:10px">   <h3> Selecione a Administradora </h3></p>
			<p>
				<p style="display:table; margin:0 auto; padding-top:20px">
					<a 	style="display:table; margin:0 auto; vertical-align: middle;    cursor: default;height: 20px;padding-right:  10px;    padding-bottom: 5px;" 
						class="botao" 
						onClick="goCecred()">
						
						<span style="margin-right: 10px; margin-left: 10px;"><? echo utf8ToHtml($sNomeCartaoMultiplo."<br>Titular") ?></span>
					</a>
					<? if($habilitaMultiploAdicional){ ?>
					<a 	style="display:table; margin:0 auto; vertical-align: middle;    cursor: default;height: 20px;padding-right:  10px;    padding-bottom: 5px;" 
						class="botao dividr" 
						onClick="goAdicional('<? echo $strOpcoes; ?>')">
						<span style="margin-right: 10px; margin-left: 10px;"><? echo utf8ToHtml($sNomeCartaoMultiplo."<br>Adicional") ?></span>
					</a>
					<?} ?>
				</p>
				<p style="display:table; margin:0 auto; padding-top:20px">
					<a style="display:table; margin:0 auto; vertical-align: middle;    cursor: default;height: 20px;padding-right:  10px;    padding-bottom: 5px;" 
						class="botao " 
						onClick="goBB(1);"><span style="margin-right: 10px; margin-left: 10px;">
						<? echo utf8ToHtml($sNomeCartaoDebito."<br>&ensp; &ensp;Titular / Adicional") ?></span>
					</a>
					
				</p>
				<br>
				<p id="bbcard"  style="display:table; margin:0 auto; padding-top:10px; padding-bottom: 20px">
					<a  class="botao" style="    cursor: default;height: 20px;"onClick="goBB(0);"> <span style="margin-right: 10px; margin-left: 10px;">Cart&atilde;o Banco do Brasil</span></a>
				</p>
				
			</p>
        </fieldset>

        <div id="divBotoes">
            <input type="image" src="<?echo $UrlImagens; ?>botoes/voltar.gif"
                   onClick="voltaDiv(0, 1, 4);
                   return false;"/>
        </div>

    </div>

    <div id="divDadosAvalistas" class="condensado">

        <br style="clear:both"/>
    </fieldset>

        <div id="divBotoes">
            <input type="image" id="btVoltar" src="<?echo $UrlImagens; ?>botoes/voltar.gif"
                   onClick="mostraDivDadosCartao();
                   return false;">
            <input type="image" src="<?echo $UrlImagens; ?>botoes/cancelar.gif"
                   onClick="showConfirmacao('Deseja cancelar a proposta de novo cart&atilde;o de cr&eacute;dito?', 'Confirma&ccedil;&atilde;o - Aimaro', 'voltaDiv(0,1,4)', 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))', 'sim.gif', 'nao.gif');
                   return false;">
            <input type="image" id="btSalvar" src="<?echo $UrlImagens; ?>botoes/concluir.gif"
                   onClick="validarAvalistas(4);
                   return false;">
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
</script>