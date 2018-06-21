<?php
	/*************************************************************************
	  Fonte: grava_dados.php                                               
	  Autor: Lucas Reinert
	  Data : Julho/2015                       �ltima Altera��o: 07/03/2017
	                                                                   
	  Objetivo  : Grava parametros na crapprm.
	                                                                 
	  Altera��es: 07/03/2017 - Gravacao do campo descprej. (P210.2 - Jaison/Daniel)
	                                                                  
	***********************************************************************/

	session_start();
	
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$tpproduto = (isset($_POST['tpproduto'])) ? $_POST['tpproduto'] : 0;
	$nrconven = (isset($_POST['nrconven'])) ? $_POST['nrconven'] : ''  ;	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : ''  ;	
	$prazomax = (isset($_POST['prazomax'])) ? $_POST['prazomax'] : ''  ;	
	$prazobxa = (isset($_POST['prazobxa'])) ? $_POST['prazobxa'] : ''  ;	
	$vlrminpp = (isset($_POST['vlrminpp'])) ? $_POST['vlrminpp'] : ''  ;	
	$vlrmintr = (isset($_POST['vlrmintr'])) ? $_POST['vlrmintr'] : ''  ;	
	$descprej = (isset($_POST['descprej'])) ? $_POST['descprej'] : ''  ;
	$dslinha1 = (isset($_POST['dslinha1'])) ? $_POST['dslinha1'] : ''  ;	
	$dslinha2 = (isset($_POST['dslinha2'])) ? $_POST['dslinha2'] : ''  ;	
	$dslinha3 = (isset($_POST['dslinha3'])) ? $_POST['dslinha3'] : ''  ;	
	$dslinha4 = (isset($_POST['dslinha4'])) ? $_POST['dslinha4'] : ''  ;	
	$dstxtsms = (isset($_POST['dstxtsms'])) ? $_POST['dstxtsms'] : ''  ;	
	$dstxtema = (isset($_POST['dstxtema'])) ? $_POST['dstxtema'] : ''  ;		
	$blqemiss = (isset($_POST['blqemiss'])) ? $_POST['blqemiss'] : ''  ;	
	$qtdmaxbl = (isset($_POST['qtdmaxbl'])) ? $_POST['qtdmaxbl'] : ''  ;	
	$flgblqvl = (isset($_POST['flgblqvl'])) ? $_POST['flgblqvl'] : ''  ;	
	
	$cdcoopex = (isset($_POST['cdcoopex'])) ? $_POST['cdcoopex'] : 0  ;	
		
	// Montar o xml de Requisicao
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Dados>";	
	$xmlCarregaDados .= "   <cdcooper>".$cdcoopex."</cdcooper>";	
	$xmlCarregaDados .= "   <nrconven>".$nrconven."</nrconven>";	
	$xmlCarregaDados .= "   <nrdconta>".$nrdconta."</nrdconta>";	
	$xmlCarregaDados .= "   <prazomax>".$prazomax."</prazomax>";	
	$xmlCarregaDados .= "   <prazobxa>".$prazobxa."</prazobxa>";	
	$xmlCarregaDados .= "   <vlrminpp>".$vlrminpp."</vlrminpp>";	
	$xmlCarregaDados .= "   <vlrmintr>".$vlrmintr."</vlrmintr>";	
	$xmlCarregaDados .= "   <descprej>".$descprej."</descprej>";
	$xmlCarregaDados .= "   <dslinha1>".$dslinha1."</dslinha1>";	
	$xmlCarregaDados .= "   <dslinha2>".$dslinha2."</dslinha2>";	
	$xmlCarregaDados .= "   <dslinha3>".$dslinha3."</dslinha3>";	
	$xmlCarregaDados .= "   <dslinha4>".$dslinha4."</dslinha4>";	
	$xmlCarregaDados .= "   <dstxtsms>".$dstxtsms."</dstxtsms>";	
	$xmlCarregaDados .= "   <dstxtema>".$dstxtema."</dstxtema>";	
	$xmlCarregaDados .= "   <blqemiss>".$blqemiss."</blqemiss>";	
	$xmlCarregaDados .= "   <qtdmaxbl>".$qtdmaxbl."</qtdmaxbl>";	
	$xmlCarregaDados .= "   <flgblqvl>".$flgblqvl."</flgblqvl>";	
	$xmlCarregaDados .= "   <tpproduto>".$tpproduto."</tpproduto>";	
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";
		
	$xmlResult = mensageria($xmlCarregaDados, "TELA_TAB096", "TAB096_GRAVAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);					
	
	echo 'hideMsgAguardo();';
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
	}
				
    echo "showError('inform','Parametros alterados com sucesso!','Tab096','voltaDiv();estadoInicial();');";
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		exit();
	}
?>
