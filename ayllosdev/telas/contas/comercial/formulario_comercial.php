<?php 
/*!
 * FONTE        : formulario_comercial.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 24/05/2010 
 * OBJETIVO     : Formulário de dados de Comercial da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :  16/06/2011 - Incluir o campo 'Pessoa Politicamente Exposta' (Gabriel)
 * 				   29/11/2011 - Ajusta para a inclusao do campo "Justificativa" (Adriano)
 * 				   19/12/2013 - Adicionado campos hidden do formulario frmDadosComercial. (Jorge) 
 *                 18/08/2015 - Reformulacao cadastral (Gabriel-RKAM)
 *				   21/06/2016 - Ajustado o nome da cidade que não carregava ao selecionar
								uma empresa, conforme solicitado no chamado 469194. (Kelvin)
				   07/10/2016 - Correcao no carregamento do campo justificativa devido ao uso de
								caracteres especiais que geravam erro no retorno do Ajax. 
								SD 535228. (Carlos Rafael Tanholi).
 *                 01/12/2016 - Definir a não obrigatoriedade do PEP (Tiago/Thiago SD532690)  
 *                 09/10/2017 - Tratamento para remover caracteres especiais do campo Justificativa (Andrey - Mouts) - Chamado 749679 PRB0040072
 *   			   11/10/2017 - Removendo campo caixa postal (PRJ339 - Kelvin).	
 *                 05/12/2017 - Alteração para buscar o Nome da Empresa a partir do CNPJ digitado e regra de alteração do nome da empresa.
 *                             (Mateus Z - Mouts) 
 *                 05/07/2018 - Ajustado rotina para que nao haja inconsistencia nas informacoes da empresa
 *							   (CODIGO, NOME E CNPJ DA EMPRESA). (INC0018113 - Kelvin)
 *				   20/09/2018 - Ajustes nas rotinas envolvidas na unificação cadastral e CRM para
 *	                           corrigir antigos e evitar futuros problemas. (INC002926 - Kelvin)
 *   			   17/03/2019 - Projeto 437 Ajuste label matricula - Jackson Barcellos AMcom
 */
