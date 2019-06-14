<?php
	/*!
	 * FONTE        : busca_agendamentos.php							Última alteração: 25/04/2016
	 * CRIAÇÃO      : Jonathan
	 * DATA CRIAÇÃO : 17/11/2015
	 * OBJETIVO     : Rotina para buscar os agendamentos 
	 * --------------
	 * ALTERAÇÕES   : 25/04/2016 - Ajuste para atender as solicitações do projeto M 117
                                  (Adriano - M117).
                    
	 * -------------- 
	 
	 29/06/2016 - m117 Ajuste para incluir cdtiptra na busca (Carlos)
	 
	 */		

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$nrdconta = isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : 0;
	$cdagenci = isset($_POST["cdagenci"]) ? $_POST["cdagenci"] : 0;
	$insitlau = isset($_POST["insitlau"]) ? $_POST["insitlau"] : 0;
	$cdtiptra = isset($_POST["cdtiptra"]) ? $_POST["cdtiptra"] : 0;
	$dtiniper = isset($_POST["dtiniper"]) ? $_POST["dtiniper"] : "";
	$dtfimper = isset($_POST["dtfimper"]) ? $_POST["dtfimper"] : "";
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
	$tipsaida = isset($_POST["tipsaida"]) ? $_POST["tipsaida"] : "";
	$nmarquiv = isset($_POST["nmarquiv"]) ? $_POST["nmarquiv"] : "";

	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <dtiniper>".$dtiniper."</dtiniper>";
	$xml .= "   <dtfimper>".$dtfimper."</dtfimper>";
	$xml .= "   <cdagesel>".$cdagenci."</cdagesel>";
	$xml .= "   <insitlau>".$insitlau."</insitlau>";
	$xml .= "   <cdtiptra>".$cdtiptra."</cdtiptra>";
	
	if($cddopcao == 'I'){
		
		$xml .= "   <nrregist>99999</nrregist>";	
		
	}else{
		
		$xml .= "   <nrregist>".$nrregist."</nrregist>";	
		
	}	
	
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";	
	$xml .= "   <tipsaida>".$tipsaida."</tipsaida>";	
	$xml .= "   <nmarquiv>".$nmarquiv."</nmarquiv>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_AGENET", "BUSCA_AGENDAMENTOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrdconta";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input,select\',\'#frmFiltro\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmFiltro\');',false);		
		
	} 
	
	$registros =  $xmlObj->roottag->tags;
	$qtregist  =  $xmlObj->roottag->attributes["QTREGIST"];
	$vllanaut  =  $xmlObj->roottag->attributes["VLLANAUT"];
	$nmarquiv  =  $xmlObj->roottag->attributes["NMARQUIV"];
	
	if($cddopcao == 'I'){
		
		if($tipsaida == '0'){
			exibirErro('inform','Arquivo gerado com sucesso.','Alerta - Ayllos','controlaVoltar();');		
		
		}else{?>
		
			<script type="text/javascript">
			
				Gera_Impressao("<? echo $nmarquiv; ?>","controlaVoltar();");
				
			</script> 
		
		<?}
		
	}else{
		
		if ($qtregist == 0) { 		
		
			exibirErro('inform','Nenhum registro foi encontrado.','Alerta - Ayllos','formataFormularioFiltro();$(\'#nrdconta\',\'#frmFiltro\').focus();');		
		
		} else {      
		
			include('tab_registros.php'); 	

			?>
			<script type="text/javascript">

				$('#divTabela').css('display','block');
				$('#frmAgendamentos').css('display','block');
				$('#btConcluir','#divBotoes').css('display','none');
				formataTabelaAgendamentos();
				
			</script>

			<?	
		}	
		
	}
	
	
	function validaDados(){
		
		//Nome do arquivo
		if ( $GLOBALS["cddopcao"] == 'I'){
			
			IF($GLOBALS["nmarquiv"] == '' ){ 
			   exibirErro('error','Nome do arquivo deve ser informado.','Alerta - Ayllos','$(\'input,select\',\'#frmFiltro\').habilitaCampo();focaCampoErro(\'nmarquiv\',\'frmFiltro\');',false);
			}
			
			IF($GLOBALS["tipsaida"] == "" ){ 
			   exibirErro('error','Tipo de sa&iacute;da deve ser informado.','Alerta - Ayllos','$(\'input,select\',\'#frmFiltro\').habilitaCampo();focaCampoErro(\'tipsaida\',\'frmFiltro\');',false);
			}
			
		}
				
	}	
		
?>
