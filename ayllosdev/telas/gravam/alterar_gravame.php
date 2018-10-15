<?php
/*!
 * FONTE        : alterar_gravame.php                         Última alteração: 14/07/2016
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Maio/2016 
 * OBJETIVO     : Rotina para alterar informações do gravame
 * --------------
 * ALTERAÇÕES   :  14/07/2016 - Ajustar o nome RENAVAM (Andrei - RKAM).
 *                 24/08/2016 - Adicionada possibilidade de alterar a situação do gravame. Projeto 369 (Lombardi).
 */
?> 

<?php	
 
  session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
  
  $nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
  $nrctrpro = (isset($_POST["nrctrpro"])) ? $_POST["nrctrpro"] : 0;
  $dschassi = (isset($_POST["dschassi"])) ? $_POST["dschassi"] : '';
  $dscatbem = (isset($_POST["dscatbem"])) ? $_POST["dscatbem"] : '';
  $ufdplaca = (isset($_POST["ufdplaca"])) ? $_POST["ufdplaca"] : '';
  $nrdplaca = (isset($_POST["nrdplaca"])) ? $_POST["nrdplaca"] : '';
  $nrrenava = (isset($_POST["nrrenava"])) ? $_POST["nrrenava"] : 0;
  $nranobem = (isset($_POST["nranobem"])) ? $_POST["nranobem"] : 0;
  $nrmodbem = (isset($_POST["nrmodbem"])) ? $_POST["nrmodbem"] : 0;
  $tpctrpro = (isset($_POST["tpctrpro"])) ? $_POST["tpctrpro"] : 0;
  $idseqbem = (isset($_POST["idseqbem"])) ? $_POST["idseqbem"] : 0;
  $dssitgrv = (isset($_POST["dssitgrv"])) ? $_POST["dssitgrv"] : '';
  $dsmotivo = (isset($_POST["dsmotivo"])) ? $_POST["dsmotivo"] : '';

  validaDados();
  
  // Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
	$xml 	   .= "     <nrctrpro>".$nrctrpro."</nrctrpro>"; 
	$xml 	   .= "     <idseqbem>".$idseqbem."</idseqbem>";
	$xml 	   .= "     <dscatbem>".$dscatbem."</dscatbem>";
	$xml 	   .= "     <dschassi>".$dschassi."</dschassi>";
	$xml 	   .= "     <ufdplaca>".$ufdplaca."</ufdplaca>";
	$xml 	   .= "     <nrdplaca>".$nrdplaca."</nrdplaca>";
	$xml 	   .= "     <nrrenava>".$nrrenava."</nrrenava>";
	$xml 	   .= "     <nranobem>".$nranobem."</nranobem>";
	$xml 	   .= "     <nrmodbem>".$nrmodbem."</nrmodbem>";
	$xml 	   .= "     <tpctrpro>".$tpctrpro."</tpctrpro>";
	$xml 	   .= "     <cdsitgrv>".$dssitgrv."</cdsitgrv>";
	$xml 	   .= "     <dsaltsit>".$dsmotivo."</dsaltsit>";
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "GRVM0001", "ALTERARGRAVAM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "dschassi";
		}
    
		exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos','fechaRotina($(\'#divRotina\'));focaCampoErro(\''.$nmdcampo.'\',\'frmBens\');',false);		
					
	} 
		
  echo "showError('inform','Bem atualizado com sucesso.','Notifica&ccedil;&atilde;o - Ayllos','fechaRotina($(\'#divRotina\'));buscaBens(1, 30);');";	
	  
  
  function validaDados(){
			
		IF($GLOBALS["dschassi"] == '' ){ 
			exibirErro('error','O n&uacute;mero do chassi deve ser informado.','Alerta - Ayllos','focaCampoErro(\'dschassi\',\'frmBens\');',false);
		}
    
    IF($GLOBALS["ufdplaca"] == '' ){ 
			exibirErro('error','O UF da placa deve ser informado.','Alerta - Ayllos','focaCampoErro(\'ufdplaca\',\'frmBens\');',false);
		}
    
    IF($GLOBALS["nrdplaca"] == '' ){ 
			exibirErro('error','O n&uacute;mero da placa deve ser informado.','Alerta - Ayllos','focaCampoErro(\'nrdplaca\',\'frmBens\');',false);
		}
    
    IF($GLOBALS["nrrenava"] == 0 ){ 
			exibirErro('error','O n&uacute;mero do RENAVAM deve ser informado.','Alerta - Ayllos','focaCampoErro(\'nrrenava\',\'frmBens\');',false);
		}
				
	}	
  
 ?>
