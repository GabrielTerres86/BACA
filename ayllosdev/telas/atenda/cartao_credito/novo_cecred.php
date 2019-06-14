<?
/*!
 * FONTE        : novo_cecred.php
 * CRIAÇÃO      : Amasonas (SUPERO)
 * DATA CRIAÇÃO : Marco/2018
 * OBJETIVO     : Mostrar opção de Novos Cartões da rotina de Cartões de Crédito da tela ATENDA obtidas na consulta Bancoob
 * --------------
 * ALTERAÇÕES   : 11/07/2018 - Paulo Silva (Supero): Alterado campo Justificativa para limitar em 235 caracteres.
 * -------------- 18/03/2019 - PJ429 - Implementado tipo de envio do cartão - Anderson-Alan (Supero)
 * 
 *
 *
 */

session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();

$funcaoAposErro = 'bloqueiaFundo(divRotina);';

// Verifica permissão
if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
    exibirErro('error',$msgError,'Alerta - Aimaro',$funcaoAposErro);
}

// Verifica se o número da conta foi informado
if (!isset($_POST["nrdconta"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro);

$filter = "CECRED";


$nrdconta = $_POST["nrdconta"];

// Verifica se o número da conta é um inteiro válido
if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);

// Monta o xml de requisição
$xmlGetNovoCartao  = "";
$xmlGetNovoCartao .= "<Root>";
$xmlGetNovoCartao .= "	<Cabecalho>";
$xmlGetNovoCartao .= "		<Bo>b1wgen0028.p</Bo>";
$xmlGetNovoCartao .= "		<Proc>carrega_dados_inclusao</Proc>";
$xmlGetNovoCartao .= "	</Cabecalho>";
$xmlGetNovoCartao .= "	<Dados>";
$xmlGetNovoCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xmlGetNovoCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
$xmlGetNovoCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xmlGetNovoCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
$xmlGetNovoCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
$xmlGetNovoCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xmlGetNovoCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
$xmlGetNovoCartao .= "		<idseqttl>1</idseqttl>";
$xmlGetNovoCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
$xmlGetNovoCartao .= "		<bthabipj>'F'</bthabipj>";
$xmlGetNovoCartao .= "	</Dados>";
$xmlGetNovoCartao .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xmlGetNovoCartao);



// Cria objeto para classe de tratamento de XML
$xmlObjNovoCartao = getObjectXML($xmlResult);

