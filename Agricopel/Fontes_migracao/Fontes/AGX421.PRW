#include 'Protheus.ch'
#include 'WmsR310.ch'
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ WmsR340 ³ Autor ³ Flavio Luiz Vicco      ³Data  ³13/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relatorio de monitoramento de servicos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAWMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function AGX421()
Local oReport
Private nIndSDB1 := 0
AjustaSX1()
If !DlgV001Six(@nIndSDB1)
	Return Nil
EndIf  

If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= ReportDef()
	oReport:PrintDialog()
Else
U_XWmsR310R3()
EndIf
Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ReportDef³Autor  ³Flavio Luiz Vicco      ³Data  ³13/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de monitoramento de servicos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01: nReg = Registro posicionado do SC3 apartir Browse  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ oExpO1: Objeto do relatorio                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local cAliasNew := "SDB"
Local cTitle    := OemToAnsi(STR0004) //'Monitor de Servicos'
Local aQtdUni	:= {}
Local oReport 
Local oSection1
Local oSection2
Local oSection3
dbSelectArea(cAliasNew)
dbSetOrder(1)
#IFDEF TOP
	cAliasNew := GetNextAlias()
#ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("WMSR310",cTitle,"WMR310",{|oReport| ReportPrint(oReport,cAliasNew)},STR0004) //'Monitor de Servicos'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                   ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³ mv_par01  //  Servico   De  ?                                          ³
//³ mv_par02  //            Ate ?                                          ³
//³ mv_par03  //  Tarefa    De  ?                                          ³
//³ mv_par02  //            Ate ?                                          ³
//³ mv_par03  //  Documento De  ?                                          ³
//³ mv_par02  //            Ate ?                                          ³
//³ mv_par03  //  Carga     De  ?                                          ³
//³ mv_par02  //            Ate ?                                          ³
//³ mv_par09  //  Status        ?  Finalizado / Interrompido /             ³
//³                                Em Execucao / Nao Executado / Todos     ³
//³ mv_par10  //  Quantidade    ?  1a.UM / 2a.UM / U.M.I. / Nao Imprime    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(oReport:uParam,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:= TRSection():New(oReport,STR0028,{"SDB"},/*aOrdem*/) //"Movimentos por endereco - Documento"
oSection1:SetHeaderPage(.F.)
oSection1:SetLineStyle()
TRCell():New(oSection1,"DB_CARGA",	"SDB")
TRCell():New(oSection1,"DB_DOC",	"SDB")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2:= TRSection():New(oSection1,STR0029,{"SDB"},/*aOrdem*/) //"Movimentos por endereco - Atividades"
oSection2:SetHeaderPage()
TRCell():New(oSection2,"DATIVID",		"",STR0031,,30,,{||TABELA("L3",(cAliasNew)->DB_ATIVID,.F.)}) //"Movimento"
TRCell():New(oSection2,"DB_LOCALIZ",	"SDB")
TRCell():New(oSection2,"DB_PRODUTO",	"SDB")
TRCell():New(oSection2,"DB_LOTECTL",	"SDB")
TRCell():New(oSection2,"DB_ENDDES",		"SDB")
TRCell():New(oSection2,"DB_STATUS",		"SDB",,,12,,{||Substr(x3FieldToCbox("DB_STATUS",(cAliasNew)->DB_STATUS),4)})
TRCell():New(oSection2,"TRACO",	        "",STR0032,,23,,{||"_______________________"}) //"Traco"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection3:= TRSection():New(oSection2,STR0030,{"SDB"},/*aOrdem*/) //"Movimentos por endereco - Quantidades"
oSection3:SetLineStyle()
TRCell():New(oSection3,"DB_QUANT",		"SDB",STR0012) //"Qtde 1a.U.M. -->"
TRCell():New(oSection3,"LACUNA1",		"",   STR0033+" 1",,12,,{||"[__________]"}) //"Lacuna"
TRCell():New(oSection3,"B1_UM",			"SB1")
TRCell():New(oSection3,"DB_QTSEGUM",	"SDB")
TRCell():New(oSection3,"LACUNA2",		"",   STR0033+" 2",,12,,{||"[__________]"}) //"Lacuna"
TRCell():New(oSection3,"B1_SEGUM",		"SB1")
TRCell():New(oSection3,"NUMI", 			"",   STR0034) //"Qtd Unitiz"
TRCell():New(oSection3,"LACUNA3",		"",   STR0033+" 3",,12,,{||"[__________]"}) //"Lacuna"
TRCell():New(oSection3,"CUNIT",			"",   STR0035,,15) //"Unitizador"
Return(oReport)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Flavio Luiz Vicco     ³Data  ³20/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de monitoramento de servicos                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cAliasNew)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local oSection3 := oReport:Section(1):Section(1):Section(1)
Local lWmsACar  := (SuperGetMV('MV_WMSACAR', .F., 'S')=='S')
Local cQuebra   := ""
Local cLocaliz  := ""
#IFDEF TOP
	Local cSelect	:= ""
	Local cWhere	:= ""
	Local cOrder	:= ""
