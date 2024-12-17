#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#Include 'FWMVCDef.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#include "fileio.ch"

#define LF chr(10)

/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+---------------------------- ------------------------------------------+��
���Fun��o    �  XAG0106	   � Autor � Lucilene Mendes     � Data �03.11.22 ���
��+----------+------------------------------------------------------------���
���Descri��o �  Tela de log de integra��o de t�tulos com o banco via API  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function XAG0106()
	Local cTitulo 	:= "Log de Integra��o Banc�ria"
	Local cPerg		:= "LOGINTBCO"
	Local cFiltro	:= ""
	Local oBrowse
	Private aRotina := {}
	Private dDateSel := dDataBase

//Carrega os registros
	dbSelectArea("ZLA")
	ZLA->(dbGoTop())

//Filtro para acessara tela
	AjustaSX1(cPerg)
	If Pergunte(cPerg)
		If MV_PAR01 = 1
			cFiltro := "ZLA_RECPAG<>' '"
		Else
			cFiltro := "ZLA_RECPAG=='"+IIF(MV_PAR01=2,"P","R")+"'"
		Endif
		If !Empty(MV_PAR02)
			cFiltro+=".AND.ZLA_CLIFOR=='"+MV_PAR02+"'"
		Endif
		If !Empty(MV_PAR03)
			cFiltro+=".AND.DTOS(ZLA_DATA)=='"+DTOS(MV_PAR03)+"'"
			dDateSel := MV_PAR03
		Endif
		If MV_PAR04 = 1
			cFiltro+=".AND.ZLA_STATUS<>' '"
		Else
			cFiltro+=".AND.ZLA_STATUS=='"+cValtoChar(MV_PAR04)+"'"
		Endif
	Endif

//Inst�nciando FWMBrowse - Somente com dicion�rio de dados
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZLA")
	oBrowse:SetMenuDef( 'XAG0106' )
	//oBrowse:SetFieldMark( 'ZLA_OK' )
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetDBFFilter(.T.)
	oBrowse:SetFilterDefault(cFiltro)
//oBrowse:DisableDetails()
	oBrowse:SetSeek()
	oBrowse:SetLocate()

//Legendas
	oBrowse:AddLegend( "ZLA->ZLA_STATUS == '0'", "GRAY",	"Erro" )
	oBrowse:AddLegend( "ZLA->ZLA_STATUS == '1'", "BLUE",	"Enviado" )
	oBrowse:AddLegend( "ZLA->ZLA_STATUS == '2'", "GREEN",	"Entrada Confirmada" )
	oBrowse:AddLegend( "ZLA->ZLA_STATUS == '3'", "RED",		"Pago" )
	oBrowse:AddLegend( "ZLA->ZLA_STATUS == '4'", "ORANGE",	"Aguardando Aprova��o" )
	oBrowse:AddLegend( "ZLA->ZLA_STATUS == '5'", "BLACK",	"Cancelado" )
	oBrowse:AddLegend( "ZLA->ZLA_STATUS == '6'", "WHITE",	"Erro Comunica��o" )

//Ativa a Browse
	oBrowse:Activate()

