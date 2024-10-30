#Include "PROTHEUS.CH"

/*/{Protheus.doc} StMenEdt
Este Ponto de Entrada � executado na inicializa��o da rotina TOTVS PDV para adi��o de novos itens no menu e possui como par�metro de entrada, 
o array referente ao menu padr�o do TOTVS PDV e retorna os itens de menu espec�ficos do usu�rio.
@author Elvis Siqueira
@since 	30/10/2024
@param 	
@return Array(array_of_record) Retorno do ponto de entrada, contendo a seguinte estrutura
@see 	(https://tdn.totvs.com/pages/releaseview.action?pageId=152802891)
@obs	Estrutura do Array de Retorno. 
		Array(array_of_record) Retorno do ponto de entrada, contendo a seguinte estrutura
		aRet[1][1] - T�tulo do Menu do Tipo String (Texto) - Ex.: "Menu"
		aRet[1][2] - Fun��o a ser executada do Tipo String ( Texto ) - "U_MeuPrograma"
/*/
User Function STMenu()
	Local aRetor 	:= {}
	
	aAdd(aRetor,{"Reimpressao de Comprovantes","U_MLJF07()"})

Return(aRetor)
