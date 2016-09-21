<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Renato Darosci - SUPERO
 * DATA CRIAÇÃO : Junho/2015
 * OBJETIVO     : Cabeçalho para a tela PAGFOL
 * --------------
 * ALTERAÇÕES   : 21/10/2015 - Remocao de logica da CDDOPCAO nao utilizada (Marcos-Supero)
	*				 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>
<script>
	// Criando variavel DTMVTOLT para exibir a data cadastrada no sistema
	aux_dtmvtolt = "<? echo $glbvars['dtmvtolt'] ; ?>"; 
</script>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">

	<div id="divConsulta" >
		<fieldset>
		<hr width="250px"><br>
		<legend>Par&acirc;metros de Pesquisa</legend>
			<table width="100%">
				<tr>
					<td width="250px">
						<label for="cdcooper">Cooperativa:</label>
						<select id="cdcooper" name="cdcooper" alt="Selecione a Cooperativa desejada."></select>
					</td>
                    <td width="150px">
                        <label for="dtmvtolt">Data:</label>
                        <input name="dtmvtolt" id="dtmvtolt" type="text" value="<?php echo $glbvars['dtmvtolt']; ?>" autocomplete="off" class='campo' />
					</td>
                    <td>
						<label for="cdempres">Empresa:</label>	
						<input name="cdempres" type="text"  id="cdempres" class='campo' />
						<a href="#" onClick="mostraPesquisaEmpresa('cdempres','frmCab','');return false;" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
						<input name="nmextemp" type="text" id="nmextemp" class='campo' />
					</td>
				</tr>
			</table>
		</fieldset>		
	</div>

    <br style="clear:both" />
</form>