#ENDIF 
oSection2:Cell("TRACO"):HideHeader()
oSection3:Cell("LACUNA1"):HideHeader()
oSection3:Cell("B1_UM"):HideHeader()
oSection3:Cell("DB_QTSEGUM"):HideHeader()
oSection3:Cell("LACUNA2"):HideHeader()
oSection3:Cell("B1_SEGUM"):HideHeader()
oSection3:Cell("NUMI"):HideHeader()
oSection3:Cell("LACUNA3"):HideHeader()
oSection3:Cell("CUNIT"):HideHeader()
#IFDEF TOP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:GetParam())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatório da secao 1                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1:BeginQuery()	

	cSelect := "%, "+SqlOrder(SDB->(IndexKey(nIndSDB1)))+" %"

	cWhere := "%"
	If	mv_par09 <> 5
		cWhere += " DB_STATUS      = '"+AllTrim(Str(mv_par09))+"' AND "
	EndIf
	cWhere += "%"

	cOrder := "% "+SqlOrder(SDB->(IndexKey(nIndSDB1)))+" %"

	BeginSql Alias cAliasNew
	//-->
	SELECT DB_TAREFA, SX51.X5_DESCRI D_TAREFA , DB_ATIVID,
           SX52.X5_DESCRI D_ATIVIDADE, DB_LOCAL, DB_LOCALIZ, DB_ENDDES, DB_PRODUTO, DB_QUANT,
           DB_LOTECTL, DB_ESTORNO, DB_ESTFIS, B1_UM, B1_SEGUM
           %Exp:cSelect%
	FROM %table:SDB% SDB
	JOIN %table:SX5% SX51 ON SX51.X5_FILIAL = %xFilial:SX5% AND SX51.X5_TABELA = 'L2' AND SX51.X5_CHAVE = SDB.DB_TAREFA AND SX51.%NotDel%
	JOIN %table:SX5% SX52 ON SX52.X5_FILIAL = %xFilial:SX5% AND SX52.X5_TABELA = 'L3' AND SX52.X5_CHAVE = SDB.DB_ATIVID AND SX52.%NotDel%
	JOIN %table:SB1% SB1  ON SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.B1_COD = SDB.DB_PRODUTO AND SB1.%NotDel%
	WHERE
	DB_FILIAL         = %xFilial:SDB% AND
	DB_ESTORNO       <> 'S' AND
	DB_ATUEST         = 'N' AND
	DB_SERVIC BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
	DB_TAREFA BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND
	DB_DOC    BETWEEN %Exp:mv_par05% AND %Exp:mv_par06% AND
	DB_CARGA  BETWEEN %Exp:mv_par07% AND %Exp:mv_par08% AND
	%Exp:cWhere%
	SDB.%NotDel%
	ORDER BY %Exp:cOrder%
	//-->
	EndSql 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo EndQuery ( Classe TRSection )                                    ³
	//³                                                                        ³
	//³Prepara o relatório para executar o Embedded SQL.                       ³
	//³                                                                        ³
	//³ExpA1 : Array com os parametros do tipo Range                           ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1:EndQuery(/*Array com os parametros do tipo Range*/)
#ELSE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao Advpl                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeAdvplExpr(oReport:uParam)
	dbSelectArea('SDB')
	cQuery := " DB_FILIAL    == '"+xFilial("SDB")+"' .And. "	
	cQuery += " DB_ESTORNO   <> 'S' .And. "
	cQuery += " DB_ATUEST    == 'N' .And. "
	cQuery += " DB_SERVIC    >= '"+mv_par01+"' .And. "
	cQuery += " DB_SERVIC    <= '"+mv_par02+"' .And. "
	cQuery += " DB_TAREFA    >= '"+mv_par03+"' .And. "
	cQuery += " DB_TAREFA    <= '"+mv_par04+"' .And. "
	cQuery += " DB_DOC       >= '"+mv_par05+"' .And. "
	cQuery += " DB_DOC       <= '"+mv_par06+"' .And. "
	cQuery += " DB_CARGA     >= '"+mv_par07+"' .And. "
	cQuery += " DB_CARGA     <= '"+mv_par08+"'"
	If	mv_par09 <> 5
		cQuery += " .And. DB_STATUS == '"+AllTrim(Str(mv_par09))+"'"
	EndIf
	oSection1:SetFilter(cQuery,(cAliasNew)->(IndexKey(nIndSDB1)))
#ENDIF
SB1->(dbSetOrder(1))
SB1->(MsSeek(xFilial("SB1")+(cAliasNew)->DB_PRODUTO))
If	mv_par10 == 1
	oSection3:Cell("DB_QTSEGUM"):Disable()
	oSection3:Cell("LACUNA1"):Disable()
	oSection3:Cell("B1_SEGUM"):Disable()
	oSection3:Cell("LACUNA2"):Disable()
	oSection3:Cell("NUMI"):Disable()
	oSection3:Cell("LACUNA3"):Disable()
	oSection3:Cell("CUNIT"):Disable()
