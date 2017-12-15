<? 
/*!
 * FONTE        : form_prestacoes.php
 * CRIAÇÃO      : André Socoloski (DB1)
 * DATA CRIAÇÃO : Março/2011 
 * OBJETIVO     : Forumlário de dados de Prestações
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 001: [05/03/2012] Adicionado campo "taxa mensal" (Tiago).
 * 002: [07/05/2013] Alterações para Consultar Imagem de docmto. digitalizado (Lucas).
 * 003: [24/05/2013] Lucas R. (CECRED): Incluir camada nas includes "../".
 * 004: [22/10/2013] Jean Michel (CECRED): Alteração do botão de consulta de imagem".
 * 005: [27/02/2014] Alterado funcao de voltar. (Jorge)
 * 006: [07/03/2014] Incluido os campos da Multa, Juros de Mora e Total Pagar. (James)
 * 007: [02/01/2015] Ajuste format numero contrato/bordero para consultar imagem 
                     do contrato; adequacao ao format pre-definido para nao ocorrer 
					 divergencia ao pesquisar no SmartShare.
                     (Chamado 181988) - (Fabricio)
 * 008: [23/04/2015] Alteracao do label "Saldo" para "Saldo Liquida". (Jaison/Gielow - SD: 262029)
 * 009: [10/10/2016] Remover verificacao de digitalizaco para o botao de consultar imagem (Lucas Ranghetti #510032)
 * 010: [23/06/2017] Adicionado campos somente para Pos-Fixado. (Jaison/James - PRJ298)
 */	
