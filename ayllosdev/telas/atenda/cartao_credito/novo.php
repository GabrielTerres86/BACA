<?

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	$nrdconta = $_POST['nrdconta'];
	$funcaoAposErro = 'bloqueiaFundo(divRotina);';
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro);
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
	
	if (contaDoOperador($nrdconta,$glbvars)) exibirErro('error', utf8ToHtml("Não é possível solicitar cartão de crédito para a própria conta do Operador."),'Alerta - Ayllos',$funcaoAposErro);

?>
<script>

$(document).ready(function(){
	if(inpessoa != 1)
		$("#bbcard").hide();
});
function goBB(opt){
	var cc = opt == 0? "bb":"dbt";
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
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divOpcoesDaOpcao1").html(response);			
		}				
	});
}

function goCecred(){
	
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
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
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
</style>

<script>
    $('#nmtitcrd').tooltip();
    $('#nmextttl').tooltip();
</script>

<form action="" name="frmNovoCartao" id="frmNovoCartao" method="post" onSubmit="return false;">
    <div id="divDadosNovoCartao">
        <fieldset style="text-align: center;">
		<p style="padding-top:10px">   <h3> Selecione a admistradora </h3></p>
			<p>
				<p style="display:table; margin:0 auto; padding-top:20px">
					<a style="display:table; margin:0 auto; vertical-align: middle;    cursor: default;height: 20px;" class="botao" onClick="goBB(1);"><span style="margin-right: 10px; margin-left: 10px;"><? echo utf8ToHtml('Cartão de Débito') ?></span></a>
				</p>
				<p style="display:table; margin:0 auto; padding-top:20px">
					<a style="display:table; margin:0 auto; vertical-align: middle;    cursor: default;height: 20px;" class="botao" onClick="goCecred()"><span style="margin-right: 10px; margin-left: 10px;"><? echo utf8ToHtml('CECRED Cartões') ?></span></a>
				</p>
				<br>
				<p id="bbcard"  style="display:table; margin:0 auto; padding-top:10px; padding-bottom: 20px">
					<a  class="botao" style="    cursor: default;height: 20px;"onClick="goBB(0);"> <span style="margin-right: 10px; margin-left: 10px;">Banco do Brasil</span></a>
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
                   onClick="showConfirmacao('Deseja cancelar a proposta de novo cart&atilde;o de cr&eacute;dito?', 'Confirma&ccedil;&atilde;o - Ayllos', 'voltaDiv(0,1,4)', 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))', 'sim.gif', 'nao.gif');
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