ElseIf mv_par10 == 2
	oSection3:Cell("DB_QTSEGUM"):SetTitle(STR0013) //'Qtde 2a.U.M. -->'
	oSection3:Cell("DB_QUANT"):Disable()
	oSection3:Cell("LACUNA1"):Disable()
	oSection3:Cell("B1_UM"):Disable()
	oSection3:Cell("LACUNA2"):Disable()
	oSection3:Cell("NUMI"):Disable()
	oSection3:Cell("LACUNA3"):Disable()
	oSection3:Cell("CUNIT"):Disable()
ElseIf mv_par10 == 3
	oSection3:Cell("DB_QUANT"):SetTitle(STR0014) //'Qtde U.M.I. -->'
	oSection3:Cell("LACUNA1"):Disable()
	oSection3:Cell("LACUNA2"):Disable()
	oSection3:Cell("LACUNA3"):Disable()
ElseIf mv_par10 == 4
	oSection3:Cell("DB_QUANT"):SetTitle(STR0015) //'Qtde -->'
	oSection3:Cell("DB_QUANT"):Disable()
	oSection3:Cell("DB_QTSEGUM"):Disable()
	oSection3:Cell("NUMI"):Disable()
EndIf
oSection1:SetParentQuery()
oSection2:SetParentQuery()
oSection3:SetParentQuery()
oReport:SetTitle(STR0009+Upper(Tabela('L2',(cAliasNew)->DB_TAREFA,.F.))) //'SERVICO DE '
oReport:SetMeter(SDB->(LastRec()))
dbSelectArea(cAliasNew)
oSection1:Init()
oSection2:Init()
oSection3:Init()
While !oReport:Cancel() .And. !(cAliasNew)->(Eof())
	oReport:IncMeter()
	If oReport:Cancel()
		Exit
	EndIf
	oSection1:Cell("DB_CARGA"):Enable()
	oSection1:Cell("DB_DOC"):Enable()
	lCarga := !Empty((cAliasNew)->DB_CARGA)
	If	lCarga
		If	lWmsACar
			oSection1:Cell("DB_DOC"):Disable()
		EndIf
	Else
		oSection1:Cell("DB_CARGA"):Disable()
	EndIf
	If	cQuebra <> Iif(lCarga,(cAliasNew)->DB_CARGA,(cAliasNew)->DB_DOC)+If(lWmsACar,'',(cAliasNew)->DB_DOC)+(cAliasNew)->DB_TAREFA
		cQuebra := Iif(lCarga,(cAliasNew)->DB_CARGA,(cAliasNew)->DB_DOC)+If(lWmsACar,'',(cAliasNew)->DB_DOC)+(cAliasNew)->DB_TAREFA
		oReport:SetTitle(STR0009+Upper(Tabela('L2',(cAliasNew)->DB_TAREFA,.F.))) //'SERVICO DE '
		oReport:EndPage()
		oSection1:PrintLine()
	EndIf
	If	cLocaliz <> (cAliasNew)->DB_LOCALIZ
		cLocaliz := (cAliasNew)->DB_LOCALIZ
		oReport:SkipLine()
	EndIf
	If	mv_par10 == 3
		aQtdUni:=WmsQtdUni((cAliasNew)->DB_PRODUTO,(cAliasNew)->DB_LOCAL,(cAliasNew)->DB_ESTFIS,(cAliasNew)->DB_QUANT)
		oSection3:Cell("DB_QTSEGUM"):SetValue(aQtdUni[3,1])
		oSection3:Cell("DB_QUANT"):SetValue(aQtdUni[2,1])
		oSection3:Cell("NUMI"):SetValue(aQtdUni[1,1])
		oSection3:Cell("CUNIT"):SetValue(aQtdUni[1,2])
	ElseIf mv_par10 == 4
		aQtdUni:=WmsQtdUni((cAliasNew)->DB_PRODUTO,(cAliasNew)->DB_LOCAL,(cAliasNew)->DB_ESTFIS,(cAliasNew)->DB_QUANT)
		oSection3:Cell("CUNIT"):SetValue(aQtdUni[1,2])
	EndIf
	oSection2:PrintLine()
	oSection3:PrintLine()
	(cAliasNew)->(dbSkip())
EndDo
oSection1:Finish()

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³WmsR310R3³ Autor ³ Alex Egydio            ³ Data ³27.12.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relatorio de monitoramento de servicos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function XWmsR310R3()
Local wnRel		:= 'WMSR310' //-- Nome do Arquivo utilizado no Spool
Local cDesc1	:= STR0025   //'Este relatório pode ser utilizado quando o cliente não possui radio freqüência '
Local cDesc2	:= STR0026   //'ou por algum motivo a radio freqüência estiver desabilitada.'
Local cDesc3	:= STR0027   //'O layout é como se o usuário estivesse utilizando radio freqüência.'
Local cPerg		:= 'WMR310'
Local Tamanho	:= 'M'       //-- P M G
Local Titulo	:= STR0004 //'Monitor de Servicos'
Local lEnd		:= .F.

