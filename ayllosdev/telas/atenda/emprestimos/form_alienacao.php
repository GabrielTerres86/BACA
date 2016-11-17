<?
/*!
 * FONTE        : form_alienacao.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 18/04/2011
 * OBJETIVO     : Formulário da rotina Emprestimos da tela ATENDA
 * ALTERAÇÕES   :
 * --------------
 * 000: [20/09/2011] Correções de acentuação - Marcelo L. Pereira (GATI)
 *
 *		[01/11/2012] Incluso função para definição mascara campo CPF/CNPJ (Daniel).
 *		[06/12/2013] Incluso função para definição mascara campo Nr Placa e Renavan(Guilherme/SUPERO).
 *		[29/01/2014] Substituída função criar o campo de UF Licenc (Guilherme/SUPERO).
 *		[21/03/2014] Campo idseqbem como Hidden (Guilherme/SUPERO).
 *      [21/07/2014] Removido o valor default de 999-9999 do campo Número da Placa. (James)
 *      [12/11/2014] Projeto consultas automatizadas (Jonata-RKAM).
 *      [13/01/2015] Adicionado Tipo de Veiculo. (Jorge/Gielow) - SD 241854.
 *		[25/01/2016] Alterar a chamada do botao Salvar. (James) 
 */
 ?>

<form name="frmAlienacao" id="frmAlienacao" class="formulario">

	<input id="nrctremp" name="nrctremp" type="hidden" value="" />

	<label id="lsbemfin"></label>
	<br />

	<label for="dscatbem">Categoria:</label>
	<select name="dscatbem" id="dscatbem" onChange="formataCategoriaBem(this.value);" ></select>
	<label for="dstipbem">Tipo Ve&iacute;culo:</label>
	<select name="dstipbem" id="dstipbem">
		<option value="ZERO KM"> 1 - Zero KM</option>
		<option value="USADO" selected> 2 - Usado</option>
	</select>
	<br />

	<label for="dsbemfin"><? echo utf8ToHtml('Descrição:') ?></label>
	<input name="dsbemfin" id="dsbemfin" type="text" value="" />

	<label for="tpchassi">Tipo Chassi:</label>
	<select name="tpchassi" id="tpchassi">
		<option value="1"> 1 - Remarcado</option>
		<option value="2" selected> 2 - Normal</option>
	</select>
	<br />

	<label for="dscorbem">Cor/Classe:</label>
	<input name="dscorbem" id="dscorbem" type="text" value="" />
	<label for="vlmerbem">Valor de Mercado:</label>
	<input name="vlmerbem" id="vlmerbem" type="text" value="" />
	<br />

	<label for="ufdplaca">UF/Placa:</label>
	<? echo selectEstado('ufdplaca', '', 1) ?>
	<input name="nrdplaca" id="nrdplaca" type="text" value="" />

	<label for="dschassi">Chassi/N.Serie:</label>
	<input name="dschassi" id="dschassi" type="text" value="" />
	<br />

	<label for="nrrenava">RENAVAM:</label>
	<input name="nrrenava" id="nrrenava" type="text" value="" />

	<label for="uflicenc">UF Licenciamento:</label>
    <input name="uflicenc" id="uflicenc" type="text" value="" disabled />


	<label for="nranobem">Ano Fab.:</label>
	<input name="nranobem" id="nranobem" type="text" value="" />
	<br />

	<label for="nrmodbem">Ano Mod.:</label>
	<input name="nrmodbem" id="nrmodbem" type="text" value="" />

	<label for="nrcpfbem">CPF/CNPJ Propr.:</label>
	<input name="nrcpfbem" id="nrcpfbem" onKeyPress="VerificaPessoa(this.value)" onKeyUp="VerificaPessoa(this.value)" type="text" value="" />
	<br />

</form>

<div id="divBotoes">
	<? if ( $operacao == 'A_ALIENACAO' ) { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('A_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="validaAlienacao('atualizaArray(\'A_ALIENACAO\');','A_ALIENACAO'); return false;">Continuar</a>
	<? } else if ($operacao == 'AI_ALIENACAO') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('A_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="validaAlienacao('insereAlienacao(\'A_ALIENACAO\',\'A_INTEV_ANU\');','A_ALIENACAO'); return false;">Continuar</a>		
	<? } else if ($operacao == 'C_ALIENACAO') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('CF'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="controlaOperacao('C_ALIENACAO'); return false;">Continuar</a>
	<? } else if ($operacao == 'E_ALIENACAO') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Voltar</a>
	<? } else if ($operacao == 'I_ALIENACAO') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('I_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="validaAlienacao('insereAlienacao(\'I_ALIENACAO\',\'I_INTEV_ANU\');','I_ALIENACAO'); return false;">Continuar</a>		
	<? } else if ( $operacao == 'IA_ALIENACAO' ) { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('I_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="validaAlienacao('atualizaArray(\'I_ALIENACAO\');','I_ALIENACAO'); return false;">Continuar</a>
	<? } ?>
</div>

<script>

	$(document).ready(function() {
        highlightObjFocus($('#frmAlienacao'));
	});

	function VerificaPessoa( campo ){
		if ( verificaTipoPessoa( campo ) == 1 ) {
		$('#nrcpfbem', '#frmAlienacao').setMask('INTEGER','999.999.999-99','.-','');
		} else if( verificaTipoPessoa( campo ) == 2 ) {
			$('#nrcpfbem', '#frmAlienacao').setMask('INTEGER','z.zzz.zzz/zzzz-zz','/.-','');
		} else {
			$('#nrcpfbem', '#frmAlienacao').setMask('INTEGER', 'zzzzzzzzzzzzzz','','');
		}
	};

    function formataCategoriaBem(dscatbem) {

        $('#nrdplaca', '#frmAlienacao').removeClass('placa');
		$('#nrdplaca', '#frmAlienacao').setMask('STRING' ,'zzz-zzzz','-','');
		/*
        //$('#nrrenava', '#frmAlienacao').removeClass('renavan');
        if (dscatbem == 'AUTOMOVEL' ||
            dscatbem == 'MOTO'      ||
            dscatbem == 'CAMINHAO') {
            $('#nrdplaca', '#frmAlienacao').setMask('STRING' ,'zzz-zzzz','-','');
          //  $('#nrrenava', '#frmAlienacao').setMask('INTEGER','zz.zzz.zzz.zz9','.','');
        }
        else{
            $('#nrdplaca', '#frmAlienacao').setMask('STRING' ,'zzz-zzzz','-','');
           // $('#nrrenava', '#frmAlienacao').setMask('INTEGER','zzz.zzz.zzz.zz9','.','');
        }*/
    };

</script>