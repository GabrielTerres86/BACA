<?
/*!
 * FONTE        : consultar_dados_cartao_avais.php
 * CRIAÇÃO      : Amasonas (SUPERO)
 * DATA CRIAÇÃO : Marco/2018
 * OBJETIVO     : Mostrar opção de Novos Cartões da rotina de Cartões de Crédito da tela ATENDA obtidas na consulta Bancoob
 * --------------
 * ALTERAÇÕES   :
 * --------------
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
    exibirErro('error',$msgError,'Alerta - Ayllos',$funcaoAposErro);
}

// Verifica se o número da conta foi informado
if (!isset($_POST["nrdconta"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro);

$filter = "CECRED";


$nrdconta = $_POST["nrdconta"];

// Verifica se o número da conta é um inteiro válido
if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro);

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

//echo $xmlResult;
// Cria objeto para classe de tratamento de XML
$xmlObjNovoCartao = getObjectXML($xmlResult);

if (strtoupper($xmlObjNovoCartao->roottag->tags[0]->name) == "ERRO") {
     exibirErro('error',$xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',"voltaDiv(0,1,4)");
	 //return;
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
	$admresult = mensageria($adxml, "ATENDA_CRD", "BUSCAR_DESCRI_OPERADORA_CC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$admxmlObj = getObjectXML($admresult);//
	$xml_adm =  simplexml_load_string($admresult);
	$nm = $xml_adm->Dados->administradoras->nome;
	foreach($nm as $key=>$value)
		return "$value";
}


$xmlResult = mensageria($xml, "ATENDA_CRD", "SUGESTAO_LIMITE_CRD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

$json_sugestoes = json_decode($xmlObj->roottag->tags[0]->tags[1]->tags[0]->tags[0]->cdata,true);
echo "<!-- $xmlResult -->";
//$idacionamento = $xmlObj->roottag->tags[0]->tags[1]->tags[0]->tags[1]->cdata;

//$json_sugestoes = json_decode(html_entity_decode($xmlObj->roottag->tags[0]->tags[1]->tags[0]->tags[0]->cdata));

$idacionamento = $json_sugestoes['protocolo'];
$cartoes = $json_sugestoes["categoriasCartaoCecred"];
$sugestoes = $json_sugestoes["sugestaoCartaoCecred"];
$qtdSugestoes =  count($sugestoes);
$sugestoesMotor = array();
for($j = 0; $j < $qtdSugestoes; $j++){
    $sugestao = $sugestoes[$j];
    $sugestoesMotor[ $sugestao['codigoCategoria']] = $sugestao['vlLimite'];
}

//$cartoesSugestao = 



//print_r($cartoes);
//return;


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
            stepSelect = 2;
            if($('input[name=dsadmcrdcc]:checked').val() == "outro"){
                var select = $("#listType").val().split(";");
                $("#dsadmcrd").val(select[0]);
                $("#cdadmcrd").val(select[1]);
                if($("#valorLimite").val().length < 1){
                    showError("error", '<? echo utf8ToHtml("Por favor, preencha o valor de limite desejado.");?>', "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));")
                    return;
                }
                if($("#justificativa").val().length < 1){
                    showError("error", '<? echo utf8ToHtml("Por favor, preencha a justificativa");?>', "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));")
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
				var max = $(inputLimite ).attr("max");
				if(parseFloat(value) > parseFloat(max)){
					showError("error", '<? echo utf8ToHtml("Valor maior que o permitido, por favor selecione a opção  na parte inferior da tela.");?>', "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));")
					return;
				} else if(parseFloat(value) < parseFloat(min)){
					showError("error", '<? echo utf8ToHtml("Valor inferior ao mínimo do cartão.");?>', "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));")
					return;
                }
	            if(parseFloat(value) > parseFloat(max)){
					showError("error", '<? echo utf8ToHtml("Valor maior que o permitido, por favor selecione a opção  na parte inferior da tela.");?>', "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));")
					return;
				} else if(parseFloat(value) < parseFloat(min)){
					showError("error", '<? echo utf8ToHtml("Valor inferior ao mínimo do cartão.");?>', "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));")
					return;
				}

				$("#dsadmcrd").val($(inputLimite ).attr("nmadm"));
                $("#cdadmcrd").val($(inputLimite ).attr("cdadm"));
				 $("#vllimpro").val($(inputLimite).val());
                console.log($(inputLimite).val());
				
            }

            //var select = $("#listType").val().split(";");
            $('#btnProsseguir').hide();
            $('#btnsaveRequest').show();
            $('#backBtn').hide();
            $('#backChoose').show();

            $('#selectStep').hide();
            $('.selectStep').hide();
            $('#stepRequest').show();
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
        <fieldset  class="selectStep">
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

                    if(param.value == "outro"){

                        $("#justificativa").removeAttr("disabled");
                        $("#listType").removeAttr("disabled");
                        $("#valorLimite").removeAttr("disabled");


                    }else{
                        var paramArray = param.value.split(";");

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
                    if($valor_sugerido == 0 ){
                        $classes = "divDisabled";
                        $optionList = $optionList."<option value='$nmAdm;$id_administradora'>". $nmAdm." </option>";
                    }else{
                        $optionList = $optionList."<option value='$nmAdm;$id_administradora;$valor_sugerido'>". $nmAdm." </option>";
                    }
                    $limiteMinimo = $cartao['vlLimiteMinimo'];
                    $limiteMaximo = $cartao['vlLimiteMaximo'];

                    if($registers % 2 == 0){
                        $outPut = "<tr><td class='optCard $classes' style=\"padding-top:5px\"> .mess. </td>";
                    }else{
                        $outPut = "<td class='optCard $classes' style=\"padding-top:5px\"> .mess. </td></tr>";
                    }
                    $registers++;
                    $message ="<fieldset class=\"selectorCard $classes \" style='cursor:pointer'>"
                        ." <legend align=\"center\">". $nmAdm ."</legend>"
                        ."<br><div  style='float: left;$uniqueLeft'> "
                        ."<input type='radio' class='optradio $classes' value='".$nmAdm.";$id_administradora;".number_format($valor_sugerido,2,",",".")."' id='dsadmcrdcc' name='dsadmcrdcc' onChange='changeRadio(this)' >"
                        ."</div>"
                        ."<div style='float: right;$uniqueRight ".($pessoaFisica? " ":"width: 150px")."'>"
                        ." Min R$".number_format($limiteMinimo,2,",",".")."<br>"
                        .utf8ToHtml("Máx")." R$".number_format($limiteMaximo,2,",",".")."<br>"
                        ."<input placeholder='Valor solicitado' cdAdm='".$id_administradora."' nmAdm='".$nmAdm."' min='".$limiteMinimo."' max='".$limiteMaximo."' class='$classes valorLimite campo' style='float:left; width:85px;    margin-left: 0px;' value='". $valor_sugerido."'><br>"
                        ." </div></td>"
                        ."</fieldset>";

                    $outPut = str_replace(".mess.", $message , $outPut);

                    echo $outPut;

                }
                echo"</tr> "
                    ."<tr>"
                    ."<td colspan=2><div id=\"\" class=\" optCard \">"
                    ."<fieldset style=\"cursor:pointer\" class=\"selectorCard \" >"
                    ."<legend align='center'>".utf8ToHtml('Outra Opção')." </legend> "
                    ."<div style='height:100%; width:100%' >"
                    ."<div style='height: 100%; float: left; padding-top: 25%;'> <p><input  onChange='changeRadio(this)' type='radio' class='optradio' id='dsadmcrdcc' name='dsadmcrdcc' value='outro'></p> </div>"
                    ."<div style='float: right'>"
                    ."<select class='campo fieldclickable' id='listType' disabled> "
                    .$optionList."</select>"
                    ." </p><br><p>Justificativa </p>"
                    ."<p><textarea class='' id=\"justificativa\" rows=\"5\" cols=\"30\" style=\"resize: none; border: 1px solid #777;\" disabled></textarea>"
                    ." </p><p>Limite</p><p><input id='valorLimite' name='valorLimite' class='campo' disabled style='    margin-left: 0px;'>"
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
                        <input type="text" name="nmprimtl" id="nmprimtl" class="campoTelaSemBorda" style="width: 400px;" value="<?echo $nmtitcrd; ?>" disabled>
                        <br />
                        <label for="nrcpfcpf"><? echo utf8ToHtml('CNPJ:') ?></label>
                        <input type="text" name="nrcpfcpf" id="nrcpfcpf" class="campoTelaSemBorda" style="width: 120px;" value="<?echo formataNumericos("99.999.999/9999-99",$nrcpfcgc,"./-"); ?>" disabled>
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
                    <input  class='campo' id='vllimpro' name='vllimpro' disabled>

                    <label for="flgdebit"><? echo utf8ToHtml('Habilita função débito:') ?></label>
                    <input type="checkbox" name="flgdebit" id="flgdebit" class="campo" value="" />
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
                        <option value='1' selected>Cooperativa</option>
                        <!--option value='0'>Cooperado</option      OPÇÃO RETIRADO TEMPORÁRIAMENTE, PARA QUE SEJA ENVIADO SEMPRE PARA A COOPERATIVA (RENATO - SUPERO)-->
                    </select>
                    <br />
                </fieldset>
                <div id="divBotoes" >
				
                    <input class="btnVoltar" id="backChoose" type="image" style='display:none' src="<?echo $UrlImagens; ?>botoes/voltar.gif" onClick=" manageSelect();" />
                    <!-- <input class="" type="image" style='display:none' id="btnsaveRequest" src="<?echo $UrlImagens; ?>botoes/prosseguir.gif" onclick="validarNovoCartao solicitaSenha solicitaSenhaMagnetico('enviaSolicitacao()','643750','','sim.gif','nao.gif');" /> solicitaSenha-->
                    <input class="" type="image" style='display:none' id="btnsaveRequest" src="<?echo $UrlImagens; ?>botoes/prosseguir.gif" onclick="validarNovoCartao();" />

                
					<a style="display:none"  cdcooper="<?php echo $glbvars['cdcooper']; ?>" 
					cdagenci="<?php echo $glbvars['cdoperad']; ?>" 
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
					 <input type="image" src="<?echo $UrlImagens; ?>botoes/cancelar.gif" onClick="showConfirmacao('Deseja cancelar a proposta de novo cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Ayllos','voltaDiv(0,1,4)','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;">
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
    $("#nmtitcrd","#frmNovoCartao").setMask("STRING",40,charPermitido(),"");
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
    $("#nmtitcrd","#frmNovoCartao").setMask("STRING",40,charPermitido(),"");
    $("#vllimdeb","#frmNovoCartao").setMask("DECIMAL","zzz.zz9,99","","");
    $("#nrcpfcgc","#frmNovoCartao").setMask("INTEGER","999.999.999-99","","");
    $("#valorLimite").setMask("DECIMAL","zzz.zzz.zz9,99","","");
    $(".valorLimite").setMask("DECIMAL","zzz.zzz.zz9,99","","");

    $("#nrcpfcgc","#frmNovoCartao").unbind("blur").bind("blur",function() {
		
        if ($(this).val() != "" && $(this).val() != "000.000.000-00") {
            if ($(this).val() == cpfpriat) {
                return true;
            }
            alert($(this).val());
            if (!validaCpfCnpj(retiraCaracteres($(this).val(),"0123456789",true),1)) {
                showError("error","CPF inv&aacute;lido.","Alerta - Ayllos","$('#nrcpfcgc','#frmNovoCartao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
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
        $("#tpdpagto").attr("disabled",true);
        $("#tpenvcrd").attr("disabled",true);
        
    }else{
        $("#dscartao").val("INTERNACIONAL");
        $("#dscartao").attr("disabled","true");
        $("#flgdebit").attr("checked",true);
        $("#flgdebit").attr("disabled",true);
        $("#dtnasccr").removeAttr("disabled");
        $("#nrcpfcgc").attr("disabled",true);
       
        $("#tpenvcrd").attr("disabled",true);
    }

    
    hideMsgAguardo();
    bloqueiaFundo(divRotina);
    $('#dsadmcrd','#frmNovoCartao').focus();
</script>