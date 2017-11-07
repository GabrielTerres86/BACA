<?php
/*****************************************************************
  Fonte        : form_filtro.php						Última Alteração:  
  Criação      : Jonata - RKAM
  Data criação : Agosto/2017
  Objetivo     : Mostrar os filtros para da tela SOLG030 - Opção "G"
  --------------
	Alterações   :  
	
	
 ****************************************************************/ 
	
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

        exibirErro('error',$msgError,'Alerta - Ayllos','');
    }
		
	
?>

<form id="frmFiltro" name="frmFiltro" class="formulario" style="display:none;">	
	
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend><? echo "Filtros"; ?></legend>
		
		<label for="flctadst"><? echo utf8ToHtml('Possui conta destino:') ?></label>
		<select id="flctadst" name="flctadst">
			<option value="1">Sim</option> 			
			<option value="2">Todos</option> 			
		</select>	
		
		<br style="clear:both" />	

	</fieldset>
							
</form>

<div id="divBotoesFiltro" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1');">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="buscarContasRateioTedCapital('1','30');return false;">Prosseguir</a>	
				
</div>

<script type="text/javascript">

	formataFormFiltro();

</script>

