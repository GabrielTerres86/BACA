<?php
/*!
 * FONTE        : form_seguro_vida_prest_novo.php
 * CRIAÇÃO      : Lucas Lombardi
 * DATA CRIAÇÃO : 17/06/2016
 * OBJETIVO     : tela de consulta para novos seguros de vida.
 * --------------
 * ALTERAÇÕES   :
 * 
 */

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	isPostMethod();	

	$nmresseg = $_POST["nmresseg"];
    $tipo = $_POST['tipo'];
    $operacao = $_POST['operacao'];
	
	$data = explode("/", $glbvars[dtmvtolt]);
	$dtfim = date("d/m/Y", mktime(0, 0, 0, $data[1], $data[0] + 365, $data[2]) );
	
?>
<form name="frmNovo" id="frmNovo" class="formulario condensado">	
	<fieldset>
		<legend align="left">Detalhes do Seguro</legend>
		
		<label for='nmSegurado'>Segurado:</label>
		<input name='nmSegurado' id='nmSegurado' value="<?php echo $nmSegurado; ?>" />
		
		<label for='dsTpSeguro'>Tipo de Seguro:</label>
		<input name='dsTpSeguro' id='dsTpSeguro' value="<?php echo $dsTpSeguro; ?>" />
		
		<label for='nmSeguradora'>Seguradora:</label>
		<input name='nmSeguradora' id='nmSeguradora' value="<?php echo $nmSeguradora; ?>" />
		
		<label for='dtIniVigen'>Início de Vigência:</label>
		<input name='dtIniVigen' id='dtIniVigen' value="<?php echo $dtIniVigen; ?>" />
		
		<label for='dtFimVigen'>Final de Vigência:</label>
		<input name='dtFimVigen' id='dtFimVigen' value="<?php echo $dtFimVigen; ?>" />
		
		<label for='nrProposta'>Proposta nº:</label>
		<input name='nrProposta' id='nrProposta' value="<?php echo $nrProposta; ?>" />
		
		<label for='nrApolice'>Apólice nº:</label>
		<input name='nrApolice' id='nrApolice' value="<?php echo $nrApolice; ?>" />
		
		<label for='nrEndosso'>Endosso nº:</label>
		<input name='nrEndosso' id='nrEndosso' value="<?php echo $nrEndosso; ?>" />
		
		<label for='dsPlano'>Plano:</label>
		<input name='dsPlano' id='dsPlano' value="<?php echo $dsPlano; ?>" />
		
		<label for='vlCapital'>Capital:</label>
		<input name='vlCapital' id='vlCapital' value="<?php echo $vlCapital; ?>" />
		
		<label for='nrApoliceRenova'>Renova apólice:</label>
		<input name='nrApoliceRenova' id='nrApoliceRenova' value="<?php echo $nrApoliceRenova; ?>" />
	</fieldset>
	
	<fieldset>
		<legend align="left">Detalhes do Seguro</legend>
		<div id="divBeneficiarios" class="divRegistros" style="display:block">
			<table>
				<thead>
					<tr>
						<th>Nome</th>
						<th>Data de Nasc.</th>
						<th>Grau de Parentesco</th>
						<th>Participação (%)</th>
					</tr>
				</thead>
				<tbody>
					<?
					foreach( $registros as $registro ) { ?>
						<tr style="cursor: pointer;">
							<td align="left"  ><? echo getByTagName($registro->tags,'nmBenefici')?></td>
							<td align="center"><? echo getByTagName($registro->tags,'dtNascimento')?></td>
							<td align="center"><? echo getByTagName($registro->tags,'dsGrauParente')?></td>
							<td align="center"><? echo getByTagName($registro->tags,'perParticipa')?></td>
						</tr>
				<?
				} ?>
				</tbody>
			</table>
		</div>
	</fieldset>

	<fieldset>
		<legend align="left">Dados Complementares</legend>					
			<label for='vlPremioLiquido'>Prêmio Líquido:</label>
		<input name='vlPremioLiquido' id='vlPremioLiquido' value="<?php echo $vlPremioLiquido; ?>"  />
		
		<label for='qtParcelas'>Quantidade de Parcelas:</label>
		<input name='qtParcelas' id='qtParcelas' value="<?php echo $qtParcelas; ?>"  />
		
		<label for='vlPremioTotal'>Prêmio Total R$:</label>
		<input name='vlPremioTotal' id='vlPremioTotal' value="<?php echo $vlPremioTotal; ?>"  />
		
		<label for='vlParcela'>Valor  das Parcelas R$:</label>
		<input name='vlParcela' id='vlParcela' value="<?php echo $vlParcela; ?>"  />
		
		<label for='ddMelhorDia'>Melhor dia:</label>
		<input name='ddMelhorDia' id='ddMelhorDia' value="<?php echo $ddMelhorDia; ?>"  />
		
		<label for='perComissao'>Percentual de comissão:</label>
		<input name='perComissao' id='perComissao' value="<?php echo $perComissao; ?>"  />
		
		<div style="margin-top: 70px"></div>
		
		<label for='dsObservacoes'>Observações:</label>
		<textarea name='dsObservacoes' id='dsObservacoes' rows="3"  value="<?php echo $dsObservacoes; ?>" />
		
	</fieldset>
</form>
<br />
<div id="divBotoes">
	<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" />
	
</div>