Private aReturn:= {STR0005,1,STR0006,1,2,1,'',1} //'Zebrado'###'Administracao'
//-- Variaveis utilizadas como parametro
//--
//-- mv_par01  //  Servico   De  ?
//-- mv_par02  //            Ate ?
//-- mv_par03  //  Tarefa    De  ?
//-- mv_par02  //            Ate ?
//-- mv_par03  //  Documento De  ?
//-- mv_par02  //            Ate ?
//-- mv_par03  //  Carga     De  ?
//-- mv_par02  //            Ate ?
//-- mv_par09  //  Status        ?  Finalizado / Interrompido / Em Execucao / Nao Executado / Todos
//-- mv_par10  //  Quantidade    ?  1a.UM / 2a.UM / U.M.I. / Nao Imprime

Pergunte(cPerg,.F.)

wnRel:=SetPrint('SDB',wnRel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho,.T.)

If ( nLastKey==27 )
	DbSelectArea('SDB')
	DbSetOrder(1)
	dbClearFilter()
	Return NIL
EndIf

SetDefault(aReturn,'SDB')

If ( nLastKey==27 )
	DbSelectArea('SDB')
	DbSetOrder(1)
	dbClearFilter()
	Return NIL
EndIf

RptStatus({|lEnd| WmsR310Imp(@lEnd,wnRel,Tamanho)},Titulo)

dbClearFilter()

Return NIL
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³WmsR310Imp³ Autor ³ Alex Egydio           ³ Data ³27.12.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relatorio de monitoramento de servicos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - .F. = Interrompe a impressao                       ³±±
±±³          ³ ExpC1 - Nome do arquivo utilizado no spool de impressao    ³±±
±±³          ³ ExpC2 - Tamanho do relatorio                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function WmsR310Imp(lEnd,wnRel,Tamanho)
Local lWmsACar  := (SuperGetMV('MV_WMSACAR', .F., 'S')=='S')
Local aSx3Box   := RetSx3Box(Posicione('SX3',2,'DB_STATUS','X3CBox()'),,,1)
Local aQtdUni   := {}
Local cAliasNew := 'SDB'
//                           0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//                           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Local cCabec1	:= STR0007 //' Movimento                   Origem           Produto          Lote        Destino          Status'
//                            xxxxxxxxxx-26-xxxxxxxxxxxx  xxxxx-15-xxxxxx  xxxxx-15-xxxxxx  xxx-10-xxx  xxxxx-15-xxxxxx  xxxx-13-xxxxx  _______________________
//                                             999.999.999,99 UN        999.999.999,99 CX        999.999.999,99 PALLET BRIIXXXXXXXXXXXXXXXXXXX
Local cCabec2	:= ''
Local cQuebra	:= ''
Local cQuery	:= ''
Local cLocaliz	:= ''
Local cIndSDB	:= ''
Local cDscTar	:= ''
Local cDscAtv	:= ''
Local cCodPro	:= ''
Local cUM		:= ''
Local cSegUM	:= ''
Local cFiltro	:= ""
Local Limite	:= 132
Local lCarga	:= .F.
Local nSeek		:= 0
Local nIndex	:= 0
Local nQuant	:= 0
Private li		:= 80
Private m_pag	:= 01

