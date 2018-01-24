<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 13/05/2011
 * OBJETIVO     : Cabeçalho para a tela CHEQUE
 * --------------
 * ALTERAÇÕES   : 10/06/2016 - Incluir style nos forms (Lucas Ranghetti #422753)
 *
 *                10/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 * --------------
 */ 
?>

<form id="frmCabCheque" name="frmCabCheque" class="formulario cabecalho" style="width: 720px;">	
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
	
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<? echo getByTagName($registro,'nrdconta') ?>" alt="Informe o nro. da conta do cooperado." />
	<a class="lupa"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" id="btnOK">Ok</a>

	
	<label for="nmprimtl">Titular:</label>
	<input name="nmprimtl" id="nmprimtl" type="text" value="<? echo getByTagName($registro,'nmprimtl') ?>" />

	<label for="qtrequis">Req.:</label>
	<input name="qtrequis" id="qtrequis" type="text" value="<? echo getByTagName($registro,'qtrequis') ?>" />
	
	<br style="clear:both" />	
</form>

<form id="frmTipoCheque" name="frmTipoCheque" class="formulario" style="width: 720px;">

	<input name="nrtipoop" id="tpChequ1" type="radio" class="radio" value="1" alt="Escolha o tipo de cheque que deseja consultar." />	
	<label for="tpChequ1" class="radio">Em Uso</label>	
	
	<input name="nrtipoop" id="tpChequ2" type="radio" class="radio" value="2" alt="Escolha o tipo de cheque que deseja consultar." />
	<label for="tpChequ2" class="radio">Arquivo</label>	

	<input name="nrtipoop" id="tpChequ3" type="radio" class="radio" value="3" alt="Escolha o tipo de cheque que deseja consultar." />
	<label for="tpChequ3" class="radio">Solicitados</label>
	
	<input name="nrtipoop" id="tpChequ4" type="radio" class="radio" value="4" alt="Escolha o tipo de cheque que deseja consultar." />
	<label for="tpChequ4" class="radio">Compensados</label>
	
	<input name="nrtipoop" id="tpChequ5" type="radio" class="radio" value="5" alt="Escolha o tipo de cheque que deseja consultar." />
	<label for="tpChequ5" class="radio">Todos</label>	
	
	<label for="nrregist">Nr. Reg.:</label>
	<input name="nrregist" id="nrregist" type="text" value="30" alt="Informe a quantidade de registros em cada paginacao."/>	
	
	<label for="nrcheque">A partir de:</label>
	<input name="nrcheque" id="nrcheque" type="text" value="0" alt="Insira o nro. do cheque a ser listado (sem digito) ou 0 p/ todos."/>
	
	<a href="#" class="botao" id="btBuscaCheque">Ok</a>
						
	<br style="clear:both" />	
</form>