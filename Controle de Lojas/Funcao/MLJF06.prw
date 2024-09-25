//Bibliotecas
#Include 'Protheus.ch'
#Include "TOPCONN.ch"
#Include 'FWMVCDef.ch'

//----------------------------------------------------------------------
/*/{PROTHEUS.DOC} MLJF06
FUN��O MLJF06 - Tela para consulta de Vale Presente
@VERSION PROTHEUS 12
@SINCE 25/09/2024
/*/
//----------------------------------------------------------------------

User Function MLJF06()
  Local aButtons := {{.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.T.,"Fechar"},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,NIl}}

  Private oTabTMP1  := FWTemporaryTable():New("T1")
  Private oTabTMP2  := FWTemporaryTable():New("T2")
  Private aFields1 := {}
  Private aFields2 := {}

  aAdd(aFields1,{"T1_CLIENT","C", FWTamSX3("A1_CGC")[1]    , FWTamSX3("A1_CGC")[2]    , "C�digo ou CNPJ/CPF" ,"","SA1AZ0"})
  aAdd(aFields1,{"T1_NOMCLI","C", FWTamSX3("A1_NOME")[1]   , FWTamSX3("A1_NOME")[2]   , "Nome Cliente"       ,"",""      })
  
  oTabTMP1:SetFields(aFields1)
  oTabTMP1:AddIndex("01", {"T1_CLIENT"})
  oTabTMP1:Create()

  aAdd(aFields2,{"T2_LEGEND","C", 50 ,0    , "Status" ,"@BMP",""})
  aAdd(aFields2,{"T2_CODIGO","C", FWTamSX3("MDD_CODIGO")[1] , FWTamSX3("MDD_CODIGO")[2] , "C�digo"             ,"",""})
  aAdd(aFields2,{"T2_VALOR" ,"N", FWTamSX3("MDD_VALOR")[1]  , FWTamSX3("MDD_VALOR")[2]  , "Valor"              ,PesqPict("MDD", "MDD_VALOR"),""})
  aAdd(aFields2,{"T2_SALDO" ,"N", FWTamSX3("MDD_SALDO")[1]  , FWTamSX3("MDD_SALDO")[2]  , "Saldo"              ,PesqPict("MDD", "MDD_SALDO"),""})
  aAdd(aFields2,{"T2_VEND"  ,"C", FWTamSX3("MDD_VEND")[1]   , FWTamSX3("MDD_VEND")[2]   , "Vendedor"           ,"",""})
  aAdd(aFields2,{"T2_NOME"  ,"C", FWTamSX3("A3_NOME")[1]    , FWTamSX3("A3_NOME")[2]    , "Nome"               ,"",""})
  aAdd(aFields2,{"T2_DOCV"  ,"C", FWTamSX3("MDD_DOCV")[1]   , FWTamSX3("MDD_DOCV")[2]   , "Documento de Venda" ,"",""})
  aAdd(aFields2,{"T2_ESTV"  ,"C", FWTamSX3("MDD_ESTV")[1]   , FWTamSX3("MDD_ESTV")[2]   , "Esta��o da Venda"   ,"",""})
  aAdd(aFields2,{"T2_PDVV"  ,"C", FWTamSX3("MDD_PDVV")[1]   , FWTamSX3("MDD_PDVV")[2]   , "PDV da Venda"       ,"",""})
  aAdd(aFields2,{"T2_DATAV" ,"D", FWTamSX3("MDD_DATAV")[1]  , FWTamSX3("MDD_DATAV")[2]  , "Data da Venda"      ,"",""})
  aAdd(aFields2,{"T2_HORAV" ,"C", FWTamSX3("MDD_HORAV")[1]  , FWTamSX3("MDD_HORAV")[2]  , "Hora da Venda"      ,"",""})
  
  oTabTMP2:SetFields(aFields2)
  oTabTMP2:AddIndex("01", {"T2_CODIGO"})
  oTabTMP2:Create()

  FWExecView("",'MLJF06',3,,{||.T.},,,aButtons)
  
  oTabTMP1:Delete()
  oTabTMP2:Delete()