if (strtoupper($xmlObjNovoCartao->roottag->tags[0]->name) == "ERRO") {
     exibirErro('error',$xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',"voltaDiv(0,1,4)");
	 return;
}



// Montar o xml de Requisicao
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= " </Dados>";
$xml .= "</Root>";

function pegar_nome_adm($cod,$glbvars){
	
	$adxml .= "<Root>";
	$adxml .= " <Dados>";
	$adxml .= "   <cdadmcrd>$cod</cdadmcrd>";
	$adxml .= " </Dados>";
	$adxml .= "</Root>";
	$admresult = mensageria($adxml, "ATENDA_CRD", "BUSCAR_DESCRI_OPERADORA_CC", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$admxmlObj = getObjectXML($admresult);//
	$xml_adm =  simplexml_load_string($admresult);
	$nm = $xml_adm->Dados->administradoras->nome;
	foreach($nm as $key=>$value)
		return "$value";
}


$xmlResult = mensageria($xml, "ATENDA_CRD", "SUGESTAO_LIMITE_CRD", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);
$objXml = simplexml_load_string($xmlResult);
echo "<!-- SUGESTAO_LIMITE_CRD:\n";
print_r($objXml);
echo " \n -->";

$json_sugestoes = json_decode($xmlObj->roottag->tags[0]->tags[1]->tags[0]->tags[0]->cdata,true);

$erro = $objXml->Erro->Registro->dscritic;
if(strlen($erro) > 0){
	$erro =  str_replace(" ]"," ]<br>",$erro);
	$erro =  str_replace("\u00C3\u0192\u00C2\u00A1","a",$erro);
	echo"<script>showError('error', '".utf8ToHtml($erro)."', 'Alerta - Aimaro', 'voltaDiv(0, 1, 4);') </script>";
}

$mensagem = $objXml->Dados->sugestoes->sugestao->mensagem;
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
$mensagem =utf8ToHtml( str_replace("Ã§Ã£","ção",$mensagem));
//utf8ToHtml($mensagem)
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
	//echo"<script>showError('error', '".utf8ToHtml($mensagem)."', 'Alerta - Aimaro', 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));') </script>";
}

$idacionamento = $json_sugestoes['protocolo'];
$cartoes = $json_sugestoes["categoriasCartaoCecred"];
$sugestoes = $json_sugestoes['indicadoresGeradosRegra']["sugestaoCartaoCecred"];
$qtdSugestoes =  count($sugestoes);
$sugestoesMotor = array();
for($j = 0; $j < $qtdSugestoes; $j++){
	$tmp = $sugestoes[$j];
    $sugestoesMotor[ $tmp['codigoCategoria']] = $tmp['vlLimite'];
}
$counter = count($cartoes);
/*
if($conter == 0){
	exibirErro('error','Conta sem sugestões.','Alerta - Aimaro','voltaDiv(0, 1, 4);');
	return; 
}*/


$dados = $xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags;
// Dados Cadastrais
$dsgraupr = getByTagName($dados,"DSGRAUPR");
$cdgraupr = getByTagName($dados,"CDGRAUPR");
$dsadmcrd = getByTagName($dados,"DSADMCRD");
$cdadmcrd = getByTagName($dados,"CDADMCRD");
$dscartao = getByTagName($dados,"DSCARTAO");
$vlsalari = getByTagName($dados,"VLSALARI");
$dddebito = getByTagName($dados,"DDDEBITO");
$dsoutros = getByTagName($dados,"DSOUTROS");
$dslimite = getByTagName($dados,"DSLIMITE");
$cdadmdeb = getByTagName($dados,"CDADMDEB");
$inpessoa = getByTagName($dados,"INPESSOA");
$cdtipcta = getByTagName($dados,"CDTIPCTA");
$nmbandei = getByTagName($dados,"NMBANDEI");

// Primeiro Titular
$nmtitcrd = getByTagName($dados,"NMTITCRD");
$nrcpfcgc = getByTagName($dados,"NRCPFCGC");
$dtnasctl = getByTagName($dados,"DTNASCTL");
$nrdocptl = getByTagName($dados,"NRDOCPTL");

// Segundo Titular    
$nrcpfstl = getByTagName($dados,"NRCPFSTL");
$dtnasstl = getByTagName($dados,"DTNASSTL");
$nrdocstl = getByTagName($dados,"NRDOCSTL");
$nmsegntl = getByTagName($dados,"NMSEGNTL");

// Conjuge
$nmconjug = getByTagName($dados,"NMCONJUG");
$dtnasccj = getByTagName($dados,"DTNASCCJ");

// Representantes
$nrrepinc = getByTagName($dados,"NRREPINC");
$dsrepinc = getByTagName($dados,"DSREPINC");

// Administradoras que possuem débito	
// Buscar dias do débito da Administradora que aparece por 1º
$eCDADMDEB 			 = explode(",",$cdadmdeb);
$e_1a_ADMINISTRADORA = explode("#",$dddebito);
$e_DIASDEBITO        = explode(";",$e_1a_ADMINISTRADORA[0]);
$eDDDEBITO			 = explode(",",$e_DIASDEBITO[1]);

$cdAdmLimite   		 = explode("#",$dslimite);
$aListaLimite	     = explode(";",$cdAdmLimite[0]);
$cdLimite			 = explode("@",$aListaLimite[1]);


$adicionalXML .= "<Root>";
$adicionalXML .= " <Dados>";
$adicionalXML .= "   <nrdconta>$nrdconta</nrdconta>";
$adicionalXML .= " </Dados>";
$adicionalXML .= "</Root>";
$resultAdicionalXML = mensageria($adicionalXML, "ATENDA_CRD", "VERIFICAR_CARTOES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlAdicionalResult = simplexml_load_string($resultAdicionalXML);

$opcoesAdicional = array();
$paramsKeys = array("nrctrmul","vllimmul","ddebimul","tppagtomul","nrctress","vllimess","ddebiess","tppagtoess");
$crdParams = "{";
$temMultiplo = false;
$temCabal = false;
foreach(get_object_vars($xmlAdicionalResult->Dados->cartoes->cartao) as $key => $value){
	if(($key == "multmastti") && (strlen($value) > 0)){
		$temMultiplo = true;
	}else if(($key == "multesseti") && (strlen($value) > 0)){//multesseti
		$temCabal = true;
	}
}

// Montar o xml de Requisicao para buscar o tipo de conta do associado e termo para conta salario
$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "ATENDA_CRD", "ENVIO_CARTAO_COOP_PA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

$coop_envia_cartao = getByTagName($xmlObjeto->roottag->tags,"COOP_ENVIO_CARTAO");
$pa_envia_cartao = getByTagName($xmlObjeto->roottag->tags,"PA_ENVIO_CARTAO");

if ($coop_envia_cartao && !$pa_envia_cartao) {
	echo "<script>showError('error', 'Nenhuma op&ccedil;&atilde;o de envio definida para o PA, por favor, entre em contato com a SEDE para que seja realizada a parametriza&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina);') </script>";
} elseif ($coop_envia_cartao) {
	echo '<script>novo_fluxo_envio = true;</script>';
}
?>

<style>
    [title]{
        background-color: rgb(255,246,143);
    }


    #tooltip *{
        font-size		: 10px;
        font-weight		: normal;
        font-family		: Tahoma;
    }
    .dvselected{
       box-shadow: 2px 2px 2px 2px #888888;
    }
</style>

<script>
    //fix amasonas
    protocolo = "<?echo $idacionamento;?>";
    var stepSelect = 1;
    $('#nmtitcrd').tooltip();
    $('#nmextttl').tooltip();
    $('#nmextttl').attr("disabled",true);
    var selectable = true;

    $(".fieldclickable").mouseover(function(){
        selectable = false;
        console.log(0);
    });
    $(".fieldclickable").mouseout(function(){
        selectable = true;
        console.log(1);
    });


    function manageSelect(){

        if(stepSelect == 1){
            
            if($('input[name=dsadmcrdcc]:checked').val() == "outro"){
                var select = $("#listType").val().split(";");
                $("#dsadmcrd", "#frmNovoCartao").val(select[0]);
                $("#cdadmcrd", "#frmNovoCartao").val(select[1]);
				var vlSugMotor = select[2];
				while(vlSugMotor.indexOf(".") > -1)
					vlSugMotor = vlSugMotor.replace(".","");
				vlSugMotor = vlSugMotor.replace(",",".");
				var vlMaxlimcrd = select[3];
				
                if($("#valorLimite").val().length < 1){
                    showError("error", '<? echo utf8ToHtml("Por favor, preencha o valor de limite desejado.");?>', "Alerta - Aimaro", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));")
                    return;
                }
                if($("#justificativa").val().length < 1){
                    showError("error", '<? echo utf8ToHtml("Por favor, preencha a justificativa");?>', "Alerta - Aimaro", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));")
                    return;
                }
				var limiteSolicitado = $("#valorLimite").val();
				while(limiteSolicitado.indexOf(".") > -1)
					limiteSolicitado = limiteSolicitado.replace(".","");
				limiteSolicitado = parseFloat(limiteSolicitado.replace(",","."));
				/*if(limiteSolicitado == 0){
					var permiteZero = !(select[1] != 12) ; /*
					if( !permiteZero){
						showError("error", '<? echo utf8ToHtml("Limite R$0 não permitido para a bandeira solicitada.");?>', "Alerta - Aimaro", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));")
						return;
					}
					
				}*/
				if(limiteSolicitado > vlMaxlimcrd){
					showError("error", '<? echo utf8ToHtml("Não é possível solictar limite acima do máximo da categoria");?>', "Alerta - Aimaro", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");
                    return;
                }
				
				if(limiteSolicitado <= parseFloat(vlSugMotor) && select[4] == 't'){					
					showError("error", '<? echo utf8ToHtml("Limite solicitado dentro dos valores sugeridos, por favor utilize as caixas de seleção.");?>', "Alerta - Aimaro", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");
                    return;
				}else if(select[4] == 'n' && limiteSolicitado < parseFloat(vlSugMotor) ){
					showError("error", '<? echo utf8ToHtml("Limite solicitado abaixo do limite mínimo da categoria.");?>', "Alerta - Aimaro", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");						
					return;
				}
				
                $("#vllimpro").val($("#valorLimite").val());
            }else{
                var tpcard = $('input[name=dsadmcrdcc]:checked').val();
                var parent = $('input[name=dsadmcrdcc]:checked').parent();
                var grandparent = $(parent).parent();
                var inputLimite = $(grandparent).find(".valorLimite")[0];
				var value = $(inputLimite).val().replace('.', "").replace(",",".");
				var min = $(inputLimite ).attr("min");
				var max = $(inputLimite ).attr("max").replace('.', "").replace(",",".");
				//if(parseFloat(value) == 0 && $(inputLimite ).attr("cdadm") != 11 /*&& $(inputLimite ).attr("cdadm") != 12*/){ /*
				/*	showError("error", '<? echo utf8ToHtml("Limite com valor R$0 deve ser enviado para análise da esteira.");?>', "Alerta - Aimaro", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));")
					return;
				}*/
				if(parseFloat(value) > parseFloat(max)){
					showError("error", '<? echo utf8ToHtml("Valor maior que o permitido, por favor selecione a opção  na parte inferior da tela.");?>', "Alerta - Aimaro", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));")
					return;
				} else if(parseFloat(value) < parseFloat(min)){
					showError("error", '<? echo utf8ToHtml("Valor inferior ao mínimo do cartão.");?>', "Alerta - Aimaro", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));")
					return;
                }
	            if(parseFloat(value) > parseFloat(max)){
					showError("error", '<? echo utf8ToHtml("Valor maior que o permitido, por favor selecione a opção  na parte inferior da tela.");?>', "Alerta - Aimaro", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));")
					return;
				} else if(parseFloat(value) < parseFloat(min)){
					showError("error", '<? echo utf8ToHtml("Valor inferior ao mínimo do cartão.");?>', "Alerta - Aimaro", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));")
					return;
				}
		
				$("#dsadmcrd").val($(inputLimite ).attr("nmadm"));
                $("#cdadmcrd").val($(inputLimite ).attr("cdadm"));
				 $("#vllimpro").val($(inputLimite).val());
                console.log($(inputLimite).val());
				
            }
			
			stepSelect = 2;
            //var select = $("#listType").val().split(";");
            $('#btnProsseguir').hide();
            $('#btnsaveRequest').show();
            $('#backBtn').hide();
            $('#backChoose').show();

            $('#selectStep').hide();
            $('.selectStep').hide();
            $('#stepRequest').show();

            <?php if ($coop_envia_cartao && !$pa_envia_cartao) { ?>
				showError('error', 'Nenhuma op&ccedil;&atilde;o de envio definida para o PA, por favor, entre em contato com a SEDE para que seja realizada a parametriza&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina);');
			<? } ?>
        }else{
            stepSelect = 1;
            $('#btnProsseguir').show();
            $('#btnsaveRequest').hide();
            $('#backBtn').show();
            $('#backChoose').hide();

            $('#selectStep').show();
            $('.selectStep').show();
            $('#stepRequest').hide();
        }
    }
    $('#stepRequest').hide();
