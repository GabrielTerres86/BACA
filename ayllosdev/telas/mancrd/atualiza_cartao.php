<?php
/* 
  FONTE        : atualiza_cartao.php
  CRIAÇÃO      : Kelvin Souza Ott
  DATA CRIAÇÃO : 29/06/2017
  OBJETIVO     : Rotina para controlar as operações da tela MANCRD
  --------------
  ALTERAÇÕES   : 27/10/2017 - Efetuar ajustes e melhorias na tela (Lucas Ranghetti #742880)
				 
				 25/07/2018 - Adicionado campo insitdec na tela. PRJ345(Lombardi).
         
         24/05/2019 - Validar atualizacaoo do cartao. Alcemir Jr. (PRB0041672).
  -------------- 
 */
?> 

<?php

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrcrcard = (isset($_POST['nrcrcard'])) ? $_POST['nrcrcard'] : 0;
$nrcctitg = (isset($_POST['nrcctitg'])) ? $_POST['nrcctitg'] : 0;
$cdadmcrd = (isset($_POST['cdadmcrd'])) ? $_POST['cdadmcrd'] : 0;
$nrcpftit = (isset($_POST['nrcpftit'])) ? $_POST['nrcpftit'] : 0;
$flgdebit = (isset($_POST['flgdebit'])) ? $_POST['flgdebit'] : 0;
$nmtitcrd = (isset($_POST['nmtitcrd'])) ? $_POST['nmtitcrd'] : "";
$insitcrd = (isset($_POST['insitcrd'])) ? $_POST['insitcrd'] : 0;
$flgprcrd = (isset($_POST['flgprcrd'])) ? $_POST['flgprcrd'] : 0;
$nrctrcrd = (isset($_POST['nrctrcrd'])) ? $_POST['nrctrcrd'] : 0;
$nmempres = (isset($_POST['nmempres'])) ? $_POST['nmempres'] : "";
$insitdec = (isset($_POST['insitdec'])) ? $_POST['insitdec'] : 0;
$flgvalid = (isset($_POST['flgvalid'])) ? $_POST['flgvalid'] : 0;


if($nrcctitg == ""){
	exibirErro('error', 'Campo Conta Cartao e de preenchimento obrigatorio!', 'Alerta - Ayllos', "bloqueiaFundo(divRotina);$('#nrcctitg','#frmDetalheCartao').focus();", false);   
	return;
}

if(empty($cdadmcrd)){
	exibirErro('error', 'Campo Administradora e de preenchimento obrigatorio!', 'Alerta - Ayllos', "bloqueiaFundo(divRotina);$('#dsadmcrd','#frmDetalheCartao').focus();", false);   
	return;
}

if(empty($nrcpftit)){
	exibirErro('error', 'Campo CPF  e de preenchimento obrigatorio!', 'Alerta - Ayllos', "bloqueiaFundo(divRotina);$('#nrcpftit','#frmDetalheCartao').focus();", false);   
	return;
}

if($nmtitcrd  == ""){
	exibirErro('error', 'Campo Nome  e de preenchimento obrigatorio!', 'Alerta - Ayllos', "bloqueiaFundo(divRotina);$('#nmtitcrd','#frmDetalheCartao').focus();", false);   
	return;
}

if(strlen($nmtitcrd) > 23) {
	exibirErro('error', 'Nome no Plastico nao pode ter mais de 23 letras.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina);$('#nmtitcrd','#frmDetalheCartao').focus();", false);   
	return;
}
	
if(strlen($nmempres) > 23 && $nrcrcard == 0) {
	exibirErro('error', 'Empresa do Plastico nao pode ter mais de 23 letras.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina);$('#nmempres','#frmDetalheCartao').focus();", false);   
	return;
}	

	if ($flgvalid == 1) { 
		// validar atualização do cartão
		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
		$xml .= "   <nrcrcard>" . $nrcrcard . "</nrcrcard>";
		$xml .= "   <nrcctitg>" . $nrcctitg . "</nrcctitg>";
		$xml .= "   <nrcpftit>" . $nrcpftit . "</nrcpftit>";	
		$xml .= "   <cdadmcrd>" . $cdadmcrd . "</cdadmcrd>";	
		$xml .= "   <nrctrcrd>" . $nrctrcrd . "</nrctrcrd>";
		$xml .= "   <flgprcrd>" . $flgprcrd . "</flgprcrd>";	
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "TELA_MANCRD", "PC_VALIDA_ATUALIZA_CARTOES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
	    
		if (strtoupper($xmlObj->roottag->tags[0]->tags[0]->name) == "MSG") {
		   
		   if (strtoupper($xmlObj->roottag->tags[0]->tags[0]->cdata) != "") {
		        $msgConfirmacao = $xmlObj->roottag->tags[0]->tags[0]->cdata;
			
			    echo "showConfirmacao('".$msgConfirmacao."',
				    				  'Confirma&ccedil;&atilde;o - Aimaro',
								      'confirmaAtualizaCartao(0);',
									  'hideMsgAguardo();','sim.gif','nao.gif');";
                exit();											  
	        } 
		}else{

			if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			    if ($msgErro == "") {
			       $msgErro = $xmlObj->roottag->tags[0]->cdata;
				}
		
				exibirErro('error', $msgErro, 'Alerta - Ayllos', "", false);  		
				return false;
			}	
	        // se chegou aqui é pq não deu erro
	        $flgvalid = 0; 
		}

	}
  
  
	if ($flgvalid == 0) {
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
    $xml .= "   <nrcrcard>" . $nrcrcard . "</nrcrcard>";
    $xml .= "   <nrcctitg>" . $nrcctitg . "</nrcctitg>";
    $xml .= "   <cdadmcrd>" . $cdadmcrd . "</cdadmcrd>";
    $xml .= "   <nrcpftit>" . $nrcpftit . "</nrcpftit>";
    $xml .= "   <flgdebit>" . $flgdebit . "</flgdebit>";
    $xml .= "   <nmtitcrd>" . $nmtitcrd . "</nmtitcrd>";
    $xml .= "   <insitcrd>" . $insitcrd . "</insitcrd>";
    $xml .= "   <insitdec>" . $insitdec . "</insitdec>";
    $xml .= "   <flgprcrd>" . $flgprcrd . "</flgprcrd>";
    $xml .= "   <nrctrcrd>" . $nrctrcrd . "</nrctrcrd>";
    $xml .= "   <nmempres>" . $nmempres . "</nmempres>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_MANCRD", "PC_ATUALIZA_CARTAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }
        exibirErro('error', $msgErro, 'Alerta - Ayllos', "", false);    
    } 
    else{
	    exibirErro('inform', 'Cartao atualizado com sucesso.', 'Alerta - Ayllos', "fechaRotina($('#divRotina'));buscaCartoes();", false);
    }
    
  }

?>