Return

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Cria��o do menu MVC                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
	Private aRotina := {}
	
	//Adicionando op��es
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.XAG0106' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Gerar/Enviar'    ACTION 'U_XAG0107' OPERATION 3 ACCESS 0 //OPERATION 4	
	ADD OPTION aRotina TITLE 'Consultar Status'    ACTION 'U_XAG0107S' OPERATION 3 ACCESS 0 //OPERATION 4	
	ADD OPTION aRotina TITLE 'Aprovar'    ACTION 'U_XAG0107R' OPERATION 1 ACCESS 0 //OPERATION 4
	//ADD OPTION aRotina TITLE 'Posi��o'    ACTION 'FINC010' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	//
	//ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.XAG0106' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRotina
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Cria��o do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStPai 		:= FWFormStruct(1, 'ZLA')
	Local oStFilho 		:= FWFormStruct(1, 'ZLB')
	Local aZLBRel		:= {}

	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('_XAG0106')
	oModel:AddFields('ZLAMASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('ZLBDETAIL','ZLAMASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner � para quem pertence
	
	//Fazendo o relacionamento entre o Pai e Filho
	aAdd(aZLBRel, {'ZLB_FILIAL',	'ZLA_FILIAL'} )
	aAdd(aZLBRel, {'ZLB_CODIGO',	'ZLA_CODIGO'}) 
	aAdd(aZLBRel, {'ZLB_FILORI',	'ZLA_FILORI'}) 
	
	oModel:SetRelation('ZLBDETAIL', aZLBRel, ZLB->(IndexKey(1))) //IndexKey -> quero a ordena��o e depois filtrado
	//oModel:GetModel('ZLBDETAIL'):SetUniqueLine({"ZLB_FILIAL","ZLB_COD"})	//N�o repetir informa��es ou combina��es {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})
	
	//Setando as descri��es
	oModel:SetDescription("Log de Integra��o Banc�ria")
	oModel:GetModel('ZLAMASTER'):SetDescription('Modelo ZLA')
	oModel:GetModel('ZLBDETAIL'):SetDescription('Modelo ZLB')

Return oModel
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Cria��o da vis�o MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FWLoadModel('XAG0106') //ModelDef() 
	Local oStPai	:= FWFormStruct(2, 'ZLA')
	Local oStFilho	:= FWFormStruct(2, 'ZLB')
	
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Adicionando os campos do cabe�alho e o grid dos filhos
	oView:AddField('VIEW_ZLA',oStPai,'ZLAMASTER')
	oView:AddGrid('VIEW_ZLB',oStFilho,'ZLBDETAIL')
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',30)
	oView:CreateHorizontalBox('GRID',70)
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_ZLA','CABEC')
	oView:SetOwnerView('VIEW_ZLB','GRID')
	
	//Habilitando t�tulo
	oView:EnableTitleView('VIEW_ZLA','Log')
	oView:EnableTitleView('VIEW_ZLB','Detalhes')
	
	//Tratativa padrao para fechar a tela
    oView:SetCloseOnOk({||.T.})

	//Remove os campos de Filial e Tabela da Grid
    oStFilho:RemoveField('ZLB_FILIAL')
    oStFilho:RemoveField('ZLB_CODIGO')
	
Return oView


/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    �  XAG0107    � Autor � Lucilene Mendes    � Data �11.11.22  ���
��+----------+------------------------------------------------------------���
���Descri��o �  Gera��o de titulos para fluxo de aprova��o                ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function XAG0107(oObjLog)
Local cPerg:= "XAG0107"
Local cTitulo:= ""
Local cBcosAPI := GetNewPar("MV_XBCOAPI","001/237")
Local lAuto := isBlind()
Local cCodigo := ""
Private lTransferencia:= .F.
Private lBoleto:= .F.
Private lGuiaCB:= .F.	
Private nQtd:= 0
Default oObjLog:= nil

If !lAuto
	AjustaPerg(cPerg)
	If !Pergunte(cPerg)
		Return
	Endif
Endif

//Localiza os border�s
cQry:= "Select * From "+RetSqlName("SEA")+" SEA "
cQry+= "Where EA_FILIAL = '"+xFilial("SEA")+"' "
cQry+= "And EA_NUMBOR >= '"+MV_PAR01+"' and EA_NUMBOR <= '"+MV_PAR02+"' "
cQry+= "And EA_TRANSF = ' ' "
cQry+= "And SEA.D_E_L_E_T_ = ' ' "
If Select("QRY") > 0
	QRY->(dbCloseArea())
Endif	
TcQuery cQry New Alias "QRY"

If QRY->(Eof())
	If lAuto
		oObjLog:saveMsg("N�o foram encontrados t�tulos para grava��o!")
	Else
		Aviso("Aten��o","N�o foram encontrados t�tulos para grava��o!",{"OK"})
	Endif
	Return
Endif

SEE->(dbSetOrder(1))
SEE->(dbGotop())
If !SEE->(dbSeek(xFilial("SEE")+MV_PAR03+MV_PAR04+MV_PAR05+MV_PAR06))
	If lAuto
		oObjLog:saveMsg("Banco "+MV_PAR03+" Ag. "+MV_PAR04+" Conta "+MV_PAR05+" SubConta "+MV_PAR06+" n�o encontrado nos parametros de banco!")
	Else
		Aviso("Aten��o","Banco "+MV_PAR03+" Ag. "+MV_PAR04+" Conta "+MV_PAR05+" SubConta "+MV_PAR06+" n�o encontrado nos parametros de banco!",{"OK"},2)
	Endif
		Return
Endif


cContaVer := ALLTRIM(QRY->EA_NUMCON)


QRY->(dbGoTop())
WHILE QRY->(!Eof())
	IF QRY->EA_PORTADO $ cBcosAPI  
		IF QRY->EA_CART = "R"
			Receb106()
			nQtd ++
		ELSE //Pagamentos	
			
			IF(SUBSTRING(cContaVer,1,LEN(cContaVer)-1) <> ALLTRIM(MV_PAR05))
				FWAlertError("Conta do border�: "+QRY->EA_NUMBOR+"  diferente da conta informada. Conta: "+QRY->EA_NUMCON, "XAG0106")
				return .F.
			ELSE
				IF(EnvApr106())				
					nQtd ++
				ENDIF		
			ENDIF					
		ENDIF			
	ENDIF
	QRY->(dbSkip())
	
End

If !lAuto
	Aviso("Envio de border�",Iif(nQtd = 0, "N�o identificamos titulos, revise os parametros informados!","Foram enviados "+cvaltochar(nQtd)+" t�tulos para aprova��o."),{"OK"})
Endif

Return

user function ZLAEXIST(cPrefixo, cNumero, cParcela, cTipo, cFornece, cLoja, cNumBor)

Local aRet := {}
Local cQuery := ""

cQuery := "SELECT ZLA_CODIGO FROM ZLA010 ZLA WHERE D_E_L_E_T_ <> '*' "
cQuery += "AND ZLA_PREFIX = '"+cPrefixo+"' "
cQuery += "AND ZLA_NUM = '"+cNumero+"' "
cQuery += "AND ZLA_PARCEL = '"+cParcela+"' "
cQuery += "AND ZLA_TIPO = '"+cTipo+"' "
cQuery += "AND ZLA_CLIFOR = '"+cFornece+"' "
cQuery += "AND ZLA_LOJA = '"+cLoja+"' "
cQuery += "AND ZLA_NUMBOR = '"+cNumBor+"' "


If Select("QRYZLA") > 0
	QRYZLA->(dbCloseArea())
Endif
TcQuery cQuery New Alias "QRYZLA"
If !QRYZLA->(Eof())
	AADD(aRet, .T.)
	AADD(aRet, QRYZLA->ZLA_CODIGO)
	return aRet
ELSE
	AADD(aRet, .F.)
	AADD(aRet, "NAO ENCONTRADO")
ENDIF

return aRet

user function ZLAUPDATE(cPrefixo, cNumero, cParcela, cTipo, cFornece, cLoja,cNumBor, cStatus)
Local bRet
Local aZLA

aZLA := U_ZLAEXIST(cPrefixo, cNumero, cParcela, cTipo, cFornece, cLoja, cNumBor)

IF(aZLA[1])
	cQryStatus := "UPDATE ZLA010 SET ZLA_STATUS = '"+cStatus+"' WHERE D_E_L_E_T_ <> '*' "
	cQryStatus += "AND ZLA_PREFIX = '"+cPrefixo+"' "
	cQryStatus += "AND ZLA_NUM = '"+cNumero+"' "
	cQryStatus += "AND ZLA_PARCEL = '"+cParcela+"' "
	cQryStatus += "AND ZLA_TIPO = '"+cTipo+"' "
	cQryStatus += "AND ZLA_CLIFOR = '"+cFornece+"' "
	cQryStatus += "AND ZLA_LOJA = '"+cLoja+"' "

	TcSqlExec(cQryStatus)

	aZLA[1] := .T.
ELSE
	aZLA[1] := .F.
ENDIF

RETURN aZLA


user function ZLACAMPO(cPrefixo, cNumero, cParcela, cTipo, cFornece, cLoja,cNumBor, cCampo,cValue)
Local bRet
Local aZLA

aZLA := U_ZLAEXIST(cPrefixo, cNumero, cParcela, cTipo, cFornece, cLoja, cNumBor)

IF(aZLA[1])
	cQryStatus := "UPDATE ZLA010 SET "+cCampo+" = '"+cValue+"' WHERE D_E_L_E_T_ <> '*' "
	cQryStatus += "AND ZLA_PREFIX = '"+cPrefixo+"' "
	cQryStatus += "AND ZLA_NUM = '"+cNumero+"' "
	cQryStatus += "AND ZLA_PARCEL = '"+cParcela+"' "
	cQryStatus += "AND ZLA_TIPO = '"+cTipo+"' "
	cQryStatus += "AND ZLA_CLIFOR = '"+cFornece+"' "
	cQryStatus += "AND ZLA_LOJA = '"+cLoja+"' "

	TcSqlExec(cQryStatus)
	bRet := .T.
ELSE
	bRet := .F.
ENDIF

return bRet

user function ZLBHIST(cFilori, cCodigo, cStatus, cMsg, cEvento)

Reclock("ZLB",.T.)
	ZLB->ZLB_FILIAL:= xFilial("ZLB")
	ZLB->ZLB_CODIGO:= cCodigo
	ZLB->ZLB_DATA:= dDataBase
	ZLB->ZLB_HORA := Time()
	ZLB->ZLB_EVENTO:= cEvento
	ZLB->ZLB_STATUS:= cStatus
	ZLB->ZLB_USER:= __cUserId
	ZLB->ZLB_ERRO:= cMsg
	ZLB->ZLB_FILORI:= cFilori
	msUnlock()

return 


static function EnvApr106
Local lRec := .F.

	cCodigo:= GetSxENum("ZLA", "ZLA_CODIGO")
	ConfirmSX8()

	IF SE2->(dbSeek(xFilial("SE2")+QRY->(EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA)))
		IF SE2->E2_SALDO > 0	
	       	aZLA := U_ZLAEXIST(QRY->EA_PREFIXO, QRY->EA_NUM,  QRY->EA_PARCELA, QRY->EA_TIPO, QRY->EA_FORNECE, QRY->EA_LOJA, QRY->EA_NUMBOR)
			IF(!aZLA[1])			
				Reclock("ZLA",.T.)
				ZLA->ZLA_FILIAL:= xFilial("ZLA")
				ZLA->ZLA_PREFIX:= SE2->E2_PREFIXO
				ZLA->ZLA_NUM:= SE2->E2_NUM
				ZLA->ZLA_PARCEL:= SE2->E2_PARCELA
				ZLA->ZLA_TIPO:= SE2->E2_TIPO
				ZLA->ZLA_CLIFOR:= SE2->E2_FORNECE
				ZLA->ZLA_LOJA:= SE2->E2_LOJA
				ZLA->ZLA_VENCTO:= SE2->E2_VENCREA
				ZLA->ZLA_VALOR:= SE2->E2_SALDO
				ZLA->ZLA_NUMBOR:= SE2->E2_NUMBOR
				ZLA->ZLA_BANCO:= SEE->EE_CODIGO
				ZLA->ZLA_AGENCI:= SEE->EE_AGENCIA
				ZLA->ZLA_CONTA:= SEE->EE_CONTA
				ZLA->ZLA_RECPAG:= 'P'
				ZLA->ZLA_STATUS:= '4'
				ZLA->ZLA_DATA:= dDataBase
				ZLA->ZLA_USER:= __cUserId
				ZLA->ZLA_CODIGO:= cCodigo
				ZLA->ZLA_IDCNAB:= SE2->E2_IDCNAB
				ZLA->ZLA_FILORI:= SE2->E2_FILORIG				
				MsUnlock()
			
				Reclock("ZLB",.T.)
				ZLB_FILIAL:= xFilial("ZLB")
				ZLB_CODIGO:= cCodigo
				ZLB_DATA:= dDataBase
				ZLB_HORA:= Time()
				ZLB_EVENTO:= '6'
				ZLB_STATUS:= ZLA->ZLA_STATUS
				ZLB_USER:= __cUserId
				ZLB_ERRO:= "Aguardando aprova��o"
				ZLB_FILORI:= ZLA->ZLA_FILORI
				msUnlock()

				lRec := .T.
			ENDIF
		ENDIF
	ENDIF
return lRec

user function XAG0107S
Default oObjLog:= nil

	IF(ZLA->ZLA_STATUS == "2" .OR. ZLA->ZLA_STATUS == "0" .OR. ZLA->ZLA_STATUS == "6" .OR. ZLA->ZLA_STATUS == "5") //entrada confirmada, erro, erro comunica��o.
		IF(ZLA->ZLA_RECPAG == "P")
			U_XAG0107P(oObjLog, .T.)
		ELSE
			FWAlertError("Consulta de status somente de titulos a pagar.", "XAG0106")
		ENDIF
	ELSE 
		FWAlertError("Titulo ainda n�o aprovado.", "XAG0106")
	ENDIF
return

user function XAG0107R
Default oObjLog:= nil

IF(ZLA_RECPAG == "P")

	IF(ZLA_STATUS == "3")
		FWAlertError("Titulo j� esta baixado", "XAG0106")
		return
	ENDIF

	IF(ZLA_STATUS == "0" .OR. ZLA_STATUS == "4" .OR. ZLA_STATUS == "2" .OR. ZLA->ZLA_STATUS == "6")
		U_XAG0107P(oObjLog, .F.)
	ELSE
		FWAlertError("Status inv�lido", "XAG0106")
	ENDIF
ELSE
	FWAlertError("Aprova��o somente de titulos a pagar.", "XAG0106")
ENDIF

return .F.

user function XAG0107P(oObjLog, bConsulta)
Local cPerg:= "XAG0107"
Local cTitulo:= ""
Local cBcosAPI := GetNewPar("MV_XBCOAPI","001/237")
Local lAuto := isBlind()

Local cCodigo := ""
Local bBoleto := .F.
Local bPix := .F.
Local aBorderos := {}
Local aLstBor := {}
Local MvParDef := ""
Private lTransferencia:= .F.
Private lBoleto:= .F.

Private lGuiaCB:= .F.

Default oObjLog:= nil

//If !lAuto
//	AjustaPerg(cPerg)
	//If !Pergunte(cPerg)
		//Return
	//Endif
//Endif

//multiplos borderos
	IF(!lAuto)
		cQry:= "SELECT distinct EA_NUMBOR NUMBOR FROM "+RetSqlName("SEA")+" SEA "
		cQry+= "WHERE EA_FILIAL = '"+xFilial("SEA")+"' "
		//cQry+= "AND EA_NUMBOR >= '"+MV_PAR01+"' AND EA_NUMBOR <= '"+MV_PAR02+"' "
		cQry+= "AND EA_DATABOR = '"+DTOS(dDateSel)+"' "

		IF(bConsulta)
			cQry += " "
		ELSE
			cQry += "AND EA_TRANSF = ' ' "
		ENDIF

		IF(ZLA->ZLA_BANCO == "237")
			cQry+= " AND EA_PORTADO = '"+ZLA->ZLA_BANCO+"' AND SUBSTRING(EA_AGEDEP,1,5) = '"+ALLTRIM(ZLA->ZLA_AGENCI)+"' AND SUBSTRING(EA_NUMCON,1,7) = '"+ALLTRIM(ZLA->ZLA_CONTA)+"' AND EA_CART = 'P' "
		ELSE
			cQry+= " AND EA_PORTADO = '"+ZLA->ZLA_BANCO+"' AND SUBSTRING(EA_AGEDEP,1,4) = '"+ALLTRIM(ZLA->ZLA_AGENCI)+"' AND SUBSTRING(EA_NUMCON,1,6) = '"+ALLTRIM(ZLA->ZLA_CONTA)+"' AND EA_CART = 'P' "
		ENDIF
		cQry+= "And SEA.D_E_L_E_T_ = ' ' "

		If Select("QRYDST") > 0
			QRYDST->(dbCloseArea())
		Endif
		TcQuery cQry New Alias "QRYDST"

		While QRYDST->(!Eof())
			AADD(aLstBor,ALLTRIM(QRYDST->NUMBOR))
			MvParDef+= ALLTRIM(QRYDST->NUMBOR)
			QRYDST->(dbSkip())
		End

		cQry:= "SELECT * FROM "+RetSqlName("SEA")+" SEA "
		cQry+= "WHERE EA_FILIAL = '"+xFilial("SEA")+"' "
		IF(!bConsulta)
			IF f_Opcoes(@aBorderos,"Selecione Border�s para Aprova��o",aLstBor,MvParDef,12,49,.F.,6,5)  // Chama funcao f_Opcoes (padr�o Protheus)

				cQry+= "AND EA_NUMBOR IN ('"+ArrTokStr(aBorderos,"','")+"') "

			ELSE

				cQry+= "AND EA_NUMBOR >= '"+ZLA->ZLA_NUMBOR+"' AND EA_NUMBOR <= '"+ZLA->ZLA_NUMBOR+"' "
			
			EndIF
		else
			cQry+= "AND EA_NUMBOR >= '"+ZLA->ZLA_NUMBOR+"' AND EA_NUMBOR <= '"+ZLA->ZLA_NUMBOR+"' "
		ENDIF
	ELSE
		cQry:= "SELECT * FROM "+RetSqlName("SEA")+" SEA "
		cQry+= "WHERE EA_FILIAL = '"+xFilial("SEA")+"' "
		cQry+= "AND EA_NUMBOR >= '"+ZLA->ZLA_NUMBOR+"' AND EA_NUMBOR <= '"+ZLA->ZLA_NUMBOR+"' "
	ENDIF
/*
Function f_Opcoes(	uVarRet			,;	//Variavel de Retorno
			cTitulo			,;	//Titulo da Coluna com as opcoes
			aOpcoes			,;	//Opcoes de Escolha (Array de Opcoes)
			cOpcoes			,;	//String de Opcoes para Retorno
			nLin1			,;	//Nao Utilizado
			nCol1			,;	//Nao Utilizado
			l1Elem			,;	//Se a Selecao sera de apenas 1 Elemento por vez
			nTam			,;	//Tamanho da Chave
			nElemRet		,;	//No maximo de elementos na variavel de retorno
			lMultSelect		,;	//Inclui Botoes para Selecao de Multiplos Itens
			lComboBox		,;	//Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
			cCampo			,;	//Qual o Campo para a Montagem do aOpcoes
			lNotOrdena		,;	//Nao Permite a Ordenacao
			lNotPesq		,;	//Nao Permite a Pesquisa	
			lForceRetArr		,;	//Forca o Retorno Como Array
			cF3			 ;	//Consulta F3	
		  )

*/

//Localiza os border�s a pagar


IF(bConsulta)
	cQry += " "
ELSE
	cQry += "AND EA_TRANSF = ' ' "
ENDIF

IF(ZLA->ZLA_BANCO == "237")
	cQry+= " AND EA_PORTADO = '"+ZLA->ZLA_BANCO+"' AND SUBSTRING(EA_AGEDEP,1,5) = '"+ALLTRIM(ZLA->ZLA_AGENCI)+"' AND SUBSTRING(EA_NUMCON,1,7) = '"+ALLTRIM(ZLA->ZLA_CONTA)+"' AND EA_CART = 'P' "
ELSE
	cQry+= " AND EA_PORTADO = '"+ZLA->ZLA_BANCO+"' AND SUBSTRING(EA_AGEDEP,1,4) = '"+ALLTRIM(ZLA->ZLA_AGENCI)+"' AND SUBSTRING(EA_NUMCON,1,6) = '"+ALLTRIM(ZLA->ZLA_CONTA)+"' AND EA_CART = 'P' "
ENDIF
//adicionar filtro do banco e agencia

cQry+= "And SEA.D_E_L_E_T_ = ' ' "

If Select("QRY") > 0
	QRY->(dbCloseArea())
Endif
TcQuery cQry New Alias "QRY"

If QRY->(Eof())
	If lAuto
		oObjLog:saveMsg("N�o foram encontrados t�tulos (Contate a TI)!")
	Else
		Aviso("Aten��o","N�o foram encontrados t�tulos (Contate a TI)!",{"OK"})
	Endif

	Reclock("ZLA",.F.)
	ZLA->ZLA_STATUS:= '5'
	ZLA->ZLA_DTOPER := Date()
	MsUnlock()

	Reclock("ZLB",.T.)
	ZLB->ZLB_FILIAL:= xFilial("ZLB")
	ZLB_CODIGO:= ZLA->ZLA_CODIGO
	ZLB_DATA:= dDataBase
	ZLB_HORA:= Time()
	ZLB_EVENTO:= '1' //Altera��o boleto
	ZLB_STATUS:= '5'
	ZLB_USER:= __cUserId
	ZLB_ERRO:= "Cancelado."
	ZLB_FILORI:= ZLA->ZLA_FILORI
	msUnlock()

Return
Endif

SEE->(dbSetOrder(1))
SEE->(dbGotop())
If !SEE->(dbSeek(xFilial("SEE")+ZLA->ZLA_BANCO+ZLA->ZLA_AGENCI+ZLA->ZLA_CONTA+"PAG"))
	If lAuto
		oObjLog:saveMsg("Banco "+ZLA->ZLA_BANCO+" Ag. "+ZLA->ZLA_AGENCI+" Conta "+ZLA->ZLA_CONTA+" SubConta PAG n�o encontrado nos parametros de banco!")
	Else
		Aviso("Aten��o","Banco "+ZLA->ZLA_BANCO+" Ag. "+ZLA->ZLA_AGENCI+" Conta "+ZLA->ZLA_CONTA+" SubConta PAG n�o encontrado nos parametros de banco!",{"OK"},2)
	Endif
Return
Endif

//sele��o dos titulos..

IF(__cUserId $ GETMV("MV_XLIBBOR"))
	//oObjLog:saveMsg("Usu�rio "+__cUserId+" aprovou pagamentos via API")
ELSE
	IF(!bConsulta)
		FWAlertWarning("Usu�rio sem permiss�o para envio de informa��es ao banco!", "MV_XLIBBOR - Solicitar libera��o!")
		return
	ENDIF
ENDIF



IF(bConsulta)
	cClientId := ALLTRIM(SEE->EE_ZZCLIID)
	If SE2->(dbSeek(xFilial("SE2")+ZLA->(ZLA_PREFIX+ZLA_NUM+ZLA_PARCEL+ZLA_TIPO+ZLA_CLIFOR+ZLA_LOJA)))
		DBselectarea("SEA")
		SEA->(dbSetOrder(1))
		If SEA->(dbSeek(xFilial("SEA")+SE2->E2_NUMBOR+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO))

			IF(!EMPTY(SE2->E2_CODBAR))
				bBoleto := .T.
			ELSE
				bBoleto := .F.
			ENDIF
			
			IF(SEA->EA_MODELO == "48" .AND. !bBoleto)
				bPix := .T.
			ENDIF
			//aqui
			IF(bBoleto)
				//Boleto
				consPGT106(ZLA->ZLA_CODIGO, cClientId)
			ELSE
				IF(bPix)
					//PIX BAIXA
					oPix := BRDPix():New()
					oPix:cIdTransacao := ALLTRIM(ZLA->ZLA_IDTRAN)
					oPix:cE2e := ALLTRIM(ZLA->ZLA_PIXE2E)
					IF(oPix:ConsultaTransferencia())
						aRet := {}
						aAdd(aRet,stod(oPix:cDataPag))
                		aAdd(aRet,oPix:nValor)
						u_BaixaPag(aRet)
					ENDIF

				ELSE
					//transferencia TED
					U_XAG0122(cClientId)
				ENDIF
			ENDIF

		ENDIF
	ENDIF
ELSE
	XAGMARKAPR()
ENDIF

return

static function XAGMARKAPR()
	Local aSeek       := {}
	Private oMark := FWMarkBrowse():New()
	Private cMarca := oMark:Mark()
	Private oDlgExemp
	Private aSize := MsAdvSize(.F.)
	Private nJanLarg := aSize[5]
	Private nJanAltu := aSize[6]
	Private cFontUti    := "Tahoma"
	Private oFontSay    := TFont():New(cFontUti, , -12)
	Private oSayTot, cSayTot := "Total selecionado:"
	Private oGetTot, oGetQtd
	Private nGetTot := 0
	Private nGetQtd := 0
	Private cMascara := "@E 999,999,999,999,999.99"
	Private aRotina := {}


	aStru:={}
	Aadd(aStru,{"OK"     ,"C",02,0})
	Aadd(aStru,{"FILIAL","C",04,0})
	Aadd(aStru,{"PREFIXO","C",03,0})
	Aadd(aStru,{"NUMERO"   ,"C",09,0})
	Aadd(aStru,{"PARCELA"   ,"C",03,0})
	Aadd(aStru,{"TIPO"   ,"C",03,0})
	Aadd(aStru,{"FORNECE"   ,"C",06,0})
	Aadd(aStru,{"LOJA"   ,"C",02,0})
	Aadd(aStru,{"NOME"   ,"C",40,0})
	Aadd(aStru,{"VENCTO"   ,"D",10,0})
	Aadd(aStru,{"VALOR","N",17,2})
	Aadd(aStru,{"NUMBOR"  ,"C",06,0})
	Aadd(aStru,{"BANCO"  ,"C",03,0})
	Aadd(aStru,{"AGENCI"  ,"C",05,0})
	Aadd(aStru,{"CONTA"  ,"C",10,0})
	Aadd(aStru,{"MODELO"  ,"C",02,0})

	If (Select("TRB") <> 0)
		dbSelectArea("TRB")
		dbCloseArea()
	Endif

	oTempTable := FWTemporaryTable():New( "TRB" )

	oTemptable:SetFields( aStru )
	oTempTable:AddIndex("indice1", {"FILIAL", "PREFIXO", "NUMERO", "PARCELA"} )
	oTempTable:Create()
	aAdd(aSeek,{"Filial + Prefixo + Numero + Parcela"	,{{"","C",009,0,"Numero"	,"@!"}} } )
	DbSelectArea('TRB')

	QRY->(dbGoTop())
	While QRY->(!Eof())
		If SE2->(dbSeek(xFilial("SE2")+QRY->(EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA)))
			RECLOCK("TRB",.T.)
			TRB->FILIAL:= xFilial("ZLA")
			TRB->PREFIXO:= SE2->E2_PREFIXO
			TRB->NUMERO:= SE2->E2_NUM
			TRB->PARCELA:= SE2->E2_PARCELA
			TRB->TIPO:= SE2->E2_TIPO
			TRB->FORNECE:= SE2->E2_FORNECE
			TRB->LOJA:= SE2->E2_LOJA
			TRB->NOME:= Posicione("SA2", 1, xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA, "A2_NOME")
			TRB->VENCTO:= SE2->E2_VENCREA
			TRB->VALOR:= SE2->E2_SALDO
			TRB->NUMBOR:= SE2->E2_NUMBOR
			TRB->BANCO:= SEE->EE_CODIGO
			TRB->AGENCI:= SEE->EE_AGENCIA
			TRB->CONTA:= SEE->EE_CONTA
			TRB->MODELO:= QRY->EA_MODELO
			MSUNLOCK()
		endif
		QRY->(dbSkip())
	End

 

	TRB->(DbGoTop())
	If TRB->(!Eof())

		DEFINE MSDIALOG oDlgExemp TITLE "SELE��O DE TITULOS PARA PAGAMENTO"  FROM 0, 0 TO nJanAltu, nJanLarg PIXEL

		oFwLayer := FwLayer():New()
		oFwLayer:init(oDlgExemp,.F.)

		oFWLayer:addLine("CORPO",  085, .F.)
		oFWLayer:addLine("RODAPE", 015, .F.)

		oFWLayer:addCollumn("COLGRID",      100, .T., "CORPO")
		oFWLayer:addCollumn("COLBTN",     100, .T., "RODAPE")

		oPanGrid   := oFWLayer:GetColPanel("COLGRID",    "CORPO")
		oPanTotal   := oFWLayer:GetColPanel("COLBTN",    "RODAPE")

		oSaySubTit := TSay():New(014, 005, {|| "Valor total selecionado:."}, oPanTotal, "", oSayTot, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )

		oMark:SetDescription('SELE��O DE TITULOS PARA PAGAMENTO')

		oMark:SetAlias("TRB")
		oMark:SetFieldMark( "OK" )
		oMark:oBrowse:SetMenuDef( 'XAG0107' )
		oMark:oBrowse:SetDBFFilter(.T.)
		oMark:oBrowse:SetUseFilter(.T.)
		oMark:oBrowse:SetFixedBrowse(.T.)
		oMark:SetWalkThru(.F.)
		oMark:SetAmbiente(.T.)
		oMark:SetTemporary()
		oMark:oBrowse:SetSeek(.T.,aSeek)
		oMark:oBrowse:SetFilterDefault("")

		oMark:SetAllMark( { || fInvert() } )
		oMark:ForceQuitButton(.T.)

		aRotina := {}
		bAprova := {|| Confirmar() }

		oMark:AddButton('Confirmar',bAprova,nil,1,0)
		//oMark:AddButton("Sair",{|| MsAguarde({|| Close(oDlgExemp) },'Encerrando...')  },,2,,.F.)

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||FILIAL})
		oColumn:SetTitle("Filial")
		oColumn:SetSize(1)
		oMark:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||PREFIXO})
		oColumn:SetTitle("Prefixo")
		oColumn:SetSize(1)
		oMark:SetColumns({oColumn})


		oColumn := FWBrwColumn():New()
		oColumn:SetData({||NUMERO})
		oColumn:SetTitle("Titulo")
		oColumn:SetSize(1)
		oMark:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||PARCELA})
		oColumn:SetTitle("Parcel")
		oColumn:SetSize(1)
		oMark:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||MODELO})
		oColumn:SetTitle("Modelo")
		oColumn:SetSize(1)
		oMark:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||TIPO})
		oColumn:SetTitle("Tipo")
		oColumn:SetSize(1)
		oMark:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||FORNECE})
		oColumn:SetTitle("Fornecedor")
		oColumn:SetSize(1)
		oMark:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||LOJA})
		oColumn:SetTitle("Loja")
		oColumn:SetSize(1)
		oMark:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||NOME})
		oColumn:SetTitle("Nome")
		oColumn:SetSize(10)
		oMark:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||VENCTO})
		oColumn:SetTitle("Vencimento")
		oColumn:SetSize(1)
		oMark:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||VALOR})
		oColumn:SetTitle("Valor")
		oColumn:SetPicture("@E 999,999,999.99")
		oColumn:SetSize(1)
		oMark:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||NUMBOR})
		oColumn:SetTitle("Numero Bor.")
		oColumn:SetSize(1)
		oMark:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||BANCO})
		oColumn:SetTitle("Banco")
		oColumn:SetSize(1)
		oMark:SetColumns({oColumn})


		oColumn := FWBrwColumn():New()
		oColumn:SetData({||AGENCI})
		oColumn:SetTitle("Agencia")
		oColumn:SetSize(1)
		oMark:SetColumns({oColumn})

		oColumn := FWBrwColumn():New()
		oColumn:SetData({||CONTA})
		oColumn:SetTitle("Conta")
		oColumn:SetSize(1)
		oMark:SetColumns({oColumn})

		oMark:SetOwner(oPanGrid)

		oMark:SetCustomMarkRec({||EditaCell(oMark)})


		oMark:Activate()
		oMark:oBrowse:Setfocus()

		nLargPanel := (oPanTotal:nWidth) / 2
		nLinhaObj  := 30
		oSayTot := TSay():New(nLinhaObj, 003, {|| cSayTot}, oPanTotal, "", oFontSay,  , , , .T., RGB(031, 073, 125), , 200, 10, , , , , , .F., , )
		nLinhaObj += 10

		oGetQtd  := TGet():New(nLinhaObj, 010, {|u| Iif(PCount() > 0 , nGetQtd := u, nGetQtd)}, oPanTotal, 60, 15, cMascara, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)
		oGetQtd:lReadOnly := .T.

		oGetTot  := TGet():New(nLinhaObj, 100, {|u| Iif(PCount() > 0 , nGetTot := u, nGetTot)}, oPanTotal, 125, 15, cMascara, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)
		oGetTot:lReadOnly := .T.

		Activate MsDialog oDlgExemp Centered

	else
		MSGINFO("Nenhum registro encontrado.")
	endif

	dbCloseArea()
	oTempTable:Delete()