</script>

<form action="" name="frmNovoCartao" id="frmNovoCartao" method="post" onSubmit="return false;">
    <div id="divDadosNovoCartao">
        <fieldset  class="selectStep" style="padding-left: 30px;">
            <legend><? echo utf8ToHtml('Novo Cartão de Crédito') ?></legend>
            <script>
                $('.optCard').click(function (elem) {
                    if(selectable){
                        
                        if($(this).hasClass("divDisabled") || $(this).hasClass("dvselected"))
                            return;
                        $(".dvselected").removeClass("dvselected");
                        $(this).find('input:radio').attr('checked', true);
                        $(this).find('input:radio').change();
                        $(this).find("textarea").focus();
                        console.log(elem);
                        $(this).addClass("dvselected");
                    }
                });

                function changeRadio( param ){
					
		    $(".optradio").removeAttr("checked");
		    $(param).attr("checked",true);
                    if(param.value == "outro"){

                        $("#justificativa").removeAttr("disabled");
                        $("#listType").removeAttr("disabled");
                        $("#valorLimite").removeAttr("disabled");


                    }else{
                        var paramArray = param.value.split(";");
						
		    	$("#justificativa").removeAttr("value");                       
                        $("#valorLimite").removeAttr("value");

                        $("#justificativa").attr("disabled",true);
                        $("#listType").attr("disabled",true);
                        $("#valorLimite").attr("disabled",true);

                        $("#dsadmcrd").val(paramArray[0]);
                        $("#cdadmcrd").val(paramArray[1]);
                        $("#vllimpro").val(paramArray[2]);

                    }
                    console.log(param.value);
                    $("#btnProsseguir").show();
                }
            </script>
            <div id="selectStep">

                <?php
                
                // Pega o código da adm;dias do débito
                $e_ADMINISTRADORA = explode("#",$dddebito);
                $cdAdmLimite 	  = explode("#",$dslimite);

                // Obtem bandeiras disponiveis
                $eNMBANDEI = explode(",",$nmbandei);
                $eCDADMCRD =  explode(",",$cdadmcrd);
                $aRepresentanteOutros = explode(",",$dsoutros);
                echo "<table>";
                $optionList = "";
                $registers = 0;
                $counter = count($cartoes);
				$uniqueLeft;
				$uniqueRight;
				if($counter == 1){
					$uniqueLeft = 'padding-left: 30px;';
					$uniqueRight = 'padding-right:  50px;';
				}
				$pessoaFisica = true;
                
                $labels = array(utf8ToHtml("CECRED Clássico"),utf8ToHtml("CECRED Essêncial"),utf8ToHtml("CECRED Gold"),utf8ToHtml("CECRED Platinum"),utf8ToHtml("CECRED Black"));
				$idsMultiplo = array(12,13,14);
				echo "<!-- sugestoes \n";
				print_r($sugestoesMotor);
				echo "\n -->";
				
                for ($i = 0; $i < $counter; $i++){
                    // pega o código da adm
                   
                    $cartao = $cartoes[$i];

					//$nmAdm = pegar_nome_adm($cartao['codigo'],$glbvars);
                    $nmAdm = $cartao['descricao'];
                    if(strpos($nmAdm,"DEB") > -1){
                            continue;
                    }
					if($pessoaFisica && strpos($nmAdm,"EMPRESA") > -1 )
						$pessoaFisica = false;
                    $id_administradora = $cartao['codigo'];
                    if(isset($sugestoesMotor[$cartao['codigo']]))
                        $valor_sugerido = number_format($sugestoesMotor[$cartao['codigo']],2,",",".");
                    else
						$valor_sugerido = 0;
                    $classes = "";
					$vlLimiteMaximo = $cartao['vlLimiteMaximo'];
					$limiteMinimo = $cartao['vlLimiteMinimo'];
					echo "<!-- \n Vlor minimo: $limiteMinimo  \n -->";
					
					if(!($temMultiplo && in_array($id_administradora,$idsMultiplo )) && !($temCabal && $id_administradora ==11)){
						if($valor_sugerido == 0 || $contigenciaAtiva){
							$classes = "divDisabled";
							$optionList = $optionList."<option value='$nmAdm;$id_administradora;$limiteMinimo;$vlLimiteMaximo;n'>". $nmAdm." </option>";
						}else{
							$optionList = $optionList."<option value='$nmAdm;$id_administradora;$valor_sugerido;$vlLimiteMaximo;t'>". $nmAdm." </option>";
						}
					}
					$classes = ($contigenciaAtiva || $valor_sugerido == 0 || ($temMultiplo && in_array($id_administradora,$idsMultiplo ))  || ($temCabal && $id_administradora ==11) ) ? "divDisabled":"";
					// fix limite 
					$sugestao = $sugestoes[$j];                  
                    $limiteMaximo = $valor_sugerido;
					
                    if($registers % 2 == 0){
                        $outPut = "<tr><td class='optCard $classes' style=\"padding-top:5px\"> .mess. </td>";
                    }else{
                        $outPut = "<td class='optCard $classes' style=\"padding-top:5px\"> .mess. </td></tr>";
                    }
                    $registers++;
					if($valor_sugerido == 0)
						$valor_sugerido = number_format(0,2,",",".");
                    $message ="<fieldset class=\"selectorCard $classes \" style='cursor:pointer'>"
                        ." <legend align=\"center\">". $nmAdm ."</legend>"
                        ."<br><div  style='float: left;$uniqueLeft'> "
                        ."<input type='radio' class='optradio $classes' value='".$nmAdm.";$id_administradora;".$valor_sugerido."' id='dsadmcrdcc' name='dsadmcrdcc' onChange='changeRadio(this)' >"
                        ."</div>"
                        ."<div style='float: right;$uniqueRight ".($pessoaFisica? " ":"width: 200px")."'>"
                        .utf8ToHtml("Limite Mínimo")." R$".number_format($limiteMinimo,2,",",".")."<br>"
                        .utf8ToHtml("Limite Sugerido")." R$".$valor_sugerido."<br>"
                        ."<input title='".utf8ToHtml('Informe um valor entre o limite mínimo e o sugerido.')."' placeholder='Valor solicitado' cdAdm='".$id_administradora."' nmAdm='".$nmAdm."' min='".$limiteMinimo."' max='".$valor_sugerido."' class='$classes valorLimite campo' style='float:left; width:85px;    margin-left: 0px; background:white' value='". $valor_sugerido."'><br>"
                        ." </div></td>"
                        ."</fieldset>";

                    $outPut = str_replace(".mess.", $message , $outPut);

                    echo $outPut;

                }
                echo"</tr> "
                    ."<tr>"
                    ."<td colspan=2><div id=\"\" class=\" optCard \">"
                    ."<fieldset style=\"cursor:pointer\" class=\"selectorCard \" >"
                    ."<legend align='center'>".utf8ToHtml('Enviar para Análise da Esteira')." </legend> "
                    ."<div style='height:100%; width:100%' >"
                    ."<div style='height: 100%; float: left; padding-top: 15%;'> <p><input  onChange='changeRadio(this)' type='radio' class='optradio' id='dsadmcrdcc' name='dsadmcrdcc' value='outro'></p> </div>"
                    ."<div style='float: right'><label for='listType'style='width: 70px;margin-right: 5px;'>Categoria:</label>"
                    ."<select  class='campo fieldclickable' id='listType' disabled style='margin-left: 00px;'> "
                    .$optionList."</select>"
                    ." </p><br><br>"
                    ."<p><label for='justificativa' style='width: 70px;margin-right: 5px;'>Justificativa:</label><textarea maxlength='235' class='' placeholder='' id=\"justificativa\" rows=\"5\" cols=\"50\" style=\"resize: none; border: 1px solid #777;\" disabled></textarea>"
                    ." </p><p><label for='valorLimite'style='width: 70px;margin-right: 5px;'>Limite:</label><input id='valorLimite' name='valorLimite' class='campo' disabled style='    margin-left: 0px;'>"
                    ."</fieldset></div></div></div></td> </tr>";

                echo "</table>";
                ?>

                <span> 		</span>
        </fieldset>

        <div id="divBotoes"  class="selectStep" >
            <input class="selectStep btnVoltar" id="backBtn" type="image" src="<?echo $UrlImagens; ?>botoes/voltar.gif" onClick="opcaoNovo(1);return false;" />

            <input class="selectStep"  type="image" style='display:none' id="btnProsseguir" src="<?echo $UrlImagens; ?>botoes/prosseguir.gif" onClick="manageSelect(); buscaDados('<?echo $cdtipcta;?>','<?echo formataNumericos("999.999.999-99",$nrcpfstl,".-");?>','<?echo $inpessoa;?>','<?echo $dtnasstl ;?>','<?echo str_replace('\'','',$nrdocstl);?>','<?echo str_replace('\'','',$nmconjug); ?>','<?echo $dtnasccj ;?>','<?echo str_replace('\'','',$nmtitcrd); ?>','<?echo formataNumericos("999.999.999-99",$nrcpfcgc,".-");?>','<?echo $dtnasctl;?>','<?echo str_replace('\'','',$nrdocptl); ?>','<?echo number_format(str_replace(",",".",$vlsalari),2,",","."); ?>','<?echo str_replace('\'','',$nmsegntl);?>');carregaRepresentantes();" />

        </div>
    </div>
    <div id="stepRequest" style=''>
        <!--start form -->
        <form action="" name="frmNovoCartao" id="frmNovoCartao" method="post" onSubmit="return false;">
		
            <div id="divDadosNovoCartao">
                <fieldset>
                    <legend><? echo utf8ToHtml('Novo Cartão de Crédito') ?></legend>
                    <label for="dsadmcrd"><? echo utf8ToHtml('Administradora:') ?></label>
                    <input name="dsadmcrd" id="dsadmcrd" onblur="" onchange="" class="campo" disabled>
                    <input type="hidden" name="cdadmcrd" id="cdadmcrd" onblur="" onchange="" class="campo" disabled>
					<input type="hidden" name="idacionamento" id="idacionamento" value="<? echo $idacionamento; ?>" />

                    <div id="conteudoPJ">
                        <label for="nmprimtl"><? echo utf8ToHtml('Razão Social:') ?></label>
                        <input type="text" name="nmprimtl" id="nmprimtl" class="campoTelaSemBorda" style="width: 400px;" value="<?echo $nmtitcrd; ?>" disabled readonly>
                        <br />
                        <label for="nrcpfcpf"><? echo utf8ToHtml('CNPJ:') ?></label>
                        <input type="text" name="nrcpfcpf" id="nrcpfcpf" class="campoTelaSemBorda" style="width: 120px;" value="<?echo formataNumericos("99.999.999/9999-99",$nrcpfcgc,"./-"); ?>" disabled readonly>
                        <br />
                        <label for="dsrepinc"><? echo utf8ToHtml('Representante:') ?></label>
                        <select name="dsrepinc" id="dsrepinc" class="campo" style="width: 325px;" onblur="" onchange="selecionaRepresentante();"  >
                        </select>
                        <br />
                    </div>
                    <div id="titularidade">
                        <label for="dsgraupr"><? echo utf8ToHtml('Titularidade:') ?></label>
                        <select name="dsgraupr" id="dsgraupr" onChange="buscaDados('<?echo $cdtipcta;?>','<?echo formataNumericos("999.999.999-99",$nrcpfstl,".-");?>','<?echo $inpessoa;?>','<?echo $dtnasstl ;?>','<?echo str_replace('\'','',$nrdocstl);?>','<?echo str_replace('\'','',$nmconjug); ?>','<?echo $dtnasccj ;?>','<?echo str_replace('\'','',$nmtitcrd); ?>','<?echo formataNumericos("999.999.999-99",$nrcpfcgc,".-");?>','<?echo $dtnasctl;?>','<?echo str_replace('\'','',$nrdocptl); ?>','<?echo number_format(str_replace(",",".",$vlsalari),2,",","."); ?>','<?echo str_replace('\'','',$nmsegntl);?>');" class="campo" style="width: 100px;">
                            <option value="1">Conjuge</option>
							<option value="3">Filhos</option>
							<option value="4">Companheiro</option>
							<option value="5" selected="">Primeiro Titular</option>
							<option value="6">Segundo Titular</option>
							<option value="7">Terceiro Titular</option>
							<option value="8">Quarto Titular</option>
                        </select>
                        <br />
                    </div>
                    <label for="nrcpfcgc"><? echo utf8ToHtml('C.P.F.:') ?></label>
                    <input type="text" name="nrcpfcgc" id="nrcpfcgc" class="campo" value="" disabled=true/>
                    <div id="titular" style="margin-top:7px;">
                        <label for="nmextttl"><? echo utf8ToHtml('Titular:') ?></label>
                        <input type="text" name="nmextttl" id="nmextttl" class="campo" title="Informar nome conforme Receita Federal" value="" />
                        <br />
                    </div>
                    <br style="clear:both;" />
                    <hr style="background-color:#666; height:1px; width:480px;" id="hr1"/>
                    <label for="nmtitcrd"><? echo utf8ToHtml('Nome no Plástico:') ?></label>
                    <input type="text" name="nmtitcrd" id="nmtitcrd" class="campo" title="Nao permitido abreviar o primeiro e o ultimo nome" value="" />
                    <br />
                    <div id="empresa">
                        <label for="nmempres"><? echo utf8ToHtml('Empresa do Plástico:') ?></label>
                        <input type="text" name="nmempres" id="nmempres" class="campo" value="<?echo $nmtitcrd; ?>" />
                    </div>
                    <hr style="background-color:#666; height:1px; width:480px;" id="hr2"/>
                    <br style="clear:both;" />
                    <label for="nrdoccrd"><? echo utf8ToHtml('Identidade:') ?></label>
                    <input type="text" name="nrdoccrd" id="nrdoccrd" class="campo" value="" />
                    <label for="dtnasccr"><? echo utf8ToHtml('Nascimento:') ?></label>
                    <input type="text" name="dtnasccr" id="dtnasccr" class="campo" value="" disabled />
                    <br />
                    <label for="dscartao"><? echo utf8ToHtml('Tipo:') ?></label>
                    <select name="dscartao" id="dscartao" class="campo">
						<option value="NACIONAL">NACIONAL</option>
						<option value="INTERNACIONAL" selected="">INTERNACIONAL</option>
						<option value="GOLD">GOLD</option>
                    </select>
                    <label for="dddebito"><? echo utf8ToHtml('Dia Débito:') ?></label>
                    <select name="dddebito" id="dddebito" class="campo">
						<option value="03">03</option>
						<option value="07">07</option>
						<option value="11">11</option>
						<option value="19">19</option>
						<option value="22">22</option>
                    </select>
                    <br />
                    <label for="vlsalari"><? echo utf8ToHtml('Salário:') ?></label>
                    <input type="text" name="vlsalari" id="vlsalari" class="campo" value="0,00" />
                    <label for="vlsalcon"><? echo utf8ToHtml('Salário Cônjuge:') ?></label>
                    <input type="text" name="vlsalcon" id="vlsalcon" class="campo" value="0,00" />
                    <br />
                    <label for="vloutras"><? echo utf8ToHtml('Outras Rendas:') ?></label>
                    <input type="text" name="vloutras" id="vloutras" class="campo" value="0,00" />
                    <label for="vlalugue"><? echo utf8ToHtml('Aluguel:') ?></label>
                    <input type="text" name="vlalugue" id="vlalugue" class="campo" value="0,00" />
                    <br />
                    <label for="vllimpro"><? echo utf8ToHtml('Limite Proposto:') ?></label>
                    <input  class='campo' id='vllimpro' name='vllimpro' disabled readonly>

                    <label for="flgdebit"><? echo utf8ToHtml('Habilita função débito:') ?></label>
                    <input type="checkbox" name="flgdebit" id="flgdebit" class="campo" dtb="1" onclick='confirmaPurocredito();' />
                    <br />
                    <label for="flgimpnp"><? echo utf8ToHtml('Promissória:') ?></label>
                    <select name="flgimpnp" id="flgimpnp" class="campo">
                        <option value="yes" selected>Imprime</option>
                    </select>
                    <label for="vllimdeb"><? echo utf8ToHtml('Limite Débito:') ?></label>
                    <input type="text" name="vllimdeb" id="vllimdeb" class="campo" value="0,00" />
                    <br />
                    <label for="tpdpagto"><? echo utf8ToHtml('Forma de Pagamento:') ?></label>
                    <select class='campo' id='tpdpagto' name='tpdpagto'>
                        <option value='0' selected> </option>
                        <option value='2'>Debito CC Minimo</option>
                        <option value='1'selected>Debito CC Total</option>
                        <option value='3'>Boleto</option>
                    </select>
                    <label for="tpenvcrd"><? echo utf8ToHtml('Envio:') ?></label>
                    <select class='campo' id='tpenvcrd' name='tpenvcrd'>
                    	<option <?php if ($pa_envia_cartao) { echo "selected"; } ?> value="0">Cooperado</option>
						<option <?php if (!$pa_envia_cartao) { echo "selected"; } ?> value="1">Cooperativa</option>
                    </select>
                    <br />
                </fieldset>
                <div id="divBotoes" >

                    <input class="botao btnVoltar" id="backChoose" type="button" style='display:none' onclick=" manageSelect();" value="Voltar" />
					<?php if ($coop_envia_cartao && !$pa_envia_cartao) { ?>
					<input class="botao botaoDesativado" type="button" style='display:none' id="btnsaveRequest" onclick="return false;" value="Prosseguir" />
					<?php } else { ?>
					<input class="botao" type="button" style='display:none' id="btnsaveRequest" onclick="verificaEfetuaGravacao('I');" value="Prosseguir" />
					<?php } ?>
					<input class="" type="image" style='display:none' id="btnsaveRequest" src="<?echo $UrlImagens; ?>botoes/prosseguir.gif" onclick="verificaEfetuaGravacao('I');" />
                
					<a style="display:none"  cdcooper="<?php echo $glbvars['cdcooper']; ?>" 
					cdagenci="<?php echo $glbvars['cdpactra']; ?>" 
					nrdcaixa="<?php echo $glbvars['nrdcaixa']; ?>" 
					idorigem="<?php echo $glbvars['idorigem']; ?>" 
					cdoperad="<?php echo $glbvars['cdoperad']; ?>"
					dsdircop="<?php echo $glbvars['dsdircop']; ?>"
					   href="#" class="botao" id="emiteTermoBTN" onclick="imprimirTermoDeAdesao(this);"> <? echo utf8ToHtml("Imprimir Termo de Adesão");?></a>

                </div>
            </div>
            <div id="divDadosAvalistas" class="condensado">
                <?
                // ALTERAÇÃO 001: Substituido formulário antigo pelo include				
                include('../../../includes/avalistas/form_avalista.php');
                ?>
                <div id="divBotoes">
                    <!-- <input type="image" id="btVoltar" src="<?echo $UrlImagens; ?>botoes/voltar.gif" onClick="mostraDivDadosCartao();return false;">
					 <input type="image" src="<?echo $UrlImagens; ?>botoes/cancelar.gif" onClick="showConfirmacao('Deseja cancelar a proposta de novo cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Aimaro','voltaDiv(0,1,4)','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;">
					 <input type="image" id="btSalvar" src="<?echo $UrlImagens; ?>botoes/concluir.gif" onClick="validarAvalistas(4);return false;"> -->

                </div>
            </div>
        </form>
        <!--end form -->
    </div>
    <div id="ValidaSenha" style="display:none">

    </div>
    </div>

