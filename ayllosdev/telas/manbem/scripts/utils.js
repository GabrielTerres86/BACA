
function bloqueiaCampo(element)
{
	element.addClass('bloqueado');
	if(element.is("input"))
	{
		element.val("").prop( "disabled", true );
	}
	else if(element.is("select"))
	{
		element.prop( "disabled", true );
	}
}

function validaCampo(objName, formId)
{
	var obj = $("#"+objName, formId);
	var value = obj.val();	
	var valido =true;
  
	if(value===null||value===""||value=="R$ 0,00"||value=="-1")
	{
		addErroCampo(obj, formId);	
		addMensageError(obj, formId);
		valido =false;
	}
	else{
		removeErroCampo(obj, formId);			
	}
	return valido;
}

function removeErroCampo(obj, formId)
{
	var name = obj.attr('name');		
	var label = $("label[for='"+name+"']", formId);
	if(obj.hasClass('errorInput'))
	{
		obj.removeClass('errorInput');		
		label.text( label.text().replace("* ",""));
		label.removeClass('errorLabel');
	}
}


function addErroCampo(obj, formId)
{
	var name = obj.attr('name');	
	var label = $("label[for='"+name+"']", formId);

	if(!obj.hasClass('errorInput'))
	{
		obj.addClass('errorInput');
		label.addClass('errorLabel');
		label.text( "* "+label.text());
	}	
}

function addMensageError(obj, formId)	
{
	var name = obj.attr('name');		
	var labelObj =  $("label[for='"+name+"']", formId);
  var labelText = labelObj.text();
  
  if(labelText == "* Ano Mod./Fab.:")
  {
    labelText = "* Ano Mod.:";
  }
  
	if(labelText!="")
	{
		errorMessage = errorMessage + "	 "+labelText.replace(":","")+ "<br/>";
	}
}

function validaRadio(obj)
{	
	var radios = obj;
	var check=false;
	for (var i = 0, length = radios.length; i < length; i++)
	{
		if (radios[i].checked)
		{
			check=true;
		}
	}

	if(!check)
	{
		$('.table_alie_veiculo').addClass('errorInput');
		errorMessage = errorMessage + "	 * Bem a ser substituido<br/>";
		return false;
	}
	else {		
		$('.table_alie_veiculo').removeClass('errorInput');
		return true;
	}
	
}