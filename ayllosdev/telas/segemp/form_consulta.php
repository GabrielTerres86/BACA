<?
/* * *********************************************************************

  Fonte: form_consulta.php
  Autor: Douglas Pagel (AMcom)
  Data : Fevereiro/2019                       Última Alteração:

  Objetivo  : Mostrar o form com as informaões do segmento.

  Alterações:

 * ********************************************************************* */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	require_once("../../includes/carrega_permissoes.php");	
?>
<form id="frmConsulta" name="frmConsulta" class="formulario" style="display:none;">
		
		<?

		?>
	
	<fieldset id="fsetConsulta" name="fsetConsulta" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Parametros</legend>

		<br />
		
		<input type="hidden" id="codigo_segmento" value="<?php echo getByTagName($linha->tags, 'codigo_segmento'); ?>"/>
		
		<label for="dssegmento"><? echo utf8ToHtml("Descrição:"); ?></label>
		<input type="text" id="dssegmento" name="dssegmento" value="<? echo $linha->tags[2]->cdata; ?>" >
		
		<br />

		<label for="qtsimulacoes_padrao"><? echo utf8ToHtml("Qtd. de Parcelas Padrão:"); ?></label>
		<input  type="text" id="qtsimulacoes_padrao" name="qtsimulacoes_padrao"value="<?echo getByTagName($linha->tags,'quantidade_padrao_simulacoes'); ?>" > 

		<label for="limite_max_proposta"><? echo utf8ToHtml("Limite Máximo de Propostas:"); ?></label>
		<input  type="text" id="limite_max_proposta" name="limite_max_proposta"value="<?echo getByTagName($linha->tags,'limite_maximo_proposta'); ?>" > 
			
		
		<br />

		<label for="variacao_parc"><? echo utf8ToHtml("Variação de Parcelas:"); ?></label>
		<input  type="text" id="variacao_parc" name="variacao_parc"value="<?echo getByTagName($linha->tags,'variacao_parcelas'); ?>" > 
		
		<label for="nrintervalo_proposta"><? echo utf8ToHtml("Intervalo Tempo Proposta:"); ?></label>
		<input  type="text" id="nrintervalo_proposta" name="nrintervalo_proposta"value="<?echo getByTagName($linha->tags,'intervalo_tempo_proposta'); ?>" >
		<label for="nrintervalo_propostaDesc"><? echo utf8ToHtml("horas"); ?></label>

		<br />

		<label for='descricao_segmento'><? echo utf8ToHtml("Descrição do Segmento:"); ?></label>
		<textarea name="descricao_segmento" id="descricao_segmento" style="overflow-y: scroll; overflow-x: hidden; width: 515px; height: 100px; margin: 3px 0px 3px 3px;"><? echo $linha->tags[7]->cdata; ?></textarea>
		
		<br />

		<label for="qtdias_validade"><? echo utf8ToHtml("Validade da Simulação:"); ?></label>
		<input  type="text" id="qtdias_validade" name="qtdias_validade"value="<?echo getByTagName($linha->tags,'qtdias_validade'); ?>" > 
		<label for="qtdias_validadedesc"><? echo utf8ToHtml("dias"); ?></label>
    
		<br />
		<div id="divSubsegmentos" name="divSubsegmentos">
			<fieldset id="fsetSubsegmento" name="fsetSubsegmento" style="padding:0px; margin:0px; padding-bottom:10px;">
				
				<legend>Subsegmentos</legend>
				<div id="tabelaSubsegmento" name="tabelaSubsegmento" style= "padding: 5px;">
					<?include('tab_subseg.php');?>
				</div>
			</fieldset>
			<div id="divBotoesSubsegmentos" name="divBotoesSubsegmentos" style="margin-left: 265px;">
					<a href="#" class="botao" id="btAlterarSubsegmento" name="btAlterarSubsegmento" onClick="rotinaSubsegmento('A');">Alterar</a>
					<a href="#" class="botao" id="btConsultarSubsegmento" name="btConsultarSubsegmento" onClick="rotinaSubsegmento('C');">Consultar</a>
			</div>
		</div>

		<fieldset id="fsetPermissoes" name="fsetPermissoes" style="padding:0px; margin:0px; padding-bottom:10px;">
			
			<legend><? echo utf8ToHtml("Permissões"); ?></legend>
			
			<label for="tipo_pessoa_1"><? echo utf8ToHtml("Pessoa Física"); ?></label>
			<input  type="checkbox" id="tipo_pessoa_1" name="tipo_pessoa_1" <? if ($permis_pessoa_fisica) {echo "checked";} ?>>
			<label for="tipo_pessoa_2"><? echo utf8ToHtml("Pessoa Jurídica"); ?></label>
			<input  type="checkbox" id="tipo_pessoa_2" name="tipo_pessoa_2" <? if ($permis_pessoa_juridica) {echo "checked";} ?>>
			
			<br />
			
			<label for="canal_3"><? echo utf8ToHtml("Conta On-line:"); ?></label>
			<label for="l_canal_3_0"><? echo utf8ToHtml("Indisponível"); ?></label>
			<input type="radio" name="r_canal_3" id="l_canal_3_0" value="0" onClick="acaoRadio();" <?php echo ($canal_3_permis == 0) ? "checked" : null; ?>> 
			<label for="l_canal_3_1"><? echo utf8ToHtml("Simulação"); ?></label>
			<input type="radio" name="r_canal_3" id="l_canal_3_1" value="1" onClick="acaoRadio();"<?php echo ($canal_3_permis == 1) ? "checked" : null; ?>>
			<label for="l_canal_3_2"><? echo utf8ToHtml("Contratação"); ?></label>
			<input type="radio" name="r_canal_3" id="l_canal_3_2" value="2" onClick="acaoRadio();"<?php echo ($canal_3_permis == 2) ? "checked" : null; ?>>
			<label for="canal_3_vlr"><? echo utf8ToHtml("Vlr. Max. Aut:"); ?></label>
			<input type="text" id="canal_3_vlr" name="canal_3_vlr"value="<?php echo ($canal_3_vlr > 0) ? $canal_3_vlr : null; ?>" >
			
			<br />
			
			<label for="canal_10"><? echo utf8ToHtml("Mobile:"); ?></label>
			<label for="l_canal_10_0"><? echo utf8ToHtml("Indisponível"); ?></label>
			<input type="radio" name="r_canal_10" id="l_canal_10_0" value="0" onClick="acaoRadio();"<?php echo ($canal_10_permis == 0) ? "checked" : null; ?>> 
			<label for="l_canal_10_1"><? echo utf8ToHtml("Simulação"); ?></label>
			<input type="radio" name="r_canal_10" id="l_canal_10_1" value="1" onClick="acaoRadio();"<?php echo ($canal_10_permis == 1) ? "checked" : null; ?>>
			<label for="l_canal_10_2"><? echo utf8ToHtml("Contratação"); ?></label>
			<input type="radio" name="r_canal_10" id="l_canal_10_2" value="2" onClick="acaoRadio();"<?php echo ($canal_10_permis == 2) ? "checked" : null; ?>>
			<label for="canal_10_vlr"><? echo utf8ToHtml("Vlr. Max. Aut:"); ?></label>
			<input type="text" id="canal_10_vlr" name="canal_10_vlr"value="<?php echo ($canal_10_vlr > 0) ? $canal_10_vlr : null; ?>" >
			
			<br />
			<!--
			<label for="canal_4"><? echo utf8ToHtml("TAA:"); ?></label>
			<label for="l_canal_4_0"><? echo utf8ToHtml("Indisponível"); ?></label>
			<input type="radio" name="r_canal_4" value="0" <?php echo ($canal_4_permis == 0) ? "checked" : null; ?>> 
			<label for="l_canal_4_1"><? echo utf8ToHtml("Simulação"); ?></label>
			<input type="radio" name="r_canal_4" value="1" <?php echo ($canal_4_permis == 1) ? "checked" : null; ?>>
			<label for="l_canal_4_2"><? echo utf8ToHtml("Contratação"); ?></label>
			<input type="radio" name="r_canal_4" value="2" <?php echo ($canal_4_permis == 2) ? "checked" : null; ?>>
			<label for="canal_4_vlr"><? echo utf8ToHtml("Vlr. Max. Aut:"); ?></label>
			<input type="text" id="canal_4_vlr" name="canal_10_vlr"value="<?php echo ($canal_4_vlr > 0) ? $canal_4_vlr : null; ?>" >
			-->
		</fieldset>

		
		
	</fieldset>

</form>

<div id="divBotoesConsulta" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
																			
	<a href="#" class="botao" id="btVoltar">Voltar</a>
	<a href="#" class="botao" id="btConcluir" >Concluir</a>
																				
</div>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		consultaLinhaCredito(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		consultaLinhaCredito(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});		

	$('#divBotoes').css('display','none');
	//formataTabelaRegistros();
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();
	$('#divTabela').css('display','block');
	formataFormularioConsulta();
				
</script>