</form>

<script type="text/javascript">
    controlaLayout('frmNovoCartao');

    cpfpriat = "000.000.000-00";

    $("#divOpcoesDaOpcao1").css("display","block");
    $("#divConteudoCartoes").css("display","none");

    $(".divDisabled").attr("disabled",true);
    $(".divDisabled").css({opacity: 0.7});

    mostraDivDadosCartao();
    <?php
	
   // if ($inpessoa == "1") { // Pessoa Física 
	if ($pessoaFisica) { // Pessoa Física 
    ?>
    // Seta máscara aos campos
    $("#nmtitcrd","#frmNovoCartao").setMask("STRING",40,"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ","");
    $("#dtnasccr","#frmNovoCartao").setMask("DATE","","","divRotina");
    $("#nrcpfcgc","#frmNovoCartao").setMask("INTEGER","999.999.999-99","","");
    $("#vlsalari","#frmNovoCartao").setMask("DECIMAL","zzz.zzz.zz9,99","","");
    $("#vlsalcon","#frmNovoCartao").setMask("DECIMAL","zzz.zzz.zz9,99","","");
    $("#vloutras","#frmNovoCartao").setMask("DECIMAL","zzz.zzz.zz9,99","","");
    $("#vlalugue","#frmNovoCartao").setMask("DECIMAL","zzz.zzz.zz9,99","","");
    $("#valorLimite").setMask("DECIMAL","zzz.zzz.zz9,99","","");
    $(".valorLimite").setMask("DECIMAL","zzz.zzz.zz9,99","","");
    $("#vllimdeb","#frmNovoCartao").setMask("DECIMAL","zzz.zz9,99","","");

    // Carrega os dados do primeiro titular
    $("#dsgraupr","#frmNovoCartao").trigger("change");

    // Carrega dados da administradora padrão
    $("#dsadmcrd","#frmNovoCartao").trigger("change");

    <?php
    } else { // Pessoa Jurídica
    ?>

    // Seta máscara aos campos
    $("#dtnasccr","#frmNovoCartao").setMask("DATE","","","divRotina");
    $("#nmtitcrd","#frmNovoCartao").setMask("STRING",40,"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ","");
    $("#nmempres","#frmNovoCartao").setMask("STRING",40,"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ","");
    $("#vllimdeb","#frmNovoCartao").setMask("DECIMAL","zzz.zz9,99","","");
    $("#nrcpfcgc","#frmNovoCartao").setMask("INTEGER","999.999.999-99","","");
    $("#valorLimite").setMask("DECIMAL","zzz.zzz.zz9,99","","");
    $(".valorLimite").setMask("DECIMAL","zzz.zzz.zz9,99","","");

    $("#nrcpfcgc","#frmNovoCartao").unbind("blur").bind("blur",function() {
		
        if ($(this).val() != "" && $(this).val() != "000.000.000-00") {
            if ($(this).val() == cpfpriat) {
                return true;
            }
            
            if (!validaCpfCnpj(retiraCaracteres($(this).val(),"0123456789",true),1)) {
                showError("error","CPF inv&aacute;lido.","Alerta - Aimaro","$('#nrcpfcgc','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
                return false;
            }
            var nrdoc = $(this).val();
            while(nrdoc.indexOf(".")> -1)
            {
                nrdoc = nrdoc.replace(".","");
            }            
            carregarRepresentante("N",0, nrdoc);
        } else {
            $("#dtnasccr","#frmNovoCartao").val("").prop("disabled",true).attr("class","campoTelaSemBorda");
        }

        return true;
    });
	
	$("#vllimdeb").attr("disabled","true");
    // Seta a mácara do cpf
    $("#nrcpfcgc","#frmNovoCartao").trigger("blur");

    // Carrega dados da administradora padrão
    $("#dsadmcrd","#frmNovoCartao").trigger("change");

    <?php
    }
    ?>
    if(inpessoa == 2){
        $("#dscartao").val("INTERNACIONAL");
        $("#dscartao").attr("disabled","true");
        //dddebito
        $("#dddebito").val("03");
        $("#dddebito").attr("disabled","true");
        $("#vllimdeb").attr("disabled",true);
       // $("#tpdpagto").attr("disabled",true);
        $("#tpenvcrd").attr("disabled",true);
        
    }else{
        $("#dscartao").val("INTERNACIONAL");
        $("#dscartao").attr("disabled","true");
        $("#flgdebit").attr("checked",true);
        $("#flgdebit").attr("disabled",true);
        $("#dtnasccr").removeAttr("disabled");
		$("#vllimdeb").attr("disabled",true);
        $("#nrcpfcgc").attr("disabled",true);
       
        $("#tpenvcrd").attr("disabled",true);
    }

    $("#flgdebit").attr("checked",true);
    hideMsgAguardo();
    bloqueiaFundo(divRotina);
    $('#dsadmcrd','#frmNovoCartao').focus();
	globalesteira = false;
	glbadc = 'n';
	
	function confirmaPurocredito(){
		if(idastcjt == 1 )
			return;
		dbt = $("#flgdebit").attr("dtb");
		var chk = $("#flgdebit").attr("checked");
		if(chk && chk=="checked" && dbt =='1'){
			showConfirmacao('<? echo utf8ToHtml("Deseja solicitar um Cartão Puro crédito?");?>', 'Confirma&ccedil;&atilde;o - Aimaro', '$("#flgdebit").removeAttr("checked");$("#flgdebit").attr("dtb",0);', "", 'sim.gif', 'nao.gif');
		}
		$("#flgdebit").attr("checked",true);
		$("#flgdebit").attr("dtb",1);
	}
	
	contigenciaAtiva = false;
	justificativaCartao = undefined;
</script>