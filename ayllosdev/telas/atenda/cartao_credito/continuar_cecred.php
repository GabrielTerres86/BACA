<?php

/*!
 * FONTE        : alterar_cecred.php
 * CRIAÇÃO      : Augusto (SUPERO)
 * DATA CRIAÇÃO : Setembro/2018
 * OBJETIVO     : Alterar as propostas de cartão de crédito
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

// Verifica permissão
if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
    exibeErro($msgError);		
}			

// Verifica se o número da conta foi informado
if (!isset($_POST["nrdconta"]) ||
    !isset($_POST["nrctrcrd"])) {
    exibeErro("Par&acirc;metros incorretos.");
}	

$nrdconta = $_POST["nrdconta"];
$nrctrcrd = $_POST["nrctrcrd"];

// Verifica se o número da conta é um inteiro válido
if (!validaInteiro($nrdconta)) {
    exibeErro("Conta/dv inv&aacute;lida.");
}

// Verifica se o número da conta é um inteiro válido
if (!validaInteiro($nrctrcrd)) {
    exibeErro("N&uacute;mero do contrato do cart&atilde;o inv&aacute;lido.");
}	

// Monta o xml de requisição
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

// Executa script para envio do XML
$xmlResult = getDataXML($xmlGetDadosCartao);

// Cria objeto para classe de tratamento de XML
$xmlObjNovoCartao = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjNovoCartao->roottag->tags[0]->name) == "ERRO") {
    exibeErro($xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
}

$dados = $xmlObjNovoCartao->roottag->tags[0]->tags[0]->tags;
$nrcrcard = getByTagName($dados,"NRCRCARD");
$nrctrcrd = getByTagName($dados,"NRCTRCRD");
$dscartao = getByTagName($dados,"DSCARTAO");
$nmextttl = getByTagName($dados,"NMEXTTTL");
$nmtitcrd = getByTagName($dados,"NMTITCRD");
$nmempcrd = getByTagName($dados,"nmempcrd");
$nrcpftit = getByTagName($dados,"NRCPFTIT");
$nmempttl = getByTagName($dados,"nmempttl");
$nrcnpjtl = getByTagName($dados,"nrcnpjtl");
$dsparent = getByTagName($dados,"DSPARENT");
$dssituac = getByTagName($dados,"DSSITUAC");
$vlsalari = getByTagName($dados,"VLSALARI");
$vlsalcon = getByTagName($dados,"VLSALCON");
$vloutras = getByTagName($dados,"VLOUTRAS");
$vlalugue = getByTagName($dados,"VLALUGUE");
$dddebito = getByTagName($dados,"DDDEBITO");
$vllimite = getByTagName($dados,"VLLIMITE");
$dtpropos = getByTagName($dados,"DTPROPOS");
$vllimdeb = getByTagName($dados,"VLLIMDEB");
$dtsolici = getByTagName($dados,"DTSOLICI");
$dtlibera = getByTagName($dados,"DTLIBERA");
$dtentreg = getByTagName($dados,"DTENTREG");
$dtcancel = getByTagName($dados,"DTCANCEL");
$dsmotivo = getByTagName($dados,"DSMOTIVO");
$dtvalida = getByTagName($dados,"DTVALIDA");
$qtanuida = getByTagName($dados,"QTANUIDA");
$nrctamae = getByTagName($dados,"NRCTAMAE");
$dsde2via = getByTagName($dados,"DSDE2VIA");
$dtanucrd = getByTagName($dados,"DTANUCRD");
$dspaganu = getByTagName($dados,"DSPAGANU");
$nmoperad = getByTagName($dados,"NMOPERAD");
$ds2viasn = getByTagName($dados,"DS2VIASN");
$ds2viacr = getByTagName($dados,"DS2VIACR");
$lbcanblq = getByTagName($dados,"LBCANBLQ");
$inpessoa = getByTagName($dados,"INPESSOA");
$inacetaa = getByTagName($dados,"inacetaa");
$dsacetaa = getByTagName($dados,"dsacetaa");
$dtacetaa = getByTagName($dados,"dtacetaa");
$cdopetaa = getByTagName($dados,"cdopetaa");
$nmopetaa = getByTagName($dados,"nmopetaa");
$cdadmcrd = getByTagName($dados,"cdadmcrd");
$flgdebit = ((getByTagName($dados,"flgdebit") == "no") ? "" : "checked");
$dtrejeit = getByTagName($dados,"dtrejeit");
$nrcctitg = getByTagName($dados,"nrcctitg");
$dsdpagto = getByTagName($dados,"dsdpagto");
$dsgraupr = getByTagName($dados,"dsgraupr");
$nrdoccrd = getByTagName($dados,"nrdoccrd");
$nmresadm = getByTagName($dados,"nmresadm");
        
if (getByTagName($dados,"DDDEBANT") == 0){
    $dddebant = "";
} else {
    $dddebant = getByTagName($dados,"DDDEBANT");
}

$desabilitaOpcoesDebito = "";
// DEBITO PF OU DEBITO PJ
if ($cdadmcrd == 16 || $cdadmcrd == 17) {
    $desabilitaOpcoesDebito = "disabled";
}



$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
$xml .= "   <cdadmcrd>".$cdadmcrd."</cdadmcrd>";
$xml .= " </Dados>";
$xml .= "</Root>";
$xmlResult = mensageria($xml, "ATENDA_CRD", "BUSCA_DADOS_CRD", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

$flgTitular = getByTagName($xmlObject->roottag->tags[0]->tags, "FLGTITULAR");

if ($flgTitular && empty($desabilitaOpcoesDebito)) {
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= " </Dados>";
    $xml .= "</Root>";
    $xmlResult = mensageria($xml, "ATENDA_CRD", "SUGESTAO_LIMITE_CRD", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    $contingenciaIbra = trim($objXml->Dados->sugestoes->sugestao->contingencia_ibra);
	$contingenciaMoto = trim($objXml->Dados->sugestoes->sugestao->contingencia_mot);

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
    $json_sugestoes = json_decode($xmlObj->roottag->tags[0]->tags[1]->tags[0]->tags[0]->cdata, true);
    $sugestoes = $json_sugestoes["indicadoresGeradosRegra"]["sugestaoCartaoCecred"];
    $idacionamento = $json_sugestoes['protocolo'];
    $valorSugerido = 0;
    foreach($sugestoes as $sugestao) {
        if ($sugestao["codigoCategoria"] == $cdadmcrd) {
            $valorSugerido = $sugestao["vlLimite"];
        }
    }
    if ($valorSugerido == 0) {
        echo "<script>globalesteira = true;</script>";
    }
    echo '<script>protocolo = "'.$idacionamento.'";</script>';

}
?>

<form action="" name="frmNovoCartao" id="frmNovoCartao" method="post" onSubmit="return false;">
    <div id="stepRequest" style=''>
        <!--start form -->
        <form action="" name="frmNovoCartao" id="frmNovoCartao" method="post" onSubmit="return false;">
		
            <div id="divDadosNovoCartao">
                <fieldset>
                    <legend><?php echo utf8ToHtml('Editar proposta de Cartão de Crédito') ?></legend>
                    <label for="dsadmcrd"><?php echo utf8ToHtml('Administradora:') ?></label>
                    <input name="dsadmcrd" id="dsadmcrd" value="<?php echo $nmresadm; ?>" onblur="" onchange="" class="campo" disabled>
                    <input type="hidden" name="cdadmcrd" id="cdadmcrd" value="<?php echo $cdadmcrd; ?>" onblur="" onchange="" class="campo">
					<input type="hidden" name="idacionamento" id="idacionamento" value="<?php echo $idacionamento; ?>" />

                    <div id="conteudoPJ">
                        <label for="nmprimtl"><?php echo utf8ToHtml('Razão Social:') ?></label>
                        <input type="text" name="nmprimtl" id="nmprimtl" class="campoTelaSemBorda" style="width: 400px;" value="<?echo $nmempttl; ?>" disabled readonly>
                        <br />
                        <label for="nrcpfcpf"><?php echo utf8ToHtml('CNPJ:') ?></label>
                        <input type="text" name="nrcpfcpf" id="nrcpfcpf" class="campoTelaSemBorda" value="<?echo formataNumericos("99.999.999/9999-99",$nrcnpjtl,"./-"); ?>" style="width: 120px;" disabled readonly>
                        <br />
                        <label for="dsrepinc"><?php echo utf8ToHtml('Representante:') ?></label>
                        <select name="dsrepinc" id="dsrepinc" class="campo" style="width: 325px;" onblur="" onchange="selecionaRepresentante();">
                        </select>
                        <br />
                    </div>
                    <div id="titularidade">
                        <label for="dsgraupr"><?php echo utf8ToHtml('Titularidade:') ?></label>
                        <select name="dsgraupr" id="dsgraupr" onChange="buscaDados('<?php echo $cdtipcta;?>','<?php echo formataNumericos("999.999.999-99",$nrcpfstl,".-");?>','<?php echo $inpessoa;?>','<?php echo $dtnasstl ;?>','<?php echo str_replace('\'','',$nrdocstl);?>','<?php echo str_replace('\'','',$nmconjug); ?>','<?php echo $dtnasccj ;?>','<?php echo str_replace('\'','',$nmtitcrd); ?>','<?php echo formataNumericos("999.999.999-99",$nrcpfcgc,".-");?>','<?php echo $dtnasctl;?>','<?php echo str_replace('\'','',$nrdocptl); ?>','<?php echo number_format(str_replace(",",".",$vlsalari),2,",","."); ?>','<?php echo str_replace('\'','',$nmsegntl);?>');" class="campo" style="width: 100px;">
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
                    <label for="nrcpfcgc"><?php echo utf8ToHtml('C.P.F.:') ?></label>
                    <input type="text" name="nrcpfcgc" id="nrcpfcgc" class="campo" value="" disabled/>
                    <div id="titular" style="margin-top:7px;">
                        <label for="nmextttl"><?php echo utf8ToHtml('Titular:') ?></label>
                        <input type="text" name="nmextttl" id="nmextttl" class="campo" title="Informar nome conforme Receita Federal" value="" />
                        <br />
                    </div>
                    <br style="clear:both;" />
                    <hr style="background-color:#666; height:1px; width:480px;" id="hr1"/>
                    <label for="nmtitcrd"><?php echo utf8ToHtml('Nome no Plástico:') ?></label>
                    <input type="text" name="nmtitcrd" id="nmtitcrd" class="campo" title="Nao permitido abreviar o primeiro e o ultimo nome" value="" />
                    <br />
                    <div id="empresa">
                        <label for="nmempres"><?php echo utf8ToHtml('Empresa do Plástico:') ?></label>
                        <input type="text" name="nmempres" id="nmempres" class="campo" value="<?php echo $nmempcrd; ?>" />
                    </div>
                    <hr style="background-color:#666; height:1px; width:480px;" id="hr2"/>
                    <br style="clear:both;" />
                    <label for="nrdoccrd"><?php echo utf8ToHtml('Identidade:') ?></label>
                    <input type="text" name="nrdoccrd" id="nrdoccrd" class="campo" />
                    <label for="dtnasccr"><?php echo utf8ToHtml('Nascimento:') ?></label>
                    <input type="text" name="dtnasccr" id="dtnasccr" class="campo" value="" disabled/>
                    <br />
                    <label for="dscartao"><?php echo utf8ToHtml('Tipo:') ?></label>
                    <select name="dscartao" id="dscartao" class="campo">
						<option value="NACIONAL">NACIONAL</option>
						<option value="INTERNACIONAL" selected="">INTERNACIONAL</option>
						<option value="GOLD">GOLD</option>
                    </select>
                    <label for="dddebito"><?php echo utf8ToHtml('Dia Débito:') ?></label>
                    <select <?=$desabilitaOpcoesDebito?> name="dddebito" id="dddebito" class="campo">
                        <? if(empty($dddebito)) { echo "<option value=''></option>"; } ?>
						<option value="03">03</option>
						<option value="07">07</option>
						<option value="11">11</option>
						<option value="19">19</option>
						<option value="22">22</option>
                    </select>
                    <br />
                    <label for="vlsalari"><?php echo utf8ToHtml('Salário:') ?></label>
                    <input type="text" name="vlsalari" id="vlsalari" class="campo" value="0,00" />
                    <label for="vlsalcon"><?php echo utf8ToHtml('Salário Cônjuge:') ?></label>
                    <input type="text" name="vlsalcon" id="vlsalcon" class="campo" value="0,00" />
                    <br />
                    <label for="vloutras"><?php echo utf8ToHtml('Outras Rendas:') ?></label>
                    <input type="text" name="vloutras" id="vloutras" class="campo" value="0,00" />
                    <label for="vlalugue"><?php echo utf8ToHtml('Aluguel:') ?></label>
                    <input type="text" name="vlalugue" id="vlalugue" class="campo" value="0,00" />
                    <br />
                    <label for="vllimpro"><?php echo utf8ToHtml('Limite Proposto:') ?></label>
                    <input <?=((!$flgTitular || $desabilitaOpcoesDebito) ? 'disabled' : '')?> onblur="validaLimite()" class='campo' id='vllimpro' name='vllimpro' value="<?php echo $vllimite; ?>">
                    <input type="hidden" id="vllimmot" value="<?=$valorSugerido?>" />

                    <label for="flgdebit"><?php echo utf8ToHtml('Habilita função débito:') ?></label>
                    <input type="checkbox" <?=$flgdebit?> name="flgdebit" id="flgdebit" class="campo" dtb="1" onclick='confirmaPurocredito();' disabled />
                    <br />
                    <label for="flgimpnp"><?php echo utf8ToHtml('Promissória:') ?></label>
                    <select name="flgimpnp" id="flgimpnp" class="campo">
                        <option value="yes" selected>Imprime</option>
                    </select>
                    <label for="vllimdeb"><?php echo utf8ToHtml('Limite Débito:') ?></label>
                    <input type="text" name="vllimdeb" id="vllimdeb" class="campo" disabled value="0,00" />
                    <br />
                    <label for="tpdpagto"><?php echo utf8ToHtml('Forma de Pagamento:') ?></label>
                    <select <?=$desabilitaOpcoesDebito?> class='campo' id='tpdpagto' name='tpdpagto'>
                        <option value='0' selected> </option>
                        <option value='2'>Debito CC Minimo</option>
                        <option value='1'selected>Debito CC Total</option>
                        <option value='3'>Boleto</option>
                    </select>
                    <label for="tpenvcrd"><?php echo utf8ToHtml('Envio:') ?></label>
                    <select class='campo' disabled id='tpenvcrd' name='tpenvcrd'>
                        <option <?php if ($pa_envia_cartao) { echo "selected"; } ?> value="0">Cooperado</option>
                        <option <?php if (!$pa_envia_cartao) { echo "selected"; } ?> value="1">Cooperativa</option>
                    </select>
                    <br />
                </fieldset>
                <div id="divBotoes" >
				
                    <input class="btnVoltar" id="backChoose" type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(0, 1, 4); return false;" />
                    <input class="" type="image" id="btnsaveRequest" src="<?php echo $UrlImagens; ?>botoes/prosseguir.gif" onclick="verificaEfetuaGravacao('C'); return false;" />

                
					<a style="display:none"  cdcooper="<?php echo $glbvars['cdcooper']; ?>" 
					cdagenci="<?php echo $glbvars['cdpactra']; ?>" 
					nrdcaixa="<?php echo $glbvars['nrdcaixa']; ?>" 
					idorigem="<?php echo $glbvars['idorigem']; ?>" 
					cdoperad="<?php echo $glbvars['cdoperad']; ?>"
					dsdircop="<?php echo $glbvars['dsdircop']; ?>"
					   href="#" class="botao" id="emiteTermoBTN" onclick="imprimirTermoDeAdesao(this);"> <?php echo utf8ToHtml("Imprimir Termo de Adesão");?></a>

                </div>
            </div>
            <div id="divDadosAvalistas" class="condensado">
                <?php
                // ALTERAÇÃO 001: Substituido formulário antigo pelo include				
                //include('../../../includes/avalistas/form_avalista.php');
                ?>
                <div id="divBotoes">
                    <!-- <input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="mostraDivDadosCartao();return false;">
					 <input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelar.gif" onClick="showConfirmacao('Deseja cancelar a proposta de novo cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Ayllos','voltaDiv(0,1,4)','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;">
					 <input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="validarAvalistas(4);return false;"> -->

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

    $("#divOpcoesDaOpcao1").css("display","block");
    $("#divConteudoCartoes").css("display","none");


    $('#btnProsseguir').hide();
    $('#btnsaveRequest').show();
    $('#backBtn').hide();
    $('#backChoose').show();

    $('#selectStep').hide();
    $('.selectStep').hide();
    $('#stepRequest').show();


    $(".di").attr("disabled",true);
    $(".di").css({opacity: 0.7});
    $("#vllimpro", "#divDadosNovoCartao").setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
    $("#dtnasccr", "#divDadosNovoCartao").setMask("DATE","","","divRotina");
    $("#nrcpfcgc", "#divDadosNovoCartao").setMask("INTEGER","999.999.999-99","","");

    // Popula os valores nos campos
    buscaDados('<?echo $cdtipcta;?>','<?echo formataNumericos("999.999.999-99",$nrcpfstl,".-");?>','<?echo $inpessoa;?>','<?echo $dtnasstl ;?>','<?echo str_replace('\'','',$nrdocstl);?>','<?echo str_replace('\'','',$nmconjug); ?>','<?echo $dtnasccj ;?>','<?echo str_replace('\'','',$nmtitcrd); ?>','<?echo formataNumericos("999.999.999-99",$nrcpfcgc,".-");?>','<?echo $dtnasctl;?>','<?echo str_replace('\'','',$nrdoccrd); ?>','<?echo number_format(str_replace(",",".",$vlsalari),2,",","."); ?>','<?echo str_replace('\'','',$nmsegntl);?>');
    carregaRepresentantes();

    validaLimite();
    hideMsgAguardo();
    bloqueiaFundo(divRotina);
</script>