return



static function fInvert

	Local aBkpArea     := GetArea()
	Local cItens         := ""
	Local cMarca := oMark:Mark()

	TRB->(dbGoTop())
	While TRB->(!Eof())
		RecLock( 'TRB', .F. )
		if(oMark:IsMark(cMarca))
			nGetTot -= TRB->VALOR
			nGetQtd := nGetQtd-1
			TRB->OK := ""
		ELSE
			nGetTot += TRB->VALOR
			nGetQtd := nGetQtd+1
			TRB->OK := cMarca
		ENDIF
		MSUNLOCK()

		TRB->(dbSkip())
	End
	TRB->(dbGoTop())

	oGetTot:Refresh()
	oGetQtd:Refresh()
	oMark:Refresh()


return

Static Function EditaCell(oMarkBrow)
	Local aBkpArea     := GetArea()
	Local nPosCol     := oMarkBrow:oBrowse:ColPos()-1//Desconta campo de marca��o
	Local cItens         := ""
	Local cMarca := oMark:Mark()

	RecLock( 'TRB', .F. )
	IF(TRB->OK != cMarca)
		nGetTot += TRB->VALOR
		nGetQtd := nGetQtd+1
		TRB->OK := cMarca
	ELSE
		nGetTot -= TRB->VALOR
		nGetQtd := nGetQtd-1
		TRB->OK := ""
	ENDIF
	MSUNLOCK()

Return

static function Confirmar
	Local cBcosAPI := ""
	Local bAprovou := .F.

	oProcess := MsNewProcess():New({|| ConfTransacao(oProcess)}, "Processando...", "Aguarde...", .T.)
	oProcess:Activate()

	Close(oDlgExemp)

Return

Static Function ConfTransacao(oObj)
	Local aArea  := GetArea()
	Local nAtual := 0
	Local nTotal := 0
	Local nAtu2  := 0
	Local nTot2  := 4

	cBcosAPI := GetNewPar("MV_XBCOAPI","001/237")

	Count To nTotal
	oObj:SetRegua1(nTotal)
	oObj:SetRegua2(nTot2)

	TRB->(dbGoTop())
	While TRB->(!Eof())
		nAtual++
		If TRB->BANCO $ cBcosAPI
			if(oMark:IsMark(cMarca))
				oObj:IncRegua1("Efetuando aprova��o registro "+ TRB->NUMERO + "...")
				oObj:IncRegua2("Iniciando envio titulo ")
				Pagam106(oObj)
				bAprovou := .T.
			ENDIF
		Endif
		TRB->(dbSkip())
	End
	RestArea(aArea)
Return

