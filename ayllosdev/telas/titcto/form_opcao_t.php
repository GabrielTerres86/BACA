<? 
/* !
 * FONTE        : form_opcao_t.php
 * CRIACAO      : Luis Fernando - (GFT)
 * DATA CRIACAO : 14/03/2018
 * OBJETIVO     : Formulario que apresenta a consulta da opcao T da tela TITCTO
 * --------------
 * ALTERACOES   :
 * --------------
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	

	include('form_cabecalho.php');
	
?>

<form id="frmOpcao" class="formulario" onSubmit="return false;">
    <fieldset>
        <legend> Associado </legend>	
        
        <label for="nrdconta">Conta:</label>
        <input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
        <a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

        <label for="nrcpfcgc">CPF/CNPJ:</label>
        <input type="text" id="nrcpfcgc" name="nrcpfcgc" value="<?php echo $nrcpfcgc ?>"/>

        <label for="nmprimtl">Titular:</label>
        <input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>" />
    </fieldset>
	<fieldset>
		<legend> T&iacute;tulos a Pesquisar </legend>
		
		<label for="tpdepesq">Situa&ccedil;&atilde;o:</label>
        <select  id="tpdepesq" name="tpdepesq">
            <option value="T" <?php echo $tpdepesq == 'T' ? 'selected' : '' ?>>Todos</option>
            <option value="A" <?php echo $tpdepesq == 'A' ? 'selected' : '' ?>>Abertos</option>
            <option value="L" <?php echo $tpdepesq == 'L' ? 'selected' : '' ?>>Liquidados</option>
        </select>
		
		<label for="nrdocmto">Boleto:</label>
		<input type="text" id="nrdocmto" name="nrdocmto" value="<?php echo $nrdocmto ?>" />
		
		<label for="vltitulo">Valor:</label>
		<input type="text" id="vltitulo" name="vltitulo" value="<?php echo $vltitulo ?>"/>
		

        <div class="tipo_cobranca">
            <label for="tpcobran">Tipo de Cobran&ccedil;a</label>
            <select  id="tpcobran" name="tpcobran">
                <option value="T" <?php echo $tpcobran == 'T' ? 'selected' : '' ?>>Todos</option>
                <option value="R" <?php echo $tpcobran == 'R' ? 'selected' : '' ?>>Cobran&ccedil;a Registrada</option>
                <option value="S" <?php echo $tpcobran == 'S' ? 'selected' : '' ?>>Cobran&ccedil;a S/ Registro</option>
            </select>
        </div>
	</fieldset>		
	
	
	<fieldset>
	<legend> Boletos </legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Liberacao'); ?></th>
					<th><? echo utf8ToHtml('PA'); ?></th>
					<th><? echo utf8ToHtml('Bc/Cx');  ?></th>
					<th><? echo utf8ToHtml('Lote');  ?></th>
					<th><? echo utf8ToHtml('Vencto');  ?></th>
					<th><? echo utf8ToHtml('Bco');  ?></th>
					<th><? echo utf8ToHtml('Convenio');  ?></th>
					<th><? echo utf8ToHtml('Tipo Cobr.');  ?></th>
					<th><? echo utf8ToHtml('Boleto');  ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				foreach ( $registros as $r ) { 
				?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'dtlibbdt'); ?></span>
							      <? echo getByTagName($r->tags,'dtlibbdt'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'cdagenci'); ?></span>
							      <? echo getByTagName($r->tags,'cdagenci'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'cdbccxlt'); ?></span>
							      <? echo getByTagName($r->tags,'cdbccxlt'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrdolote'); ?></span>
							      <? echo getByTagName($r->tags,'nrdolote'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dtvencto'); ?></span>
							      <? echo getByTagName($r->tags,'dtvencto'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'cdbandoc'); ?></span>
							      <? echo getByTagName($r->tags,'cdbandoc'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrcnvcob'); ?></span>
							      <? echo getByTagName($r->tags,'nrcnvcob'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'tpcobran'); ?></span>
							      <? echo getByTagName($r->tags,'tpcobran'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrdocmto'); ?></span>
							      <? echo getByTagName($r->tags,'nrdocmto'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vltitulo'); ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vltitulo')); ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>
	</fieldset>

</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
</div>

