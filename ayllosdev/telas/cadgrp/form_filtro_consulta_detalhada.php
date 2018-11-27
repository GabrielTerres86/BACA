<?php  
	/*********************************************************************
	 Fonte: form_filtro_consulta_detalhada.php.php                                                 
	 Autor: Jonata - Mouts
	 Data : Setembro/2018                 Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o de filtro para pesquisa da opção C - CADGRP                                 
	                                                                  
	 Alterações: 	 
	
	**********************************************************************/
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
		
?>


<form name="frmFiltroConsultaDetalhada" id="frmFiltroConsultaDetalhada" class="formulario" >
		
	<fieldset id="fsetFiltro" name="fsetFiltro" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>

		<label for="cdagenci"><?php echo utf8ToHtml("PA:"); ?></label>
		<input type="text" id="cdagenci" name="cdagenci" />
        <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		
		<br />
		
		<label for="nrdgrupo"><?php echo utf8ToHtml("Grupo:"); ?></label>
		<input type="text" id="nrdgrupo" name="nrdgrupo" value="<?php echo $dtfim_grupo;?>" >
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
		
		<br style="clear:both" />

		<label for="qtdRetorno">Qtd. por pag.:</label>
		<select name="qtdRetorno" id="qtdRetorno">
			<option value="15" >15</option>
			<option value="30" selected>30</option>
			<option value="60" >60</option>
			<option value="100" >100</option>
		</select>
		
	</fieldset>

</form>	

<div id="divBotoesFiltroConsultaDetalhda" style="margin-top:5px; margin-bottom :10px; text-align: center;">
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1');return false;" >Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onClick="consultaDetalhadaGrupos('1','30');return false;">Prosseguir</a>	

</div>

<script type="text/javascript">

	formataFiltroConsultaDetalhada();
	
</script>
	