Static function Receb106
	Local nQtd := 0
	Local cTitulo:= ""
	Local lAuto := isBlind()
	Local cCodigo := ""
	SE1->(dbSetOrder(1))
	If SE1->(dbSeek(xFilial("SE1")+QRY->(EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO)))
		//Verifica se j� foi confirmado
		cQry:= "Select * From "+RetSqlName("ZLA")+" ZLA "
		cQry+= "Where ZLA_PREFIX = '"+QRY->EA_PREFIXO+"' "
		cQry+= "And ZLA_NUM = '"+QRY->EA_NUM+"' "
		cQry+= "And ZLA_PARCEL = '"+QRY->EA_PARCELA+"' "
		cQry+= "And ZLA_TIPO = '"+QRY->EA_TIPO+"' "
		cQry+= "And ZLA_STATUS = '2' "
		cQry+= "And ZLA.D_E_L_E_T_ = ' ' "
		If Select("QRS") > 0
			QRS->(dbCloseArea())
		EndIf
		TcQuery cQry New Alias "QRS"

		If Contar("QRS","!Eof()") = 0 .and. SE1->E1_SALDO > 0
			nQtd++
			//Posiciona no cliente
			SA1->(dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))

			//Grava o idcnab
			If Empty(SE1->E1_IDCNAB)
				Reclock("SE1",.F.)
				SE1->E1_IDCNAB:= GetSxENum("SE1", "E1_IDCNAB","E1_IDCNAB"+cEmpAnt)
				MsUnlock()
				ConfirmSX8()
			Endif

			If QRY->EA_PORTADO == '001'

				cTitulo:= '{'
				cTitulo+= '"numeroConvenio": '+Alltrim(SEE->EE_CODEMP)+','
				cTitulo+= '"numeroCarteira": '+Alltrim(SEE->EE_CODCART)+','
				cTitulo+= '"numeroVariacaoCarteira": "'+Alltrim(SEE->EE_VARCART )+'",'
				cTitulo+= '"codigoModalidade": 4,' //1=Simples; 4=Vinculada
				cTitulo+= '"dataEmissao": "'+StrTran(Left(FWTIMESTAMP(2,SE1->E1_EMISSAO),10),"/",".")+'",'
				cTitulo+= '"dataVencimento": "'+StrTran(Left(FWTIMESTAMP(2,SE1->E1_VENCREA),10),"/",".")+'",'
				cTitulo+= '"valorOriginal": '+Alltrim(STRTRAN(TRANSFORM(SE1->E1_VALOR,"@E 99999999999999.99"),",","."))+','
				cTitulo+= '"valorAbatimento": 0,'
				cTitulo+= '"quantidadeDiasProtesto": '+cValtoChar(val(SEE->EE_DIASPRT))+','
				// cTitulo+= '"quantidadeDiasNegativacao": 0,'
				// cTitulo+= '"orgaoNegativador": 0,'
				// cTitulo+= '"indicadorAceiteTituloVencido": "string",'
				// cTitulo+= '"numeroDiasLimiteRecebimento": 0,'
				cTitulo+= '"codigoAceite": "N",'
				cTitulo+= '"codigoTipoTitulo": 2,'
				cTitulo+= '"descricaoTipoTitulo": "DM",'
				cTitulo+= '"indicadorPermissaoRecebimentoParcial": "N",'
				cTitulo+= '"numeroTituloBeneficiario": "'+Alltrim(SE1->E1_NUM)+Alltrim(SE1->E1_PARCELA)+'",'
				// cTitulo+= '"campoUtilizacaoBeneficiario": "string",'
				cTitulo+= '"numeroTituloCliente": "000'+Alltrim(SEE->EE_CODEMP)+PADL(Right(Alltrim(NossoNum()),10),10,'0')+'",'
				cTitulo+= '"mensagemBloquetoOcorrencia": "'+Alltrim(SEE->EE_FORMEN1)+'",'
				cTitulo+= '"desconto": {'
				cTitulo+= '		"tipo": 0,'
				// cTitulo+= '		"dataExpiracao": "string",'
				cTitulo+= '		"porcentagem": 0,'
				cTitulo+= '		"valor": 0'
				cTitulo+= '		},'
				// cTitulo+= '"segundoDesconto": {'
				// cTitulo+= '		"dataExpiracao": "string",'
				// cTitulo+= '		"porcentagem": 0,'
				// cTitulo+= '		"valor": 0'
				// cTitulo+= '		},'
				// cTitulo+= '"terceiroDesconto": {'
				// cTitulo+= '		"dataExpiracao": "string",'
				// cTitulo+= '		"porcentagem": 0,'
				// cTitulo+= '		"valor": 0'
				// cTitulo+= '		},'
				cTitulo+= '"jurosMora": {'
				cTitulo+= '		"tipo": '+Iif(SE1->E1_VALJUR > 0,'1','0')+',' //VALOR DIA DE ATRASO
				cTitulo+= '		"porcentagem": 0,'//'+cValtochar(Round(GetMV("MV_TXPER"),2))+','
				cTitulo+= '		"valor": '+Alltrim(STRTRAN(TRANSFORM(SE1->E1_VALJUR,"@E 99999999999999.99"),",","."))
				cTitulo+= '		},'
				// cTitulo+= '"multa": {'
				// cTitulo+= '		"tipo": 0,'
				// cTitulo+= '		"data": "string",'
				// cTitulo+= '		"porcentagem": 0,'
				// cTitulo+= '		"valor": 0'
				// cTitulo+= '		},'
				cTitulo+= '"pagador": {'
				cTitulo+= '		"tipoInscricao": '+IIF(LEN(Alltrim(SA1->A1_CGC))=14,'2','1')+','
				cTitulo+= '		"numeroInscricao": "'+STRZERO(VAL(SA1->A1_CGC),14)+'",'
				cTitulo+= '		"nome": "'+Alltrim(SA1->A1_NOME)+'",'
				cTitulo+= '		"endereco": "'+Alltrim(SA1->A1_END)+'",'
				cTitulo+= '		"cep": '+u_TiraZero(SA1->A1_CEP)+','
				cTitulo+= '		"cidade": "'+Alltrim(SA1->A1_MUN)+'",'
				cTitulo+= '		"bairro": "'+Alltrim(SA1->A1_BAIRRO)+'",'
				cTitulo+= '		"uf": "'+Alltrim(SA1->A1_EST)+'",'
				cTitulo+= '		"telefone": "'+Alltrim(SA1->A1_DDD)+Alltrim(SA1->A1_TEL)+'"'
				cTitulo+= '		},'
				// cTitulo+= '"beneficiarioFinal": {'
				// cTitulo+= '		"tipoInscricao": 0,'
				// cTitulo+= '		"numeroInscricao": 0,'
				// cTitulo+= '		"nome": "string"'
				// cTitulo+= '		},'
				cTitulo+= '"indicadorPix": "S"'
				cTitulo+= '}'

				cCodigo:= GetSxENum("ZLA", "ZLA_CODIGO")
				ConfirmSX8()
				//Chama a API do banco
				If lAuto
					u_XAG0109(cTitulo,cCodigo)
				Else
					FWMsgRun(,{|| u_XAG0109(cTitulo,cCodigo)},"Envio ao Banco do Brasil","Enviando t�tulo(s)... Aguarde...")
				Endif
			Else
				cTitulo:= '{'
				//cTitulo+= '"agenciaDestino":'+u_TiraZero(Alltrim(SEE->EE_AGENCIA))+',' //testar sem
				cTitulo+= '"nuCPFCNPJ":'+u_TiraZero(Left(alltrim(SEE->EE_NUMCTR),9))+',' //38052160
				cTitulo+= '"filialCPFCNPJ":'+u_TiraZero(Substr(alltrim(SEE->EE_NUMCTR),10,4))+','//57
				cTitulo+= '"ctrlCPFCNPJ":'+u_TiraZero(Right(alltrim(SEE->EE_NUMCTR),2))+','
				cTitulo+= '"idProduto":'+U_TiraZero(SEE->EE_CODCART)+','
				cTitulo+= '"nuNegociacao":'+strzero(Val(SEE->EE_AGENCIA),4) + Strzero(Val(Alltrim(SEE->EE_CODEMP)),14)+',' //399500000000075557
				cNossoNum:= Alltrim(NossoNum())
				cTitulo+= '"nuTitulo":'+u_TiraZero(Substr(cNossoNum,1,Len(cNossoNum)-1))+','
				cTitulo+= '"nuCliente":"'+ALLTRIM(SE1->E1_NUM)+'",'
				cTitulo+= '"dtEmissaoTitulo":"'+StrTran(Left(FWTIMESTAMP(2,SE1->E1_EMISSAO),10),"/",".")+'",'
				cTitulo+= '"dtVencimentoTitulo":"'+StrTran(Left(FWTIMESTAMP(2,SE1->E1_VENCTO),10),"/",".")+'",'
				//cTitulo+= '"tpVencimento":0,'
				cTitulo+= '"vlNominalTitulo":'+Alltrim(STRTRAN(TRANSFORM(SE1->E1_VALOR,"@E 99999999999999.99"),",",""))+','
				cTitulo+= '"cdEspecieTitulo":"02",' //DM
				//cTitulo+= '"tpProtestoAutomaticoNegativacao":0,'
				//cTitulo+= '"prazoProtestoAutomaticoNegativacao":0,'
				cTitulo+= '"controleParticipante":"'+u_TiraZero(Alltrim(SE1->E1_IDCNAB))+'",'
				//cTitulo+= '"cdPagamentoParcial":"N",'
				//cTitulo+= '"qtdePagamentoParcial":0,'
				If SE1->E1_VALJUR > 0
					cTitulo+= '"cdJuros":1,'
					cTitulo+= '"percentualJuros":0,' //'+cValtochar(Round(GetMV("MV_TXPER"),2))+','
					cTitulo+= '"vlJuros":'+u_TiraZero(Alltrim(STRTRAN(TRANSFORM(SE1->E1_VALJUR,"@E 99999999999999.99"),",","")))+','
					cTitulo+= '"qtdeDiasJuros":1,'
				Endif
				cTitulo+= '"percentualMulta":0,'
				cTitulo+= '"vlMulta":0,'
				cTitulo+= '"qtdeDiasMulta":0,'
				// cTitulo+= '"percentualDesconto1":0,'
				// cTitulo+= '"vlDesconto1":0,'
				// cTitulo+= '"dataLimiteDesconto1":0,'
				// cTitulo+= '"percentualDesconto2":0,'
				// cTitulo+= '"vlDesconto2":0,'
				// cTitulo+= '"dataLimiteDesconto2":"",'
				// cTitulo+= '"percentualDesconto3":0,'
				// cTitulo+= '"vlDesconto3":0,'
				// cTitulo+= '"dataLimiteDesconto3":"",'
				// cTitulo+= '"prazoBonificacao":0,'
				// cTitulo+= '"percentualBonificacao":0,'
				// cTitulo+= '"vlBonificacao":0,'
				// cTitulo+= '"dtLimiteBonificacao":"",'
				// cTitulo+= '"vlAbatimento":0,'
				// cTitulo+= '"vlIOF":"0",'
				cTitulo+= '"nomePagador":"'+U_RemCarEsp(Alltrim(Left(SA1->A1_NOME,70)))+'",'
				cTitulo+= '"logradouroPagador":"'+Left(U_RemCarEsp(Alltrim(SA1->A1_END)),40)+'",'
				cTitulo+= '"nuLogradouroPagador":"0",'
				cTitulo+= '"complementoLogradouroPagador":"'+U_RemCarEsp(Alltrim(LEFT(SA1->A1_COMPLEM,15)))+'",'
				cTitulo+= '"cepPagador":"'+Left(Alltrim(SA1->A1_CEP),5)+'",'
				cTitulo+= '"complementoCepPagador":"'+Right(Alltrim(SA1->A1_CEP),3)+'",'
				cTitulo+= '"bairroPagador":"'+Left(U_RemCarEsp(Alltrim(SA1->A1_BAIRRO)),40)+'",'
				//cTitulo+= '"bairroPagador":"'+U_RemCarEsp(Alltrim(SA1->A1_BAIRRO))+'",'
				cTitulo+= '"municipioPagador":"'+U_RemCarEsp(Alltrim(SA1->A1_MUN))+'",'
				cTitulo+= '"ufPagador":"'+Alltrim(SA1->A1_EST)+'",'
				cTitulo+= '"cdIndCpfcnpjPagador":"'+IIF(LEN(Alltrim(SA1->A1_CGC))=14,'2','1')+'",'
				cTitulo+= '"nuCpfcnpjPagador":"'+Alltrim(Strzero(VAL(SA1->A1_CGC),14))+'",'
				cTitulo+= '"quantidadeMoeda":1,'
				cTitulo+= '"registraTitulo":1'
				// cTitulo+= '"endEletronicoPagador":"'+Alltrim(SA1->A1_EMAIL)+'",'
				// cTitulo+= '"nomeSacadorAvalista":"",'
				// cTitulo+= '"logradouroSacadorAvalista":"",'
				// cTitulo+= '"nuLogradouroSacadorAvalista":"",'
				// cTitulo+= '"complementoLogradouroSacadorAvalista":"",'
				// cTitulo+= '"cepSacadorAvalista":0,'
				// cTitulo+= '"complementoCepSacadorAvalista":0,'
				// cTitulo+= '"bairroSacadorAvalista":"",'
				// cTitulo+= '"municipioSacadorAvalista":"",'
				// cTitulo+= '"ufSacadorAvalista":"",'
				// cTitulo+= '"cdIndCpfcnpjSacadorAvalista":0,'
				// cTitulo+= '"nuCpfcnpjSacadorAvalista":0,'
				// cTitulo+= '"endEletronicoSacadorAvalista":""'
				cTitulo+= '}'
				cCodigo:= GetSxENum("ZLA", "ZLA_CODIGO")
				ConfirmSX8()
				//Chama a API do banco
				cClientId := ALLTRIM(SEE->EE_ZZCLIID)

				If lAuto
					u_XAG0120(cTitulo,cCodigo, cClientId)
				Else
					FWMsgRun(,{|| u_XAG0120(cTitulo,cCodigo, cClientId)},"Envio ao Bradesco","Enviando t�tulo(s)... Aguarde...")
				Endif
			Endif
		Endif
	Endif
return



