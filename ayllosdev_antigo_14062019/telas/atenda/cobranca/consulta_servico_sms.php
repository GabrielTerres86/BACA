<?
/*************************************************************************
	Fonte: consulta_servico_sms.php
	Autor: Odirlei Busana - AMcom   		Ultima atualizacao: 18/10/2016
	Data : Outubro/2016
	
	Objetivo: Tela para visualizar a e alterar as informaçoes do 
              serviço de SMS de cobrança do cooperado.
	
	Alteracoes: 

*************************************************************************/

session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");	

$nrdconta    = $_POST["nrdconta"];
$idseqttl    = trim($_POST["idseqttl"]);
$inpessoa    = trim($_POST["inpessoa"]);
$cddopcao    = trim($_POST["cddopcao"]);
$nmemisms    = trim($_POST["nmemisms"]);
$tpnmemis    = trim($_POST["tpnmemis"]);
$idcontrato  = trim($_POST["idcontrato"]);
$flimpctr    = trim($_POST["flimpctr"]);
$idpacote    = trim($_POST["idpacote"]);
$dsiduser    = session_id();	
$nmdeacao    = '';


if ($cddopcao == 'A'  ||
    $cddopcao == 'CA' ||
    $cddopcao == 'AR' ||
    $cddopcao == 'IC') {

    //Ativar/Criar serviço de SMS de cobrança
    if ($cddopcao == 'A') {
        
        // Montar o xml de Requisicao
        $xml = new XmlMensageria();
        $xml->add('nrdconta',$nrdconta);  
        $xml->add('idseqttl',$idseqttl);  
        $xml->add('idpacote',$idpacote);

        $nmdeacao = 'GERA_CTR_SERV_SMS'; 
        
        $idcontrato   = getByTagName($xmlDados->tags,"idcontrato");
        
        if ($idcontrato != ""){
            exibeErroNew('inform','Contrato de servi&ccedil;o de SMS de numero '.$idcontrato.' criado com sucesso!');       
        }
      // Cancelamento  
    } else if ($cddopcao == 'CA') {
        
        // Montar o xml de Requisicao
        $xml = new XmlMensageria();
        $xml->add('nrdconta',$nrdconta);
        $xml->add('idseqttl',$idseqttl);
        $xml->add('idcontrato',$idcontrato);
        $nmdeacao = 'CANCEL_SERV_SMS';
        
        $idcontrato   = getByTagName($xmlDados->tags,"idcontrato");
        
        if ($idcontrato != ""){
            exibeErroNew('inform','Contrato de servi&ccedil;o de SMS cancelado com sucesso!');       
        }

    // Alteração do Remetente
    }else if ($cddopcao == 'AR') {
        
        // Montar o xml de Requisicao
        $xml = new XmlMensageria();
        $xml->add('nrdconta',$nrdconta);
        $xml->add('idcontrato'    ,$idcontrato);
        $xml->add('nmemissao_sms',$nmemisms);
        $xml->add('tpnome_emissao',$tpnmemis);       
        
        $nmdeacao = 'ATUALIZA_REMETENTE_SMS';
     
    }

    $xmlResult = mensageria($xml, "ATENDA", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);
    $xmlDados  = $xmlObject->roottag->tags[0];

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {

       $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObject->roottag->tags[0]->cdata;
        }

        exibeErroNew('error',$msgErro);
        exit();
    }
    
    /**** BUSCAR RETORNOS ****/
    //Ativar/Criar serviço de SMS de cobrança
    if ($cddopcao == 'A') {
        
        $idcontrato   = getByTagName($xmlDados->tags,"idcontrato");
        
        if ($idcontrato != ""){

            // Verificar se deve gerar impressao do contrato apos ativar o serviço
            if ($flimpctr == 0){
                exibeErroNew('inform','Contrato de servi&ccedil;o de SMS de numero '.$idcontrato.' criado com sucesso!');                       
            }else{
                exibeErroNew('inform','Contrato de servi&ccedil;o de SMS de numero '.$idcontrato.' criado com sucesso,imprima o contrato e solicite assinatura do cooperado.','imprimirServSMS(\'IA\');');
            }
        }
        
        
        
      // Cancelamento  
    } else if ($cddopcao == 'CA') {
        
        $idcontrato   = getByTagName($xmlDados->tags,"idcontrato");
        
        if ($idcontrato != ""){
            
            // Verificar se deve gerar impressao do contrato apos cancelamento do serviço
            if ($flimpctr == 0){
                exibeErroNew('inform','Contrato de servi&ccedil;o de SMS cancelado com sucesso!');       
            }else {            
                exibeErroNew('inform','Contrato de servi&ccedil;o de SMS cancelado com sucesso, imprima o termo de cancelamento e solicite assinatura do cooperado.','imprimirServSMS(\'IC\');');       
            }
        }
        
        

    // Alteração do Remetente
    }else if ($cddopcao == 'AR') {
        exibeErroNew('inform','Remetente alterado com sucesso!');       
    }
    
}


