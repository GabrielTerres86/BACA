<?php  
	/*********************************************************************
	 Fonte: form_filtro.php                                                 
	 Autor: Jonata - Mouts
	 Data : Setembro/2018                 Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o de filtro para pesquisa da opção M - PESSOA
	                                                                  
	 Alterações: 
	 
	 
	
	**********************************************************************/
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
		
?>


<form name="frmFiltro" id="frmFiltro" class="formulario" >
		
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>

		<label for="nrdconta"><? echo utf8ToHtml('Conta:') ?></label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?echo getByTagName($registro->tags,'nrdconta');?>"/>
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
				
		<br style="clear:both" />	
		
	</fieldset>

</form>	

<div id="divBotoesFiltro" style="margin-top:5px; margin-bottom :10px; text-align: center;">
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1');return false;" >Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="buscarCooperado('1','30');return false;">Prosseguir</a>	

</div>

<script type="text/javascript">

	formataFiltro();
	
</script>
	




