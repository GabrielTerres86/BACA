<?php
/*!
 * FONTE        : form_ativar_processo.php
 * CRIAÇÃO      : Reginaldo Rubens da Silva (AMcom)         
 * DATA CRIAÇÃO : Março/2018
 * OBJETIVO     : Formulário para inclusão de horários de execução do programa
 *                (tela ALTERAR do cadastro de prioridades da parametrização 
 *                do Debitador Único)
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

 session_start();

 require_once('../../../includes/config.php');
 require_once('../../../includes/funcoes.php');
 require_once('../../../includes/controla_secao.php');
 require_once('../../../class/xmlfile.php');

 //----------------------------------------------------------------------------------------------------------------------------------	
// Controle de Erros
//----------------------------------------------------------------------------------------------------------------------------------
if ( $glbvars['cddepart'] <> 20 && $cddopcao <> 'C' ) {
    $msgErro	= "Acesso n&atilde;o permitido.";
    exibirErro('error', $msgErro, 'Alerta - Ayllos','',false);
}

 isPostMethod();	

 $cdprocesso = $_POST['cdprocesso'];
 $dsprocesso = $_POST['dsprocesso'];


 // Monta o xml de requisição
 $xml = "<Root>";
 $xml .= " <Dados>";
 $xml .= " </Dados>";
 $xml .= "</Root>";
 
 $xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_HR_CONSULTAR", 
     $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], 
     $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");    
 
 
 $xmlObjeto = getObjectXML($xmlResult);
 
 //----------------------------------------------------------------------------------------------------------------------------------	
 // Controle de Erros
 //----------------------------------------------------------------------------------------------------------------------------------
 if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
     $msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
     exibirErro('error',$msgErro,'Alerta - Ayllos','unblockBackground()',false);
 }

?>

                    <form id="frmDet" name="frmDet" class="formulario detalhe" onSubmit="return false;">
                        <fieldset>
                            <legend>Ativar programa</legend>
                            <input type="hidden" id="cdprocesso" name="cdprocesso" value="<?php echo $cdprocesso; ?>">
                            <label for="dsprocesso"><?php echo utf8ToHtml('Descrição do programa:'); ?></label>
                            <input type="text" class="campo" id="dsprocesso" name="dsprocesso" value="<?php echo $dsprocesso; ?>" readonly>
                        </fieldset>
                    </form>
<?php	
	$horarios = $xmlObjeto->roottag->tags[0]->tags;

    echo '<p style="text-align: center; color: grey; padding:7px;">' . utf8ToHtml('Selecione os horários para os quais deseja agendar o programa.') . '</p>';
	

	echo '	<div class="divRegistros">';
	echo '		<table>';
	echo '			<thead>';
	echo '				<tr>';	
	echo '					<th>'.utf8ToHtml('Horário').'</th>';	
	echo '				</tr>';
	echo '			</thead>';
	echo '			<tbody>';	
			
	foreach( $horarios as $horario ) { 	
		echo "<tr>";	
		echo	"<td><input type=\"hidden\" value=\"" . getByTagName($horario->tags, 'idhora_processamento') . "\"><input type=\"checkbox\" class=\"checkboxAddHorario\">&nbsp;&nbsp;" .getByTagName($horario->tags, 'dhprocessamento') . "</td>";
		echo "</tr>";
	} 	
			
	echo '			</tbody>';
	echo '		</table>';
	echo '	</div>';
