#INCLUDE 'Protheus.ch'
#INCLUDE 'PRTOPDEF.CH'

//---------------------------------------------------------------------------
/*/{PROTHEUS.DOC} LJ7061
PE LJ7061 - Ponto de Entrada chamado para valida��es na digita��o do c�digo 
			do produto na Venda Assitida e antes da impress�o concomitante.
@OWNER MADECENTER
@VERSION PROTHEUS 12
@SINCE 24/09/2024
/*/
//---------------------------------------------------------------------------
User Function LJ7061()
	
	Local lRet := .T.
	Local nPosPro := aScan(aHeader, {|x| Alltrim(x[2])=="LR_PRODUTO" })
	Local nPosDes := aScan(aHeader, {|x| Alltrim(x[2])=="LR_DESCRI" })
	Local nPosEnt := aScan(aHeader, {|x| Alltrim(x[2])=="LR_ENTREGA" })
	Local cCodPro := aCOLS[N][nPosPro]
	Local cDescPr := AllTrim(aCOLS[N][nPosDes])
	Local nY 

	DeFault lEntreg := .F.

	For nY := 1 To Len(aCOLS)
		IF nY != N .And. (aCOLS[N][Len(aCOLS[N])])
			IF aCOLS[nY][nPosPro] == aCOLS[N][nPosPro]
				FWAlertWarning("O Produto " + AllTrim(cCodPro) + " - " + cDescPr +", j� foi inserido anteriormente.","Produto")
				lRet := .F.
			EndIF
		EndIF 
	Next 

	IF lRet .And. lEntreg
		aCOLS[N][nPosEnt] := '3'
	EndIF 

Return lRet