//********** CARREGAR DADOS DA TELA ********//
// Montar o xml de Requisicao
$xml = new XmlMensageria();
$xml->add('nrdconta',$nrdconta);


$xmlResult = mensageria($xml, "ATENDA", "RET_DADOS_SERV_SMS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);
$xmlDados  = $xmlObject->roottag->tags[0];

if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObject->roottag->tags[0]->cdata;
        }

        exibeErroNew('error',$msgErro);
        exit();
    }

$nmprintl   = getByTagName($xmlDados->tags,"nmprintl");
$nmfansia   = getByTagName($xmlDados->tags,"nmfansia");
$nmemisms   = getByTagName($xmlDados->tags,"nmemisms");
$tpnmemis   = getByTagName($xmlDados->tags,"tpnmemis");
$flgativo   = getByTagName($xmlDados->tags,"flgativo");
$dspacote   = getByTagName($xmlDados->tags,"dspacote");
$dhadesao   = getByTagName($xmlDados->tags,"dhadesao");
$idcontrato = getByTagName($xmlDados->tags,"idcontrato");
$vltarifa   = getByTagName($xmlDados->tags,"vltarifa");
$flsitsms   = getByTagName($xmlDados->tags,"flsitsms");
$dsalerta   = getByTagName($xmlDados->tags,"dsalerta");

$qtsmspct   = getByTagName($xmlDados->tags,"qtsmspct");
$qtsmsusd   = getByTagName($xmlDados->tags,"qtsmsusd");
$idpacote   = getByTagName($xmlDados->tags,"idpacote");

if ($flgativo == 1){
  $dssituac  = 'Ativo';    
}else{
  $dssituac  = 'Inativo';  
}

// Se retornou alerta ou serviço nao estiver ativo
if ($dsalerta != '' || $flsitsms == 0){
if ($dsalerta != ''){
    exibeErroNew('error',$dsalerta);    
    }
    $cddopcao  = 'CA';
}

// Se esta abrindo o modo de consulta e serviço esta inativo e OK, 
// será questionado se deseja ativa
if ($cddopcao== 'C' && $flgativo == 0 && $flsitsms == 1 ) {    
    echo '<script>hideMsgAguardo(); confirmarHabilitacaoSmsCobranca();</script>';
    exit();
}

function exibeErroNew($tpdmsg,$msgErro,$dsdacao) {
    
    echo '<script>';
    echo 'hideMsgAguardo();';
    echo 'showError("'.$tpdmsg.'","' . $msgErro . '","Alerta - Aimaro","desbloqueia();'. $dsdacao .'");';
    echo '</script>';
}

?>

