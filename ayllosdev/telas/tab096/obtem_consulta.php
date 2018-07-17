<?php
	/*************************************************************************
	  Fonte: obtem_consulta.php                                               
	  Autor: Lucas Reinert                                          
	  Data : Julho/2015                         Última Alteração: 07/03/2017
	                                                                   
	  Objetivo  : Carrega os dados da tela TAB096.              
	                                                                 
	  Alterações: 07/03/2017 - Busca do campo descprej. (P210.2 - Jaison/Daniel)
				  20/06/2018 - Adicionado tipo de produto desconto de título - Luis Fernando (GFT)
	***********************************************************************/

	session_start();
	
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	$cdcoopex = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0  ;	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 0  ;	
	$tpproduto = (isset($_POST['tpproduto'])) ? $_POST['tpproduto'] : 0;
		
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "   <cdcooper>".$cdcoopex."</cdcooper>";	
	$xml .= "   <tpproduto>".$tpproduto."</tpproduto>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
		
	$xmlResult = mensageria($xml, "TELA_TAB096", "TAB096_BUSCAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);					
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
	}
		
	$registros = $xmlObj->roottag->tags;		
	
	$nrconven = getByTagName($xmlObj->roottag->tags,'nrconven');
	$nrdconta = getByTagName($xmlObj->roottag->tags,'nrdconta');
	$pzmaxvct = getByTagName($xmlObj->roottag->tags,'pzmaxvct');
	$pzbxavct = getByTagName($xmlObj->roottag->tags,'pzbxavct');
	$vlrminpp = getByTagName($xmlObj->roottag->tags,'vlrminpp');
	$vlrmintr = getByTagName($xmlObj->roottag->tags,'vlrmintr');
	$descprej = getByTagName($xmlObj->roottag->tags,'descprej');
	$dslinha1 = getByTagName($xmlObj->roottag->tags,'dslinha1');
	$dslinha2 = getByTagName($xmlObj->roottag->tags,'dslinha2');
	$dslinha3 = getByTagName($xmlObj->roottag->tags,'dslinha3');
	$dslinha4 = getByTagName($xmlObj->roottag->tags,'dslinha4');
	$dstxtsms = getByTagName($xmlObj->roottag->tags,'dstxtsms');
	$dstxtema = getByTagName($xmlObj->roottag->tags,'dstxtema');
	$blqemibo = explode(';',getByTagName($xmlObj->roottag->tags,'blqemibo'));
	$qtmaxbol = getByTagName($xmlObj->roottag->tags,'qtmaxbol');
	$blqrsgcc = getByTagName($xmlObj->roottag->tags,'blqrsgcc');	
	$slnrconven = '<option value="0">'.utf8ToHtml('&lt;Conv&ecirc;nio de Cobran&ccedil;a&gt;').'</option>';	

	if ($cdcoopex != 0){
		// Montar o xml de Requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";	
		$xml .= "   <cdcooper>".$cdcoopex."</cdcooper>";	
		$xml .= " </Dados>";
		$xml .= "</Root>";
			
		$xmlResult = mensageria($xml, "EMPR0007", "BUSCA_CONV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);					
		
		if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
			exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
		}
			
		$registros = $xmlObj->roottag->tags;						
		
		foreach( $registros as $r ) {			
			if ($nrconven == getByTagName($r->tags,'nrconven')){				
				$slnrconven = $slnrconven . '<option value="'.getByTagName($r->tags,'nrconven').'" selected >'.getByTagName($r->tags,'nrconven').'</option>';
			}else
				$slnrconven = $slnrconven . '<option value="'.getByTagName($r->tags,'nrconven').'">'.getByTagName($r->tags,'nrconven').'</option>';		
		}
			
	}
	include('form_tab096.php');
?>

<script type="text/javascript">	
											
	$('#nrconven','#frmTab096').html('<? echo $slnrconven ?>');
	$('#nrdconta','#frmTab096').val('<? echo $nrdconta; ?>');
	$('#prazomax','#frmTab096').val('<? echo $pzmaxvct; ?>');
	$('#prazobxa','#frmTab096').val('<? echo $pzbxavct; ?>');
	$('#vlrminpp','#frmTab096').val('<? echo formataMoeda($vlrminpp); ?>');
	$('#vlrmintr','#frmTab096').val('<? echo formataMoeda($vlrmintr); ?>');			
	$('#descprej','#frmTab096').val('<? echo formataMoeda($descprej); ?>');
	$('#dslinha1','#frmTab096').val('<? echo $dslinha1; ?>');
	$('#dslinha2','#frmTab096').val('<? echo $dslinha2; ?>');
	$('#dslinha3','#frmTab096').val('<? echo $dslinha3; ?>');	
	$('#dslinha4','#frmTab096').val('<? echo $dslinha4; ?>');
	$('#dstxtsms','#frmTab096').val('<? echo $dstxtsms; ?>');
	$('#dstxtema','#frmTab096').val('<? echo $dstxtema; ?>');
	$('#blqemiss','#frmTab096').val('<? echo $blqemibo[0]; ?>');	
	$('#emissnpg','#frmTab096').val('<? echo $blqemibo[1]; ?>');		
	$('#qtdmaxbl','#frmTab096').val('<? echo $qtmaxbol; ?>');	
	$('#flgblqvl','#frmTab096').val('<? echo $blqrsgcc; ?>');	
		
</script>

