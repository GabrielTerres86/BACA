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
$nrdconta       = !empty($_POST["nrdconta"]) ? $_POST["nrdconta"] : 0;
$nrcrcard       = !empty($_POST['nrcrcard']) ? $_POST['nrcrcard'] : 0;
$cdAdmCartao    = !empty($_POST['cdadmcrd']) ? $_POST['cdadmcrd'] : 0;
$cdadmcrd       = !empty($_POST['cdadmcrd']) ? $_POST['cdadmcrd'] : 0;
$nrctrcrd       = !empty($_POST['nrctrcrd']) ? $_POST['nrctrcrd'] : 0;
$cartaoCECRED   = in_array($cdAdmCartao, $cecredADM);
$nrctrcrd       = !empty($_POST['nrctrcrd']) ? $_POST['nrctrcrd'] : 0;

function strToNm($nrStr){
    return str_replace(",",".",str_replace(".","",$nrStr));
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

<form action="" name="frmAlterarLimitePJ" id="frmAlterarLimitePJ" method="post" onSubmit="return false;">
    <div id="divAlterarLimitePJ">
		
		<p style='padding-left:32%; padding-top:30px'>
			<a 	style="display:table; margin:0 auto; vertical-align: middle;    cursor: default;height: 20px;padding-right:  10px;    padding-bottom: 5px;" 
				class="botao" 
				onClick="alteraLimitePJ('G')">
				
				<span style="margin-right: 10px; margin-left: 10px;"><? echo utf8ToHtml("Limite Global") ?></span>
			</a>			
			<a 	style=" display:table; margin:0 auto; vertical-align: middle;    cursor: default;height: 20px;padding-right:  10px;    padding-bottom: 5px;margin-left: 20px;" 
				class="botao" 
				onClick="alteraLimitePJ('D')">
				
				<span style="margin-right: 10px; margin-left: 10px;"><? echo utf8ToHtml("Limite Diferenciado") ?></span>
			</a>
		<p>
		
        <!--<label class="rotulo txtNormalBold"><? echo utf8ToHtml("Limite Global") ?>
        <input type="radio" id="tplimite" name="tplimite" class="campoTelaSemBorda" onClick="alteraLimitePJ('G')"></label>
		<label class="rotulo txtNormalBold"><? echo utf8ToHtml("Limite Diferenciado") ?>
        <input type="radio" id="tplimite" name="tplimite" class="campoTelaSemBorda" onClick="alteraLimitePJ('D')"></label> -->
    </div>
	<div id="divBotoes">
            <input type="image" src="<?echo $UrlImagens; ?>botoes/voltar.gif"
                   onClick="voltaDiv(0, 1, 4);
                   return false;"/>            
        </div>
</form>

<script type="text/javascript">
    controlaLayout('frmAlterarLimitePJ');
	$("#divOpcoesDaOpcao1").css("display", "block");
    $("#divConteudoCartoes").css("display", "none");
	
	//alert('Adequar Anderson.');
	var nrcrcard    = <?php  echo $nrcrcard; ?>;
	var nrdconta    = <?php  echo $nrdconta; ?>;
	var cdadmcrd    = <?php  echo $cdadmcrd; ?>;
	var cdAdmCartao = <?php  echo $cdadmcrd; ?>;
	var nrctrcrd    = <?php  echo $nrctrcrd; ?>;
	
	
	function alteraLimitePJ(opcao){
		if (opcao == 'G') {
			// Global
			showMsgAguardo("Aguarde...");
			$.ajax({
				type: "POST",
				dataType: "html",
				url: UrlSite + "telas/atenda/cartao_credito/alterar_limite_cartao.php",
				data: {
					nrcrcard      : nrcrcard,
					nrdconta      : nrdconta,
					cdadmcrd      : cdadmcrd,
					cdAdmCartao   : cdAdmCartao,
					nrctrcrd      : nrctrcrd,
					opcao         : opcao
				},
				error: function (objAjax, responseError, objExcept) {

					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
				},
				success: function (response) {
					$("#divOpcoesDaOpcao1").html(response);
				}
			});
		} else if (opcao == 'D') {
			// Diferenciado
			showMsgAguardo("Aguarde...");
			$.ajax({
				type: "POST",
				dataType: "html",
				url: UrlSite + "telas/atenda/cartao_credito/alterar_limite_cartao.php",
				data: {
					nrcrcard      : nrcrcard,
					nrdconta      : nrdconta,
					cdadmcrd      : cdadmcrd,
					cdAdmCartao   : cdAdmCartao,
					nrctrcrd      : nrctrcrd,
					opcao         : opcao
				},
				error: function (objAjax, responseError, objExcept) {

					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
				},
				success: function (response) {
					$("#divOpcoesDaOpcao1").html(response);
				}
			});
		} else {
			showError("error", "Por favor, selecione uma opcao de alteracao de limite.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            return;
		}
	} 
	
	mostraDivDadosCartao();
    hideMsgAguardo();
    bloqueiaFundo(divRotina);
    //$('#dsadmcrd', '#frmAlterarLimitePJ').focus();
   
	
</script>