#IFDEF TOP
	cAliasNew:= GetNextAlias()
	cQuery := " SELECT DB_TAREFA, DB_ATIVID, "
	If __Language == "ENGLISH"
		cQuery += " SX51.X5_DESCENG D_TAREFA, SX52.X5_DESCENG D_ATIVIDADE, "
	ElseIf __Language == "SPANISH"
		cQuery += " SX51.X5_DESCSPA D_TAREFA, SX52.X5_DESCSPA D_ATIVIDADE, "
	Else
		cQuery += " SX51.X5_DESCRI  D_TAREFA, SX52.X5_DESCRI  D_ATIVIDADE, "
	EndIf
	cQuery += " DB_LOCAL, DB_LOCALIZ, DB_ENDDES, DB_PRODUTO, DB_QUANT, "
	cQuery += " DB_LOTECTL, DB_ESTORNO, DB_ESTFIS, B1_UM, B1_SEGUM, "
	cQuery += SqlOrder(SDB->(IndexKey(nIndSDB1)))+" "
	If !Empty(aReturn[7])
		cFiltro := A285QryFil("SDB",cQuery,aReturn[7])
		If !Empty(cFiltro)
			cQuery += ","+cFiltro+"SDB.R_E_C_N_O_ SDBREC"
		Endif
	Endif
	cQuery += " FROM"
	cQuery += " "+RetSqlName('SDB')+" SDB"
	cQuery += " JOIN "+RetSqlName('SX5')+" SX51 ON SX51.X5_FILIAL = '"+xFilial("SX5")+"' AND SX51.X5_TABELA = 'L2' AND SX51.X5_CHAVE = SDB.DB_TAREFA AND SX51.D_E_L_E_T_ = ' '"
	cQuery += " JOIN "+RetSqlName('SX5')+" SX52 ON SX52.X5_FILIAL = '"+xFilial("SX5")+"' AND SX52.X5_TABELA = 'L3' AND SX52.X5_CHAVE = SDB.DB_ATIVID AND SX52.D_E_L_E_T_ = ' '"
	cQuery += " JOIN "+RetSqlName('SB1')+" SB1  ON SB1.B1_FILIAL  = '"+xFilial("SB1")+"' AND SB1.B1_COD = SDB.DB_PRODUTO AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE"
	cQuery += " DB_FILIAL             = '"+xFilial("SDB")+"'"
	cQuery += " AND DB_ESTORNO       <> 'S'"
	cQuery += " AND DB_ATUEST         = 'N'"
	cQuery += " AND DB_SERVIC BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
	cQuery += " AND DB_TAREFA BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
	cQuery += " AND DB_DOC    BETWEEN '"+mv_par05+"' AND '"+mv_par06+"'"
	cQuery += " AND DB_CARGA  BETWEEN '"+mv_par07+"' AND '"+mv_par08+"'"
	If	mv_par09 <> 5
		cQuery += " AND DB_STATUS      = '"+AllTrim(Str(mv_par09))+"'"
	EndIf
	cQuery += " AND SDB.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY "+SqlOrder(SDB->(IndexKey(nIndSDB1)))
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
	TCSetField(cAliasNew,'DB_QUANT','N',TamSx3('DB_QUANT')[1],TamSx3('DB_QUANT')[2])
#ELSE
	DbSelectArea('SDB')
	cIndSDB := CriaTrab(NIL,.F.)
	cQuery := " DB_FILIAL    == '"+xFilial("SDB")+"' .And. "
	cQuery += " DB_ESTORNO   <> 'S' .And. "
	cQuery += " DB_ATUEST    == 'N' .And. "
	cQuery += " DB_SERVIC    >= '"+mv_par01+"' .And. "
	cQuery += " DB_SERVIC    <= '"+mv_par02+"' .And. "
	cQuery += " DB_TAREFA    >= '"+mv_par03+"' .And. "
	cQuery += " DB_TAREFA    <= '"+mv_par04+"' .And. "
	cQuery += " DB_DOC       >= '"+mv_par05+"' .And. "
	cQuery += " DB_DOC       <= '"+mv_par06+"' .And. "
	cQuery += " DB_CARGA     >= '"+mv_par07+"' .And. "
	cQuery += " DB_CARGA     <= '"+mv_par08+"'"
	If	mv_par09 <> 5
		cQuery += " .And. DB_STATUS == '"+AllTrim(Str(mv_par09))+"'"
	EndIf
	IndRegua(cAliasNew,cIndSDB,(cAliasNew)->(IndexKey(nIndSDB1)),,cQuery+If(!Empty(aReturn[7]),'.And.'+aReturn[7],''),STR0008) //'Selecionando enderecos...'
	nIndex := RetIndex()
	DbSetIndex(cIndSDB+OrdBagExt())
	DbSetOrder(nIndex+1)
	DbGotop()
#ENDIF

While (cAliasNew)->(!Eof())

	If lEnd
		@ Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
		Exit
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacao do filtro do usuario no SDB.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aReturn[7]) .And. !&(aReturn[7]) //Filtro do Usuario
		(cAliasNew)->(dbSkip())
		Loop
	Endif

	lCarga	:= !Empty((cAliasNew)->DB_CARGA)
	cCodPro	:= (cAliasNew)->DB_PRODUTO
	nQuant	:= (cAliasNew)->DB_QUANT
	cServic := (cAliasNew)->DB_SERVIC
	
	dbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(MsSeek(xFilial('SB1')+cCodPro))
	cDescPro := SB1->B1_DESC
	

	#IFDEF TOP
		cDscTar	:= AllTrim((cAliasNew)->D_TAREFA)
		cDscAtv	:= (cAliasNew)->D_ATIVIDADE
		cUM		:= (cAliasNew)->B1_UM
		cSegUM	:= (cAliasNew)->B1_SEGUM                      

	#ELSE
		SB1->(DbSetOrder(1))
		SB1->(MsSeek(xFilial('SB1')+cCodPro))
		cDscTar	:= Upper(Tabela('L2',(cAliasNew)->DB_TAREFA,.F.))
		cDscAtv	:= Tabela('L3',(cAliasNew)->DB_ATIVID,.F.)
		cUM		:= SB1->B1_UM
		cSegUM	:= SB1->B1_SEGUM
	#ENDIF

	If	li > 55 .Or. cQuebra != Iif(lCarga,(cAliasNew)->DB_CARGA,(cAliasNew)->DB_DOC)+If(lWmsACar,'',(cAliasNew)->DB_DOC)+(cAliasNew)->DB_TAREFA
		cLocaliz := ''
		Cabec(STR0009+Upper(cDscTar),cCabec1,cCabec2,wnRel,Tamanho) //'SERVICO DE '
		cQuebra := Iif(lCarga,(cAliasNew)->DB_CARGA,(cAliasNew)->DB_DOC)+If(lWmsACar,'',(cAliasNew)->DB_DOC)+(cAliasNew)->DB_TAREFA
		If	lCarga
			@ li, 01 PSay PadC(STR0010+(cAliasNew)->DB_CARGA,Limite) //'Carga: '
			If !lWmsACar
				@ li, 20 PSay PadC(STR0011+(cAliasNew)->DB_DOC,Limite) //'Documento: '
			EndIf
		Else
			@ li, 01 PSay PadC(STR0011+(cAliasNew)->DB_DOC,Limite) //'Documento: '
		EndIf
	EndIf
	If	cLocaliz != (cAliasNew)->DB_LOCALIZ
		li += 1
		cLocaliz := (cAliasNew)->DB_LOCALIZ
	EndIf
	li+=1                  
    	
