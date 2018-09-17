<? 
/*!
 * FONTE        : busca_ratings.php
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Maio/2016 
 * OBJETIVO     : Busca os registros de rating
 * --------------
 * ALTERAÇÕES   : 
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
	$dtinirat = isset($_POST["dtinirat"]) ? $_POST["dtinirat"] : "";
	$dtfinrat = isset($_POST["dtfinrat"]) ? $_POST["dtfinrat"] : "";
	$tprelato = isset($_POST["tprelato"]) ? $_POST["tprelato"] : 0;
	$nrregist = isset($_POST["nrregist"]) ? $_POST["nrregist"] : 0;
	$nriniseq = isset($_POST["nriniseq"]) ? $_POST["nriniseq"] : 0;

	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <dtinirat>".$dtinirat."</dtinirat>";
	$xml .= "   <dtfinrat>".$dtfinrat."</dtfinrat>";
	$xml .= "   <cdagesel>".$cdagenci."</cdagesel>";
	$xml .= "   <tprelato>".$tprelato."</tprelato>";
	$xml .= "   <nrregist>".$nrregist."</nrregist>";
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_ATURAT", "BUSCARATINGS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
	
	$registros =  $xmlObj->roottag->tags[0]->tags;
	$nmarquiv  =  $xmlObj->roottag->attributes["NMARQUIV"];
	$qtregist  =  $xmlObj->roottag->tags[0]->attributes["QTREGIST"];

	if($cddopcao == "R" && $tprelato == 2){
			
		?>
		
			<script type="text/javascript">
			
				Gera_Impressao("<? echo $nmarquiv; ?>","controlaVoltar('3');");
				
			</script> 
		
		<?
	
	}else{

		if (count($registros) == 0) { 		
		
			exibirErro('inform','Nenhum Rating foi encontrado para estas condi&ccedil;&atilde;es.','Alerta - Ayllos','$(\'input,select\',\'#frmFiltro\').habilitaCampo();$(\'#nrdconta\',\'#frmFiltro\').focus();');		
		
		} else {      
		
			include('tab_registros.php'); 	

			?>
			<script type="text/javascript">

				$('#divTabela').css('display','block');
				$('#frmDetalhes').css('display','block');
				$('#divBotoes').css('display','none');			
				formataDetalhes();
				formataTabelaRatings();
				
			</script>

			<?

			if($cddopcao == "C"){

				?>
				<script type="text/javascript">

					$('#btConcluir', '#divBotoesRatings').css({ 'display': 'none' });
				
				</script>

				<?

			}elseif($cddopcao == "R" && $tprelato == 1){
				
				?>
				<script type="text/javascript">

					$('#btConcluir', '#divBotoesRatings').css({ 'display': 'none' });
					$('#btImprimir', '#divBotoesRatings').css({ 'display': 'inline' });
				
				</script>

				<?
			
			}
				
		}	
		
	}

	function validaDados(){
		
		
		IF(($GLOBALS["cddopcao"] == 'C' && $GLOBALS["nrdconta"] != 0) && $GLOBALS["cdagenci"] == 0 ){ 
			exibirErro('error','Ag&ecirc;ncia deve ser informada.','Alerta - Ayllos','$(\'input,select\',\'#frmFiltro\').habilitaCampo();focaCampoErro(\'cdagenci\',\'frmFiltro\');',false);
		}
			
						
	}	
		
?>
