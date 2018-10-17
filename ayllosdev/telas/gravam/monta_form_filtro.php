<? 
/*!
 * FONTE        : monta_form_filtro.php
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Maio/2016 
 * OBJETIVO     : Monta o form de filtro correspondente a opção selecionada
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
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	if($cddopcao == "G" ||
	   $cddopcao == "I" ||
	   $cddopcao == "R" ||
	   $cddopcao == "P"){
		   
		// Monta o xml de requisição		
		$xml  		= "";
		$xml 	   .= "<Root>";
		$xml 	   .= "  <Dados>";
		$xml 	   .= "     <flcecred>1</flcecred>";
		$xml 	   .= "     <flgtodas>1</flgtodas>";
		$xml 	   .= "  </Dados>";
		$xml 	   .= "</Root>";
		
		// Executa script para envio do XML	
		$xmlResult = mensageria($xml, "TELA_GRAVAM", "BUSCACOOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',$msgErro,'Alerta - Aimaro','estadoInicial();',false);		
						
		} 
			
		$cooperativas = $xmlObj->roottag->tags[0]->tags;
	  
		foreach ( $cooperativas as $coop ) {
		  
		   $nmrescop .= '<option value="'.getByTagName($coop->tags,'cdcooper').'">'.getByTagName($coop->tags,'nmrescop').'</option> ';
		
		}
	
	}	
	  
	if($cddopcao == "G" || $cddopcao == "R"){
			
		include('form_filtro_arquivo.php'); 
		
		?>
		<script type="text/javascript">

			formataFiltroArquivo();
			$('#cdcooper','#divFiltroArq').html('');
		    $('#cdcooper','#divFiltroArq').append('<?php echo $nmrescop;?>');			
			
		</script>

		<?
	
	}else if($cddopcao == "I"){
		
		include('form_filtro_impressao.php'); 
		
		?>
		<script type="text/javascript">
			
			formataFiltroImpressao();
			$('#cdcooper','#divFiltroImpressao').html('');
		    $('#cdcooper','#divFiltroImpressao').append('<?php echo $nmrescop;?>');	
			
		</script>

		<?
		
	}else if($cddopcao == "P"){
		include('form_filtro_parametros.php');
		?>
		<script type="text/javscript">
			$(document).ready(function(){
				console.log('nmdatela: <?php echo $glbvars['nmdatela'];?>, nmrotina: <?php echo $glbvars['nmrotina'];?>, cddopcao: <?php echo $cddopcao;?>' );
			});
		</script>
		<?
	}else{
		
		include('form_filtro.php'); 
		
		?>
		<script type="text/javascript">
			
			formataFiltro();
			
		</script>

		<?
		
	}
		
?>