/*	Do Case 
	   Case cServic == "003"
	      @ li,001 PSay Alltrim((cAliasNew)->DB_LOCALIZ)
	      @ li,025 PSay Alltrim(cCodPro)  
          @ li,038 PSay Alltrim(cDescPro) 
          @ li,063 PSay (cAliasNew)->DB_LOTECTL
	      @ li,075 PSay Alltrim((cAliasNew)->DB_ENDDES) 
          
//	
	      
	   Case cServic == "016"  
	      @ li,001 PSay Alltrim((cAliasNew)->DB_LOCALIZ)
	      @ li,025 PSay Alltrim(cCodPro)  
          @ li,038 PSay Alltrim(cDescPro)               
          @ li,063 PSay (cAliasNew)->DB_LOTECTL
	      @ li,075 PSay Alltrim((cAliasNew)->DB_ENDDES) 
    OtherWise
   	      @ li,001 PSay Left(cDscAtv,26)
    	  @ li,029 PSay Alltrim((cAliasNew)->DB_LOCALIZ)
	      @ li,046 PSay Alltrim(cCodPro)
//	      @ li,056 PSay Alltrim(cDescPro)
	EndCase*/
	
	   
	   
	
	
    	* Adicionar o campo descrição do produto
* Remover campo quantidade 
* Adicionar lacuna para quantidade
* Adicionar lacuna para a data de validade(____/_____/________)
* Adicionar lacuna para informar o conferente  (_____________________)
    	
	Do Case 
	   Case cServic == "003"
	      @ li,001 PSay Alltrim((cAliasNew)->DB_LOCALIZ)
	      @ li,020 PSay Alltrim(cCodPro)  
          @ li,030 PSay Alltrim(cDescPro)           
	  	  @ li,070 PSay (cAliasNew)->DB_LOTECTL
          @ li,090 PSay Alltrim((cAliasNew)->DB_ENDDES)   

       Case cServic == "015"
  	      @ li,001 PSay Alltrim((cAliasNew)->DB_LOCALIZ)
	      @ li,017 PSay Alltrim(cCodPro)  
          @ li,029 PSay Alltrim(cDescPro)         
          @ li,075 PSay "_____________"    
          @ li,090 PSay "____/____/________"      
          
            
	  	//  @ li,063 PSay (cAliasNew)->DB_LOTECTL
        //  @ li,075 PSay Alltrim((cAliasNew)->DB_ENDDES)
		      
//	
	      
	   Case cServic == "016"  
	      @ li,001 PSay Alltrim((cAliasNew)->DB_LOCALIZ)
	      @ li,012 PSay Alltrim(cCodPro)  
          @ li,020 PSay Alltrim(cDescPro) 
          @ li,063 PSay (cAliasNew)->DB_LOTECTL
		  @ li,075 PSay Alltrim((cAliasNew)->DB_ENDDES)
          
    OtherWise
   	      @ li,001 PSay Left(cDscAtv,26)
    	  @ li,029 PSay Alltrim((cAliasNew)->DB_LOCALIZ)
	      @ li,046 PSay Alltrim(cCodPro)
//	      @ li,056 PSay Alltrim(cDescPro)
	EndCase
	
	   
	   
	
	