Static function Pagam106(oObj)
	Local nQtd := 0
	Local cTitulo:= ""
	Local lAuto := isBlind()
	Local cCodigo := ""
	Local oPix := BRDPix():New()


	If SE2->(dbSeek(xFilial("SE2")+TRB->(PREFIXO+NUMERO+PARCELA+TIPO+FORNECE+LOJA)))
		If SE2->E2_SALDO > 0
			nQtd++
			lTransferencia := .F.
			lBoleto := .F.
			lGuiaCB := .F.
			If TRB->BANCO == '001'
				//Posiciona no fornecedor
				SA2->(dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))

				//Grava o idcnab
				If Empty(SE2->E2_IDCNAB)
					Reclock("SE2",.F.)
					SE2->E2_IDCNAB:= GetSxENum("SE2", "E2_IDCNAB","E2_IDCNAB"+cEmpAnt)
					MsUnlock()
					ConfirmSX8()
				Endif

				//Numero da requisi��o
				cNumReq:= Soma1(Alltrim(SEE->EE_FAXATU))
				Reclock("SEE",.F.)
				SEE->EE_FAXATU:= cNumReq
				SEE->(msUnlock())

				//Transferencias
				If TRB->MODELO $ "41/43"
					lTransferencia:= .T.
					cTitulo:= '{'
					cTitulo+= '"numeroRequisicao": '+cNumReq+','
					cTitulo+= '"numeroContratoPagamento": '+Alltrim(SEE->EE_CODEMP)+','
					cTitulo+= '"agenciaDebito": '+SEE->EE_AGENCIA+','
					cTitulo+= '"contaCorrenteDebito": '+SEE->EE_CONTA+','
					cTitulo+= '"digitoVerificadorContaCorrente": "'+SEE->EE_DVCTA+'",'
					cTitulo+= '"tipoPagamento": 126,'
					cTitulo+= '"listaTransferencias": ['
					cTitulo+= '  {'
					cTitulo+= '    "numeroCOMPE": '+cvaltochar(val(SA2->A2_BANCO))+','
					cTitulo+= '    "numeroISPB": 0,'
					cTitulo+= '    "agenciaCredito": '+cvaltochar(val(SA2->A2_AGENCIA))+','
					If !Empty(SA2->A2_DVCTA)
						cDigCta:= Alltrim(SA2->A2_DVCTA)
						cConta:= cvaltochar(val(SA2->A2_NUMCON))
					Else
						nPosDig:= At("-",SA2->A2_NUMCON)
						If nPosDig > 0
							cDigCta:= Alltrim(Substr(SA2->A2_NUMCON,nPosDig))
							cConta:= cvaltochar(val(substr(Alltrim(SA2->A2_NUMCON),1,nPosDig-1)))
						Else
							cDigCta:= Right(Alltrim(SA2->A2_NUMCON),1)
							cConta:= cvaltochar(val(substr(Alltrim(SA2->A2_NUMCON),1,Len(Alltrim(SA2->A2_NUMCON)-1))))
						Endif
					Endif
					cTitulo+= '    "contaCorrenteCredito": '+cConta+','
					cTitulo+= '    "digitoVerificadorContaCorrente": "'+cDigCta+'",'
					cTitulo+= '    "contaPagamentoCredito": "",'
					cTitulo+= '    "cpfBeneficiario": '+Iif(Len(Alltrim(SA2->A2_CGC)) == 14,'0', cvaltochar(val(SA2->A2_CGC)))+','
					cTitulo+= '    "cnpjBeneficiario": '+Iif(Len(Alltrim(SA2->A2_CGC)) == 14, cvaltochar(val(SA2->A2_CGC)),'0')+','
					cTitulo+= '    "dataTransferencia": '+cvaltochar(val((GRAVADATA(dDataBase,.F.,5))))+','
					cTitulo+= '    "valorTransferencia": '+cvaltochar(SE2->E2_VALOR)+','
					cTitulo+= '    "documentoDebito": 0,'
					cTitulo+= '    "documentoCredito": 0,'
					If TRB->MODELO = '03' //DOC
						cTitulo+= '    "codigoFinalidadeDOC": 1,'
					Elseif TRB->MODELO <> '01' //Ted
						cTitulo+= '    "codigoFinalidadeTED": 10,'
					Endif
					cTitulo+= '    "numeroDepositoJudicial": "",'
					cTitulo+= '    "descricaoTransferencia": "'+SE2->E2_IDCNAB+'"'
					cTitulo+= '  }'
					cTitulo+= ']'
					cTitulo+= '}'

					//Boletos
				Elseif TRB->MODELO $ "30/31"
					If !Empty(SE2->E2_CODBAR)
						lBoleto:= .T.

						cTitulo:= '{'
						cTitulo+= '"numeroRequisicao": '+u_TiraZero(cNumReq)+','
						cTitulo+= '"codigoContrato": '+Alltrim(SEE->EE_CODEMP)+','
						cTitulo+= '"numeroAgenciaDebito": '+SEE->EE_AGENCIA+','
						cTitulo+= '"numeroContaCorrenteDebito": '+u_TiraZero(Alltrim(SEE->EE_CONTA))+','
						cTitulo+= '"digitoVerificadorContaCorrenteDebito": "'+SEE->EE_DVCTA+'",'
						cTitulo+= '"lancamentos": ['
						cTitulo+= '  {'
						cTitulo+= '    "numeroDocumentoDebito": '+cvaltochar(val(SA2->A2_BANCO))+','
						cTitulo+= '    "numeroCodigoBarras": "'+Alltrim(SE2->E2_CODBAR)+'",'
						cTitulo+= '    "dataPagamento": '+cvaltochar(val((GRAVADATA(dDataBase,.F.,5))))+','
						cTitulo+= '    "valorPagamento": '+cvaltochar(SE2->E2_VALOR)+','
						cTitulo+= '    "descricaoPagamento": "",'
						cTitulo+= '    "codigoSeuDocumento": "'+SE2->E2_IDCNAB+'",'
						cTitulo+= '    "codigoNossoDocumento": "",'
						cTitulo+= '    "valorNominal": '+cvaltochar(SE2->E2_VALOR)+','
						cTitulo+= '    "valorDesconto": 0,'
						cTitulo+= '    "valorMoraMulta": 0,'
						cTitulo+= '    "codigoTipoPagador": 0,'
						cTitulo+= '    "documentoPagador": 0,'
						cTitulo+= '    "codigoTipoBeneficiario": '+Iif(Len(Alltrim(SA2->A2_CGC)) == 14,'2','1')+','
						cTitulo+= '    "documentoBeneficiario": '+cvaltochar(val(SA2->A2_CGC))+','
						cTitulo+= '    "codigoTipoAvalista": 0,'
						cTitulo+= '    "documentoAvalista": 0'
						cTitulo+= '  }'
						cTitulo+= ']'
						cTitulo+= '}'
					Endif

					//Guias com c�digo de barras
				Elseif TRB->MODELO $ "11/13/16/17/18"
					If !Empty(SE2->E2_CODBAR)
						lGuiaCB:= .T.

						cTitulo:= '{'
						cTitulo+= '"numeroRequisicao": '+cNumReq+','
						cTitulo+= '"codigoContrato": '+Alltrim(SEE->EE_CODEMP)+','
						cTitulo+= '"numeroAgenciaDebito": '+SEE->EE_AGENCIA+','
						cTitulo+= '"numeroContaCorrenteDebito": '+SEE->EE_CONTA+','
						cTitulo+= '"digitoVerificadorContaCorrenteDebito": "'+SEE->EE_DVCTA+'",'
						cTitulo+= '"lancamentos": ['
						cTitulo+= '  {'
						cTitulo+= '    "codigoBarras": "'+Alltrim(SE2->E2_CODBAR)+'",'
						cTitulo+= '    "dataPagamento": '+cvaltochar(val((GRAVADATA(dDataBase,.F.,5))))+','
						cTitulo+= '    "valorPagamento": '+cvaltochar(SE2->E2_VALOR)+','
						cTitulo+= '    "numeroDocumentoDebito": 0,'
						cTitulo+= '    "codigoSeuDocumento": "'+SE2->E2_IDCNAB+'",'
						cTitulo+= '    "descricaoPagamento": ""'
						cTitulo+= '  }'
						cTitulo+= ']'
						cTitulo+= '}'
					Endif
				Endif


				If !Empty(cTitulo)
					cCodigo:= GetSxENum("ZLA", "ZLA_CODIGO")
					ConfirmSX8()
					//Chama a API do banco
					If lAuto
						u_XAG0114(cTitulo,cCodigo)
					Else
						FWMsgRun(,{|| u_XAG0114(cTitulo,cCodigo)},"Envio ao Banco do Brasil","Enviando t�tulo(s)... Aguarde...")
					Endif
				Endif

				cLiberaJson:= '{'
				cLiberaJson+= '"numeroRequisicao": '+cNumReq+','
				cLiberaJson+= '"indicadorFloat": "S"'
				cLiberaJson+= '}'

				If lAuto
					u_XAG0114B(cLiberaJson,cCodigo)
				Else
					FWMsgRun(,{|| u_XAG0114(cTitulo,cCodigo)},"Envio ao Banco do Brasil","Enviando t�tulo(s)... Aguarde...")
				Endif

			Else
				//237 - BRADESCO
				//Posiciona no fornecedor
				SA2->(dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))

				//Grava o idcnab
				If Empty(SE2->E2_IDCNAB)
					Reclock("SE2",.F.)
					SE2->E2_IDCNAB:= GetSxENum("SE2", "E2_IDCNAB","E2_IDCNAB"+cEmpAnt)
					MsUnlock()
					ConfirmSX8()
				Endif

				//Numero da requisi��o
				cNumReq:= Soma1(Alltrim(SEE->EE_FAXATU))
				Reclock("SEE",.F.)
				SEE->EE_FAXATU:= cNumReq
				SEE->(msUnlock())

				//Transferencias
				//If TRB->MODELO $ "01/03/41/43" // REMOVIDO PIX.
				If TRB->MODELO $ "01/03/41/43/48"
					lTransferencia:= .T.

					IF(!EMPTY(SA2->A2_PIXTP) .AND. TRB->MODELO == "48")// se o fornecedor possui PIX
						oObj:IncRegua2("Efetuando pagamento com PIX")
						oPix:oRecebedor:cCpfCnpj := SA2->A2_CGC
						oPix:oRecebedor:cTipoChave := SA2->A2_PIXTP
						IF(oPix:oRecebedor:cTipoChave == "C")
							oPix:oRecebedor:cChavePix := ALLTRIM(SA2->A2_PIXCHAV)
						ELSE
							oPix:oPagador:cTipoChave := "AGENCIACONTA"
							oPix:oRecebedor:cChavePix := ALLTRIM(SA2->A2_PIXCHAV)
							oPix:oRecebedor:cAgencia := ALLTRIM(SA2->A2_AGENCIA)
							oPix:oRecebedor:cBanco := ALLTRIM(SA2->A2_BANCO)
							oPix:oRecebedor:cConta := ALLTRIM(SA2->A2_NUMCON)
							oPix:oRecebedor:cIspb := Posicione("SA6",1,xFilial("SA6")+SA2->A2_BANCO,"A6_ISPB") //ALLTRIM(SA2->A2_BANCO)
							oPix:oRecebedor:cDigitoConta := ALLTRIM(SA2->A2_DVCTA)
							//01800
						ENDIF
						oPix:oRecebedor:cFavorecido	:= SA2->A2_NOME
						oPix:cIdTransacao := Alltrim(SE2->E2_IDCNAB)
						oPix:nValor := SE2->E2_SALDO
						oPix:cDescricao := "PAGAMENTO FORNECEDOR"

						IF(oPix:SolicitarTransferencia())
							lRec:= .T.
						ELSE
							oObj:IncRegua2("ERRO PIX")
						ENDIF


					ELSEIF TRB->MODELO != "48"
						oObj:IncRegua2("Efetuando TED")
						cTitulo:='{'
						cTitulo+='"identificadorDoTipoDeTransferencia":1,' //diferente titularidade
						cTitulo+='"agenciaRemetente":'+cvaltochar(val(SEE->EE_AGENCIA))+','
						cTitulo+='"bancoDestinatario":'+cvaltochar(val(SA2->A2_BANCO))+','
						cTitulo+='"agenciaDestinatario":'+cvaltochar(val(SA2->A2_AGENCIA))+','
						cTitulo+='"contaRemetenteComDigito":'+cvaltochar(val(SEE->EE_CONTA))+cvaltochar(val(SEE->EE_DVCTA))+','
						cTitulo+='"tipoContaRemetente":"CC",' //CC=Conta corrente - PP=Poupan�a
						cTitulo+='"tipoDePessoaRemetente":"J",'
						If !Empty(SA2->A2_DVCTA)
							cDigCta:= Alltrim(SA2->A2_DVCTA)
							cConta:= cvaltochar(val(SA2->A2_NUMCON))
						Else
							nPosDig:= At("-",SA2->A2_NUMCON)
							If nPosDig > 0
								cDigCta:= Alltrim(Substr(SA2->A2_NUMCON,nPosDig))
								cConta:= cvaltochar(val(substr(Alltrim(SA2->A2_NUMCON),1,nPosDig-1)))
							Else
								cDigCta:= Right(Alltrim(SA2->A2_NUMCON),1)
								cConta:= cvaltochar(val(substr(Alltrim(SA2->A2_NUMCON),1,Len(Alltrim(SA2->A2_NUMCON))-1)))
							Endif
						Endif
						cTitulo+='"contaDestinatario":'+cConta+cDigCta+','
						cTitulo+='"tipoDeContaDestinatario":"CC",
						cTitulo+='"tipodePessoaDestinatario":"'+Iif(Len(Alltrim(SA2->A2_CGC)) == 14,'J','F')+'",'
						cTitulo+='"numeroInscricao":"'+Iif(Len(Alltrim(SA2->A2_CGC))==14,Left(SA2->A2_CGC,8),Left(SA2->A2_CGC,9))+'",'
						//cTitulo+='"numeroFilial":"'+Substr(Alltrim(SA2->A2_CGC),9,4)+'",
						cTitulo+='"numeroFilial":"'+Iif(Len(Alltrim(SA2->A2_CGC))==14,Substr(Alltrim(SA2->A2_CGC),9,4),"00000")+'",
						cTitulo+='"numeroControle":"'+Right(Alltrim(SA2->A2_CGC),2)+'",'
						cTitulo+='"nomeClienteDestinatario":"'+U_RemCarEsp(Alltrim(SA2->A2_NOME))+'",'
						cTitulo+='"valorDaTransferencia":'+cvaltochar(SE2->E2_SALDO)+','
						cTitulo+='"finalidadeDaTransferencia":10,'
						cTitulo+='"codigoIdentificadorDaTransferencia":"'+Alltrim(SE2->E2_IDCNAB)+'",'
						cTitulo+='"dataMovimento":"'+StrTran(Left(FWTIMESTAMP(2,dDataBase),10),"/",".")+'",'
						cTitulo+='"tipoDeDoc":"",' //D=mesma titularidade E=diferente titularidade
						cTitulo+='"tipoDeDocumentoDeBarras":"",'
						cTitulo+='"numeroCodigoDeBarras":"",'
						cTitulo+='"canalPagamento":0,'
						cTitulo+='"valorMulta":0,'
						cTitulo+='"valorJuro":0,'
						cTitulo+='"valorDescontoOuAbatimento":0,'
						cTitulo+='"valorOutrosAcrescimos":0,'
						cTitulo+='"indicadorDda":"N"'
						cTitulo+='}'
					ENDIF
					//Boletos
				Elseif TRB->MODELO $ "30/31"
					If !Empty(SE2->E2_CODBAR)
						oObj:IncRegua2("Efetuando pagamento BOLETO")
						lBoleto:= .T.
						cCodigo:= GetSxENum("ZLA", "ZLA_CODIGO")
						cClientId := ALLTRIM(SEE->EE_ZZCLIID)
						ConfirmSX8()
						If u_XAG0121A(cCodigo, cClientId)
							if(U_XAG0121B(cCodigo, cClientId))
								cTitulo:='{'
								cTitulo+='"agencia":'+U_TiraZero(Alltrim(SEE->EE_AGENCIA))+','
								cTitulo+='"indicadorFuncao":"1",'//0-CONSULTAPR�-PAGAMENTO;1 - PAGAMENTO / AGENDAMENTO;2 - ANULA��O.
								cTitulo+='"nomeCliente":"'+SUBSTR(U_RemCarEsp(Alltrim(Upper(SM0->M0_NOMECOM))),1,40)+'",'//"'+U_RemCarEsp(Alltrim(SA2->A2_NOME))+'",'
								If Left(SE2->E2_CODBAR,3) <> '237'
									//buscar PIXTID ***
									Dbselectarea("ZLA")
									Dbsetorder(1)
									dbgotop()
									If ZLA->(DBSeek(xFilial("ZLA")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)))										
										cTitulo+= '"numeroControleParticipante":"'+Alltrim(ZLA->ZLA_PIXTID)+'",'
									ELSE
										U_ZLAUPDATE(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NUMBOR, "6")
    									U_ZLBHIST(SE2->E2_FILORIG, aZLA[2], '6', "N�O IDENTIFICADO C�DIGO DE CONTROLE DE PARTICIPANTE.", '1')
									ENDIF
								Else
									cTitulo+= '"numeroControleParticipante":"0",'
								Endif
								cTitulo+='"identificacaoChequeCartao":0,'
								cTitulo+='"indicadorValidacaoGravacao":"N",'
								cTitulo+='"valorMinimoIdentificacao":0.00,'//'+cvaltochar(SE2->E2_VALOR)+'",
								cTitulo+='"destinatarioDadosComum":{
								cTitulo+='"cpfCnpjDestinatario":"'+Alltrim(SM0->M0_CGC)+'"'
								cTitulo+='},
								cTitulo+='"pagamentoComumRequest":{'
								cTitulo+='"dadosSegundaLinhaExtrato":"'+SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+'",
								cTitulo+='"dataMovimento":'+DTOS(dDataBase)+','
								cTitulo+='"dataPagamento":'+DTOS(dDataBase)+','
								cTitulo+='"dataVencimento":'+DTOS(dDataBase)+','
								cTitulo+='"horaTransacao":'+cvaltochar(val(StrTran(Time(),":","")))+',
								cTitulo+='"identificacaoTituloCobranca":"'+Alltrim(SE2->E2_CODBAR)+'",
								cTitulo+='"indicadorFormaCaptura":1,'//1=codigodebarras,2=linhadigit�vel
								cTitulo+='"valorTitulo":'+cvaltochar(SE2->E2_VALOR )+',
								cTitulo+='"contaDadosComum":{
								cTitulo+='"agenciaContaDebitada":'+cvaltochar(val(SEE->EE_AGENCIA))+',
								cTitulo+='"bancoContaDebitada":'+cvaltochar(val(SEE->EE_CODIGO))+',
								cTitulo+='"contaDebitada": '+cvaltochar(val(SEE->EE_CONTA))+',
								//cTitulo+= '"contaDebitada":27720,'
								cTitulo+='"digitoAgenciaDebitada":'+Alltrim(SEE->EE_DVAGE)+',
								//cTitulo+='"digitoContaDebitada":7'
								cTitulo+= '"digitoContaDebitada": "'+Alltrim(SEE->EE_DVCTA)+'"'
								cTitulo+='}'
								cTitulo+='},
								cTitulo+='"portadorDadosComum":{
								//cTitulo+='"cpfCnpjPortador":"'+Alltrim(SM0->M0_CGC)+'"'//'+Alltrim(SA2->A2_CGC)+'
								//cTitulo+='"cpfCnpjPortador":"81632093000411"'//'+Alltrim(SEE->EE_ZZCNPJP)+'
								cTitulo+='"cpfCnpjPortador":"'+Alltrim(SEE->EE_ZZCNPJP)+'"'//'+Alltrim(SEE->EE_ZZCNPJP)+'
								cTitulo+='},
								cTitulo+='"remetenteDadosComum":{
								cTitulo+='"cpfCnpjRemetente":"'+Alltrim(SA2->A2_CGC)+'"'
								cTitulo+='},
								cTitulo+='"transactionId":'+LEFT(CVALTOCHAR(VAL(SUBSTR(SE2->E2_IDCNAB,2,10))),9)//'+u_TiraZero(Right(cNumReq,9))
								cTitulo+='}
							Endif
						Endif
					Endif

					//Guias com c�digo de barras
				Elseif QRY->EA_MODELO $ "11/13/16/17/18"
					If !Empty(SE2->E2_CODBAR)
						lGuiaCB:= .T.

						cTitulo:= '{'
						cTitulo+= '"agencia": '+cvaltochar(val(SEE->EE_AGENCIA))+','
						cTitulo+= '"codigoBarras": "'+Alltrim(SE2->E2_CODBAR)+'",'
						//cTitulo+= '"conta":27720 ,'
						cTitulo+= '"conta": '+cvaltochar(val(SEE->EE_CONTA))+','
						cTitulo+= '"dataDebito": "'+Left(FwTimeStamp(3,dDataBase),10)+'",'
						cTitulo+= '"digitoAgencia": '+Alltrim(SEE->EE_DVAGE)+','
						//cTitulo+= '"digitoAgencia":7,'
						cTitulo+= '"digitoConta": "'+Alltrim(SEE->EE_DVCTA)+'",'
						cTitulo+= '"idTransacao": "'+Right(Alltrim(SE2->E2_IDCNAB),9)+'",'
						cTitulo+= '"tipoConta": 1,' //1-conta corrente, 2-poupan�a
						cTitulo+= '"tipoRegistro": 1,' // 0- consulta, 1-inclusao
						cTitulo+= '"valorPrincipal": '+cvaltochar(SE2->E2_VALOR)
						cTitulo+= '}'

					Endif

				Endif

 				If !Empty(cTitulo)
					If Empty(cCodigo)
						cCodigo:= GetSxENum("ZLA", "ZLA_CODIGO")
						ConfirmSX8()
					Endif
					//Chama a API do banco
					cClientId := ALLTRIM(SEE->EE_ZZCLIID)
					oObj:IncRegua2("Enviado ao Bradesco")
					If lAuto
						u_XAG0121(cTitulo,cCodigo, cClientId)
					Else
						FWMsgRun(,{|| u_XAG0121(cTitulo,cCodigo, cClientId)},"Envio ao Bradesco","Enviando t�tulo(s)... Aguarde...")
					Endif
					oObj:IncRegua2("Finalizado")
				Endif
			Endif
		ELSE
			//ALERTA
			FWAlertWarning("Titulo "+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)+" j� baixado!","Status atualizado")

			aZLA := U_ZLAUPDATE(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NUMBOR, "3")
			U_ZLBHIST(SE2->E2_FILORIG, aZLA[2], '3', "TITULO J� BAIXADO NO SISTEMA", '1')							
			Endif
		Endif