Return

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Desc:  Cria��o do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
  Local oModel
  Local oStrTMP1 := fnM01TMP('1')
  Local oStrTMP2 := fnM01TMP('2')

  oStrTMP1:AddTrigger("T1_CLIENT", "T1_NOMCLI" ,{||.T.},{|oStrTMP1| fBusNCli(oStrTMP1) })

  oModel := MPFormModel():New('MLJF06M',/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)
  oModel:AddFields('T1MASTER',/*cOwner*/,oStrTMP1,/*bPre*/,/*bPos*/,/*bLoad*/)
  oModel:AddGrid('T2DETAIL', 'T1MASTER', oStrTMP2,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)

  oModel:SetPrimaryKey({})
  oModel:SetDescription("Historico Cliente")
  oModel:GetModel('T1MASTER'):SetDescription('Dados do Cliente')
  oModel:GetModel('T2DETAIL'):SetDescription('Creditos Correntista')

  oModel:AddCalc( 'CALCTMP2',  'T1MASTER', 'T2DETAIL', 'T2_VALOR', 'VALOR', 'SUM' , { || .T. },,'Valor')
  oModel:AddCalc( 'CALCTMP2',  'T1MASTER', 'T2DETAIL', 'T2_SALDO', 'SALDO', 'SUM' , { || .T. },,'Saldo')

  oStrTMP1:SetProperty("T1_NOMCLI", MODEL_FIELD_WHEN, {||.F.})

Return oModel

