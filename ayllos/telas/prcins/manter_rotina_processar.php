<?php
	/*!
	 * FONTE        : manter_rotina_processar.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 05/10/2015
	 * OBJETIVO     : Rotina para processar o arquivo INSS
	 * --------------
	 * ALTERAÇÕES   :  29/02/2016 - Ajuste para enviar o parâmetro nmdatela pois não está sendo
					                possível gerar o relatório. A rotina do oracle está tentando
								    encontrar o registro crapprg com base no parâmetro cdprogra 
								    e não o encontra, pois ele é gravado com o nome da tela.
								    (Adriano - SD 409943)
	 * ALTERAÇÕES   : 14/06/2016 - No format dos valores, substituir str_replace(',','' por str_replace(',','.' (Lucas Ranghetti #462560)
	 * -------------- 
	 */		

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"P")) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$nmdarqui = isset($_POST["nmdarqui"]) ? $_POST["nmdarqui"] : "";

	if ( $nmdarqui == "" ) {
		exibirErro('error','Arquivo n&atilde;o informado.','Alerta - Ayllos','',false);
	}

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nmarquiv>".$nmdarqui."</nmarquiv>";
	$xml .= "   <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PRCINS", "PROCESSA_PLANILHA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nmdarqui";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input\',\'#frmProcessar\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmProcessar\');',false);		
		
	} 
	
	$qtplanil = number_format(str_replace(',','',getByTagName($xmlObj->roottag->tags[0]->tags,'qtplanil')),0,',','.');
	$vltotpla = number_format(str_replace(',','.',getByTagName($xmlObj->roottag->tags[0]->tags,'vltotpla')),2,',','.');
	$qtproces = number_format(str_replace(',','',getByTagName($xmlObj->roottag->tags[0]->tags,'qtproces')),0,',','.');
	$qtderros = number_format(str_replace(',','',getByTagName($xmlObj->roottag->tags[0]->tags,'qtderros')),0,',','.');
	$vlderros = number_format(str_replace(',','.',getByTagName($xmlObj->roottag->tags[0]->tags,'vlderros')),2,',','.');
	$vltotpro = number_format(str_replace(',','.',getByTagName($xmlObj->roottag->tags[0]->tags,'vltotpro')),2,',','.');
	$nmarqerr = getByTagName($xmlObj->roottag->tags[0]->tags,'nmarqerr');
	
	$command = "exibirResumoProcesso('" . $qtplanil . 
	                              "','" . $vltotpla . 
	                              "','" . $qtproces . 
								  "','" . $qtderros . 
								  "','" . $vlderros . 
								  "','" . $vltotpro . "');";
								  
	$command .= "$('#fsetFiltroProcessarResumo','#frmProcessar').css({'display':'block'});$('#fsetFiltroProcessarDivergencia','#frmProcessar').css({'display':'block'});";							 
	$command .= "$('#fsetFiltroProcessarObs','#frmProcessar').css({'display':'none'}); $('#btConcluir','#divBotoes').css({'display':'none'});";	

	// Buscar todas as cooperativas que ocorreram erro
	// array_filter para remover as posições que não possuem valor, caso o valor tenha sido retornado vazio
	$aCooperativas = array_filter(explode(",",$nmarqerr));

	echo "strHTML  = '<div class=\"divRegistros\">';";
	echo "strHTML += '  <table>';";
	echo "strHTML += '     <thead>';";
	echo "strHTML += '       <tr>';";
	echo "strHTML += '          <th>Cooperativas que cont&ecirc;m rejeitados</th>';";
	echo "strHTML += '	   </tr>';";
	echo "strHTML += '     </thead>';";
	echo "strHTML += '     <tbody>';";		
		
	foreach($aCooperativas as $coop){
		/* Converter os campos de valores */ 			
		echo "strHTML += '<tr>';";	
		echo "strHTML += '   <td><span>".$coop."</span>".$coop."</td>';";
		echo "strHTML += '</tr>';";
	}
	
	echo "strHTML += '    </tbody>';";
	echo "strHTML += '  </table>';";
	echo "strHTML += '</div>';";
	echo "strHTML += '<div id=\"divRegistrosRodape\" class=\"divRegistrosRodape\">';";
	echo "strHTML += '   <table>';";	
	echo "strHTML += '     <tr>';";
	echo "strHTML += '        <td></td>';";
	echo "strHTML += '	      <td>	       Cooperativas com erro: ".count($aCooperativas)."</td>';";
	echo "strHTML += '        <td></td>';";
	echo "strHTML += '     </tr>';";
	echo "strHTML += '   </table>';";
	echo "strHTML += '</div>';";
	
	echo "$('#divResumoErros','#frmProcessar').html(strHTML);";
	echo "formataTabelaCooperativaErros();";
	
	$command .= "$('#lbArquivoErros','#divResumoProcesso').css({'display':'block'});";
	$command .= "$('#divResumoErros','#frmProcessar').css('display','block');"; 
	$command .= "$('#fsetFiltroProcessarResumo','#frmProcessar').css('display','block');";
	$command .= "$('#btConcluir','#divBotoes').css({'display':'none'});";


	exibirErro('inform','Planilha processada com sucesso.','Alerta - Ayllos',$command,false);
?>