return


//  Cria as perguntas na SX1                               
//********************************************************************************

Static Function AjustaSx1(cPerg)

	Local aRegs:= {}

	aAdd(aRegs,{cPerg, '01', "Carteira"				,"Carteira" 		,"Carteira" 			, 'mv_ch1' , 'C', 01	, 0, 0, 'C', '', 'mv_par03', 'Ambos','','','','','Pagar','','','','','Receber','','','','','','','','','','','','','','','','',''})
	aAdd(aRegs,{cPerg, '02', "Cliente/Fornecedor"   ,"Cliente/Fornecedor","Cliente/Fornecedor"	, 'mv_ch2' , 'C', 06	, 0, 0, 'G', '', 'mv_par04', '','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
	aAdd(aRegs,{cPerg, '03', "Data de Envio"   		,"Data de Envio" 	,"Data de Envio"    	, 'mv_ch3' , 'D', 10	, 0, 0, 'G', '', 'mv_par05', '','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
	aAdd(aRegs,{cPerg, '04', "Status"  				,"Status"  			,"Status"   			, 'mv_ch4' , 'C', 01	, 0, 0, 'C', '', 'mv_par06', 'Todos','','','','','Enviado','','','','','Entr. Confirm. ','','','','','Pago','','','','','Erro','','','','','','',''})

	U_XAG0112(aRegs)

Return


//  Cria as perguntas na SX1                               
//********************************************************************************

Static Function AjustaPerg(cPerg)

	Local aRegs:= {}

	aAdd(aRegs,{cPerg, '01', "Bordero De"		,"Bordero De" 	,"Bordero De" 	, 'mv_ch1' , 'C', 06	, 0, 0, 'G', '', 'mv_par01', '','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
	aAdd(aRegs,{cPerg, '02', "Bordero At�"   	,"Bordero At�"	,"Bordero At�"	, 'mv_ch2' , 'C', 06	, 0, 0, 'G', '', 'mv_par02', '','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
	aAdd(aRegs,{cPerg, '03', "Banco"   			,"Banco" 		,"Banco"    	, 'mv_ch3' , 'C', 03	, 0, 0, 'G', '', 'mv_par03', '','','','','','','','','','','','','','','','','','','','','','','','','SA6','','',''})
	aAdd(aRegs,{cPerg, '04', "Agencia"  		,"Agencia"		,"Agencia"   	, 'mv_ch4' , 'C', 05	, 0, 0, 'G', '', 'mv_par04', '','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
	aAdd(aRegs,{cPerg, '05', "Conta"  			,"Conta"		,"Conta"   		, 'mv_ch5' , 'C', 10	, 0, 0, 'G', '', 'mv_par05', '','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
	aAdd(aRegs,{cPerg, '06', "Subconta"  		,"Subconta"		,"Subconta"   	, 'mv_ch6' , 'C', 03	, 0, 0, 'G', '', 'mv_par06', '','','','','','','','','','','','','','','','','','','','','','','','','','','',''})

	U_XAG0112(aRegs)

Return

//  Remove zeros � esquerda                              
//*******************************************************************************
User Function TiraZero(cTexto)
	Local cRetorno  := ""
	Local lContinua := .T.
	Default cTexto  := ""

//Pegando o texto atual
	cRetorno := Alltrim(cTexto)

//Enquanto existir zeros a esquerda
	While lContinua
		//Se a priemira posi��o for diferente de 0 ou n�o existir mais texto de retorno, encerra o la�o
		If SubStr(cRetorno, 1, 1) <> "0" .Or. Len(cRetorno) ==0 .or. cRetorno == "0"
			lContinua := .f.
		EndIf

		//Se for continuar o processo, pega da pr�xima posi��o at� o fim
		If lContinua
			cRetorno := Substr(cRetorno, 2, Len(cRetorno))
		EndIf
	End

Return cRetorno


//  Remove acento e caracter especial                              
//*******************************************************************************
User Function RemCarEsp(cTexto)
	Local cRet:= ""
//Local aCarEsp:= {'"',"'",'#','%','*','&','>','<','!','$','(',')','_','=','+','{','}','[',']','/','?','.','\','|',':','�','�'}
	Local aCarEsp:= {'"',"'",'#','%','*','&','>','<','!','$','�','(',')','_','=','�','�','+','{','}','[',']','/','?','.','\','|',':','�','�','�'}

//Remove acentos
	cRet:= FWNoAccent(cTexto)

//Remove caracteres especiais
	aEval(aCarEsp,{|x| cRet:= StrTran(cRet,x,'') })

Return cRet

/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    �  XAG0107A   � Autor � Lucilene Mendes    � Data �31.03.23  ���
��+----------+------------------------------------------------------------���
���Descri��o �  Envio autom�tico de border� para o banco	              ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function XAG0107A(aParam)
Local cBcosAPI := ""
Private oObjLog     := nil

RpcSetType( 3 )
If !RPCSetEnv(aParam[1],aParam[2])
	Return
Endif

//RPCSetEnv("01","06")

//Gera��o de log
oObjLog := LogSMS():new("XAG0107A")
oObjLog:setFileName('\log\ENVIO_BORDERO_API\envio_bordero_'+cEmpAnt+'_'+cFilant+'_'+dtos(date())+"_"+strtran(time(),":","")+"_"+cValToChar(ThreadId())+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg(GetEnvServer())


cBcosAPI := GetNewPar("MV_XBCOAPI","001/237")

//Localiza os borderos gerados no dia
cQry:= "SELECT DISTINCT EA_NUMBOR, EA_PORTADO, EA_AGEDEP, EA_NUMCON, EA_CART "
cQry+= "FROM "+RetSqlName("SEA")+" SEA "
cQry+= "INNER JOIN "+RetSqlName("SE1")+" SE1 ON E1_FILIAL = '"+xFilial("SEA")+"' AND E1_PREFIXO = EA_PREFIXO AND E1_NUM = EA_NUM AND E1_PARCELA = EA_PARCELA "
cQry+= " AND E1_TIPO = EA_TIPO AND E1_FILORIG = '"+cFilAnt+"' AND SE1.D_E_L_E_T_ = ' ' "
cQry+= "WHERE EA_PORTADO IN "+FormatIn(cBcosAPI,"/")+" "
cQry+= "AND EA_DATABOR >= '"+dtos(dDataBase-4)+"' "
cQry+= "AND EA_TRANSF = '' "
cQry+= "AND SEA.D_E_L_E_T_ = ' ' "
cQry+= "ORDER BY EA_NUMBOR "
If Select("QEA") > 0
	QEA->(dbCloseArea())
Endif
TcQuery cQry New Alias "QEA"

If QEA->(Eof())
	oObjLog:saveMsg("Nenhum bordero encontrado para "+dtoc(dDataBase)) 
	Return
Endif

While QEA->(!Eof())
	//Localiza a SEE
	cQry:= "SELECT EE_CODIGO, EE_AGENCIA, EE_CONTA, EE_SUBCTA "
	cQry+= "FROM "+RetSqlName("SEE")+" SEE "
	cQry+= "WHERE EE_CODIGO = '"+QEA->EA_PORTADO+"' "
	cQry+= "AND EE_AGEOFI = '"+QEA->EA_AGEDEP+"' "
	cQry+= "AND EE_CTAOFI = '"+QEA->EA_NUMCON+"' "
	IF(QEA->EA_CART == "P")
		cQry+= "AND EE_SUBCTA = 'PAG' " //A PAGAR
	ELSE
		cQry+= "AND EE_SUBCTA = 'REC' " //A RECEBER
	ENDIF
	cQry+= "AND SEE.D_E_L_E_T_ = ' ' "
	If Select("QEE") > 0
		QEE->(dbCloseArea())
	Endif
	TcQuery cQry New Alias "QEE"

	If QEE->(Eof())
		oObjLog:saveMsg("Cadastro de parametro de banco (SEE) n�o encontrado para banco: "+Alltrim(QEA->EA_PORTADO)+" agencia: "+Alltrim(QEA->EA_AGEDEP)+" conta: "+Alltrim(QEA->EA_NUMCON)+".") 
		QEA->(dbSkip())
		Loop
	Endif

	//Atualiza os parametros para a chamada da rotina
	MV_PAR01:= QEA->EA_NUMBOR
	MV_PAR02:= QEA->EA_NUMBOR
	MV_PAR03:= QEE->EE_CODIGO
	MV_PAR04:= QEE->EE_AGENCIA
	MV_PAR05:= QEE->EE_CONTA
	MV_PAR06:= QEE->EE_SUBCTA //???

	oObjLog:saveMsg("Processando bordero "+QEE->EE_CODIGO+" - "+QEA->EA_NUMBOR)
	
	//Envio de border�
	U_XAG0107()

	QEA->(dbSkip())

End

Return

static Function ConsBRD106(cCodigo, cClientId)
Local cJson:= ""
Local cURL:= '/oapi/v1/pagamentos/boleto/validarDadosTitulo'
Local cURLBase:= ""
Local cToken:= ""
Local cHeaderRet:= ""
Local cErro:= ""
Local cJti:= ""
Local cAssinatura:= ""
Local cConteudo:= ""
//Local cClientId:= GetNewPar("AC_BRDCLIP","e67ca582-a3d6-47d0-af05-8713f8a520be")
Local cDirServ:= "\cert APIs bancos\openssl\"
Local lRec:= .T.
Local lRet:= .F.
Local aToken      	:= {} 
Local aHeadStr      := {} 
Local nCodResp:= 0
Private nNossoNum   := 0
Private oObjLog     := nil




//Gera��o de log
oObjLog := LogSMS():new("APIBRD_ENVIAR_PGTO")
oObjLog:setFileName('\log\APIBRD\validar_boleto_'+cEmpAnt+'_'+cFilant+'_'+dtos(date())+"_"+strtran(time(),":","")+"_"+SE2->E2_NUM+"_"+cValToChar(ThreadId())+'.txt')
oObjLog:eraseLog()
oObjLog:saveMsg(GetEnvServer())

cJson:='{'
cJson+='"agencia":"'+u_TiraZero(SEE->EE_AGENCIA)+'",'
cJson+='"dadosEntrada":"'+Alltrim(SE2->E2_CODBAR)+'",'
cJson+='"tipoEntrada":"1"'
cJson+='}


cUrlBase:= GetNewPar("AC_BRDURL","https://proxy.api.prebanco.com.br") //https://openapi.bradesco.com.br

//Busca o token para autentica��o
aToken:= U_gTokenBrd(cClientId)
If !aToken[1]
	oObjLog:saveMsg("Autentica��o inv�lida!!!") 
    Return
Else
	cToken:= aToken[2]
	cJti:= aToken[3]
	cTime:= aToken[4]
Endif

//Salva o arquivo com o request para uso na assinatura
cConteudo:= "POST"+LF
cConteudo+= cUrl+LF
cConteudo+= LF
cConteudo+= Alltrim(cJson)+LF
cConteudo+= cToken+LF
cConteudo+= cJti+LF
cConteudo+= Left(FwTimeStamp(3,date(),cTime),19)+'-00:00'+LF
cConteudo+= "SHA256"

//Gera a assinatura
cAssinatura:= U_gSignBrd("ValidarDadosTitulo", SE2->E2_IDCNAB, cConteudo) 

If Empty(cAssinatura)
    Return
Endif    

//Autoriza��o no header
Aadd(aHeadStr, "Content-Type: application/json") 
Aadd(aHeadStr, "Authorization: Bearer "+cToken )
Aadd(aHeadStr, "X-Brad-Signature: "+cAssinatura)
Aadd(aHeadStr, "X-Brad-Nonce: "+cJti)
Aadd(aHeadStr, "X-Brad-Timestamp: "+Left(FwTimeStamp(3,date(),cTime),19)+'-00:00') 
Aadd(aHeadStr, "X-Brad-Algorithm: SHA256") 
Aadd(aHeadStr, "Access-token: "+cClientId) 


//Efetua o POST na API
cRetPost := HTTPPost(cUrlBase+cUrl, /*cGetParms*/, cJson, /*nTimeOut*/, aHeadStr, @cHeaderRet)
cRetPost:= DecodeUTF8(cRetPost)
nCodResp:= HTTPGetStatus(cHeaderRet)
oObjLog:saveMsg("Envia Pr�-Pagamento") 
oObjLog:saveMsg("**URL: "+cUrlBase+cUrl) 
oObjLog:saveMsg("**Body: "+cJson)  
oObjLog:saveMsg("**Retorno: "+Iif(cRetPost = nil,"",cRetPost)) 
oObjLog:saveMsg("**Cabe�alho Retorno: "+cHeaderRet) 

//Transforma o retorno em um JSON
jJsonBol := JsonObject():New()
jJsonBol:FromJson(cRetPost)

If nCodResp <> 200
    If nCodResp = 401
        cErro:= jJsonBol["message"]
    Else
        If jJsonBol:HasProperty("codigo")
            cErro:= jJsonBol["codigo"]+" - "+jJsonBol["mensagem"]
        Elseif jJsonBol:HasProperty("code")
            cErro:= jJsonBol["code"]+" - "+jJsonBol["message"]
        Else 
            cErro:= "Falha ao enviar a requisicao. Codi	go: " +cvaltochar(nCodResp)+' - '+cHeaderRet
        Endif      
    Endif
Else
    lRet:= .T.
Endif

Return lRet


static Function ConsBB106()
	local jJsonList     := ""
	local cRetGet       := ""
	local cGetParms     := ""
	Local cCodResp      := ""
	local cHeaderList   := ""
	Local cUrlListar    := GetNewPar("MV_XBBURLP","https://api.sandbox.bb.com.br/pagamentos-lote/v1")
	Local cApiKey       := GetNewPar("MV_XBBAPKP","d27b677901ffab801361e17d50050256b991a5b4")
	Local cToken        := ""
	Local cErro         := ""
	Local cDirServ      := "\cert APIs bancos\openssl\"
	Local cPathCert     := cDirServ+"certificado_"+cEmpAnt+".pem"
	Local cPathPrivK    := cDirServ+"privkey_"+cEmpAnt+".pem"
	Local cPassCert     := GetNewPar("MV_XCERTPS","p3tro_@632")
	Local i             := 0
	Local aRet          := {}
	Local aHeadStr      := {}
	Local cQry:= ""
	Local cBcosAPI := ""
	Private oObjLog:= nil

	cBcosAPI:= GetNewPar("MV_XBCOAPI","001/237")

//Gera��o de log
	oObjLog := LogSMS():new("API_BUSCAR_PAGAMENTO")
	oObjLog:setFileName('\log\API\buscar_pagamento_'+cEmpAnt+'_'+cFilant+'_'+dtos(date())+"_"+strtran(time(),":","")+"_"+cValToChar(ThreadId())+'.txt')
	oObjLog:eraseLog()
	oObjLog:saveMsg(GetEnvServer())


//Busca todos os titulos pendentes
	cQry:= "Select SE2.R_E_C_N_O_ RECSE2, ZLA.R_E_C_N_O_ RECZLA, SEA.R_E_C_N_O_ RECSEA "
	cQry+= "From "+RetSQLName("ZLA")+" ZLA "
	cQry+= "Inner Join "+RetSQLName("SE2")+" SE2 on E2_FILIAL = '"+xFilial("SE2")+"' "
	cQry+= " AND E2_PREFIXO = ZLA_PREFIX AND E2_NUM = ZLA_NUM AND E2_PARCELA = ZLA_PARCEL "
	cQry+= " AND E2_TIPO = ZLA_TIPO AND E2_FORNECE = ZLA_CLIFOR AND E2_LOJA = ZLA_LOJA "
	cQry+= " AND E2_SALDO > 0 AND E2_FILORIG = '"+cFilAnt+"' AND SE2.D_E_L_E_T_ = ' ' "
	cQry+= "Inner Join "+RetSQLName("SEA")+" SEA on EA_FILIAL = '"+xFilial("SEA")+"' "
	cQry+= " AND EA_NUMBOR = ZLA_NUMBOR AND EA_PREFIXO = E2_PREFIXO AND EA_NUM = E2_NUM "
	cQry+= " AND EA_PARCELA = E2_PARCELA AND EA_TIPO = E2_TIPO AND EA_FORNECE = E2_FORNECE AND EA_LOJA = E2_LOJA "
	cQry+= " AND SEA.D_E_L_E_T_ = ' ' "
	cQry+= "Where ZLA_FILIAL = '"+xFilial("ZLA")+"' "
//cQry+= "And ZLA_STATUS = '2' " //entrada confirmada
	cQry+= "And ZLA_FILORI = '"+cFilAnt+"' "
	cQry+= "And ZLA_BANCO = '001' "
	cQry+= "And ZLA.D_E_L_E_T_ = ' ' "
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	Endif
	TcQuery cQry New Alias "QRY"

	While QRY->(!Eof())
		SE2->(dbGoto(QRY->RECSE2))
		SEA->(dbGoto(QRY->RECSEA))
		ZLA->(dbGoto(QRY->RECZLA))

		oObjLog:saveMsg("Processando t�tulo "+SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA)

		//Busca o t�tulo
		If ZLA->ZLA_BANCO = '001'

//Transferencias
			If SEA->EA_MODELO $ "01/03/41/43"
				cUrlListar+="/transferencias/"
//Boletos	
			Elseif SEA->EA_MODELO $ "30/31"
				cUrlListar+="/boletos/"
//Guias com c�digo de barras	
			Elseif SEA->EA_MODELO $ "11/13/16/17/18"
				cUrlListar+="/guias-codigo-barras/"
			Endif
			cUrlListar+= Alltrim(ZLA->ZLA_IDENT)

//Busca o token para autentica��o
			cToken:= gTokenBB('P')
			If Empty(cToken)
				oObjLog:saveMsg("Autentica��o inv�lida!!!")
				Return
			Endif

//Autoriza��o no header
			Aadd(aHeadStr, "Authorization: Bearer "+cToken )
			Aadd(aHeadStr, "Content-Type: application/json")

//Parametros
			cGetParms := "gw-dev-app-key="+cApiKey

//Efetua o POST na API
//cRetGet := HTTPGet(cUrlListar, cGetParms,/*nTimeOut*/, aHeadStr, @cHeaderList)
			cRetGet := HTTPSGet(cUrlListar, cPathCert, cPathPrivK, cPassCert,cGetParms, /*nTimeOut*/, aHeadStr, @cHeaderList)
			cCodResp:= HTTPGetStatus(cHeaderList)

			oObjLog:saveMsg("Lista Pagamentos")
			oObjLog:saveMsg("**URL: "+cUrlListar)
			oObjLog:saveMsg("**GetPar: "+cGetParms)
			oObjLog:saveMsg("**CodRet: "+cValtoChar(cCodResp))
			oObjLog:saveMsg("**Retorno: "+Iif(cRetGet = nil,"",cRetGet))
			oObjLog:saveMsg("**Cabe�alho Retorno: "+cHeaderList)

//Transforma o retorno em um JSON
			jJsonList := JsonObject():New()
			jJsonList:FromJson(cRetGet)

			If cCodResp <> 200
				If cCodResp = 401
					cErro:= DecodeUTF8(jJsonList["message"])
				Else
					For i:= 1 to Len(jJsonList["erros"])
						cErro+= Iif(i>1," / ","")+DecodeUTF8(jJsonList["erros"][i]["mensagem"])
					Next
				Endif

				oObjLog:saveMsg("**Erro: "+cErro)

			Else
				If UPPER(jJsonList["estadoPagamento"]) = "PAGO"

					If SE2->E2_SALDO > 0
						aAdd(aRet,ctod(Transform(jJsonList["dataPagamento"],"99/99/9999")))
						aAdd(aRet,jJsonList["valorPagamento"])

						u_BaixaPag(aRet)
					Endif

				Else
					oObjLog:saveMsg("**Sem pagamento para processar")
				Endif
			Endif
		Else
			//U_XAG0122()
		Endif
		QRY->(dbSkip())
	End


Return


static Function consPGT106(cCodigo, cClientId)
	Local cJson:= ""
	Local cURL:= '/oapi/v1/pagamentos/boleto/validarPagamento'
	Local cURLBase:= ""
	Local cToken:= ""
	Local cHeaderRet:= ""
	Local cErro:= ""
	Local cJti:= ""
	Local cAssinatura:= ""
	Local cConteudo:= ""
//Local cClientId:= GetNewPar("AC_BRDCLIP","e67ca582-a3d6-47d0-af05-8713f8a520be")
	Local cDirServ:= "\cert APIs bancos\openssl\"
	Local lRec:= .T.
	Local lRet:= .F.
	Local aRet          := {}
	Local aToken      	:= {}
	Local aHeadStr      := {}
	Local nCodResp:= 0
	Private nNossoNum   := 0
	Private oObjLog     := nil

//Gera��o de log
	oObjLog := LogSMS():new("APIBRD_VALIDAR_PGTO")
	oObjLog:setFileName('\log\APIBRD\validar_pgt_boleto_'+cEmpAnt+'_'+cFilant+'_'+dtos(date())+"_"+strtran(time(),":","")+"_"+SE2->E2_NUM+"_"+cValToChar(ThreadId())+'.txt')
	oObjLog:eraseLog()
	oObjLog:saveMsg(GetEnvServer())

	cJson:='{'
	cJson+='"agencia":'+U_TiraZero(Alltrim(SEE->EE_AGENCIA))+','
	cJson+='"pagamentoComumRequest":'
	cJson+='{'
	cJson+='"contaDadosComum":'
	cJson+='{'
	cJson+='"agenciaContaDebitada":'+cvaltochar(val(SEE->EE_AGENCIA))+','
	cJson+='"bancoContaDebitada":'+cvaltochar(val(SEE->EE_CODIGO))+','
	cJson+='"contaDebitada":'+cvaltochar(val(SEE->EE_CONTA))+','
	cJson+='"digitoAgenciaDebitada": '+Alltrim(SEE->EE_DVAGE)+','
	cJson+='"digitoContaDebitada":"'+Alltrim(SEE->EE_DVCTA)+'"'
	cJson+='},'
	cJson+='"dadosSegundaLinhaExtrato":"'+SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+'",'
	cJson+='"dataMovimento":'+DTOS(DDATABASE)+','
	cJson+='"dataPagamento":'+DTOS(DDATABASE)+','
	cJson+='"dataVencimento":'+DTOS(SE2->E2_VENCTO)+','
	cJson+='"horaTransacao":'+cvaltochar(val(StrTran(Time(),":","")))+','
	cJson+='"identificacaoTituloCobranca":"'+Alltrim(SE2->E2_CODBAR)+'",'
	cJson+='"indicadorFormaCaptura":1,'
	cJson+='"valorTitulo":'+cvaltochar(SE2->E2_VALOR)+''
	cJson+='},'
	cJson+='"destinatarioDadosComum":'
	cJson+='{'
	cJson+='"cpfCnpjDestinatario":""'
	cJson+='},'
	cJson+='"identificacaoChequeCartao":0,'
	cJson+='"indicadorValidacaoGravacao":"N",'
	cJson+='"nomeCliente":"'+SUBSTR(U_RemCarEsp(Alltrim(SA2->A2_NOME)),1,40)+'",'
	If Left(SE2->E2_CODBAR,3) <> '237'
		cJson+= '"numeroControleParticipante":"'+Alltrim(ZLA->ZLA_PIXTID)+'",'
	Else
		cJson+= '"numeroControleParticipante":"0",'
	Endif

	cJson+='"portadorDadosComum":'
	cJson+='{'
//cJson+='"cpfCnpjPortador":"81632093000411"' 
	cJson+='"cpfCnpjPortador":"'+Alltrim(SEE->EE_ZZCNPJP)+'"'

	cJson+='},'
	cJson+='"remetenteDadosComum":'
	cJson+='{'
	cJson+='"cpfCnpjRemetente":"'+Alltrim(SA2->A2_CGC)+'"'
	cJson+='},'
	cJson+='"valorMinimoIdentificacao":0'
	cJson+='}'

/*

cTitulo+= '  "portadorDadosComum": {
cTitulo+= '    "cpfCnpjPortador": "'+Alltrim(SM0->M0_CGC)+'"' //'+Alltrim(SA2->A2_CGC)+'
cTitulo+= '  },
cTitulo+= '  "remetenteDadosComum": {
cTitulo+= '    "cpfCnpjRemetente": "'+Alltrim(SA2->A2_CGC)+'"'
cTitulo+= '  },

{
   "agencia":2693,
   "pagamentoComumRequest":{
      "contaDadosComum":{
         "agenciaContaDebitada":2693,
         "bancoContaDebitada":237,
         "contaDebitada":52922,
         "digitoAgenciaDebitada":0,
         "digitoContaDebitada":"2"
      },
      "dadosSegundaLinhaExtrato":"  031000047596B  ",
      "dataMovimento":20240226,
      "dataPagamento":20240226,
      "dataVencimento":20240229,
      "horaTransacao":112513,
      "identificacaoTituloCobranca":"23795964100000396677254091900001213200277560",
      "indicadorFormaCaptura":1,
      "valorTitulo":396.67
   },
   "destinatarioDadosComum":{
      "cpfCnpjDestinatario":""
   },
   "identificacaoChequeCartao":0,
   "indicadorValidacaoGravacao":"N",
   "nomeCliente":"GRAFICA REGIS LTDA",
   "numeroControleParticipante":"0",
   "portadorDadosComum":{
      "cpfCnpjPortador":"79500443000100"
   },
   "remetenteDadosComum":{
      "cpfCnpjRemetente":""
   },
   "valorMinimoIdentificacao":0
}

*/

	cUrlBase:= GetNewPar("AC_BRDURL","https://proxy.api.prebanco.com.br") //https://openapi.bradesco.com.br

//Busca o token para autentica��o
	aToken:= U_gTokenBrd(cClientId)
	If !aToken[1]
		oObjLog:saveMsg("Autentica��o inv�lida!!!")
		Return
	Else
		cToken:= aToken[2]
		cJti:= aToken[3]
		cTime:= aToken[4]
	Endif

//Salva o arquivo com o request para uso na assinatura
	cConteudo:= "POST"+LF
	cConteudo+= cUrl+LF
	cConteudo+= LF
	cConteudo+= Alltrim(cJson)+LF
	cConteudo+= cToken+LF
	cConteudo+= cJti+LF
	cConteudo+= Left(FwTimeStamp(3,date(),cTime),19)+'-00:00'+LF
	cConteudo+= "SHA256"

//Gera a assinatura
	cAssinatura:= U_gSignBrd("ValidarPagamento", SE2->E2_IDCNAB, cConteudo)

	If Empty(cAssinatura)
		//TRATAR ERRO QUANDO N�O CONSEGUE ASSINAR!
		Return
	Endif

//Autoriza��o no header
	Aadd(aHeadStr, "Content-Type: application/json")
	Aadd(aHeadStr, "Authorization: Bearer "+cToken )
	Aadd(aHeadStr, "X-Brad-Signature: "+cAssinatura)
	Aadd(aHeadStr, "X-Brad-Nonce: "+cJti)
	Aadd(aHeadStr, "X-Brad-Timestamp: "+Left(FwTimeStamp(3,date(),cTime),19)+'-00:00')
	Aadd(aHeadStr, "X-Brad-Algorithm: SHA256")
	Aadd(aHeadStr, "Access-token: "+cClientId)


//Efetua o POST na API
	cRetPost := HTTPPost(cUrlBase+cUrl, /*cGetParms*/, cJson, /*nTimeOut*/, aHeadStr, @cHeaderRet)
	cRetPost:= DecodeUTF8(cRetPost)
	nCodResp:= HTTPGetStatus(cHeaderRet)
	oObjLog:saveMsg("Envia Validacao-Pagamento")
	oObjLog:saveMsg("**URL: "+cUrlBase+cUrl)
	oObjLog:saveMsg("**Body: "+cJson)
	oObjLog:saveMsg("**Retorno: "+Iif(cRetPost = nil,"",cRetPost))
	oObjLog:saveMsg("**Cabe�alho Retorno: "+cHeaderRet)

//Transforma o retorno em um JSON
	jJsonBol := JsonObject():New()
	jJsonBol:FromJson(cRetPost)


	If nCodResp = 401
		cErro:= jJsonBol["message"]
	Else
		If jJsonBol:HasProperty("codigo") .OR. jJsonBol["pagamentoComumResponse"]:HasProperty("codigoRetorno")
			IF(jJsonBol:HasProperty("codigo"))
				IF((jJsonBol["codigo"] == "2125") .OR. (jJsonBol["codigo"] == "2135"))
					lRet := .T.
					cErro:= "TRANSACAO EFETUADA BRADESCO"
					aAdd(aRet,ZLA->ZLA_DTOPER)
					aAdd(aRet,SE2->E2_SALDO)
					lRet:= .T.
				ELSE
					cErro:= jJsonBol["codigo"]+" - "+jJsonBol["mensagem"]
				ENDIF
			ELSEIF jJsonBol["pagamentoComumResponse"]:HasProperty("codigoRetorno")
				IF jJsonBol["pagamentoComumResponse"]["codigoRetorno"] == 2143
					lRet := .F.
					cErro:= "N�O FOI PROCESSADO PAGAMENTO, REFAZER O PROCESSO"
				ELSE
					cErro:= "ERRO AO CONSULTAR BOLETO COD:"+ jJsonBol["pagamentoComumResponse"]["codigoRetorno"]
				ENDIF
			ELSE
				cErro:= "ERRO AO CONSULTAR BOLETO"
			ENDIF

		Elseif jJsonBol:HasProperty("code")
			cErro:= jJsonBol["code"]+" - "+jJsonBol["message"]
		Else
			cErro:= "Falha ao enviar a requisicao. Codigo: " +cvaltochar(nCodResp)+' - '+cHeaderRet
		Endif
	Endif


	IF(lRet)
		If Len(aRet) > 0
			IF(u_BaixaPag(aRet)	)

				aZLA := U_ZLAUPDATE(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NUMBOR, "3")
				U_ZLBHIST(SE2->E2_FILORIG, aZLA[2], '3', cErro, '1')
			
			ELSE
				FWAlertError("N�o foi possivel fazer a baixa. ", "AGRICOPEL")
			ENDIF


		ELSE			
			FWAlertError("Erro na consulta. ", "AGRICOPEL")
		Endif
	ELSE
		FWAlertError("Erro na consulta. ", "AGRICOPEL")
	ENDIF

Return lRet



