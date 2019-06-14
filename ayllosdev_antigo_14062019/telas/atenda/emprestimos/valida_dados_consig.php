<?php
/* **********************************************************************

  Fonte: valida_dados_consig.php
  Autor: JDB - AMcom
  Data : Mar 2018                      Última Alteração:

  Objetivo  : Validar dados cadastrais para geração de emprestimo (somente para o consignado)

  Alterações: 
  

 ********************************************************************** */

 session_start();
 require_once('../../../includes/config.php');
 require_once('../../../includes/funcoes.php');
 require_once('../../../includes/controla_secao.php');		
 require_once('../../../class/xmlfile.php');
 isPostMethod();
 
 $nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;
 $cdlcremp = (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : '' ;
 
 //Valida dados
 $xml  = '';
 $xml .= '<Root>';
 $xml .= '	<Dados>';
 $xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
 $xml .= '       <cdlcremp>30</cdlcremp>';
 $xml .= '	</Dados>';
 $xml .= '</Root>';

 $xmlResult = mensageria(
	$xml,
	"TELA_ATENDA_EMPRESTIMO",
	"VALIDAR_INF_CADASTRAIS",
	$glbvars["cdcooper"],
	$glbvars["cdagenci"],
	$glbvars["nrdcaixa"],
	$glbvars["idorigem"],
	$glbvars["cdoperad"],
	"</Root>");

 $xmlObj = getObjectXML($xmlResult);
 
if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
	echo 'var aux = false;';
	exibirErro(
		"error",
		$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,
		"Alerta - Ayllos",
		"",
		false);
	
	
} //erro

 
 $ret = ( isset($xmlObj->roottag->tags[0]->tags[0]->tags) ) ? $xmlObj->roottag->tags : array(); 
 $total = ( isset($xmlObj->roottag->tags[0]->attributes["QTREGIST"]) ) ? $xmlObj->roottag->tags[0]->attributes["QTREGIST"] : 0;			
 //$total = 1;
 //die($xmlResult);
 if ($total > 0 ) {
	 echo 'var strHTML = \'<table class="tituloRegistros" id="tblErrosConsig" cellpadding="1" cellspacing="1"><thead><tr id="trCabecalho" name="trCabecalho"><th class="header" id="tdTitLinha"><strong>Ln</strong></td><th class="header" id="tdMensagem"><strong>Mensagem</strong></td><th class="header" id="tdTipo"><strong>Tipo</strong></td></tr> \';'; 
	 for($i=0; $i<$total; $i++){									
		$linha = $i+1;
		if ($linha % 2 == 0){					
			$classLinha = 'class= "odd corPar"';
		}else{
			$classLinha = 'class= "even corImpar"';
		}
		//$msg = 'msg erro';
		//$tipo = '1';
		$msg = getByTagName($ret[0]->tags[$i]->tags,'dscritic');
		$tipo = getByTagName($ret[0]->tags[$i]->tags,'tpcritic');
		//cdcritic		
		$idLinha = "trLinha$i";
		echo 'strHTML += \'<tr '.$classLinha.' id="'.$idLinha.'"> \';'; 
		echo 'strHTML += \'<td align="center">'.$linha.'</td> \';'; 
		echo 'strHTML += \'<td align="center" >'.$msg.'</td> \';'; 
		if ($tipo == 1){
			echo 'strHTML += \'<td align="center" ><img src="'.$UrlImagens.'geral/servico_nao_ativo.gif" alt="Erro" title="Erro"></td> \';'; 		
		}else{
			echo 'strHTML += \'<td align="center" ><img src="'.$UrlImagens.'geral/ico_atencao.gif" alt="Erro" title="Erro"></td> \';'; 						
		}
		echo 'strHTML += \'</tr> \';';
	 }
	 echo 'strHTML += \'</table>  \';'; 
	 
	 // Coloca conteúdo HTML no div
	 echo '$("#divListaMsgsAlerta").html(strHTML);';
	 // Mostra div 
	 echo '$("#divMsgsAlerta").css("visibility","visible");';
	 // Esconde mensagem de aguardo
	 echo 'hideMsgAguardo();';	
	 // Bloqueia conteúdo que está átras do div de mensagens
	 echo 'blockBackground(parseInt($("#divMsgsAlerta").css("z-index")));';	 
	 echo 'var aux = false;';
	 
 }
 else{
	  echo 'var aux = true;';
 }
 
?>