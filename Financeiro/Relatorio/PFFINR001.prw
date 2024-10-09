#Include "Protheus.ch"
#Include "FwPrintSetup.Ch" 
#Include "RptDef.Ch" 

#DEFINE ENTER Chr(10)+Chr(13)
#define PAD_LEFT		0
#define PAD_RIGHT		1
#define PAD_CENTER   	2

/*/{Protheus.doc} PFINR001
Recibo de Movimento Bancário
@type function
@version
@author TOTVS Nordeste
@since 07/10/2024
@return 
/*/
User Function PFINR001()

Local nLin       := 40
Local nCol       := 13
Local cNomeEmp   := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_NOMECOM" } )[1][2])
Local cCNPJ      := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2]
Local cMun       := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CIDENT" } )[1][2])

Private  cPathPDF := ""

oFont10  := TFont():New( "Arial",,10,,.F.,,,,,.F. )
oFont10B := TFont():New( "Arial",,10,,.T.,,,,,.F. )
oFont11  := TFont():New( "Arial",,11,,.F.,,,,,.F. )
oFont11B := TFont():New( "Arial",,11,,.T.,,,,,.F. )
oFont12  := TFont():New( "Arial",,12,,.F.,,,,,.F. )
oFont12B := TFont():New( "Arial",,12,,.T.,,,,,.F. )
oFont13  := TFont():New( "Arial",,13,,.F.,,,,,.F. )
oFont13B := TFont():New( "Arial",,13,,.T.,,,,,.F. )
oFont14  := TFont():New( "Arial",,14,,.F.,,,,,.F. )
oFont14B := TFont():New( "Arial",,14,,.T.,,,,,.F. )
oFont15  := TFont():New( "Arial",,15,,.F.,,,,,.F. )
oFont15B := TFont():New( "Arial",,15,,.T.,,,,,.F. )
oFont16  := TFont():New( "Arial",,16,,.F.,,,,,.F. )
oFont16B := TFont():New( "Arial",,16,,.T.,,,,,.F. )

// Inicialize o objeto desta forma
oPrint:=FWMSPrinter():New("recibo.rel",IMP_PDF, .F., , .T.)
oPrint:SetResolution(72)
oPrint:SetPortrait()
oPrint:SetPaperSize(DMPAPER_A4)
oPrint:SetMargin(60,60,60,60) // nEsquerda, nSuperior, nDireita, nInferior
oPrint:cPathPDF := "C:\TOTVS\TEMP\"
oPrint:StartPage()

			oPrint:Say (nLin, nCol, cCNPJ +" - "+ Alltrim(cNomeEmp), oFont16B,,,,PAD_LEFT)
			nLin += 10
			oPrint:Line(nLin,nCol,nLin,nCol+540)
			nLin += 20
			oPrint:Say (nLin, nCol+155, "Recibo de Movimento Bancário", oFont16B,,,,PAD_CENTER)
			nLin += 15
			oPrint:Line(nLin,nCol,nLin,nCol+540)
			nLin += 20
			oPrint:Say (nLin, nCol, "Nº Recebimento: " + E5_IDMOVI, oFont16B,,,,PAD_CENTER)
			nLin += 20
			oPrint:Say (nLin, nCol, "Valor: R$ " + Alltrim(Transform(E5_VALOR,PesqPict( 'SE5', 'E5_VALOR' ))), oFont14B,,,,PAD_CENTER)
			oPrint:Say (nLin, nCol+110, " ( "+Extenso(E5_VALOR,.F.,1)+" )", oFont10,,,,PAD_CENTER)
			nLin += 20
			oPrint:Say (nLin, nCol+350, cMun + Space(2) + Day2Str(Date()) + " de" + Space(2) + MesExtenso(Month(Date())) + " de";
			 			  + Space(2)	+ Year2Str(Date()),oFont12,,,,PAD_CENTER)
			nLin += 20
			oPrint:Say (nLin, nCol+350, "Recebido de: ", oFont12B,,,,PAD_CENTER)
			nLin += 15	
			oPrint:Say (nLin, nCol+350, E5_BENEF , oFont12,,,,PAD_CENTER)
			nLin += 20
			oPrint:Say (nLin, nCol+350, "Tesoureiro: ", oFont12B,,,,PAD_CENTER)
			nLin += 15
			oPrint:Say (nLin, nCol+350, UPPER(UsrFullName(RetCodUsr())), oFont12,,,,PAD_CENTER)
			nLin += 20
			oPrint:Box(nLin,nCol,nLin+40,nCol+540)
			nLin += 15
			oPrint:Say (nLin, nCol+5, "Este recibo destina-se a: ", oFont12,,,,PAD_CENTER)
			nLin += 15
			oPrint:Say (nLin, nCol+12, E5_HISTOR, oFont12,,,,PAD_CENTER)

oPrint:EndPage()
oPrint:Preview()

ms_flush()

Return