//	@ li,063 PSay (cAliasNew)->DB_LOTECTL
//	@ li,075 PSay Alltrim((cAliasNew)->DB_ENDDES)
if cServic <> "015"
//	If	( nSeek := Ascan( aSx3Box, { |x| x[ 2 ] == (cAliasNew)->DB_STATUS } ) ) > 0
//		@ li,92 PSay AllTrim( aSx3Box[ nSeek, 3 ] )
//	EndIf
	@ li,107 PSay '_______________________'

	li+=1
	If	mv_par10 == 1
		@ li,001 PSay STR0012 //'Qtde 1a.U.M. -->'
		@ li,018 PSay nQuant Picture PesqPictQt('DB_QUANT')
		@ li,033 PSay cUM
	ElseIf mv_par10 == 2
		@ li,001 PSay STR0013 //'Qtde 2a.U.M. -->'
		@ li,043 PSay ConvUm(cCodPro,nQuant,0,2) Picture PesqPictQt('DB_QUANT')
		@ li,058 PSay cSegUM
	ElseIf mv_par10 == 3
		aQtdUni:=WmsQtdUni(cCodPro,(cAliasNew)->DB_LOCAL,(cAliasNew)->DB_ESTFIS,nQuant)
		@ li,001 PSay STR0014 //'Qtde U.M.I. -->'
		@ li,018 PSay aQtdUni[3,1] Picture PesqPictQt('DB_QUANT')
		@ li,033 Psay aQtdUni[3,2]
		@ li,043 PSay aQtdUni[2,1] Picture PesqPictQt('DB_QUANT')
		@ li,058 PSay aQtdUni[2,2]
		@ li,068 PSay aQtdUni[1,1] Picture PesqPictQt('DB_QUANT')
		@ li,083 Psay aQtdUni[1,2]
	Else
		aQtdUni:=WmsQtdUni(cCodPro,(cAliasNew)->DB_LOCAL,(cAliasNew)->DB_ESTFIS,nQuant)
		@ li,001 PSay STR0015 //'Qtde -->'
		@ li,010 PSay '[__________]'
		@ li,025 PSay aQtdUni[3,2]
		@ li,048 PSay '[__________]'
		@ li,063 PSay aQtdUni[2,2]
		@ li,086 PSay '[__________]'
		@ li,101 PSay aQtdUni[1,2]
	EndIf       
   EndIf  
	(cAliasNew)->(dbSkip())
EndDo     
     
Do Case
   Case cServic == "015"
   
	   li++
	   li++
	   li++  
	   li++
	   li++
	   li++
       @ li,001 PSay "Conferente:________________________________________________"
EndCase
#IFDEF TOP
	DbSelectarea(cAliasNew)
	DbCloseArea()
#ELSE
	If	File(cIndSDB+OrdBagExt())
		Ferase(cIndSDB+OrdBagExt())
	EndIf
#ENDIF

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnRel)
Endif

MS_FLUSH()

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjustaSX1 ³ Autor ³ Flavio Luiz Vicco     ³ Data ³13/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria as perguntas necessarias para o programa               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1()
Local cPerg      := 'WMR310'
Local nTam       := TamSx3("DB_DOC")[1]
Local nTamSX1    := Len(SX1->X1_GRUPO)
Local aHelpPor01 := {'Serviço inicial para seleção dos','movimentos de WMS.'}
Local aHelpEsp01 := {'Servicio initial para selección','de los movimientos de WMS.'}
Local aHelpEng01 := {'Initial service to select the','WMS movements.'}
Local aHelpPor02 := {'Serviço final para seleção dos','movimentos de WMS.'}
Local aHelpEsp02 := {'Servicio final para selección','de los movimientos de WMS.'}
Local aHelpEng02 := {'Final service to select the','WMS movements.'}
Local aHelpPor03 := {'Tarefa inicial para seleção dos','movimentos de WMS.'}
Local aHelpEsp03 := {'Tarea inicial para selección','de los movimientos de WMS.'}
Local aHelpEng03 := {'Initial task to select the','WMS movements.'}
Local aHelpPor04 := {'Tarefa final para seleção dos','movimentos de WMS.'}
Local aHelpEsp04 := {'Tarea final para selección','de los movimientos de WMS.'}
Local aHelpEng04 := {'Final task to select the','WMS movements.'}
Local aHelpPor05 := {'Documento inicial para seleção dos','movimentos de WMS.'}
Local aHelpEsp05 := {'Documento inicial para selección','de los movimientos de WMS.'}
Local aHelpEng05 := {'Initial document to select the','WMS movements.'}
Local aHelpPor06 := {'Documento final para seleção dos','movimentos de WMS.'}
Local aHelpEsp06 := {'Documento final para selección','de los movimientos de WMS.'}
Local aHelpEng06 := {'Final document to select the','WMS movements.'}
Local aHelpPor07 := {'Carga inicial para seleção dos','movimentos de WMS'}
Local aHelpEsp07 := {'Carga inicial para selección','de los movimientos de WMS.'}
Local aHelpEng07 := {'Initial cargo to select the','WMS movements.'}
Local aHelpPor08 := {'Carga final para seleção dos','movimentos de WMS.'}
Local aHelpEsp08 := {'Carga final para selección','de los movimientos de WMS.'}
Local aHelpEng08 := {'Final cargo to select the','WMS movements.'}
Local aHelpPor09 := {'Informe o status do movimento desejado'}
Local aHelpEsp09 := {'Informe el estatus del movimiento','deseado.'}
Local aHelpEng09 := {'Enter the required movement status.'}
Local aHelpPor10 := {'Especifica se as Quantidades deverao ser','impressas na 1aUM, 2aUM, na U.M.I ou se','nao devera ser impressa'}
Local aHelpEsp10 := {'Especifica si las cantidades deben','imprimirse en la 1aUM, 2aUM,','en la U.M.I., o si no debe imprimirse.'}
Local aHelpEng10 := {'Specify if quantities must be','printed on the 1st. M.U., 2nd. M.U.,','in the I.M.U.,otherwise not.'}
//-- Verifica se a pergunta 01 esta atualizada - Se nao estiver, apaga todas as perguntas...
If	SX1->(MsSeek(PADR(cPerg,nTamSX1)+'01', .F.) .And. "SERVICO" $ Upper(X1_PERSPA))
	Do While !SX1->(Eof()) .And. PADR(cPerg,nTamSX1) == SX1->X1_GRUPO
		Reclock('SX1', .F.)
		dbDelete()
		MsUnlock()
		SX1->(dbSkip())
	EndDo
