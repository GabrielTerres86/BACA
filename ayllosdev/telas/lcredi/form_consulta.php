<?
/* * *********************************************************************

  Fonte: form_consulta.php
  Autor: Andrei - RKAM
  Data : Julho/2016                       Última Alteração: 27/03/2017

  Objetivo  : Mostrar o form com as informaões da linha de crédito.

  Alterações: 10/08/2016 - Ajuste referente a homologação da área de negócio
                          (Andrei - RKAM)
  
			  24/08/2016 - Ajuste para alimentar os campos select corretamente
						  (Adriano)

              27/03/2017 - Inclusao dos campos Produto e Indexador. Ajuste na
                           label de Taxa variavel. (Jaison/James - PRJ298)

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
	
	<fieldset id="fsetConsulta" name="fsetConsulta" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Informa&ccedil;&otilde;es</legend>

		<label for="tpprodut"><? echo utf8ToHtml("Produto:"); ?></label>
		<select id="tpprodut" name="tpprodut" onchange="exibeFieldIndexador();">
			<option value="1" <?php echo (getByTagName($linha->tags,'tpprodut') == 1 ? 'selected' : ''); ?>>Price TR/Price Pr&eacute;-Fixado</option>
			<option value="2" <?php echo (getByTagName($linha->tags,'tpprodut') == 2 ? 'selected' : ''); ?>>P&oacute;s-Fixado</option>
		</select>

		<br />

		<label for="dslcremp"><? echo utf8ToHtml("Descri&ccedil;&atilde;o:"); ?></label>
		<input type="text" id="dslcremp" name="dslcremp" value="<?echo getByTagName($linha->tags,'dslcremp');?>" >
		
		<br />
			
		<label for="dsoperac"><? echo utf8ToHtml("Opera&ccedil;&atilde;o:"); ?></label>
		<select  id="dsoperac" name="dsoperac" value="<?echo getByTagName($linha->tags,'dsoperac'); ?>">
			<option value="EMPRESTIMO" <?php if (getByTagName($linha->tags,'dsoperac') == "EMPRESTIMO") { ?> selected <?php } ?> >Empr&eacute;stimo</option>
			<option value="FINANCIAMENTO" <?php if (getByTagName($linha->tags,'dsoperac') == "FINANCIAMENTO") { ?> selected <?php } ?> >Financiamento</option>
			<option value="CAPITAL DE GIRO ATE 30 DIAS" <?php if (getByTagName($linha->tags,'dsoperac') == "CAPITAL DE GIRO ATE 30 DIAS") { ?> selected <?php } ?> >Capital de giro at&eacute; 30 dias</option>
			<option value="CAPITAL DE GIRO ACIMA 30 DIAS" <?php if (getByTagName($linha->tags,'dsoperac') == "CAPITAL DE GIRO ACIMA 30 DIAS") { ?> selected <?php } ?> >Capital de giro acima 30 dias</option>
		</select>  
		
		<label for="tplcremp"><? echo utf8ToHtml("Tipo:"); ?></label>
		<select  id="tplcremp" name="tplcremp" value="<?echo getByTagName($linha->tags,'tplcremp'); ?>">
			<option value="1" <?php if (getByTagName($linha->tags,'tplcremp') == 1) { ?> selected <?php } ?> >Normal</option>
			<option value="2" <?php if (getByTagName($linha->tags,'tplcremp') == 2) { ?> selected <?php } ?> >Equival&ecirc;ncia Sal&aacute;rial</option>
		</select>  

		<br />
		
		<label for="tpdescto"><? echo utf8ToHtml("Tipo de Desconto:"); ?></label>
		<select  id="tpdescto" name="tpdescto" value="<?echo getByTagName($linha->tags,'tpdescto'); ?>">
			<option value="1" <?php if (getByTagName($linha->tags,'tpdescto') == 1) { ?> selected <?php } ?> >C/C</option>
			<option value="2" <?php if (getByTagName($linha->tags,'tpdescto') == 2) { ?> selected <?php } ?> >Consignado Folha</option>
		</select>  

		<label for="tpctrato"><? echo utf8ToHtml("Modelo:"); ?></label>
		<select  id="tpctrato" name="tpctrato" value="<?echo getByTagName($linha->tags,'tpctrato'); ?>">
			<option value="1" <?php if (getByTagName($linha->tags,'tpctrato') == 1) { ?> selected <?php } ?> >Empr&eacute;stimo</option>
			<option value="2" <?php if (getByTagName($linha->tags,'tpctrato') == 2) { ?> selected <?php } ?> >Aliena&ccedil;&atilde;o fiduciaria</option>
			<option value="3" <?php if (getByTagName($linha->tags,'tpctrato') == 3) { ?> selected <?php } ?> >Hipoteca</option>
		</select>
						
		<br />

		<label for="nrdevias"><? echo utf8ToHtml("Quantidade de vias:"); ?></label>
		<input  type="text" id="nrdevias" name="nrdevias"value="<?echo getByTagName($linha->tags,'nrdevias'); ?>" > 
		
		<br />

		<label for="flgrefin"><? echo utf8ToHtml("Refinancia contratos:"); ?></label>
		<select  id="flgrefin" name="flgrefin" value="<?echo getByTagName($linha->tags,'flgrefin'); ?>">
			<option value="0" <?php if (getByTagName($linha->tags,'flgrefin') == 0) { ?> selected <?php } ?> >N&atilde;o</option>
			<option value="1" <?php if (getByTagName($linha->tags,'flgrefin') == 1) { ?> selected <?php } ?> >Sim</option>
		</select>

		<label for="flgreneg"><? echo utf8ToHtml("Renegocia&ccedil;&atilde;o:"); ?></label>
		<select  id="flgreneg" name="flgreneg" value="<?echo getByTagName($linha->tags,'flgreneg'); ?>">
			<option value="0" <?php if (getByTagName($linha->tags,'flgreneg') == 0) { ?> selected <?php } ?> >N&atilde;o</option>
			<option value="1" <?php if (getByTagName($linha->tags,'flgreneg') == 1) { ?> selected <?php } ?> >Sim</option>
		</select>

		<br />
		
		<label for="cdusolcr"><? echo utf8ToHtml("C&oacute;digo de uso:"); ?></label>
		<select  id="cdusolcr" name="cdusolcr" val_cdusolcr="<?php echo getByTagName($linha->tags,'cdusolcr'); ?>"></select>

		<label for="flgtarif"><? echo utf8ToHtml("Tarifa normal:"); ?></label>
		<select  id="flgtarif" name="flgtarif" value="<?echo getByTagName($linha->tags,'flgtarif'); ?>">
			<option value="0" <?php if (getByTagName($linha->tags,'flgtarif') == 0) { ?> selected <?php } ?> >Isentar</option>
			<option value="1" <?php if (getByTagName($linha->tags,'flgtarif') == 1) { ?> selected <?php } ?> >Cobrar</option>
		</select>

		<label for="flgtaiof"><? echo utf8ToHtml("IOF:"); ?></label>
		<select  id="flgtaiof" name="flgtaiof" value="<?echo getByTagName($linha->tags,'flgtaiof'); ?>">
			<option value="0" <?php if (getByTagName($linha->tags,'flgtaiof') == 0) { ?> selected <?php } ?> >Isentar</option>
			<option value="1" <?php if (getByTagName($linha->tags,'flgtaiof') == 1) { ?> selected <?php } ?> >Cobrar</option>
		</select>

		<br />

		<label for="vltrfesp"><? echo utf8ToHtml("Valor tarifa especial:"); ?></label>
		<input  type="text" id="vltrfesp" name="vltrfesp"value="<?echo getByTagName($linha->tags,'vltrfesp'); ?>" > 
		
		<label for="flgcrcta"><? echo utf8ToHtml("Credita C/C:"); ?></label>
		<select  id="flgcrcta" name="flgcrcta" value="<?echo getByTagName($linha->tags,'flgcrcta'); ?>">
			<option value="0" <?php if (getByTagName($linha->tags,'flgcrcta') == 0) { ?> selected <?php } ?> >N&atilde;o</option>
			<option value="1" <?php if (getByTagName($linha->tags,'flgcrcta') == 1) { ?> selected <?php } ?> >Sim</option>
		</select>

		<br />

		<label for="manterpo"><? echo utf8ToHtml("Manter ap&oacute;s liquidar:"); ?></label>
		<input  type="text" id="manterpo" name="manterpo"value="<?echo getByTagName($linha->tags,'manterpo'); ?>" > 
		
		<label for="flgimpde"><? echo utf8ToHtml("Imprime declara&ccedil;&atilde;o:"); ?></label>
		<select  id="flgimpde" name="flgimpde" value="<?echo getByTagName($linha->tags,'flgimpde'); ?>">
			<option value="0" <?php if (getByTagName($linha->tags,'flgimpde') == 0) { ?> selected <?php } ?> >N&atilde;o</option>
			<option value="1" <?php if (getByTagName($linha->tags,'flgimpde') == 1) { ?> selected <?php } ?> >Sim</option>
		</select>

		<br />

		<label for="dsorgrec"><? echo utf8ToHtml("Origem do recurso:"); ?></label>
		<select  id="dsorgrec" name="dsorgrec" value="<?echo getByTagName($linha->tags,'dsorgrec'); ?>">
			<option value="RECURSO PROPRIO" <?php if (getByTagName($linha->tags,'dsorgrec') == 'RECURSO PROPRIO') { ?> selected <?php } ?> >Recurso pr&oacute;prio</option>
			<option value="MICROCREDITO ABN" <?php if (getByTagName($linha->tags,'dsorgrec') == 'MICROCREDITO ABN') { ?> selected <?php } ?> >Microcr&eacute;dito ABN</option>
			<option value="MICROCREDITO PNMPO ABN" <?php if (getByTagName($linha->tags,'dsorgrec') == 'MICROCREDITO PNMPO ABN') { ?> selected <?php } ?> >Microcr&eacute;dito PNMPO ABN</option>
			<option value="MICROCREDITO PNMPO BB" <?php if (getByTagName($linha->tags,'dsorgrec') == 'MICROCREDITO PNMPO BB') { ?> selected <?php } ?> >Microcr&eacute;dito PNMPO BB</option>
			<option value="MICROCREDITO PNMPO BNDES" <?php if (getByTagName($linha->tags,'dsorgrec') == 'MICROCREDITO PNMPO BNDES') { ?> selected <?php } ?> >Microcr&eacute;dito PNMPO BNDES</option>
			<option value="MICROCREDITO PNMPO BNDES CECRED" <?php if (getByTagName($linha->tags,'dsorgrec') == 'MICROCREDITO PNMPO BNDES CECRED') { ?> selected <?php } ?> >Microcr&eacute;dito PNMPO BNDES CECRED</option>
			<option value="MICROCREDITO PNMPO BRDE" <?php if (getByTagName($linha->tags,'dsorgrec') == 'MICROCREDITO PNMPO BRDE') { ?> selected <?php } ?> >Microcr&eacute;dito PNMPO BRDE</option>
			<option value="MICROCREDITO PNMPO CAIXA" <?php if (getByTagName($linha->tags,'dsorgrec') == 'MICROCREDITO PNMPO CAIXA') { ?> selected <?php } ?> >Microcr&eacute;dito PNMPO CAIXA</option>
			<option value="MICROCREDITO PNMPO DIM" <?php if (getByTagName($linha->tags,'dsorgrec') == 'MICROCREDITO PNMPO DIM') { ?> selected <?php } ?> >Microcr&eacute;dito PNMPO DIM</option>
			<option value="MICROCREDITO DIM" <?php if (getByTagName($linha->tags,'dsorgrec') == 'MICROCREDITO DIM') { ?> selected <?php } ?> >Microcr&eacute;dito DIM</option>
		</select>

		<br />

		<label for="flglispr"><? echo utf8ToHtml("Listar na proposta"); ?></label>
		<select  id="flglispr" name="flglispr" value="<?echo getByTagName($linha->tags,'flglispr'); ?>">
			<option value="0" <?php if (getByTagName($linha->tags,'flglispr') == 0) { ?> selected <?php } ?> >N&atilde;o</option>
			<option value="1" <?php if (getByTagName($linha->tags,'flglispr') == 1) { ?> selected <?php } ?> >Sim</option>
		</select>

		<label for="dssitlcr"><? echo utf8ToHtml("Situa&ccedil;&atilde;o:"); ?></label>
		<input  type="text" id="dssitlcr" name="dssitlcr"value="<?echo getByTagName($linha->tags,'dssitlcr'); ?>" > 
		
		<br />

		<label for="cdmodali"><? echo utf8ToHtml("Modalidade (BACEN):"); ?></label>
		<input  type="text" id="cdmodali" name="cdmodali"value="<?echo getByTagName($linha->tags,'cdmodali'); ?>" > 
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa('2'); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
		<input  type="text" id="dsmodali" name="dsmodali"value="<?echo getByTagName($linha->tags,'dsmodali'); ?>" >
				
		<br />

		<label for="cdsubmod"><? echo utf8ToHtml("Submodalidade (BACEN):"); ?></label>
		<input  type="text" id="cdsubmod" name="cdsubmod"value="<?echo getByTagName($linha->tags,'cdsubmod'); ?>" > 
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa('3'); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
		<input  type="text" id="dssubmod" name="dssubmod"value="<?echo getByTagName($linha->tags,'dssubmod'); ?>" >
				
		<br style="clear:both" />
							
		
	</fieldset>

	<fieldset id="fsetTaxa" name="fsetTaxa" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Taxa</legend>

		<div id="divIndexador">
            <label for="cddindex"><? echo utf8ToHtml("Indexador:"); ?></label>
            <select id="cddindex" name="cddindex">
            <?php
                foreach ($xmlIndexa as $reg) {
                    $cddindex = getByTagName($reg->tags,'CDDINDEX');
                    $nmdindex = getByTagName($reg->tags,'NMDINDEX');
                    echo '<option value="'.$cddindex.'" '.(getByTagName($linha->tags,'cddindex') == $cddindex ? 'selected' : '').'>'.$nmdindex.'</option>';
                }
            ?>
            </select>
		</div>

		<label for="txjurfix"><? echo utf8ToHtml("Taxa Fixa %:"); ?></label>
		<input  type="text" id="txjurfix" name="txjurfix"value="<?echo getByTagName($linha->tags,'txjurfix'); ?>" > 
		
		<label for="txjurvar"><? echo utf8ToHtml("Taxa vari&aacute;vel %:"); ?></label>
		<input  type="text" id="txjurvar" name="txjurvar"value="<?echo getByTagName($linha->tags,'txjurvar'); ?>" > 
		<label for="txjurvarDesc"><? echo utf8ToHtml("CDI/TR/UFIR"); ?></label>
		
		<br />

		<label for="txpresta"><? echo utf8ToHtml("Taxa s/ Prest. %:"); ?></label>
		<input  type="text" id="txpresta" name="txpresta"value="<?echo getByTagName($linha->tags,'txpresta'); ?>" > 
		
		<label for="txminima"><? echo utf8ToHtml("Taxa m&iacute;nima %:"); ?></label>
		<input  type="text" id="txminima" name="txminima"value="<?echo getByTagName($linha->tags,'txminima'); ?>" > 
		
		<br />

		<label for="txmaxima"><? echo utf8ToHtml("Taxa m&aacute;xima %:"); ?></label>
		<input  type="text" id="txmaxima" name="txmaxima"value="<?echo getByTagName($linha->tags,'txmaxima'); ?>" > 
		
		<label for="txmensal"><? echo utf8ToHtml("Taxa mensal %:"); ?></label>
		<input  type="text" id="txmensal" name="txmensal"value="<?echo getByTagName($linha->tags,'txmensal'); ?>" > 
		
		<br />

		<label for="txdiaria"><? echo utf8ToHtml("Taxa di&aacute;ria %:"); ?></label>
		<input  type="text" id="txdiaria" name="txdiaria"value="<?echo getByTagName($linha->tags,'txdiaria'); ?>" > 
		
		<label for="txbaspre"><? echo utf8ToHtml("Taxa base %:"); ?></label>
		<input  type="text" id="txbaspre" name="txbaspre"value="<?echo getByTagName($linha->tags,'txbaspre'); ?>" > 
		
		<br />

		<label for="nrgrplcr"><? echo utf8ToHtml("Grupo:"); ?></label>
		<input  type="text" id="nrgrplcr" name="nrgrplcr"value="<?echo getByTagName($linha->tags,'nrgrplcr'); ?>" > 

		<label for="qtcarenc"><? echo utf8ToHtml("Dias car&ecirc;ncia:"); ?></label>
		<input  type="text" id="qtcarenc" name="qtcarenc"value="<?echo getByTagName($linha->tags,'qtcarenc'); ?>" > 
		
		<br />

		<label for="perjurmo"><? echo utf8ToHtml("Juros de mora %:"); ?></label>
		<input  type="text" id="perjurmo" name="perjurmo"value="<?echo getByTagName($linha->tags,'perjurmo'); ?>" > 
		
		<label for="vlmaxass"><? echo utf8ToHtml("Valor m&aacute;ximo associado:"); ?></label>
		<input  type="text" id="vlmaxass" name="vlmaxass"value="<?echo getByTagName($linha->tags,'vlmaxass'); ?>" > 
		
		<br />

		<label for="consaut"><? echo utf8ToHtml("Consulta automatizada:"); ?></label>
		<select  id="consaut" name="consaut" value="<?echo getByTagName($linha->tags,'consaut'); ?>">
			<option value="0" <?php if (getByTagName($linha->tags,'consaut') == 0) { ?> selected <?php } ?> >N&atilde;o</option>
			<option value="1" <?php if (getByTagName($linha->tags,'consaut') == 1) { ?> selected <?php } ?> >Sim</option>
		</select> 

		<label for="vlmaxasj"><? echo utf8ToHtml("Valor m&aacute;ximo pessoa juridica:"); ?></label>
		<input  type="text" id="vlmaxasj" name="vlmaxasj"value="<?echo getByTagName($linha->tags,'vlmaxasj'); ?>" > 
		
		<br />

		<label for="nrinipre"><? echo utf8ToHtml("Presta&ccedil;&atilde;o:"); ?></label>
		<input  type="text" id="nrinipre" name="nrinipre"value="<?echo getByTagName($linha->tags,'nrinipre'); ?>" > 
		
		<label for="nrfimpre"><? echo utf8ToHtml("a"); ?></label>
		<input  type="text" id="nrfimpre" name="nrfimpre"value="<?echo getByTagName($linha->tags,'nrfimpre'); ?>" > 
		
		<label for="qtdcasas"><? echo utf8ToHtml("Decimais:"); ?></label>
		<input  type="text" id="qtdcasas" name="qtdcasas"value="<?echo getByTagName($linha->tags,'qtdcasas'); ?>" > 
		
		<label for="qtrecpro"><? echo utf8ToHtml("Reciprocidade da linha:"); ?></label>
		<input  type="text" id="qtrecpro" name="qtrecpro"value="<?echo getByTagName($linha->tags,'qtrecpro'); ?>" > 
		
		<br style="clear:both" />							
		
	</fieldset>

	<fieldset id="fsetAprovacao" name="fsetAprovacao" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Aprova&ccedil;&atilde;o</legend>
				
		<label for="flgdisap"><? echo utf8ToHtml("Dispensar aprova&ccedil;&atilde;o:"); ?></label>
		<select  id="flgdisap" name="flgdisap" value="<?echo getByTagName($linha->tags,'flgdisap'); ?>">
			<option value="0" <?php if (getByTagName($linha->tags,'flgdisap') == 0) { ?> selected <?php } ?> >N&atilde;o</option>
			<option value="1" <?php if (getByTagName($linha->tags,'flgdisap') == 1) { ?> selected <?php } ?> >Sim</option>
		</select> 

		<label for="flgcobmu"><? echo utf8ToHtml("Cobrar multa:"); ?></label>
		<select  id="flgcobmu" name="flgcobmu" value="<?echo getByTagName($linha->tags,'flgcobmu'); ?>">
			<option value="0" <?php if (getByTagName($linha->tags,'flgcobmu') == 0) { ?> selected <?php } ?> >N&atilde;o</option>
			<option value="1" <?php if (getByTagName($linha->tags,'flgcobmu') == 1) { ?> selected <?php } ?> >Sim</option>
		</select> 

		<br />

		<label for="flgsegpr"><? echo utf8ToHtml("Seguro prestamista:"); ?></label>
		<select  id="flgsegpr" name="flgsegpr" value="<?echo getByTagName($linha->tags,'flgsegpr'); ?>">
			<option value="0" <?php if (getByTagName($linha->tags,'flgsegpr') == 0) { ?> selected <?php } ?> >N&atilde;o</option>
			<option value="1" <?php if (getByTagName($linha->tags,'flgsegpr') == 1) { ?> selected <?php } ?> >Sim</option>
		</select> 

		<br />

		<label for="cdhistor"><? echo utf8ToHtml("Hist. lan&ccedil;amento cont&aacute;bil:"); ?></label>
		<input  type="text" id="cdhistor" name="cdhistor" value="<?echo getByTagName($linha->tags,'cdhistor'); ?>" > 		
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa('4'); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
		
		<br style="clear:both" />
							
		
	</fieldset>

	<?php

	if( $qtregist > 0 && $cddopcao == 'F' ){?>

		<fieldset id="fsetFinalidades" name="fsetFinalidades" style="padding:0px; margin:0px; padding-bottom:10px;">
		
			<legend>Finalidade(s)</legend>
		
			<div class="divRegistros">
		
				<table>
					<thead>
						<tr>
							<th>C&oacute;digo</th>
							<th>Descri&ccedil;&atilde;o</th>							
						</tr>
					</thead>
					<tbody>
						<? foreach( $registros as $result ) {    ?>
							<tr>	
								<td><span><? echo getByTagName($result->tags,'cdfinemp'); ?></span> <? echo getByTagName($result->tags,'cdfinemp'); ?> </td>
								<td><span><? echo getByTagName($result->tags,'dsfinemp'); ?></span> <? echo getByTagName($result->tags,'dsfinemp'); ?> </td>
								<input type="hidden" id="cdfinemp" name="cdfinemp" value="<? echo getByTagName($result->tags,'cdfinemp'); ?>" />
								<input type="hidden" id="dsfinemp" name="dsfinemp" value="<? echo getByTagName($result->tags,'dsfinemp'); ?>" />
						
							</tr>	
						<? } ?>
					</tbody>	
				</table>
			</div>
			<div id="divRegistrosRodape" class="divRegistrosRodape">
				<table>	
					<tr>
						<td>
							<? if (isset($qtregist) and $qtregist == 0){ $nriniseq = 0;} ?>
							<? if ($nriniseq > 1){ ?>
									<a class="paginacaoAnt"><<< Anterior</a>
							<? }else{ ?>
									&nbsp;
							<? } ?>
						</td>
						<td>
							<? if (isset($nriniseq)) { ?>
									Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
								<? } ?>
							
						</td>
						<td>
							<? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
									<a class="paginacaoProx">Pr&oacute;ximo >>></a>
							<? }else{ ?>
									&nbsp;
							<? } ?>
						</td>
					</tr>
				</table>
			</div>	
		</fieldset>

   <?}else if($qtregist > 0 && $cddopcao == 'P'){ ?>

      <fieldset id="fsetPrestacoes" name="fsetPrestacoes" style="padding:0px; margin:0px; padding-bottom:10px;">
		
			<legend>Presta&ccedil;&otilde;es</legend>
		
			<div class="divRegistros">
		
				<table>
					<thead>
						<tr>
							<th>Prazo</th>
							<th>Indice</th>
						</tr>
					</thead>
					<tbody>
						<? foreach( $registros as $result ) {    ?>
							<tr>	
								<td><span><? echo getByTagName($result->tags,'qtpresta'); ?></span> <? echo getByTagName($result->tags,'qtpresta'); ?> </td>
								<td><span><? echo getByTagName($result->tags,'incalpre'); ?></span> <? echo getByTagName($result->tags,'incalpre'); ?> </td>
								<input type="hidden" id="qtpresta" name="qtpresta" value="<? echo getByTagName($result->tags,'qtpresta'); ?>" />
								<input type="hidden" id="incalpre" name="incalpre" value="<? echo getByTagName($result->tags,'incalpre'); ?>" />
						
							</tr>	
						<? } ?>
					</tbody>	
				</table>
			</div>
			<div id="divRegistrosRodape" class="divRegistrosRodape">
				<table>	
					<tr>
						<td>
							<? if (isset($qtregist) and $qtregist == 0){ $nriniseq = 0;} ?>
							<? if ($nriniseq > 1){ ?>
									<a class="paginacaoAnt"><<< Anterior</a>
							<? }else{ ?>
									&nbsp;
							<? } ?>
						</td>
						<td>
							<? if (isset($nriniseq)) { ?>
									Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
								<? } ?>
							
						</td>
						<td>
							<? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
									<a class="paginacaoProx">Pr&oacute;ximo >>></a>
							<? }else{ ?>
									&nbsp;
							<? } ?>
						</td>
					</tr>
				</table>
			</div>	
		</fieldset>

    <?}else if($cddopcao == 'I'){ ?>

		<fieldset id="fsetFinalidades" name="fsetFinalidades" style="padding:0px; margin:0px; padding-bottom:10px;">
		
			<legend>Finalidade(s)</legend>

			<table width=100%>
				<tr><td>&nbsp;</td></tr>
				<tr>
					<td>
					<label for="cdfinemp">C&oacute;digo:</label>
					<input type="text" id="cdfinemp" name="cdfinemp" value="" />
					<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa('5');return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
					<input type="text" id="dsfinemp" name="dsfinemp" value="" />
					<a href="#" class="botao" id="btInserir" onclick="btnInserirFinalidade(); return false;" >Inserir</a>&nbsp;
					</td>
				</tr>
				<tr><td>&nbsp;</td></tr>
			</table>
		
			<div class="divRegistros">
		
				<table class="tituloRegistros" id="tbRegFinalidades">
					<thead>
						<tr>
							<th><input type="checkbox" id="'checkTodos" name="checkTodos"></th>
							<th>C&oacute;digo</th>
							<th>Descri&ccedil;&atilde;o</th>							
						</tr>
					</thead>
					<tbody>
						<? foreach( $registros as $result ) {    ?>
							<tr>	
								<td><span>&nbsp;</span>&nbsp;</td>
							    <td><span><? echo getByTagName($result->tags,'cdfinemp'); ?></span> <? echo getByTagName($result->tags,'cdfinemp'); ?> </td>
								<td><span><? echo getByTagName($result->tags,'dsfinemp'); ?></span> <? echo getByTagName($result->tags,'dsfinemp'); ?> </td>
								<input type="hidden" id="cdfinemp" name="cdfinemp" value="<? echo getByTagName($result->tags,'cdfinemp'); ?>" />
								<input type="hidden" id="dsfinemp" name="dsfinemp" value="<? echo getByTagName($result->tags,'dsfinemp'); ?>" />
						
							</tr>	
						<? } ?>
					</tbody>	
				</table>
			</div>
			<div id="divRegistrosRodape" class="divRegistrosRodape">
				<table>	
					<tr>
						<td>
							<? if (isset($qtregist) and $qtregist == 0){ $nriniseq = 0;} ?>
							<? if ($nriniseq > 1){ ?>
									<a class="paginacaoAnt"><<< Anterior</a>
							<? }else{ ?>
									&nbsp;
							<? } ?>
						</td>
						<td>
							<? if (isset($nriniseq)) { ?>
									Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
								<? } ?>
							
						</td>
						<td>
							<? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
									<a class="paginacaoProx">Pr&oacute;ximo >>></a>
							<? }else{ ?>
									&nbsp;
							<? } ?>
						</td>
					</tr>
				</table>
			</div>	
		</fieldset>

	<?}?>

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
	formataTabelaRegistros();
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();
	$('#divTabela').css('display','block');
	formataFormularioConsulta();
				
</script>

