<? 
/* !
 * FONTE        : form_opcao_s.php
 * CRIACAO      : Luis Fernando - (GFT)
 * DATA CRIACAO : 13/03/2018
 * OBJETIVO     : Formulario que apresenta a consulta da opcao S da tela TITCTO
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
		<legend> <? echo utf8ToHtml('Conciliação Contabil'); ?> </legend>

		<div class="tipo_cobranca">
            <label for="tpcobran">Tipo de Cobran&ccedil;a</label>
            <select  id="tpcobran" name="tpcobran">
                <option value="T" <?php echo $tpcobran == 'T' ? 'selected' : '' ?>>Todos</option>
                <option value="R" <?php echo $tpcobran == 'R' ? 'selected' : '' ?>>Cobran&ccedil;a Registrada</option>
                <option value="S" <?php echo $tpcobran == 'S' ? 'selected' : '' ?>>Cobran&ccedil;a S/ Registro</option>
            </select>
        </div>
        <div class="saldo_contabil">
			<label for="dsvencto">Saldo Contabil em:</label>
			<label for="dtvencto"></label>
			<input type="text" id="dtvencto" name="dtvencto" value="<?php echo $dtvencto ?>" />
			<a href="#" class="botao" id="btnOk3">Ok</a>


			<br style="clear:both" /><br />

			<h4 style="text-align:center;">Saldo Cont&aacute;bil</h4>

			<br style="clear:both" /><br />

			<label for="lqtdedas">Qtde.</label>
			<label for="lvalores">Valor</label>

			<br />
			
			<label for="dssldant">Saldo Anterior:</label>
			<label for="qtsldant"></label>
			<input type="text" id="qtsldant" name="qtsldant" value="0" />
			<label for="vlsldant"></label>
			<input type="text" id="vlsldant" name="vlsldant" value="0" />
			
			<br />
			
			<label for="dstitulo">T&iacute;tulos Recebidos:</label>
			<label for="qttitulo"></label>
			<input type="text" id="qttitulo" name="qttitulo" value="0" />
			<label for="vltitulo"></label>
			<input type="text" id="vltitulo" name="vltitulo" value="0" />


			<br />
			
			<label for="dsvencid">Vencimentos no dia:</label>
			<label for="qtvencid"></label>
			<input type="text" id="qtvencid" name="qtvencid" value="0" />
			<label for="vlvencid"></label>
			<input type="text" id="vlvencid" name="vlvencid" value="0" />

			<br />
			
			<label for="dsderesg">T&iacute;tulos Resgatados:</label>
			<label for="qtderesg"></label>
			<input type="text" id="qtderesg" name="qtderesg" value="0" />
			<label for="vlderesg"></label>
			<input type="text" id="vlderesg" name="vlderesg" value="0" />

			<br style="clear:both" /><br />
			
			<label for="dscredit">SALDO ATUAL:</label>
			<label for="qtcredit"></label>
			<input type="text" id="qtcredit" name="qtcredit" value="0" />
			<label for="vlcredit"></label>
			<input type="text" id="vlcredit" name="vlcredit" value="0" />

			<br style="clear:both" /><br />
			<br style="clear:both" /><br />

			<h4 style="text-align:center;">Saldo Cont&aacute;bil Residual</h4>

			<br style="clear:both" /><br />

			<label for="lqtdedas_residual">Qtde.</label>
			<label for="lvalores_residual">Valor</label>

			<br />
			
			<label for="dssldant_residual">Saldo Anterior:</label>
			<label for="qtsldant_residual"></label>
			<input type="text" id="qtsldant_residual" name="qtsldant_residual" value="<?php echo getByTagName($dados->tags,'qtsldant') ?>" />
			<label for="vlsldant_residual"></label>
			<input type="text" id="vlsldant_residual" name="vlsldant_residual" value="<?php echo getByTagName($dados->tags,'vlsldant') ?>" />
			
			<br />
			
			<label for="dstitulo_residual">T&iacute;tulos Recebidos:</label>
			<label for="qttitulo_residual"></label>
			<input type="text" id="qttitulo_residual" name="qttitulo_residual" value="<?php echo getByTagName($dados->tags,'qttitulo') ?>" />
			<label for="vltitulo_residual"></label>
			<input type="text" id="vltitulo_residual" name="vltitulo_residual" value="<?php echo getByTagName($dados->tags,'vltitulo') ?>" />


			<br />
			
			<label for="dsvencid_residual">Vencimentos no dia:</label>
			<label for="qtvencid_residual"></label>
			<input type="text" id="qtvencid_residual" name="qtvencid_residual" value="<?php echo getByTagName($dados->tags,'qtvencid') ?>" />
			<label for="vlvencid_residual"></label>
			<input type="text" id="vlvencid_residual" name="vlvencid_residual" value="<?php echo getByTagName($dados->tags,'vlvencid') ?>" />

			<br />
			
			<label for="dsderesg_residual">T&iacute;tulos Resgatados:</label>
			<label for="qtderesg_residual"></label>
			<input type="text" id="qtderesg_residual" name="qtderesg_residual" value="<?php echo getByTagName($dados->tags,'qtderesg') ?>" />
			<label for="vlderesg_residual"></label>
			<input type="text" id="vlderesg_residual" name="vlderesg_residual" value="<?php echo getByTagName($dados->tags,'vlderesg') ?>" />

			<br style="clear:both" /><br />
			
			<label for="dscredit_residual">SALDO ATUAL:</label>
			<label for="qtcredit_residual"></label>
			<input type="text" id="qtcredit_residual" name="qtcredit_residual" value="<?php echo getByTagName($dados->tags,'qtcredit') ?>" />
			<label for="vlcredit_residual"></label>
			<input type="text" id="vlcredit_residual" name="vlcredit_residual" value="<?php echo getByTagName($dados->tags,'vlcredit') ?>" />
		</div>

	</fieldset>

</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
</div>