//-----------------------------------------
/*/ fnM01TMP
  Estrutura dos Par�metros.								  
/*/
//-----------------------------------------
Static Function fnM01TMP(cTab)
  Local oStruct := FWFormModelStruct():New()
  Local cField := "aFields"+cTab
  Local nId  

  oStruct:AddTable(cTab,{},"Tabela "+cTab)

  For nId := 1 To Len(&(cField))
      oStruct:AddField(&(cField)[nId][5]; 
                      ,&(cField)[nId][5]; 
                      ,&(cField)[nId][1]; 
                      ,&(cField)[nId][2];
                      ,&(cField)[nId][3];
                      ,&(cField)[nId][4];
                      ,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  Next nId

Return oStruct

//-----------------------------------------
/*/ fBusNCli
  Retorna o Nome do Cliente.								  
/*/
//-----------------------------------------
Static Function fBusNCli(oStrTMP1)
  Local cRet := ""
  Local _cAlias := GetNextAlias()
  
  cQry := " SELECT SA1.A1_NOME "
  cQry += " FROM "+RetSQLName("SA1")+" SA1 "
  cQry += " WHERE SA1.D_E_L_E_T_ <> '*' "
  cQry += " 	AND ( SA1.A1_COD = '"+AllTrim(oStrTMP1:GetValue("T1_CLIENT"))+"' OR SA1.A1_CGC = '"+AllTrim(oStrTMP1:GetValue("T1_CLIENT"))+"' ) "
  cQry := ChangeQuery(cQry)
  TCQuery cQry ALIAS (_cAlias) NEW
  
  IF !(_cAlias)->(EOF())
      cRet := Alltrim((_cAlias)->A1_NOME)
  Endif

  (_cAlias)->(DBCloseArea())

Return cRet

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Desc:  Cria��o da vis�o MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
Local oView 
Local oModel   := FWLoadModel('MLJF06')
Local oStrTMP1 := fnV01TMP('1')
Local oStrTMP2 := fnV01TMP('2')
Local oStrCalc := FWCalcStruct(oModel:GetModel('CALCTMP2'))

  oView := FWFormView():New()
  oView:SetModel(oModel)
  oView:SetProgressBar(.T.)
  oView:AddField('VIEW_TMP',oStrTMP1,'T1MASTER')
  oView:AddGrid('VIEW_TMP2',oStrTMP2,'T2DETAIL')
  oView:AddField('VIEW_CALC',oStrCalc,'CALCTMP2')
    
  oView:CreateHorizontalBox('CABEC',010)
  oView:CreateHorizontalBox('GRID',080)
  oView:CreateHorizontalBox('CALC',010)
    
  oView:SetOwnerView('VIEW_TMP','CABEC')
  oView:SetOwnerView('VIEW_TMP2','GRID')
  oView:SetOwnerView('VIEW_CALC','CALC')
    
  oView:EnableTitleView('VIEW_TMP','Cliente')
  oView:EnableTitleView('VIEW_TMP2','Cr�ditos Correntista')
    
  oView:SetViewProperty("VIEW_TMP2", "SETCSS", {"QTableView { selection-background-color: #CD853F; selection-color: #000000; }"} )
  oView:SetViewProperty("VIEW_TMP2", "GRIDSEEK",   {.T.})
  oView:SetViewProperty("VIEW_TMP2", "GRIDFILTER", {.T.})

  oView:AddUserButton( 'Consultar', 'NOTE',;
                       {|oView| FWMsgRun(, {|| fConsulta(oView) }, "Aguarde...", "Consultando Cr�ditos")},;
                        /*cToolTip  | Coment�rio do bot�o*/,;
                        /*nShortCut | Codigo da Tecla para cria��o de Tecla de Atalho*/,;
                        /*aOptions  | */,;
                        /*lShowBar */ .T.)
    
  oView:AddUserButton( 'Or�amento', 'NOTE',;
                       {|| FWMsgRun(, {|| fOrcamento() }, "Aguarde...", "Abrindo Or�amento") },;
                        /*cToolTip  | Coment�rio do bot�o*/,;
                        /*nShortCut | Codigo da Tecla para cria��o de Tecla de Atalho*/,;
                        /*aOptions  | */,;
                        /*lShowBar */ .T.)
    
  oView:SetViewAction("ASKONCANCELSHOW",{|| .F.}) // Tirar a mensagem do final "H� Altera��es n�o..."

Return oView

//-------------------------------------------------------------------
/*/ Fun��o fnV01TMP()
  Estrutura do cabe�alho (View)	
/*/
//-------------------------------------------------------------------
Static Function fnV01TMP(cTab)
  Local oViewTMP := FWFormViewStruct():New() 
  Local cField := "aFields"+cTab
  Local cCampLib := "T1_CLIENT"
  Local lLibEdit := .F.
  Local nId
  
  For nId := 1 To Len(&(cField))

    lLibEdit := IIF(&(cField)[nId][1] $ (cCampLib),.T.,.F.)

    oViewTMP:AddField(&(cField)[nId][1],;       // 01 = Nome do Campo
                        StrZero(nId,2),;        // 02 = Ordem
                        &(cField)[nId][5],;     // 03 = T�tulo do campo
                        &(cField)[nId][5],;     // 04 = Descri��o do campo
                        Nil,;                   // 05 = Array com Help
                        &(cField)[nId][2],;     // 06 = Tipo do campo
                        &(cField)[nId][6],;     // 07 = Picture
                        Nil,;                   // 08 = Bloco de PictTre Var
                        &(cField)[nId][7],;     // 09 = Consulta F3
                        lLibEdit,;              // 10 = Indica se o campo � alter�vel
                        Nil,;                   // 11 = Pasta do Campo
                        Nil,;                   // 12 = Agrupamnento do campo
                        Nil,;                   // 13 = Lista de valores permitido do campo (Combo)
                        Nil,;                   // 14 = Tamanho m�ximo da op��o do combo
                        Nil,;                   // 15 = Inicializador de Browse
                        .F.,;                   // 16 = Indica se o campo � virtual (.T. ou .F.)
                        Nil,;                   // 17 = Picture Variavel
                        Nil)                    // 18 = Indica pulo de linha ap�s o campo (.T. ou .F.)
  Next nId

Return oViewTMP

/*---------------------------------------------------------------------*
 | Func:  fConsulta                                                    |
 | Desc:  Realiza consulta na TMP2 para trazer os Vales Cr�ditos        |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function fConsulta(oView)
    Local oModel := FWModelActive() 
    Local oModelTMP1 := oModel:GetModel("T1MASTER")
    Local oModelTMP2 := oModel:GetModel("T2DETAIL")
    Local _cAlias   := GetNextAlias()
    Local cQry      := ""
    Local nLinQry   := 0
    
    oModel:GetModel('CALCTMP2'):LoadValue("VALOR", 0)
    oModel:GetModel('CALCTMP2'):LoadValue("SALDO", 0)

    oView:Refresh()

    cQry := " SELECT * "
    cQry += " FROM "+RetSQLName("MDD")+" MDD "
    cQry += " INNER JOIN "+RetSQLName("SA3")+" SA3 ON SA3.A3_COD = MDD.MDD_VEND"
    cQry += " INNER JOIN "+RetSQLName("SA1")+" SA1 ON SA1.A1_COD = MDD.MDD_CLIV"
    cQry += " WHERE MDD.D_E_L_E_T_ <> '*' "
    cQry += " 	AND SA3.D_E_L_E_T_ <> '*' "
    cQry += " 	AND SA1.D_E_L_E_T_ <> '*' "
    cQry += " 	AND MDD.MDD_FILIAL = '" + xFilial("MDD") + "'"
    cQry += " 	AND SA3.A3_FILIAL = '" + xFilial("SA3") + "'"
    cQry += " 	AND SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
    cQry += " 	AND ( SA1.A1_COD = '"+AllTrim(oModelTMP1:GetValue("T1_CLIENT"))+"' OR SA1.A1_CGC = '"+AllTrim(oModelTMP1:GetValue("T1_CLIENT"))+"' ) "
    cQry := ChangeQuery(cQry)
    TCQuery cQry ALIAS (_cAlias) NEW

    oModelTMP2:ClearData(.T.)

    While !(_cAlias)->(EOF())
        
        nLinQry++
        IF nLinQry > 1
            oModelTMP2:AddLine()
        EndIF 

        Do Case
          Case (_cAlias)->MDD_VALOR == (_cAlias)->MDD_SALDO
            oModelTMP2:LoadValue("T2_LEGEND", "BR_VERDE"    )
          Case Empty((_cAlias)->MDD_SALDO)
            oModelTMP2:LoadValue("T2_LEGEND", "BR_VERMELHO" )
          Case (_cAlias)->MDD_SALDO < (_cAlias)->MDD_VALOR
            oModelTMP2:LoadValue("T2_LEGEND", "BR_AZUL"     )
        EndCase

        oModelTMP2:LoadValue("T2_CODIGO",(_cAlias)->MDD_CODIGO      )
        oModelTMP2:LoadValue("T2_VALOR" ,(_cAlias)->MDD_VALOR       )
        oModelTMP2:LoadValue("T2_SALDO" ,(_cAlias)->MDD_SALDO       )
        oModelTMP2:LoadValue("T2_VEND"  ,(_cAlias)->MDD_VEND        )
        oModelTMP2:LoadValue("T2_NOME"  ,(_cAlias)->A3_NOME         )
        oModelTMP2:LoadValue("T2_DOCV"  ,(_cAlias)->MDD_DOCV        )
        oModelTMP2:LoadValue("T2_ESTV"  ,(_cAlias)->MDD_ESTV        )
        oModelTMP2:LoadValue("T2_PDVV"  ,(_cAlias)->MDD_PDVV        )
        oModelTMP2:LoadValue("T2_DATAV" ,STOD((_cAlias)->MDD_DATAV) )
        oModelTMP2:LoadValue("T2_HORAV" ,(_cAlias)->MDD_HORAV       )
        
        oView:Refresh('VIEW_TMP2')
    
    (_cAlias)->(DBSkip()) 
    EndDo
    
    (_cAlias)->(DBCloseArea())

    oModelTMP2:GoLine(1)
    oView:Refresh('VIEW_TMP2')
    oView:SetNoDeleteLine('VIEW_TMP2')
    oView:SetNoInsertLine('VIEW_TMP2')
    
Return

/*---------------------------------------------------------------------*
 | Func:  fOrcamento                                                   |
 | Desc:  Visualiza o Orcamento corresponde ao Vale Presente           |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function fOrcamento()
  Local aArea    := FWGetArea()
  Local aAreaSL1 := SL1->(FWGetArea())

  DBSelectArea("SL1")
  SL1->(DBSetOrder(2))
  IF SL1->(MSSeek(xFilial("SL1") + T2->T2_ESTV + T2->T2_DOCV + T2->T2_PDVV ))
    Lj7Venda("SL1", Recno(), 2)
  EndIF 

  FWRestArea(aAreaSL1)
  FWRestArea(aArea)

Return