EndIf
PutSx1(cPerg,'01','Servico   De  ?','¿De Servicio?                 ', 'From Service ?                ', 'mv_ch1','C', 3,    0, 0,'G','',''   ,'','','mv_par01','','','','','','','','','','','','','','','','',aHelpPor01,aHelpEng01,aHelpEsp01)
PutSx1(cPerg,'02','Servico   Ate ?','¿A Servicio ?                 ', 'To Service ?                  ', 'mv_ch2','C', 3,    0, 0,'G','',''   ,'','','mv_par02','','','','','','','','','','','','','','','','',aHelpPor02,aHelpEng02,aHelpEsp02)
PutSx1(cPerg,'03','Tarefa    De  ?','¿De Tarea ?                   ', 'From Task ?                   ', 'mv_ch3','C', 3,    0, 0,'G','',''   ,'','','mv_par03','','','','','','','','','','','','','','','','',aHelpPor03,aHelpEng03,aHelpEsp03)
PutSx1(cPerg,'04','Tarefa    Ate ?','¿A Tarea ?                    ', 'To Task ?                     ', 'mv_ch4','C', 3,    0, 0,'G','',''   ,'','','mv_par04','','','','','','','','','','','','','','','','',aHelpPor04,aHelpEng04,aHelpEsp04)
PutSx1(cPerg,'05','Documento De  ?','¿De Documento ?               ', 'From Document ?               ', 'mv_ch5','C', nTam, 0, 0,'G','',''   ,'','','mv_par05','','','','','','','','','','','','','','','','',aHelpPor05,aHelpEng05,aHelpEsp05)
PutSx1(cPerg,'06','Documento Ate ?','¿A Documento ?                ', 'To Document ?                 ', 'mv_ch6','C', nTam, 0, 0,'G','',''   ,'','','mv_par06','','','','','','','','','','','','','','','','',aHelpPor06,aHelpEng06,aHelpEsp06)
PutSx1(cPerg,'07','Carga     De  ?','¿De Carga ?                   ', 'From Load ?                   ', 'mv_ch7','C', 6,    0, 0,'G','',''   ,'','','mv_par07','','','','','','','','','','','','','','','','',aHelpPor07,aHelpEng07,aHelpEsp07)
PutSx1(cPerg,'08','Carga     Ate ?','¿A Carga ?                    ', 'To Load ?                     ', 'mv_ch8','C', 6,    0, 0,'G','',''   ,'','','mv_par08','','','','','','','','','','','','','','','','',aHelpPor08,aHelpEng08,aHelpEsp08)
PutSx1(cPerg,'09','Status        ?','¿Estatus ?                    ', 'Status ?                      ', 'mv_ch9','N', 1,    0, 0,'C','',''   ,'','','mv_par09','Executada','Ejecutada','Executed','','Com Problemas','Con Problemas','With Problems','Interrompida','Interrumpida','Interrupted','A Executar' ,'Por Ejecutar' ,'To Executer','Todos','Todos','All',aHelpPor09,aHelpEng09,aHelpEsp09)
PutSx1(cPerg,'10','Quantidade    ?','¿Cantidad ?                   ', 'Quantity ?                    ', 'mv_cha','N', 1,    0, 1,'C','',''   ,'','','mv_par10','1a.UM'    ,'1a.UM'    ,'1st MU'  ,'','2a.UM'        ,'2a.U.M.'      ,'2a.U.M'       ,'U.M.I.'      ,'U.M.I.'      ,'U.M.I.'     ,'Nao Imprime','No Imprime'   ,'Dont Print' ,''     ,''     ,''   ,aHelpPor10,aHelpEng10,aHelpEsp10)
Return NIL
