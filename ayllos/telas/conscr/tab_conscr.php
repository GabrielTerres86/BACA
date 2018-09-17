<?php
/*!
 * FONTE        : tab_conscr.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 01/12/2011 
 * OBJETIVO     : Tabela que apresenta a consulta CONSCR
 * --------------
 * ALTERAÇÕES   :
 * 001: 21/01/2013 - Daniel (CECRED) : Implantacao novo layout.
 * 002: 14/08/2013 - Carlos (CECRED) : Alteração da sigla PAC para PA.
	* 003: 01/08/2016 - Carlos R. (CECRED) : Corrigi o uso desnecessario da funcao session_start. SD 491672.
 * --------------
 */
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form id="tabConscr" class="formulario">

	<fieldset>
	<legend> Cooperados </legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th>PA</th>
					<th><?php echo $tpconsul == '2' ? 'CPF/CNPJ' : 'Conta'; ?></th>
					<th>Tiacute;tular</th>
					<th>Tipo Conta</th>
					<th>Seq</th>
				</tr>
			</thead>
			<tbody>
				<?
				foreach ( $registro as $r ) { 
				?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'cdagenci'); ?></span>
							      <? echo getByTagName($r->tags,'cdagenci'); ?>
  								  <input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($r->tags,'nrdconta') ?>" />								  
  								  <input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="<? echo getByTagName($r->tags,'nrcpfcgc') ?>" />								  
  								  <input type="hidden" id="nmprimtl" name="nmprimtl" value="<? echo getByTagName($r->tags,'nmprimtl') ?>" />								  
  
						</td>
						
						<?php
						if ( $tpconsul == '2' ) {
						?>
						<td><span><? echo getByTagName($r->tags,'nrcpfcgc'); ?></span>
							      <? echo getByTagName($r->tags,'nrcpfcgc'); ?>
						</td>
						<?php
						} else if ( $tpconsul == '1' ) {
						?>
						<td><span><? echo getByTagName($r->tags,'nrdconta'); ?></span>
							      <? echo formataContaDV( getByTagName($r->tags,'nrdconta') ); ?>
						</td>
						<?php
						}
						?>
						
						<td><span><? echo getByTagName($r->tags,'nmprimtl'); ?></span>
							      <? echo stringTabela(getByTagName($r->tags,'nmprimtl'),35,'maiuscula'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'tpdconta'); ?></span>
							      <? echo getByTagName($r->tags,'tpdconta'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'idseqttl'); ?></span>
							      <? echo getByTagName($r->tags,'idseqttl'); ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>
	</fieldset>
	
</form>

<!-- <div id="divMsgAjuda">
	<span>Selecione a CONTA ou CPF/CNPJ desejado e clique em CONSULTAR para continuar.</span> -->

	<div id="divBotoes" style="margin-bottom:10px">
		<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>
		<a href="#" class="botao" id="btSalvar" onclick="selecionaTabela(); return false;" >Consultar</a>
	</div>

<!-- </div>		-->																	
