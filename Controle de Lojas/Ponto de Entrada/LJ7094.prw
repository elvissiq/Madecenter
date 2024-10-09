#INCLUDE 'Protheus.ch'
#INCLUDE 'PRTOPDEF.CH'

//---------------------------------------------------------------------------------------------------------------------
/*/{PROTHEUS.DOC} LJ7094
PE LJ7094 - Este Ponto de entrada � utilizado para permitir ao usu�rio alterar 
			a regra de utiliza��o do valor do Vale Presente, na finaliza��o da venda. 
			No modelo padr�o, se o valor da venda for diferente do valor do Vale Presente, a venda n�o � finalizada..
@OWNER MADECENTER
@VERSION PROTHEUS 12
@SINCE 25/09/2024
/*/
//---------------------------------------------------------------------------------------------------------------------
User Function LJ7094()
	
	Local lRet 	   := .F.
	//Local aColsVP  := ParamIXB[1] // Acols com os itens de Vale presente
	Local nVlrPgto := ParamIXB[2] // Valor da compra
	Local nValorVP := ParamIXB[3] // Valor do Vale Presente

	If nVlrPgto <= nValorVP
		lRet := .T.
	EndIf

Return lRet