<form name="frmServSMS" id="frmServSMS" method="post" onsubmit="return false;">	
	<input type="hidden" name="cddopcao"  id="cddopcao" value="<?php echo $cddopcao; ?>" />
    <input type="hidden" name="idseqttl"  id="idseqttl" value="<?php echo $idseqttl; ?>" />
    
    <fieldset>
		<legend>Nome do remetente que aparecer&aacute; no SMS</legend>
		<br>
        
        <input name="tpnommis" id="tpnommis_razao" type="radio" style='margin-left:30px' value="1" onclick= "habilitaOutro(false);" <?php if ($tpnmemis == 1){ ?> checked <?php } ?> >
        <label for="tpnommis_razao" title="Raz&atilde;o Social">Raz&atilde;o Social: </label>&nbsp;&nbsp;
        <input name="nmprimtl" id="nmprimtl" class="campo" value="<?php echo $nmprintl; ?>" disabled />
        <br style="clear:both" >
        
        <?php 
        // Não exibir opcao nome fantasia para pessoa fisica
        if ($inpessoa != 1){ 
        ?>
        
            <input name="tpnommis" id="tpnommis_fansia" type="radio" value="2" style='margin-left:30px' onclick= "habilitaOutro(false);" <?php if ($tpnmemis == 2){ ?> checked <?php } ?> >
            <label for="tpnommis_fansia" title="Nome Fantasia">Nome Fantasia: </label>    
            <input name="nmfansia" id="nmfansia" class="campo" value="<?php echo $nmfansia; ?>" disabled />        
            <br style="clear:both">
        
        <? } ?>
        
        <input name="tpnommis" id="tpnommis_outro" type="radio" value="2" style='margin-left:30px' onclick= "habilitaOutro(true);" <?php if ($tpnmemis == 3){ ?> checked <?php } ?> >
        <label for="tpnommis_outro" title="Outro nome para remetente">Outro: </label>    
        <input name="nmemisms" id="nmemisms" class="campo" value="<?php echo $nmemisms; ?>" />        
        <br style="clear:both">
        
        <div id="divBotoes">                
            <a href="#" class="botao" id="btnAltRemSMS"  style ='padding:3px 3px' onclick="confirmaAltReme(); return false;" > Alterar</a>
            <a href="#" class="botao" id="btVoltar"      style ='padding:3px 3px' onclick="acessaOpcaoAba(); return false;"  > Voltar </a>
        </div>
        
    </fieldset>
    
    <br style="clear:both">
    
    <fieldset>    
        <legend>Informa&ccedil;&otilde;es sobre servi&ccedil;o de SMS</legend>
        <br>
        
        <label for="dspacote">Descri&ccedil;&atilde;o:</label>
        <input name="dspacote" id="dspacote" class="campo" value="<?php echo $dspacote; ?>" />
        
        <label for="dhadesao">Contrata&ccedil;&atilde;o:</label>
        <input name="dhadesao" id="dhadesao" class="campo" value="<?php echo $dhadesao; ?>" />
        <br style="clear:both">
        
        <label for="vltarifa">Valor:</label>
        <input name="vltarifa" id="vltarifa" class="campo" value="<?php echo $vltarifa; ?>" />
        
        <label for="idcontrato">Contrato:</label>
        <input name="idcontrato" id="idcontrato" class="campo" value="<?php echo $idcontrato; ?>" />
        
        <label for="dssituac">Situa&ccedil;&atilde;o:</label>
        <input name="dssituac" id="dssituac" class="campo" value="<?php echo $dssituac; ?>" />
        <br style="clear:both">

        <? if ($idpacote > 2) { ?>

            <label class='rotulo' style='width:207px;' for="qtsmspct">SMSs contratados:</label>
            <input name="qtsmspct" id="qtsmspct" class="campo" style="width:65px;" value="<?php echo $qtsmspct; ?>" />

            <label class='rotulo-linha' style='width:79px;' for="qtsmsusd">Utilizados:</label>
            <input name="qtsmsusd" id="qtsmsusd" class="campo" style="width:71px;" value="<?php echo $qtsmsusd; ?>" />

        <? } ?>

    
	</fieldset>
</form>

<form id="frmImprimirSMS" name="frmImprimirSMS" action="<?php echo $UrlSite; ?>telas/atenda/cobranca/impressao_serv_sms.php" method="post">
    <input type="hidden" name="sidlogin"    id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>" />
    <input type="hidden" name="cddopcao"    id="cddopcao" />
    <input type="hidden" name="idcontrato"  id="idcontrato" />
    <input type="hidden" name="nrdconta"    id="nrdconta" />
</form>

<div id="divBotoes">    
    <a href="#" class="botao" id="btTrocarPacoteSMS" onclick="exibirHabilitacaoSmsCobranca();" >Trocar Pacote</a>
    <a href="#" class="botao" id="btCancelServSMS"  onclick="confirmaCancelServSMS(); return false;" > Cancelar Servi&ccedil;o</a>
    <a href="#" class="botao" id="btImpCtrSMS"      onclick="imprimirServSMS('IA'); return false;"   > Imprimir Contrato</a>
	<a href="#" class="botao" id="btVoltar"         onclick="acessaOpcaoAba(); return false;"        > Voltar</a>
</div>

<script type="text/javascript">
controlaLayout('frmServSMS');

$("#divConteudoOpcao").css("display","none");
$("#divOpcaoIncluiAltera").css("display","none");

$("#divServSMS").css("display","block");

blockBackground(parseInt($("#divRotina").css("z-index")));


</script>
