<?php
/*!
 * FONTE        : filiais.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : Agosto/2016
 * OBJETIVO     : Listagem das filiais
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	

	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();

    // Guardo os parâmetos do POST em variáveis	
    $idmatriz = (isset($_POST['idmatriz'])) ? $_POST['idmatriz'] : 'C';

    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <idmatriz>".$idmatriz."</idmatriz>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_ATENDA_CVNCDC", "CVNCDC_BUSCA_FILIAL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObject->roottag->tags[0]->cdata;
        }
        exibirErro('error',$msgErro,'Alerta - Aimaro','acessaOpcaoAba(\'P\',0)');
    }

    $registros = $xmlObject->roottag->tags[0]->tags;
?>
<div class="divRegistros">	
	<table>
		<thead>
			<tr>
				<th width="180">Filial</th>
				<th width="170">Cidade</th>
				<th width="120">Bairro</th>
			</tr>
		</thead>
		<tbody id="tBodyRegs">
			<?php
                foreach ($registros as $reg) {
                    $idcooperado_cdc = getByTagName($reg->tags,'IDCOOPERADO_CDC');
                    $nmfantasia      = getByTagName($reg->tags,'NMFANTASIA');
                    $dscidade        = getByTagName($reg->tags,'DSCIDADE');
                    $nmbairro        = getByTagName($reg->tags,'NMBAIRRO');
                    ?>
                    <tr>
                        <td><span><?php echo $nmfantasia; ?></span>
                                  <?php echo $nmfantasia; ?>
                                  <input type="hidden" id="glbIdMatriz" value="<?php echo $idmatriz; ?>" />
                                  <input type="hidden" id="glbIdCooperado_CDC" value="<?php echo $idcooperado_cdc; ?>" />
                        </td>
                        <td><span><?php echo $dscidade; ?></span>
                                  <?php echo $dscidade; ?>
                        </td>
                        <td><span><?php echo $nmbairro; ?></span>
                                  <?php echo $nmbairro; ?>
                        </td>
                    </tr>
                    <?php
                }
            ?>	
		</tbody>
	</table>
</div>

<div id="divBotoes">	
	<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="acessaOpcaoAba('P',0)" />
	<input type="image" id="btExcluir" src="<? echo $UrlImagens; ?>botoes/excluir.gif"  onClick="controlaOperacao('FCE')" />
    <input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaOperacao('FCA')" />
    <input type="image" id="btIncluir" src="<? echo $UrlImagens; ?>botoes/incluir.gif"  onClick="controlaOperacao('FCI')" />
</div>