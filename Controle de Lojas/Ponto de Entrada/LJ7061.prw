#INCLUDE 'Protheus.ch'
#INCLUDE 'PRTOPDEF.CH'

//------------------------------------------------------------------------
/*/{PROTHEUS.DOC} ValidSLR
FUNÇÃO ValidSLR - Valida se o produto já foi inserido no grid de produtos
@OWNER MADECENTER
@VERSION PROTHEUS 12
@SINCE 23/08/2024
/*/
//------------------------------------------------------------------------
User Function LJ7061()
	
	Local lRet := .T.
	Local nPosPro := aScan(aHeader, {|x| Alltrim(x[2])=="LR_PRODUTO" })
	Local nPosDes := aScan(aHeader, {|x| Alltrim(x[2])=="LR_DESCRI" })
	Local cCodPro := aCOLS[N][nPosPro]
	Local cDescPr := AllTrim(aCOLS[N][nPosDes])
	Local nY 

	For nY := 1 To Len(aCOLS)
		IF nY != N 
			IF aCOLS[nY][nPosPro] == aCOLS[N][nPosPro]
				FWAlertWarning("O Produto " + AllTrim(cCodPro) + " - " + cDescPr +", já foi inserido anteriormente.","Produto")
				lRet := .F.
			EndIF
		EndIF 
	Next 

Return lRet
