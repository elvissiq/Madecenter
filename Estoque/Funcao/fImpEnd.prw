

#INCLUDE "Totvs.ch"
#INCLUDE "Protheus.ch"

User Function fImpEnd()
    Local aArea  := FWGetArea()
    Local cArq   := TFileDialog( "CSV Files (*.csv) | Arquivo texto (*.txt)",,,, .F., /*GETF_MULTISELECT*/ )
    
    Private aDados := {}
    Private lMSHelpAuto := .T.
    Private lAutoErrNoFile := .T.
    Private lMsErroAuto := .F.

    If !File(cArq)
        Return
    EndIf

    While !FT_FEOF()
        aAdd(aDados,Strtokarr(FT_FREADLN(),";"))
    FT_FSKIP()
    End
    
    Processa({|| fMta265I()}, "Processando...")

    FWAlert()

    FWRestArea(aArea)

Return
Static Function fMta265I()
    Local aCab := {}
    Local aItem:= {}
    Local cFilAux := cFilAnt
    Local nY 

    ProcRegua( Len(aDados) )

    For nY := 1 To Len(aDados)

        IncProc("Integrando registro " + cValToChar(nY) + " de " + cValToChar(Len(aDados)) + "...")

        aCab := {}
        aItem:= {}

        cFilAnt := aDados[nY,1]

        aCab := { {"DA_PRODUTO", aDados[nY,2] , NIL } }

        aAdd(aItem, { {"DB_ITEM","001", NIL },;
                      {"DB_LOCALIZ", aDados[nY,3] , NIL },;
                      {"DB_DATA"   , dDataBase    , NIL },;
                      {"DB_QUANT"  , aDados[nY,4] , NIL }})
        
        lMsErroAuto := .F.
        
        MSExecAuto({|x,y,z| mata265(x,y,z)},aCab,aItem,3)

        If lMsErroAuto
            MostraErro()
        Endif

        cFilAnt := cFilAux
    Next 

Return