?>
<form name="frmDadosComercial" id="frmDadosComercial" class="formulario">	
	<input type="hidden" id="tpdrendi" name="tpdrendi">
	<input type="hidden" id="tpdrend2" name="tpdrend2">
	<input type="hidden" id="tpdrend3" name="tpdrend3">
	<input type="hidden" id="tpdrend4" name="tpdrend4">
	<input type="hidden" id="vldrendi" name="vldrendi">
	<input type="hidden" id="vldrend22" name="vldrend22">
	<input type="hidden" id="vldrend3" name="vldrend3">
	<input type="hidden" id="vldrend4" name="vldrend4">
	<input type="hidden" id="inpolexpAnt" name="inpolexpAnt" value="<?php echo getByTagName($comercial,'inpolexp') ?>" />
	<fieldset>
		<legend>Inf. Profissionais</legend>
		
		<label for="cdnatopc"><?php echo utf8ToHtml('Nat. Ocupação:') ?></label>
		<input name="cdnatopc" id="cdnatopc" type="text" value="<?php echo getByTagName($comercial,'cdnatopc') ?>" />
		<a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="rsnatocp" id="rsnatocp" type="text" value="<?php echo getByTagName($comercial,'rsnatocp') ?>" />
		
		<label for="cdocpttl"><?php echo utf8ToHtml('Ocupação:') ?></label>
		<input name="cdocpttl" id="cdocpttl" type="text" value="<?php echo getByTagName($comercial,'cdocpttl') ?>" />
		<a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="rsocupa" id="rsocupa" type="text" value="<?php echo getByTagName($comercial,'rsocupa') ?>" />
		<br />
		
		<label for="tpcttrab">Tp. Ctr. Trab.:</label>
		<select name="tpcttrab" id="tpcttrab">
			<option value=""> - </option> 
			<option value="1" <?php if (getByTagName($comercial,'tpcttrab') == "1"){ echo " selected"; } ?>>1 - PERMANENTE</option>
			<option value="2" <?php if (getByTagName($comercial,'tpcttrab') == "2"){ echo " selected"; } ?>>2 - TEMP/TERCEIRO</option>
			<option value="3" <?php if (getByTagName($comercial,'tpcttrab') == "3"){ echo " selected"; } ?>>3 - SEM V&Iacute;NCULO</option>
			<option value="4" <?php if (getByTagName($comercial,'tpcttrab') == "4"){ echo " selected"; } ?>>4 - AUT&Ocirc;NOMO</option>
		</select>
		
		<label for="cdempres"><?php echo utf8ToHtml('Empregador:') ?></label>
		<input name="cdempres" id="cdempres" type="text" value="<?php echo getByTagName($comercial,'cdempres') ?>" />
		<a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="nmresemp" id="nmresemp" type="text" value="<?php echo getByTagName($comercial,'nmresemp') ?>" />
		<br />
		
		<label for="nrcpfemp"><?=($tppesemp == 1 ? 'CPF' : 'CNPJ')?>:</label>
		<input name="nrcpfemp" id="nrcpfemp" type="text"  value="<?php if ($operacao == 'CAE') { echo $nrcnpjot; } else {echo getByTagName($comercial,'nrcpfemp');} ?>" />
		
		<label for="nmextemp">Nome Empregador:</label>
		<input name="nmextemp" id="nmextemp" disabled type="text" value="<?php if ($operacao == 'CAE') { echo $nmpessoa;} else {echo getByTagName($comercial,'nmextemp');} ?>" />		
		<br />
		 				
		<label for="dsproftl"><?php echo utf8ToHtml('Cargo:') ?></label>
		<input name="dsproftl" id="dsproftl" type="text" value="<?php echo getByTagName($comercial,'dsproftl') ?>" />
		
		<label for="cdnvlcgo"><?php echo utf8ToHtml('Nível Cargo:') ?></label>
		<select name="cdnvlcgo" id="cdnvlcgo">
			<option value="" selected> - </option>
		</select>
		
		<br />
		<label for="inpolexp">Pessoa exposta politicamente:</label>
		<select id="inpolexp" name="inpolexp">
   			<option value="0" <?php if (getByTagName($comercial,'inpolexp') == "0") { echo ' selected'; } ?>> N&atilde;o </option>
  			<option value="1" <?php if (getByTagName($comercial,'inpolexp') == "1") { echo ' selected'; } ?>> Sim </option>
		</select>
				
		<label for="otrsrend"><?php echo utf8ToHtml('Total de outros rendimentos:')?></label>		
		<input name="otrsrend" id="otrsrend" type="text"/>
		
		<br />
		
		<label for="cdturnos">Turno:</label>
		<select name="cdturnos" id="cdturnos">
			<option value="" selected> - </option>
		</select>
		
		<label for="dtadmemp">Dt. Adm.:</label>
		<input name="dtadmemp" id="dtadmemp" type="text" value="<?php echo getByTagName($comercial,'dtadmemp') ?>" />
		
		<label for="vlsalari">Rendim.:</label>
		<input name="vlsalari" id="vlsalari" type="text" value="<?php echo getByTagName($comercial,'vlsalari') ?>" />		
		
		<label for="nrcadast"><?php echo utf8ToHtml('Matr. Emp.:') ?></label>
		<input name="nrcadast" id="nrcadast" type="text" value="<?php echo getByTagName($comercial,'nrcadast') ?>" />
		
		<br style="clear:both" />
	</fieldset>
	<?php if ($_POST['inpessoa'] == 1) { ?>
		<fieldset>
			<legend><? echo utf8ToHtml('Atualização Cadastral');?></legend>
	
			<label for="idcanal_empresa">Empresa Canal:</label>
			<input name="idcanal_empresa" id="idcanal_empresa" type="text"  value="<? echo getByTagName($comercial,'dscanale') ?>" />

			<label for="dtrevisa_empresa"><? echo utf8ToHtml('Data revisão:'); ?></label>
			<input name="dtrevisa_empresa" id="dtrevisa_empresa" type="text"  value="<? echo getByTagName($comercial,'dtrevise') ?>" />

			<label for="dsstatus"><? echo utf8ToHtml('Status:'); ?></label>
			<input name="dsstatus" id="dsstatus" type="text"  value="<? echo getByTagName($comercial,'dssituae') ?>" />

			<label for="idcanal_renda">Renda Canal:</label>
			<input name="idcanal_renda" id="idcanal_renda" type="text"  value="<? echo getByTagName($comercial,'dscanalr') ?>" />

			<label for="dtrevisa_renda"><? echo utf8ToHtml('Data revisão:'); ?></label>
			<input name="dtrevisa_renda" id="dtrevisa_renda" type="text"  value="<? echo getByTagName($comercial,'dtrevisr') ?>" />

			<label for="dsstatus"><? echo utf8ToHtml('Status:'); ?></label>
			<input name="dsstatus" id="dsstatus" type="text"  value="<? echo getByTagName($comercial,'dssituar') ?>" />
			
		    <br style="clear:both" />
		</fieldset>
	<?php } ?>
	<fieldset>
		<legend><? echo utf8ToHtml('Rendas automáticas') ?></legend>

		<label for="dtrefere">Refer&ecirc;ncia.:</label>
		<input name="dtrefere" id="dtrefere" type="text" value="<? echo $edDtrefere; ?>" />

		<label for="vltotmes">Valor total m&ecirc;s.:</label>
		<input name="vltotmes" id="vltotmes" type="text" value="<? echo $edVlrefere; ?>" />

		<a href="#" onClick="buscaReferenciaFolha(<? echo $nrdconta; ?>);"><img src="<? echo $UrlImagens; ?>botoes/detalhar.gif"></img></a>

	    <br style="clear:both" />
	</fieldset>
	
	<fieldset>
		<legend><? echo utf8ToHtml('Endereço') ?></legend>

		<label for="cepedct1"><?php echo utf8ToHtml('CEP:') ?></label>
		<input name="cepedct1" id="cepedct1" type="text" value="<?php echo getByTagName($comercial,'cepedct1') ?>" />
		<a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		
		<label for="endrect1"><?php echo utf8ToHtml('End.:') ?></label>
		<input name="endrect1" id="endrect1" type="text" value="<?php echo getByTagName($comercial,'endrect1') ?>" />		
		<br />

		<label for="nrendcom"><?php echo utf8ToHtml('Nro.:') ?></label>
		<input name="nrendcom" id="nrendcom" type="text" value="<?php echo getByTagName($comercial,'nrendcom') ?>" />
		
		<label for="complcom"><?php echo utf8ToHtml('Comple.:') ?></label>
		<input name="complcom" id="complcom" type="text" value="<?php echo getByTagName($comercial,'complcom') ?>" />
		<br />
		
		<label for="bairoct1"><?php echo utf8ToHtml('Bairro:') ?></label>
		<input name="bairoct1" id="bairoct1" type="text" value="<?php echo getByTagName($comercial,'bairoct1') ?>" />								
		<br />	
		
		<label for="ufresct1"><?php echo utf8ToHtml('U.F.:') ?></label>
		<?php echo selectEstado('ufresct1', getByTagName($comercial,'ufresct1'), 1); ?>	
		
		<label for="cidadct1"><?php echo utf8ToHtml('Cidade:') ?></label>
		<input name="cidadct1" id="cidadct1" type="text" value="<?php echo getByTagName($comercial,'cidadct1') ?>"/>
					
		<br style="clear:both" />
	</fieldset>
	
