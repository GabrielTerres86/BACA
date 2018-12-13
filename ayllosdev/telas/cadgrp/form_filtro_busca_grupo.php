<?php  
	/*********************************************************************
	 Fonte: form_filtro_busca_grupo.php.php                                                 
	 Autor: Jonata - Mouts
	 Data : Setembro/2018                 Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o de filtro para pesquisa da opção B - CADGRP                               
	                                                                  
	 Alterações: 
	 
	 
	
	**********************************************************************/
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
		
?>


<form name="frmFiltroBuscaGrupo" id="frmFiltroBuscaGrupo" class="formulario" >
		
	<fieldset id="fsetFiltroBuscaGrupo" name="fsetFiltroBuscaGrupo" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>

		<label for="nrdconta"><? echo utf8ToHtml('Conta:') ?></label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?echo getByTagName($registro->tags,'nrdconta');?>"/>
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		
		<br />
		
		<label for="nrcpfcgc"><?php echo utf8ToHtml("CPF/CNPJ:"); ?></label>
		<input type="text" id="nrcpfcgc" name="nrcpfcgc" >
		
		<br style="clear:both" />	
		
	</fieldset>

</form>	

<div id="divBotoesFiltroBuscaGrupo" style="margin-top:5px; margin-bottom :10px; text-align: center;">
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1');return false;" >Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="buscaGrupoCooperado();return false;">Prosseguir</a>	

</div>

<script type="text/javascript">

	formataFiltroBuscaGrupo();
	
</script>
	