?>	
<form id="formEmpres" ></form>
<?php include("../../../../includes/rating/rating_formulario_impressao.php"); ?>
<form name="frmDadosPrest" id="frmDadosPrest" class="formulario" >
	
	<input id="nrctremp" name="nrctremp" type="hidden" value="" />
	
	<fieldset>
		<legend><? echo utf8ToHtml('Empréstimo calculado até hoje') ?></legend>
		
		<label for="nrctremp">Contrato:</label>
		<input name="nrctremp" id="nrctremp" type="text" value="" />
		
		<label for="cdpesqui">Pesquisa:</label>
		<input name="cdpesqui" id="cdpesqui" type="text" value="" />
		<br />
		
		<label for="qtaditiv">Qtd.Aditivos:</label>
		<input name="qtaditiv" id="qtaditiv" type="text" value="" />
		
		<label for="txmensal">Taxa Mensal:</label>
		<input name="txmensal" id="txmensal" type="text" value="" />
		<br />
		
		<label for="vlemprst">Emprestado:</label>
		<input name="vlemprst" id="vlemprst" type="text" value="" />
				
		<label for="txjuremp">Taxa de Juros:</label>
		<input name="txjuremp" id="txjuremp" type="text" value="" />
		<br />
		
		<label for="vlsdeved">Saldo Liquida:</label>
		<input name="vlsdeved" id="vlsdeved" type="text" value="" />
		
		<label for="vljurmes"><? echo utf8ToHtml('Juros do Mês:') ?></label>
		<input name="vljurmes" id="vljurmes" type="text" value="" />
		<br />
		
		<label for="vlpreemp"><? echo utf8ToHtml('Prestação:') ?></label>
		<input name="vlpreemp" id="vlpreemp" type="text" value="" />
		
		<label for="vljuracu">Juros Acumulados:</label>
		<input name="vljuracu" id="vljuracu" type="text" value="" />
		<br />
		
		<label for="vlprepag"><? echo utf8ToHtml('Pagos no Mês:') ?></label>
		<input name="vlprepag" id="vlprepag" type="text" value="" />
		
		<label for="dspreapg">Prest.Pagas/Tot.:</label>
		<input name="dspreapg" id="dspreapg" type="text" value="" />
		<br />
		
		<label for="vlpreapg">Parc. Pagar:</label>
		<input name="vlpreapg" id="vlpreapg" type="text" value="" />
		
		<label for="qtmesdec">Meses Decorridos:</label>
		<input name="qtmesdec" id="qtmesdec" type="text" value="" />
		<br />
		
		<label for="vlmtapar">Multa:</label>
		<input name="vlmtapar" id="vlmtapar" type="text" value="" />		
		<br />

        <?php
            // Se for Pos-Fixado
            if ($tpemprst == 2) {
                ?>
                <label for="tpatuidx"><? echo utf8ToHtml('Atualização Valor Parcela:') ?></label>
                <select name="tpatuidx" id="tpatuidx">
                    <option value="1">Diario</option>
                    <option value="2">Quinzenal</option>
                    <option value="3">Mensal</option>
                </select>
                <br />
                <?php
            }
        ?>
		
		<label for="vlmrapar">Juros Mora:</label>
		<input name="vlmrapar" id="vlmrapar" type="text" value="" />		
		<br />

        <?php
            // Se for Pos-Fixado
            if ($tpemprst == 2) {
                ?>
                <label for="idcarenc"><? echo utf8ToHtml('Carência:') ?></label>
                <select name="idcarenc" id="idcarenc">
                <?php
                    $xml  = "<Root>";
                    $xml .= " <Dados>";
                    $xml .= "   <flghabilitado>2</flghabilitado>"; // Habilitado (0-Nao/1-Sim/2-Todos)
                    $xml .= " </Dados>";
                    $xml .= "</Root>";
                    $xmlResult = mensageria($xml, "TELA_PRMPOS", "PRMPOS_BUSCA_CARENCIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
                    $xmlObject = getObjectXML($xmlResult);
                    $xmlCarenc = $xmlObject->roottag->tags[0]->tags;
                    foreach ($xmlCarenc as $reg) {
                        echo '<option value="'.getByTagName($reg->tags,'IDCARENCIA').'">'.getByTagName($reg->tags,'DSCARENCIA').'</option>';
                    }
                ?>
                </select>
                <br />
                <?php
            }
        ?>
		
		<label for="vltotpag">Total Pagar:</label>
		<input name="vltotpag" id="vltotpag" type="text" value="" />		
		<br />

        <?php
            // Se for Pos-Fixado
            if ($tpemprst == 2) {
                ?>
                <label for="dtcarenc"><? echo utf8ToHtml('Data Pagto 1ª Carência:') ?></label>
                <input name="dtcarenc" id="dtcarenc" type="text" value="" />
                <br />

                <label  for="nrdiacar"><? echo utf8ToHtml('Dias Carência:') ?></label>
                <input name="nrdiacar" id="nrdiacar" type="text" value="" />
                <br />
                <?php
            }
        ?>
		
		<label for="dslcremp"><? echo utf8ToHtml('Linha Crédito:') ?></label>
		<input name="dslcremp" id="dslcremp" type="text" value="" />
		<br />
		
		<label for="dsfinemp">Finalidade:</label>
		<input name="dsfinemp" id="dsfinemp" type="text" value="" />
		<br />
		
		<label for="dsdaval1">Avais:</label>
		<input name="dsdaval1" id="dsdaval1" type="text" value="" />
		<br />
		
		<label for="dsdaval2"></label>
		<input name="dsdaval2" id="dsdaval2" type="text" value="" />
		<br />
		
		<label for="dsdpagto">Forma Pagto:</label>
		<input name="dsdpagto" id="dsdpagto" type="text" value="" />
		<br />
	</fieldset>
</form>	
		
<div id="divBotoes">
	<a href="#"onClick="acessaOpcaoAba( 0, 0, 0, glb_nriniseq, glb_nrregist);	;return false;" ><img id="btVoltar" src="<? echo $UrlImagens;  ?>botoes/voltar.gif"  /></a>
	<? if ($prejuizo > 0) { ?>
			<a href="#"onClick="controlaOperacao('C_PREJU');return false;"> <img id="btPrejuizo" src="<? echo $UrlImagens;  ?>botoes/prejuizo.gif"  /></a>
	<? } ?>
	
	<a href="#"onClick="controlaOperacao('IMP');return false;" >	    <img id="btImprimir" src="<? echo $UrlImagens;  ?>botoes/imprimir.gif"  /></a>
	<a href="#"onClick="controlaOperacao('C_NOVA_PROP');return false;" ><img id="btSalvar"   src="<? echo $UrlImagens;  ?>botoes/continuar.gif" /></a>
	<a href="#"onClick="mostraExtrato('C_EXTRATO');return false;" >		<img id="btExtrato"  src="<? echo $UrlImagens;  ?>botoes/extrato.gif"   /></a>
	
			<a href="http://<?php echo $GEDServidor;?>/smartshare/clientes/viewerexterno.aspx?pkey=xCPtb&conta=<?php echo formataContaDVsimples($nrdconta); ?>&contrato=<?php echo formataNumericos('zz.zzz.zz9',$nrctremp,'.'); ?>&cooperativa=<?php echo $glbvars["cdcooper"]; ?>" target="_blank"><img src="<? echo $UrlImagens; ?>botoes/consultar_imagem.gif" /></a>
	
</div>			
