<?
 /*!
 * FONTE        : form_tipo5.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 28/09/2011
 * OBJETIVO     : Formulário de exibição do TIPO 5 do ADITIV
 * --------------
 * ALTERAÇÕES   : 22/11/2012 - Alterado botões do tipo tag <input> por
 *							   tag <a> (Daniel).
 *                28/02/2014 - Novos campos NrCpfCgc e validações. Guilherme(SUPERO)
 *
 * --------------
 */
?>
<?
	include('../manbem/form_alie_veiculo.php');
	if($cddopcao=="I")
	{
		?>
		<div id="table_substitui_bens">
			<? 
			include('../manbem/table_alie_bens.php');
			?>
		</div>
		<?
	}
?>

<div id="divBotoes" style="margin-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Cancelar</a>
	<a href="#" class="botao" id="btSalvar" onClick="Gera_Impressao(); return false;">Imprimir</a>
</div>

<script>
formataTipo5();
</script>