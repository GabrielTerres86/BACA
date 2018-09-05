<?php
/*!
 * FONTE        : form_convenio_cdc.php
 * CRIAÇÃO      : Andre Santos (SUPERO)
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Formulário da rotina Convenio CDC da tela de CONTAS 
 * --------------
 * ALTERAÇÕES   : 11/08/2016 - Inclusao de campos para apresentacao no site da cooperativa.
 *                             (Jaison/Anderson)
 *
 *                19/01/2017 - Alterado layout do form de convenio e adicionado lupa para o CEP. (Reinert)
 *					
 *				  27/03/2017 - Adicionado o botão "Dossie DigiDOC". (Projeto 357 - Reinert)
	 *					
	 *				  			29/11/2017 - Inclusão de novas funcionalidades, Prj.402 (Jean Michel)
	 *               
	 *                          04/05/2018 - Iclusão de novos campos e funcionalidades Reestruturação CDC - Diego Simas - AMcom
	 *
 * --------------
 */	
?>
<form name="frmConvenioCdc" id="frmConvenioCdc" class="formulario">

    <div id="divDados" class="clsCampos">
        
    <input type="hidden" id="cdestado" name="cdestado" value="<?php echo ($cdestado ? $cdestado : $cdufende); ?>" />
    <label for="flgconve" class="clsCampos">Possui Convênio CDC:</label>
	<select id="flgconve" name="flgconve" class="clsCampos">
        <option value="1" <?php echo ($flgconve == 1 ? 'selected' : ''); ?>>Sim</option>
		<option value="0" <?php echo ($flgconve == 0 ? 'selected' : ''); ?>>Não</option>
	</select>
        <label for="dtinicon" class="clsCampos">Data Início:</label>
    <input name="dtinicon" id="dtinicon" type="text" value="<?php echo $dtinicon ; ?>" autocomplete="off" class="clsCampos" />
        <label for="dtacectr" class="clsCampos">Data Migração:</label>
        <input name="dtacectr" id="dtacectr" type="text" value="<?php echo $dtacectr ; ?>" autocomplete="off" class="clsCampos" />
		
            </br>
		
    <fieldset style="padding: 5px">
			<legend style="margin-top: 10px; padding: 2px 10px 2px 10px">Cancelamento</legend>
		
			
			<label for="inmotcan" class="clsCampos">Motivo:</label>
            <select id="inmotcan" name="inmotcan" class="clsCampos">
                <option value="" <?php echo ($inmotcan == 0 ? 'selected' : ''); ?>>-</option>
                <option value="1" <?php echo ($inmotcan == 1 ? 'selected' : ''); ?>>Inadimplência</option>
                <option value="2" <?php echo ($inmotcan == 2 ? 'selected' : ''); ?>>Não Utiliza CDC</option>
                <option value="3" <?php echo ($inmotcan == 3 ? 'selected' : ''); ?>>Empresa Inativa</option>
                <option value="4" <?php echo ($inmotcan == 4 ? 'selected' : ''); ?>>Conta Demitida</option>
                <option value="5" <?php echo ($inmotcan == 5 ? 'selected' : ''); ?>>Outros</option>
            </select>

            <label for="dsmotcan" class="clsCampos">Outro:</label>
            <input type="text" class="clsCampos" id="dsmotcan" name="dsmotcan" value="<?php echo $dsmotcan; ?>" />
			
			<label for="dtcancon" class="clsCampos">Data:</label>
			<input name="dtcancon" id="dtcancon" type="text" value="<?php echo $dtcancon ; ?>" autocomplete="off" class="clsCampos" />
		</br>
		
		</fieldset>
			
            <label for="dtrencon" class="clsCampos">Data Renovação:</label>
        <input name="dtrencon" id="dtrencon" type="text" value="<?php echo $dtrencon ; ?>" autocomplete="off" class="clsCampos" />
            
            <label for="dttercon" class="clsCampos">Data Término:</label>
        <input name="dttercon" id="dttercon" type="text" value="<?php echo $dttercon ; ?>" autocomplete="off" class="clsCampos" />

        <label for="flgitctr" class="clsCampos">Tarifa Contratual:</label>
	        <select id="flgitctr" name="flgitctr" class="clsCampos">
		        <option value="1" <?php echo ($flgitctr == 1 ? 'selected' : ''); ?>>Isentar</option>
		        <option value="0" <?php echo ($flgitctr == 0 ? 'selected' : ''); ?>>Cobrar</option>
	        </select>		
	</div>	
    <fieldset style="padding: 5px">
        <legend style="margin-top: 10px; padding: 2px 10px 2px 10px">Dados para o Site da Cooperativa</legend>
            
            <label for="idcooperado_cdc">Código:</label>
            <input type="text" id="idcooperado_cdc" name="idcooperado_cdc" value="<?php echo $idcooperado_cdc ; ?>" />
            
            
        <label for="nmfantasia">Nome fantasia:</label>
        <input type="text" id="nmfantasia" name="nmfantasia" value="<?php echo $nmfantasia; ?>" />
        <label for="cdcnae" class="clsCampos">CNAE:</label>
        <input type="text" id="cdcnae" name="cdcnae" value="<?php echo $cdcnae; ?>" class="clsCampos" />
        <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" class="clsCampos"></a>
        <input type="text" id="dscnae" name="dscnae" class="clsCampos" />
        <label for="nrcepend">CEP:</label>
        <input type="text" id="nrcepend" name="nrcepend" value="<?php echo $nrcep; ?>"/>
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>		
        <label for="dslogradouro">Endereço:</label>
        <input type="text" id="dslogradouro" name="dslogradouro" value="<?php echo $dslogradouro; ?>" />
        <label for="nrendereco">Nr:</label>
        <input type="text" id="nrendereco" name="nrendereco" value="<?php echo $nrendereco; ?>" />
        <label for="dscomplemento">Complemento:</label>
        <input type="text" id="dscomplemento" name="dscomplemento" value="<?php echo $dscomplemento; ?>" />
        <label for="nmbairro">Bairro:</label>
        <input type="text" id="nmbairro" name="nmbairro" value="<?php echo $nmbairro; ?>" />
		<label for="idcidade">Cidade:</label>
		<input type="text" id="idcidade" name="idcidade" value="<?php echo $idcidade; ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input type="text" id="dscidade" name="dscidade" value="<?php echo $dscidade; ?>" />
		<label for="cdufende">UF:</label>
		<input type="text" id="cdufende" name="cdufende" value="<?php echo $cdufende; ?>" />
        <label for="dstelefone">Telefone:</label>
        <input type="text" id="dstelefone" name="dstelefone" value="<?php echo $dstelefone; ?>" />
        <label for="dsemail">E-mail:</label>
        <input type="text" id="dsemail" name="dsemail" value="<?php echo $dsemail; ?>" />
			<br/>  
				<label for="idcomissao" class="clsCampos">Comissão:</label>
        <input type="text" id="idcomissao" name="idcomissao" value="<?php echo $idcomissao; ?>"  class="clsCampos"/>
				<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" class="clsCampos"></a>	
				<input type="text" id="nmcomissao" name="nmcomissao" class="clsCampos" value="<?php echo $nmcomissao; ?>" />	
			<br/>      
			<label for="nrlatitude">Latitude:</label>
			<input type="text" id="nrlatitude" name="nrlatitude" maxlength="15" value="<?php echo $nrlatitude; ?>" />
			<br/>
			<label for="nrlongitude">Longitude:</label>
			<input type="text" id="nrlongitude" name="nrlongitude" maxlength="15" value="<?php echo $nrlongitude; ?>" />
	</fieldset>
</form>

<div id="divBotoes">	
	<? if ( in_array($operacao,array('AC',''))){ ?>
        <input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="encerraRotina(true);return false;" />
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaOperacao('CA')" />
        <input type="image" id="btFiliais" src="<? echo $UrlImagens; ?>botoes/filiais.png"  onClick="controlaOperacao('FILIAIS')" />
		<input class="FluxoNavega" id="btndossie" onclick="dossieDigdoc(4);return false;" type="image" src="<? echo $UrlImagens; ?>botoes/dossie.gif">
	<? } else if ( $operacao == 'CA' ){ ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('AC')" />		
		<input type="image" id="btSalvar"  src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('ALTERAR')" />
	<? } else if ( in_array($operacao,array('FCA','FCI'))){ ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="controlaOperacao('FILIAIS')" />		
		<input type="image" id="btSalvar"  src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('<?php echo ($operacao == 'FCA' ? 'ALTERAR' : 'INCLUIR' ); ?>')" />
	<? } ?>
</div>