</form>

<div id="divRendimentos"></div>

<div id="divReferencia"></div>

<form name="frmJustificativa" id="frmJustificativa" class="formulario">

	<br />
	
	<label for="dsjusren"><?php echo utf8ToHtml('Justificativa:'); ?></label>
	<textarea name="dsjusren" id="dsjusren"></textarea>
		
	<script type="text/javascript"> 
    $('#dsjusren','#frmJustificativa').val( '<?php echo removeCaracteresInvalidos(getByTagName($comercial,'dsjusren')); ?>' );
	</script>	
	<br style="class:both" />	
		
</form>

<form id="frmManipulaRendi" name="frmManipulaRendi" class="formulario">

	<fieldset>
		
		<legend id="nmdfield" name="nmdfield"></legend>
		
			<label for="tpdrend2"><?php echo utf8ToHtml('Origem:'); ?></label>
			<input name="tpdrend2" id="tpdrend2" type="text" />
			<a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dsdrend2" id="dsdrend2" type="text" />
			
			<label for="vldrend2"><?php echo utf8ToHtml('Valor:'); ?></label>
			<input name="vldrend2" id="vldrend2" type="text" />
			
			<br />
			
			<label for="dsjusre2"><?php echo utf8ToHtml('Justificativa:'); ?></label>
			<textarea name="dsjusre2" id="dsjusre2"></textarea>
			
			<br style="class:both" />
			
	</fieldset>	

</form>

<div id="divBotoesRendi">	

	<br />
	
	<input type="image" id="btRendVoltar"   src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaRendimentos('V');" />		
	<input type="image" id="btRendAlterar"  src="<?php echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaRendimentos('A');" />		
	<input type="image" id="btRendExcluir"  src="<?php echo $UrlImagens; ?>botoes/excluir.gif"  onClick="controlaRendimentos('E');" />		
	<input type="image" id="btRendIncluir"  src="<?php echo $UrlImagens; ?>botoes/incluir.gif"  onClick="controlaRendimentos('I');" />	
	<input type="image" id="btContinuar"  src="<?php echo $UrlImagens; ?>botoes/continuar.gif"  onClick="controlaContinuar(false);" />	
	

</div>

<div id="divBotoesRendas">	
	<br />
	<input type="image" id="btRendVoltar"   src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaRendimentos('V');" />		
</div>


<div id="divBotoesManip">

	<br />
	
	<input type="image" id="btManipVoltar"    src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaRendimentos('VR');" />		
	<input type="image" id="btManipConcluir"  src="<?php echo $UrlImagens; ?>botoes/concluir.gif"  onClick="validaJustificativa(operacao);" />		

</div>

<div id="divBotoes">
	<?php if ( ($operacao == 'CA' || $operacao == 'CAE') && $flgcadas != 'M') { ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('AC');" />		
		<input type="image" id="btSalvar"  src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV', true);" />	
	<?php }else if ( $flgcadas == 'M' ){ ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="voltarRotina();" />		
	<?php }else if ( $operacao == 'SC' ){?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina);" />
	<?php } else { ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina);" />
		<input type="image" id="btAlterar" src="<?php echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaOperacao('CA');" />	
		<input type="image" id="btRendimento" src="<?php echo $UrlImagens; ?>botoes/outros_rendimentos.gif"  onClick="buscaRendimentos(1,30);" />
	<?php } ?>

	<input type="image" id="btContinuar"  src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaContinuar(true);" />
</div>
